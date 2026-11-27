#!/bin/sh
# Builds the installable mod zip from the repository, leaving out dev/ and git files.
# Usage: sh dev/package.sh [output-directory]
set -e
root="$(cd "$(dirname "$0")/.." && pwd)"
out="${1:-$root/..}"
version="$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$root/info.json")"
name="se-ship-repair_$version"
tmp="$(mktemp -d)"
mkdir "$tmp/$name"
(cd "$root" && tar cf - --exclude=./dev --exclude=./.git --exclude=./.github --exclude=./.gitignore --exclude=./.gitattributes --exclude=./README.md .) | (cd "$tmp/$name" && tar xf -)
(cd "$tmp" && zip -qr "$name.zip" "$name")
mv "$tmp/$name.zip" "$out/"
rm -rf "$tmp"
echo "$out/$name.zip"
