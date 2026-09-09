#!/usr/bin/env bash
# Builds a signed, installable Android APK.
#
# Godot's non-gradle Android export (export_filter="all_resources") doesn't
# pack a single embedded .pck the way most Godot exports do - it mirrors the
# whole project onto the APK's asset tree as loose files, with every imported
# resource appearing TWICE: once as the compiled texture under
# assets/.godot/imported/*.ctex, and once as the raw *.import sidecar next to
# it. That *.import file is NOT dead editor metadata in this export mode - the
# engine's runtime resource loader reads it to resolve a res:// path to its
# compiled .ctex, exactly like it does from a live project folder in the
# editor. (An earlier version of this script stripped *.import entries to cut
# the ZIP entry count; that broke every sprite/icon load in the shipped APK -
# do not do that again.)
#
# Every resource costs 2 ZIP entries this way, and the whole APK's entry
# count must stay under the classic 65535 cap: past that, Zip64 format kicks
# in, and every apksigner available in this environment (the bundled
# build-tools 29.0.3 one and the newer 31.0.2 from Ubuntu's own apksigner
# package - both tried) fails to parse the resulting Zip64 central directory
# ("ApkFormatException: Unused space at the end of ZIP Central Directory"),
# even though the archive is verifiably well-formed (confirmed by
# hand-walking every central directory record - the Zip64 EOCD's stated
# offsets/sizes match exactly). Worse, Android's own on-device package
# parser hit the exact same wall on a real device (confirmed: a v1-only
# jarsigner build AND a from-scratch, independently-verified v2 signature
# were BOTH rejected with the same generic "package appears to be invalid",
# which only makes sense if the OS parser - not the signature scheme - can't
# read the Zip64 structure either). A newer/official build-tools isn't
# installable here (its installer needs dl.google.com, blocked), and a
# Gradle-based export would need Google's Maven (also blocked).
#
# So MAX_FRAMES (scripts/tools/extract_generation_sprites.py) has to stay
# low enough that total entries stay under 65535 - see that file's own
# comment for the current safe value and the math behind it. When that
# holds, Godot's own bundled apksigner works fine and produces a real
# v1+v2+v3 signature; this script uses that directly. As a safety net for
# ever going over the cap again, it falls back to apk_v2_sign.py (a
# from-scratch APK Signature Scheme v2 implementation, self-verified against
# openssl) - but that fallback should be treated as a red flag that
# MAX_FRAMES needs lowering again, not a long-term solution, since it's
# ONLY the signing step that fallback fixes and the on-device parser
# rejection described above suggests installs would still fail past the cap.
#
# Usage: GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD=... scripts/tools/build_android_release.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GODOT="${GODOT_BIN:-/opt/godot43/Godot_v4.3-stable_linux.x86_64}"
BUILD_TOOLS="${ANDROID_BUILD_TOOLS:-/opt/android-sdk/build-tools/29.0.3}"
KEYSTORE="${GODOT_ANDROID_KEYSTORE_RELEASE:-/root/.android/pokerpg-release.keystore}"
KEYSTORE_ALIAS="${GODOT_ANDROID_KEYSTORE_RELEASE_USER:-pokerpg}"
: "${GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD:?set GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD to the release keystore password}"

UNSIGNED="$ROOT/build/pokerpg-release-unsigned.apk"
OUT="${1:-$ROOT/releases/pokerpg.apk}"
KEYMAT_DIR="$(mktemp -d)"
trap 'rm -rf "$KEYMAT_DIR"' EXIT

mkdir -p "$ROOT/build" "$(dirname "$OUT")"

echo "== 1/2: Godot export (signs in-place via its own apksigner call) =="
cd "$ROOT"
"$GODOT" --headless --path . --export-release "Android" "$UNSIGNED" && GODOT_SIGNED=1 || GODOT_SIGNED=0
test -f "$UNSIGNED" || { echo "Godot did not produce an APK at $UNSIGNED"; exit 1; }

if [ "$GODOT_SIGNED" = "1" ] && "$BUILD_TOOLS/apksigner" verify "$UNSIGNED" >/dev/null 2>&1; then
  echo "Godot's own apksigner signed and verified it directly - using that."
  cp "$UNSIGNED" "$OUT"
  "$BUILD_TOOLS/apksigner" verify --verbose "$OUT"
else
  echo "Godot's own signing failed or didn't verify (likely over the Zip64 entry cap - see script"
  echo "header) - falling back to the from-scratch APK Signature Scheme v2 implementation."
  echo "== extracting signing key/cert from the release keystore =="
  keytool -importkeystore \
    -srckeystore "$KEYSTORE" -srcstorepass "$GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD" -srcalias "$KEYSTORE_ALIAS" \
    -destkeystore "$KEYMAT_DIR/release.p12" -deststoretype PKCS12 \
    -deststorepass "$GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD" -destalias "$KEYSTORE_ALIAS" >/dev/null
  openssl pkcs12 -in "$KEYMAT_DIR/release.p12" -nocerts -nodes \
    -passin "pass:$GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD" -out "$KEYMAT_DIR/key.pem" 2>/dev/null
  openssl pkcs12 -in "$KEYMAT_DIR/release.p12" -clcerts -nokeys \
    -passin "pass:$GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD" -out "$KEYMAT_DIR/cert.pem" 2>/dev/null
  openssl x509 -in "$KEYMAT_DIR/cert.pem" -outform DER -out "$KEYMAT_DIR/cert.der"
  openssl x509 -in "$KEYMAT_DIR/cert.pem" -pubkey -noout -out "$KEYMAT_DIR/pubkey.pem"
  openssl pkey -pubin -in "$KEYMAT_DIR/pubkey.pem" -outform DER -out "$KEYMAT_DIR/pubkey_spki.der"

  python3 "$ROOT/scripts/tools/apk_v2_sign.py" \
    "$UNSIGNED" "$OUT" \
    "$KEYMAT_DIR/cert.der" "$KEYMAT_DIR/pubkey_spki.der" "$KEYMAT_DIR/key.pem"
  python3 "$ROOT/scripts/tools/apk_v2_verify.py" "$OUT"
fi

python3 -c "
import zipfile
z = zipfile.ZipFile('$OUT')
n = len(z.namelist())
print(f'Final APK entry count: {n}' + (' (WARNING: over the 65535 Zip64 cap!)' if n > 65535 else ' (under the 65535 cap)'))
"
echo "Built: $OUT"
