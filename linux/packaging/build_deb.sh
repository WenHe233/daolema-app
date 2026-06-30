#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 3 ]]; then
  echo "Usage: $0 <build-version> [artifact-label] [build-number]" >&2
  exit 64
fi

version="$1"
label="${2:-$version}"
build_number="${3:-1}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
bundle="$root/build/linux/x64/release/bundle"
stage="$root/build/packaging/deb/daolema"
output_dir="$root/dist"
target="$output_dir/daolema_${label}_amd64.deb"
desktop_file="$root/linux/packaging/daolema.desktop"
icon_file="$root/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png"

[[ -x "$bundle/daolema" ]] || {
  echo "Linux release bundle not found: $bundle" >&2
  exit 1
}

rm -rf "$stage"
mkdir -p \
  "$stage/DEBIAN" \
  "$stage/opt/daolema" \
  "$stage/usr/bin" \
  "$stage/usr/share/applications" \
  "$stage/usr/share/icons/hicolor/256x256/apps" \
  "$output_dir"

cp -a "$bundle/." "$stage/opt/daolema/"
cp "$desktop_file" "$stage/usr/share/applications/daolema.desktop"
cp "$icon_file" "$stage/usr/share/icons/hicolor/256x256/apps/daolema.png"
ln -s /opt/daolema/daolema "$stage/usr/bin/daolema"

installed_size="$(du -sk "$stage/opt/daolema" | cut -f1)"
cat > "$stage/DEBIAN/control" <<EOF
Package: daolema
Version: ${version}+${build_number}
Section: utils
Priority: optional
Architecture: amd64
Installed-Size: ${installed_size}
Depends: libgtk-3-0, libsecret-1-0
Maintainer: Daolema Contributors <noreply@github.com>
Homepage: https://github.com/WenHe233/daolema-app
Description: Private personal record and statistics app
 A restrained, local-first personal record and statistics application.
EOF

rm -f "$target"
dpkg-deb --build --root-owner-group "$stage" "$target"
[[ -s "$target" ]] || {
  echo "Debian package was not created: $target" >&2
  exit 1
}
echo "$target"
