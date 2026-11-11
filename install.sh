#!/usr/bin/env bash
# Install the Hive CLI. HIVE_VERSION and HIVE_INSTALL_DIR are optional.
set -euo pipefail

repo="tonycodes/hive-releases"
dir="${HIVE_INSTALL_DIR:-$HOME/.local/bin}"

case "$(uname -s)-$(uname -m)" in
  Linux-x86_64) target="x86_64-unknown-linux-gnu" ;;
  Linux-aarch64 | Linux-arm64) target="aarch64-unknown-linux-gnu" ;;
  Darwin-arm64) target="aarch64-apple-darwin" ;;
  *) echo "No Hive build for $(uname -s) $(uname -m)" >&2; exit 1 ;;
esac

if [ -n "${HIVE_VERSION:-}" ]; then
  base="https://github.com/$repo/releases/download/v$HIVE_VERSION"
else
  base="https://github.com/$repo/releases/latest/download"
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
archive="hive-$target.tar.gz"
curl -fsSL --retry 3 -o "$work/$archive" "$base/$archive"
curl -fsSL --retry 3 -o "$work/$archive.sha256" "$base/$archive.sha256"
(cd "$work" && shasum -a 256 -c "$archive.sha256" >/dev/null)
tar -xzf "$work/$archive" -C "$work"
mkdir -p "$dir"
install -m 0755 "$work/hive" "$dir/hive"
echo "Installed $("$dir/hive" --version) to $dir"
