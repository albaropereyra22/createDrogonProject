# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Does

`createDrogonProject` is a macOS shell script toolchain that automates the full lifecycle of bootstrapping a new [Drogon](https://github.com/drogonframework/drogon) (C++ web framework) project: installing dependencies via Homebrew, compiling Drogon from source, scaffolding via `drogon_ctl`, creating a GitHub repo, building with CMake, and pushing the first commit.

## Installation & Setup

```sh
sh bin/installer.sh
```

This installs Homebrew (if missing), all Drogon dependencies, compiles Drogon from source into `$HOME/opt/drogon`, and symlinks the main script to `/usr/local/bin/createDrogonProject`.

After installation, the tool is available globally as `createDrogonProject`.

## Common Commands

```sh
# Create a new Drogon project (interactive)
createDrogonProject

# Create a project with a name, private repo
createDrogonProject -n myProjectName -p

# Show help
createDrogonProject -h

# Push changes to this toolchain's own repo
sh pushUpdates.sh "your commit message"

# Uninstall
sh bin/uninstaller.sh
```

## Architecture

The execution flow has two phases:

**1. Self-update (always runs first in `createDrogonProject.sh`):**
`createDrogonProject.sh` copies `bin/createDrogonProjectUpdater.sh` to `~/bin/` and runs it before any argument parsing. This updater pulls the latest version of this repo, then updates Homebrew and Drogon if needed.

**2. Project creation:**
- Prompts for (or accepts via flags): `softwareName`, `gitServer`, `ghUserName`
- Creates a GitHub repo via `gh repo create`
- Scaffolds via `drogon_ctl create project $softwareName`
- Builds in `$HOME/opt/$softwareName/build/` with `cmake` + `make`
- Runs the binary in the background, then does the initial git push

**Support scripts in `bin/`:**

| Script | Purpose |
|---|---|
| `installer.sh` | Full dependency + Drogon install |
| `uninstaller.sh` | Removes symlinks, man page, Drogon |
| `updater.sh` | Generic repo updater; intended for cron `@reboot` use |
| `createDrogonProjectUpdater.sh` | Specific updater for this toolchain |
| `getNetworkStatus.sh` | Polls until routing to `8.8.8.8` is available (used before updates on reboot) |
| `createDrogonService.sh` | **Under development** — FreeBSD rc.d service generator |
| `continueKilledProcess.sh` | **Under development** — process watchdog |

## Known Bugs to Keep in Mind

- **`optDir="~/opt/"`** — tilde does not expand inside double quotes; use `"$HOME/opt/"` instead
- **`$ghUserName` vs `$ghUsername`** — typo in `createDrogonProject.sh` means the git remote URL always falls back to the hardcoded default username
- **`if [ $private ]`** — evaluates as always-true because `"false"` is non-empty; use `[ "$private" = "true" ]`
- **`installer.sh`**: `git config --global user.email "emailAddress"` is missing the `$`, so it sets the literal string `"emailAddress"` as the email
- **`uninstaller.sh`**: `rm -rf "mapPage"` is a typo for `rm -rf "$manPage"`

## Platform

macOS only. Scripts use `/bin/sh` but some (`updater.sh`) rely on bash-specific syntax (`<<<`). Tested on macOS X.
