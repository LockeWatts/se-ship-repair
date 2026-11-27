# Releasing

Releases are published to the [Factorio mod portal](https://mods.factorio.com) by the
`Release` workflow in `.github/workflows/release.yml`.

## One-time setup

1. On <https://factorio.com/profile>, create an API key with the usages
   "ModPortal: Publish Mods", "ModPortal: Upload Mods" and "ModPortal: Edit Mods".
2. In this repository on GitHub, go to Settings → Secrets and variables → Actions and
   add it as a repository secret named `FACTORIO_API_KEY`.

## Each release

1. Set the new version in `info.json` and add its entry at the top of `changelog.txt`.
2. Commit and merge to `main`.
3. Tag that commit `v<version>`, for example `v0.6.1`, and push the tag.

The workflow checks the tag against `info.json`, runs the mock tests, builds the zip with
`dev/package.sh` and runs `dev/publish.sh`. The first run publishes the mod as new; later
runs add a release. The workflow can also be started by hand from the Actions tab, which
releases whatever version `info.json` holds on the chosen branch.

Each run sets the portal page's long description to `README.md` and its category, tags
and licence to the values in `dev/portal.json`, so change those here, not on the portal.

To see what a release would do without sending anything:

    sh dev/package.sh /tmp && sh dev/publish.sh /tmp/<name>_<version>.zip --dry-run
