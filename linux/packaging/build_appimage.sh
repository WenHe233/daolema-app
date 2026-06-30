#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <build-version> [artifact-label]" >&2
  exit 64
fi

version="$1"
label="${2:-$version}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
bundle="$root/build/linux/x64/release/bundle"
appdir="$root/build/packaging/appimage/Daolema.AppDir"
output_dir="$root/dist"
desktop_file="$root/linux/packaging/daolema.desktop"
icon_file="$root/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png"
linuxdeploy="${LINUXDEPLOY:-linuxdeploy-x86_64.AppImage}"
target="$output_dir/Daolema-${label}-linux-x86_64.AppImage"

[[ -x "$bundle/daolema" ]] || {
  echo "Linux release bundle not found: $bundle" >&2
  exit 1
}
command -v "$linuxdeploy" >/dev/null 2>&1 || [[ -x "$linuxdeploy" ]] || {
  echo "linuxdeploy is not executable: $linuxdeploy" >&2
  exit 1
}

rm -rf "$appdir"
mkdir -p \
  "$appdir/usr/lib/daolema" \
  "$appdir/usr/bin" \
  "$appdir/usr/share/applications" \
  "$appdir/usr/share/icons/hicolor/256x256/apps" \
  "$output_dir"

cp -a "$bundle/." "$appdir/usr/lib/daolema/"
cp "$desktop_file" "$appdir/usr/share/applications/daolema.desktop"
cp "$icon_file" "$appdir/usr/share/icons/hicolor/256x256/apps/daolema.png"
ln -s ../lib/daolema/daolema "$appdir/usr/bin/daolema"
ln -s usr/lib/daolema/daolema "$appdir/AppRun"
ln -s usr/share/applications/daolema.desktop "$appdir/daolema.desktop"
ln -s usr/share/icons/hicolor/256x256/apps/daolema.png "$appdir/daolema.png"

rm -f "$target"
export ARCH=x86_64
export APPIMAGE_EXTRACT_AND_RUN=1
export OUTPUT="$(basename "$target")"
(
  cd "$output_dir"
  "$linuxdeploy" \
    --appdir "$appdir" \
    --desktop-file "$desktop_file" \
    --icon-file "$icon_file" \
    --executable "$appdir/usr/lib/daolema/daolema" \
    --output appimage
)

[[ -s "$target" ]] || {
  echo "AppImage was not created: $target" >&2
  exit 1
}
echo "$target"
