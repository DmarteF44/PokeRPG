#!/usr/bin/env python3
"""Strip the raw .import sidecar entries Godot's Android 'all_resources'
export mode redundantly bundles (never read at runtime - only the compiled
assets/.godot/imported/*.ctex entries matter) so total ZIP entry count
drops below the classic 65535 cap, avoiding Zip64 entirely and sidestepping
the old apksigner's broken Zip64 central-directory parser."""
import sys
import zipfile

src_path, dst_path = sys.argv[1], sys.argv[2]

src = zipfile.ZipFile(src_path, "r")
infos = src.infolist()
kept = [i for i in infos if not i.filename.endswith(".import")]
dropped = len(infos) - len(kept)
print(f"source entries: {len(infos)}, dropping .import entries: {dropped}, keeping: {len(kept)}")

dst = zipfile.ZipFile(dst_path, "w", allowZip64=True)
for i, info in enumerate(kept):
    data = src.read(info.filename)
    zi = zipfile.ZipInfo(info.filename, date_time=info.date_time)
    zi.compress_type = info.compress_type
    zi.external_attr = info.external_attr
    zi.create_system = info.create_system
    dst.writestr(zi, data, compress_type=info.compress_type)
dst.close()
src.close()

check = zipfile.ZipFile(dst_path)
print("dst entries:", len(check.namelist()))
print("testzip:", check.testzip())
