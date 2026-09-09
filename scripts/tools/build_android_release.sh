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
# With this project's asset count, the real (non-strippable) entry total
# comes out around 107k, which exceeds the classic 65535-entry ZIP cap and
# forces Zip64 format. EVERY apksigner available in this environment (the
# bundled build-tools 29.0.3 one and the newer 31.0.2 from Ubuntu's own
# apksigner package - both tried) fails to parse the resulting Zip64 central
# directory ("ApkFormatException: Unused space at the end of ZIP Central
# Directory"), even though the archive is verifiably well-formed (confirmed
# by hand-walking every central directory record and cross-checking the
# Zip64 EOCD's stated offsets/sizes against them - they match exactly). A
# newer/official build-tools isn't installable here (its installer needs
# dl.google.com, which is network-policy-blocked), and Gradle-based export
# would need Google's Maven repo (also blocked) with nothing cached locally.
#
# So this script signs with apk_v2_sign.py, a from-scratch implementation of
# APK Signature Scheme v2 (see comments in that file) that splices the
# signing block in directly rather than going through any apksigner tool at
# all. It self-verifies (recomputes the content digest independently and
# checks the RSA signature with openssl) before writing the output. This
# produces a v2-only signature - no v1/JAR or v3 - which is sufficient for
# this app's targetSdkVersion (Android requires v2 or higher for
# targetSdkVersion >= 30; v2 alone satisfies that).
#
# Usage: GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD=... scripts/tools/build_android_release.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GODOT="${GODOT_BIN:-/opt/godot43/Godot_v4.3-stable_linux.x86_64}"
KEYSTORE="${GODOT_ANDROID_KEYSTORE_RELEASE:-/root/.android/pokerpg-release.keystore}"
KEYSTORE_ALIAS="${GODOT_ANDROID_KEYSTORE_RELEASE_USER:-pokerpg}"
: "${GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD:?set GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD to the release keystore password}"

UNSIGNED="$ROOT/build/pokerpg-release-unsigned.apk"
OUT="${1:-$ROOT/releases/pokerpg.apk}"
KEYMAT_DIR="$(mktemp -d)"
trap 'rm -rf "$KEYMAT_DIR"' EXIT

mkdir -p "$ROOT/build" "$(dirname "$OUT")"

echo "== 1/3: Godot export (fails at its own apksigner signing step - expected) =="
cd "$ROOT"
"$GODOT" --headless --path . --export-release "Android" "$UNSIGNED" || true
test -f "$UNSIGNED" || { echo "Godot did not produce an unsigned APK at $UNSIGNED"; exit 1; }

echo "== 2/3: extracting signing key/cert from the release keystore =="
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

echo "== 3/3: applying APK Signature Scheme v2 (manual implementation) =="
python3 "$ROOT/scripts/tools/apk_v2_sign.py" \
  "$UNSIGNED" "$OUT" \
  "$KEYMAT_DIR/cert.der" "$KEYMAT_DIR/pubkey_spki.der" "$KEYMAT_DIR/key.pem"
python3 "$ROOT/scripts/tools/apk_v2_verify.py" "$OUT"

echo "Built: $OUT"
