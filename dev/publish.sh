#!/bin/sh
# Publishes a packaged mod zip to the Factorio mod portal, then brings the portal
# page in line with the repository.
#
#   - If the mod is not on the portal yet, it is published as a new mod.
#   - If it is, the zip is uploaded as a new release, unless that version is
#     already there.
#   - Either way the portal's long description is set to README.md, and its
#     category, tags, licence and links to the values in dev/portal.json and
#     info.json. Edits made by hand on the portal page are overwritten.
#
# Usage: FACTORIO_API_KEY=... sh dev/publish.sh <zip> [--dry-run]
#
# The key comes from https://factorio.com/profile and needs the usages
# "ModPortal: Publish Mods", "ModPortal: Upload Mods" and "ModPortal: Edit Mods".
# With --dry-run nothing is sent that needs the key; it only reports what would happen.
set -eu

root="$(cd "$(dirname "$0")/.." && pwd)"
zip="${1:?usage: sh dev/publish.sh <zip> [--dry-run]}"
dry_run="${2:-}"
portal="${FACTORIO_PORTAL_URL:-https://mods.factorio.com}"

name="$(jq -r .name "$root/info.json")"
version="$(jq -r .version "$root/info.json")"
homepage="$(jq -r '.homepage // empty' "$root/info.json")"
category="$(jq -r .category "$root/dev/portal.json")"
license="$(jq -r .license "$root/dev/portal.json")"

[ -f "$zip" ] || { echo "no such file: $zip" >&2; exit 1; }
case "$(basename "$zip")" in
  "${name}_${version}.zip") ;;
  *) echo "expected ${name}_${version}.zip, got $(basename "$zip")" >&2; exit 1 ;;
esac

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Is the mod on the portal, and does it already have this version?
code="$(curl -sS -o "$tmp/mod.json" -w '%{http_code}' "$portal/api/mods/$name")"
case "$code" in
  200) exists=yes ;;
  404) exists=no ;;
  *) echo "could not look up $name on the portal (HTTP $code)" >&2; exit 1 ;;
esac
released=no
if [ "$exists" = yes ] && jq -e --arg v "$version" 'any(.releases[]?; .version == $v)' "$tmp/mod.json" > /dev/null; then
  released=yes
fi

if [ "$exists" = no ]; then
  echo "$name is not on the portal: publishing it as a new mod at version $version"
elif [ "$released" = yes ]; then
  echo "$name $version is already on the portal: no upload"
else
  echo "$name is on the portal: uploading release $version"
fi
echo "portal page: description from README.md, category $category, licence $license, tags $(jq -c .tags "$root/dev/portal.json")"

if [ "$dry_run" = "--dry-run" ]; then
  echo "dry run: nothing sent"
  exit 0
fi
: "${FACTORIO_API_KEY:?FACTORIO_API_KEY is not set}"

# post <label> <curl arguments...>: sends a request and stops on a portal error.
post() {
  label="$1"; shift
  code="$(curl -sS -o "$tmp/response.json" -w '%{http_code}' "$@")"
  error="$(jq -r '.error // empty' "$tmp/response.json" 2> /dev/null || true)"
  if [ "$code" -lt 200 ] || [ "$code" -ge 300 ] || [ -n "$error" ]; then
    echo "$label failed (HTTP $code): $(cat "$tmp/response.json")" >&2
    exit 1
  fi
}

if [ "$exists" = no ]; then
  post "init_publish" -H "Authorization: Bearer $FACTORIO_API_KEY" \
    --form-string "mod=$name" "$portal/api/v2/mods/init_publish"
  upload_url="$(jq -r .upload_url "$tmp/response.json")"
  post "publish" -F "file=@$zip" -F "description=<$root/README.md" \
    --form-string "category=$category" --form-string "license=$license" \
    --form-string "source_url=$homepage" "$upload_url"
  echo "published $name $version"
elif [ "$released" = no ]; then
  post "init_upload" -H "Authorization: Bearer $FACTORIO_API_KEY" \
    --form-string "mod=$name" "$portal/api/v2/mods/releases/init_upload"
  upload_url="$(jq -r .upload_url "$tmp/response.json")"
  post "upload" -F "file=@$zip" "$upload_url"
  echo "uploaded $name $version"
fi

set -- --form-string "mod=$name" -F "description=<$root/README.md" \
  --form-string "category=$category" --form-string "license=$license" \
  --form-string "homepage=$homepage" --form-string "source_url=$homepage"
for tag in $(jq -r '.tags[]' "$root/dev/portal.json"); do
  set -- "$@" --form-string "tags=$tag"
done
post "edit_details" -H "Authorization: Bearer $FACTORIO_API_KEY" "$@" "$portal/api/v2/mods/edit_details"
echo "portal page updated: $portal/mod/$name"
