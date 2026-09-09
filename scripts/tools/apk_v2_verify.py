#!/usr/bin/env python3
"""Independent re-verification of a manually-applied APK Signature Scheme v2
block: re-locates the signing block by scanning backward from the (patched)
central directory offset per spec, re-parses its ASN-like structure, recomputes
the chunked content digest from scratch, and verifies the RSA signature
against the public key using openssl - without trusting any of the signer
script's own internal bookkeeping.
"""
import hashlib
import struct
import subprocess
import sys

CHUNK_SIZE = 1024 * 1024


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


def read_lp(buf: bytes, off: int):
    n = struct.unpack_from("<I", buf, off)[0]
    return buf[off + 4:off + 4 + n], off + 4 + n


def main(apk_path: str):
    data = open(apk_path, "rb").read()

    eocd_idx = data.rfind(b"PK\x05\x06")
    loc_idx = eocd_idx - 20
    assert data[loc_idx:loc_idx + 4] == b"PK\x06\x07"
    z64_eocd_offset = struct.unpack_from("<Q", data, loc_idx + 8)[0]
    assert data[z64_eocd_offset:z64_eocd_offset + 4] == b"PK\x06\x06"
    cd_offset = struct.unpack_from("<Q", data, z64_eocd_offset + 48)[0]
    cd_size = struct.unpack_from("<Q", data, z64_eocd_offset + 40)[0]
    print(f"cd_offset={cd_offset} cd_size={cd_size} z64_eocd_offset={z64_eocd_offset}")

    # Locate signing block by scanning backward from cd_offset, per spec.
    magic = data[cd_offset - 16:cd_offset]
    assert magic == b"APK Sig Block 42", f"magic mismatch: {magic!r}"
    size_b = struct.unpack_from("<Q", data, cd_offset - 24)[0]
    block_start = cd_offset - 8 - size_b
    size_a = struct.unpack_from("<Q", data, block_start)[0]
    assert size_a == size_b, f"size_a {size_a} != size_b {size_b}"
    print(f"signing block found: start={block_start} size_value={size_a} total_len={8+size_b}")

    pairs_region = data[block_start + 8:cd_offset - 24]
    # Walk pairs looking for ID 0x7109871a
    pos = 0
    v2_value = None
    while pos < len(pairs_region):
        pair_len = struct.unpack_from("<Q", pairs_region, pos)[0]
        pair_id = struct.unpack_from("<I", pairs_region, pos + 8)[0]
        value = pairs_region[pos + 12:pos + 8 + pair_len]
        print(f"  pair id=0x{pair_id:08x} len={pair_len}")
        if pair_id == 0x7109871A:
            v2_value = value
        pos += 8 + pair_len
    assert v2_value is not None, "no v2 signature pair found"

    signers_seq, _ = read_lp(v2_value, 0)
    # only one signer expected
    signer_bytes, _ = read_lp(signers_seq, 0)
    signed_data, off = read_lp(signer_bytes, 0)
    signatures_seq, off = read_lp(signer_bytes, off)
    pubkey_der, off = read_lp(signer_bytes, off)

    digests_seq, doff = read_lp(signed_data, 0)
    certs_seq, doff = read_lp(signed_data, doff)
    attrs_seq, doff = read_lp(signed_data, doff)

    one_digest_entry, _ = read_lp(digests_seq, 0)
    algo_id = struct.unpack_from("<I", one_digest_entry, 0)[0]
    embedded_digest, _ = read_lp(one_digest_entry, 4)
    print(f"digest algo=0x{algo_id:04x} embedded_digest={embedded_digest.hex()}")

    one_cert, _ = read_lp(certs_seq, 0)
    print(f"cert der len={len(one_cert)}")

    one_sig_entry, _ = read_lp(signatures_seq, 0)
    sig_algo = struct.unpack_from("<I", one_sig_entry, 0)[0]
    signature, _ = read_lp(one_sig_entry, 4)
    print(f"signature algo=0x{sig_algo:04x} signature len={len(signature)}")
    print(f"pubkey der len={len(pubkey_der)}")

    # Recompute content digest INDEPENDENTLY from the three sections.
    contents = data[:block_start]
    central_dir = data[cd_offset:cd_offset + cd_size]
    tail = data[z64_eocd_offset:]
    recomputed = chunk_digest_sha256(contents + central_dir + tail)
    print(f"recomputed_digest={recomputed.hex()}")
    assert recomputed == embedded_digest, "CONTENT DIGEST MISMATCH"
    print("content digest MATCHES")

    # Verify signature using openssl against the embedded public key.
    open("/tmp/_v2verify_signed_data.bin", "wb").write(signed_data)
    open("/tmp/_v2verify_sig.bin", "wb").write(signature)
    open("/tmp/_v2verify_pubkey.der", "wb").write(pubkey_der)
    subprocess.run(["openssl", "pkey", "-pubin", "-inform", "DER", "-in", "/tmp/_v2verify_pubkey.der",
                     "-out", "/tmp/_v2verify_pubkey.pem"], check=True)
    result = subprocess.run(
        ["openssl", "dgst", "-sha256", "-verify", "/tmp/_v2verify_pubkey.pem",
         "-signature", "/tmp/_v2verify_sig.bin", "/tmp/_v2verify_signed_data.bin"],
        capture_output=True, text=True,
    )
    print("openssl verify stdout:", result.stdout.strip())
    print("openssl verify stderr:", result.stderr.strip())
    assert result.returncode == 0 and "Verified OK" in result.stdout, "SIGNATURE VERIFY FAILED"
    print("RSA SIGNATURE VERIFIES OK")


if __name__ == "__main__":
    main(sys.argv[1])
