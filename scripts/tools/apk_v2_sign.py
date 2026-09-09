#!/usr/bin/env python3
"""Manually applies APK Signature Scheme v2 to an unsigned, aligned APK,
bypassing the local apksigner tool (which cannot parse this project's
large Zip64 central directory - confirmed by hand: the archive itself is
structurally valid, apksigner's Zip64 parser is what's broken).

Implements https://source.android.com/docs/security/features/apksigning/v2
directly: builds the APK Signing Block (ID 0x7109871a v2 pair), computes
the three-section chunked SHA-256 content digest, signs the signed-data
structure with the release RSA key via `openssl dgst`, and splices the
signing block in between the ZIP contents and the (untouched) central
directory, patching only the central-directory-offset fields in the
Zip64 EOCD / Zip64 locator / legacy EOCD to account for the insertion.
"""
import hashlib
import struct
import subprocess
import sys

CHUNK_SIZE = 1024 * 1024
SIG_ALGO_ID = 0x0103  # RSASSA-PKCS1-v1_5 with SHA2-256, content digested with SHA2-256


def u32(n):
    return struct.pack("<I", n)


def u64(n):
    return struct.pack("<Q", n)


def lp(b: bytes) -> bytes:
    return u32(len(b)) + b


def chunk_digest_sha256(data: bytes) -> bytes:
    chunks = [data[i:i + CHUNK_SIZE] for i in range(0, len(data), CHUNK_SIZE)] if data else []
    per_chunk = []
    for c in chunks:
        h = hashlib.sha256()
        h.update(b"\xa5")
        h.update(struct.pack("<I", len(c)))
        h.update(c)
        per_chunk.append(h.digest())
    top = hashlib.sha256()
    top.update(b"\x5a")
    top.update(struct.pack("<I", len(chunks)))
    for d in per_chunk:
        top.update(d)
    return top.digest()


def parse_zip_tail(data: bytes) -> dict:
    EOCD_SIG = b"PK\x05\x06"
    eocd_idx = data.rfind(EOCD_SIG)
    if eocd_idx < 0:
        raise ValueError("EOCD not found")
    loc_idx = eocd_idx - 20
    if data[loc_idx:loc_idx + 4] != b"PK\x06\x07":
        raise ValueError("Zip64 locator not found - this signer only handles Zip64 archives")
    (_, _, z64_eocd_offset, _) = struct.unpack("<IIQI", data[loc_idx:loc_idx + 20])
    if data[z64_eocd_offset:z64_eocd_offset + 4] != b"PK\x06\x06":
        raise ValueError("Zip64 EOCD record not found at expected offset")
    z64 = data[z64_eocd_offset:z64_eocd_offset + 56]
    (_, rec_size, ver_made, ver_need, disk_no, cd_disk, disk_entries,
     total_entries, cd_size, cd_offset) = struct.unpack("<IQHHIIQQQQ", z64)
    return {
        "eocd_idx": eocd_idx,
        "loc_idx": loc_idx,
        "z64_eocd_offset": z64_eocd_offset,
        "cd_offset": cd_offset,
        "cd_size": cd_size,
        "total_entries": total_entries,
    }


def patch_offset_fields(tail: dict, data: bytes, shift: int) -> bytes:
    """Returns the bytes from z64_eocd_offset to EOF, with every
    "offset of start of central directory" / "offset of zip64 eocd record"
    field increased by `shift` (the inserted signing block's length)."""
    buf = bytearray(data[tail["z64_eocd_offset"]:])
    # Zip64 EOCD record: cd_offset is the last 8 bytes of a 56-byte record starting at buf[0]
    old_cd_offset = struct.unpack_from("<Q", buf, 48)[0]
    assert old_cd_offset == tail["cd_offset"]
    struct.pack_into("<Q", buf, 48, old_cd_offset + shift)

    # Zip64 locator follows immediately (20 bytes): sig(4) disk_start(4) z64_eocd_offset(8) total_disks(4)
    loc_off_in_buf = 56
    assert buf[loc_off_in_buf:loc_off_in_buf + 4] == b"PK\x06\x07"
    old_z64_off = struct.unpack_from("<Q", buf, loc_off_in_buf + 8)[0]
    assert old_z64_off == tail["z64_eocd_offset"]
    struct.pack_into("<Q", buf, loc_off_in_buf + 8, old_z64_off + shift)

    # Legacy EOCD follows (22 bytes + comment): sig cd_offset is bytes [16:20] (uint32)
    eocd_off_in_buf = loc_off_in_buf + 20
    assert buf[eocd_off_in_buf:eocd_off_in_buf + 4] == b"PK\x05\x06"
    old_legacy_cd_offset = struct.unpack_from("<I", buf, eocd_off_in_buf + 16)[0]
    assert old_legacy_cd_offset == tail["cd_offset"] & 0xFFFFFFFF
    new_legacy = old_legacy_cd_offset + shift
    assert new_legacy < 0xFFFFFFFF, "legacy cd offset would overflow 32 bits"
    struct.pack_into("<I", buf, eocd_off_in_buf + 16, new_legacy)

    return bytes(buf)


def build_v2_block(content_digest: bytes, cert_der: bytes, pubkey_spki_der: bytes, key_pem_path: str) -> bytes:
    one_digest_entry = u32(SIG_ALGO_ID) + lp(content_digest)
    digests_seq = lp(lp(one_digest_entry))

    certs_seq = lp(lp(cert_der))

    attrs_seq = lp(b"")

    signed_data = digests_seq + certs_seq + attrs_seq

    proc = subprocess.run(
        ["openssl", "dgst", "-sha256", "-sign", key_pem_path],
        input=signed_data, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True,
    )
    signature = proc.stdout
    assert len(signature) == 256, f"unexpected RSA signature length {len(signature)}"

    one_sig_entry = u32(SIG_ALGO_ID) + lp(signature)
    signatures_seq = lp(lp(one_sig_entry))

    signer_bytes = lp(signed_data) + signatures_seq + lp(pubkey_spki_der)
    signers_seq = lp(lp(signer_bytes))

    v2_pair_content = u32(0x7109871A) + signers_seq
    pairs_bytes = u64(len(v2_pair_content)) + v2_pair_content

    size_value = len(pairs_bytes) + 8 + 16
    block = u64(size_value) + pairs_bytes + u64(size_value) + b"APK Sig Block 42"
    return block


def sign_apk(in_path: str, out_path: str, cert_der_path: str, pubkey_spki_path: str, key_pem_path: str) -> None:
    data = open(in_path, "rb").read()
    tail = parse_zip_tail(data)
    contents = data[:tail["cd_offset"]]
    central_dir = data[tail["cd_offset"]:tail["cd_offset"] + tail["cd_size"]]
    assert tail["cd_offset"] + tail["cd_size"] == tail["z64_eocd_offset"], "unexpected gap before Zip64 EOCD"

    cert_der = open(cert_der_path, "rb").read()
    pubkey_spki = open(pubkey_spki_path, "rb").read()

    # First pass: build the block with a zero digest placeholder just to learn its exact byte length
    # (RSA-2048 signature is always 256 bytes, so length doesn't depend on digest value).
    placeholder_digest = b"\x00" * 32
    placeholder_block = build_v2_block(placeholder_digest, cert_der, pubkey_spki, key_pem_path)
    shift = len(placeholder_block)

    patched_tail = patch_offset_fields(tail, data, shift)

    section1 = contents
    section2 = central_dir
    section3 = patched_tail
    combined_for_digest = section1 + section2 + section3
    real_digest = chunk_digest_sha256(combined_for_digest)

    final_block = build_v2_block(real_digest, cert_der, pubkey_spki, key_pem_path)
    assert len(final_block) == shift, "signing block length changed between passes"

    with open(out_path, "wb") as f:
        f.write(section1)
        f.write(final_block)
        f.write(section2)
        f.write(section3)

    print(f"Wrote {out_path}: {len(section1)} (contents) + {len(final_block)} (v2 block) + "
          f"{len(section2)} (central dir) + {len(section3)} (eocd tail) = "
          f"{len(section1)+len(final_block)+len(section2)+len(section3)} bytes")


if __name__ == "__main__":
    sign_apk(*sys.argv[1:6])
