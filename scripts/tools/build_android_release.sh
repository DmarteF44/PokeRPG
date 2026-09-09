#!/usr/bin/env bash
# Builds a signed, installable Android APK.
#
# Godot's non-gradle Android export (export_filter="all_resources") bundles
# every project file twice: once as the compiled resource under
# assets/.godot/imported/*.ctex (what the engine actually reads at runtime)
# and once more as the raw *.import sidecar next to it (pure metadata, never
# read at runtime). With this project's asset count that redundant copy
# alone adds ~53k dead entries, pushing the APK's total ZIP entry count past
# 65535 and forcing the Zip64 format - which the only apksigner available in
# this environment (build-tools 29.0.3) fails to parse
# ("ApkFormatException: Unused space at the end of ZIP Central Directory").
# A newer build-tools isn't installable here (dl.google.com is network-
# policy-blocked), so this script works around it: export unsigned, strip
# the *.import entries, then sign what's left with the old apksigner.
#
# Usage: GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD=... scripts/tools/build_android_release.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GODOT="${GODOT_BIN:-/opt/godot43/Godot_v4.3-stable_linux.x86_64}"
BUILD_TOOLS="${ANDROID_BUILD_TOOLS:-/opt/android-sdk/build-tools/29.0.3}"
KEYSTORE="${GODOT_ANDROID_KEYSTORE_RELEASE:-/root/.android/pokerpg-release.keystore}"
KEYSTORE_USER="${GODOT_ANDROID_KEYSTORE_RELEASE_USER:-pokerpg}"
: "${GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD:?set GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD to the release keystore password}"

UNSIGNED="$ROOT/build/pokerpg-release-unsigned.apk"
STRIPPED="$ROOT/build/pokerpg-release-stripped.apk"
OUT="${1:-$ROOT/releases/pokerpg.apk}"

mkdir -p "$ROOT/build" "$(dirname "$OUT")"

echo "== 1/3: Godot export (fails at its own signing step - expected) =="
cd "$ROOT"
"$GODOT" --headless --path . --export-release "Android" "$UNSIGNED" || true
test -f "$UNSIGNED" || { echo "Godot did not produce an unsigned APK at $UNSIGNED"; exit 1; }

echo "== 2/3: stripping redundant *.import entries =="
python3 "$ROOT/scripts/tools/strip_apk_import_sidecars.py" "$UNSIGNED" "$STRIPPED"

echo "== 3/3: signing =="
"$BUILD_TOOLS/apksigner" sign \
  --ks "$KEYSTORE" \
  --ks-pass "pass:$GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD" \
  --ks-key-alias "$KEYSTORE_USER" \
  --key-pass "pass:$GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD" \
  --out "$OUT" \
  "$STRIPPED"

"$BUILD_TOOLS/apksigner" verify "$OUT"
echo "Built: $OUT"
