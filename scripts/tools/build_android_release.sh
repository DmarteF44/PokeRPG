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
# compiled .ctex, exactly like it does when running from the live project
# folder in the editor. (An earlier version of this script stripped *.import
# entries to cut the ZIP entry count; that broke every sprite/icon load in the
# shipped APK - do not do that again.)
#
# With this project's asset count, the real (non-strippable) entry total
# comes out around 107k, which exceeds the classic 65535-entry ZIP cap and
# forces Zip64 format. The only apksigner available in this environment
# (build-tools 29.0.3) can't parse a Zip64 central directory that large
# ("ApkFormatException: Unused space at the end of ZIP Central Directory") -
# a newer build-tools isn't installable here (dl.google.com is network-
# policy-blocked). So this script signs with `jarsigner` instead (JDK's own
# zip/jar handling has no such Zip64 limit) - a v1 (JAR) signature only, no
# v2/v3 APK Signature Scheme block. That's a real tradeoff (see README note
# below) but it's the only path in this environment that ships every asset
# intact.
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

mkdir -p "$ROOT/build" "$(dirname "$OUT")"

echo "== 1/2: Godot export (fails at its own apksigner signing step - expected) =="
cd "$ROOT"
"$GODOT" --headless --path . --export-release "Android" "$UNSIGNED" || true
test -f "$UNSIGNED" || { echo "Godot did not produce an unsigned APK at $UNSIGNED"; exit 1; }

echo "== 2/2: signing with jarsigner (v1/JAR scheme - see script header) =="
cp "$UNSIGNED" "$OUT"
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 \
  -keystore "$KEYSTORE" \
  -storepass "$GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD" \
  "$OUT" "$KEYSTORE_ALIAS"

jarsigner -verify "$OUT"
echo "Built: $OUT"
