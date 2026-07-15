# O2 - Package Building (.deb)

## What is package Building (.deb)

A `.deb` file is Debian's native package format - the same format `apt install` fetches and unpacks under the hood. it's an `ar` archive containing three components: `debian-binary` (version string), `control.tar.xz` (metadata), and `data.tar.xz` (the actual files, laid out at their final install paths).

## Why it Matters

CIPHER Linux is currently a customized Debian install. To ship custom tools, branding assets, or onboarding scripts to future users, they need to install, upgrade, and uninstall cleanly - exactly like native Debian software. A raw shell script can't enforce dependencies, can't be clearly uninstalled, and has no version tracking. A `.deb` package can.

## Key Concepts

| Concept | Description |
|---|---|
| `ar` archive | The container format of a `.deb` - holds three components, verified with `ar t package.deb` | 
| `control` file | Metadata file - package name, version, dependencies, maintainer, description | 
| Build folder structure | Mirrors the target filesystem exactly - `usr/local/bin/x` becomes `/usr/local/bin/x` on install | 
| `Depends` field | Machine-enforced dependency requirement - dpkg/apt refuse to install broken |
| `dpkg` vs `apt` | `dpkg` installs a local `.deb` only, no dependency resolution. `apt` resolves and downloads dependencies from repos, then calls `dpkg` | 
| `--root-owner-group` | Forces packaged files to be root:root owned, standard practice for real packages | 

## Core Commands

```bash
# Build folder skeleton
mkdir -p cipher-welcome-1.0.0/DEBIAN
mkdir -p cipher-welcome-1.0.0/usr/local/bin

# Set correct ownership before building 
sudo chown -R root:root cipher-welcome-1.0.0

# Build the package 
dpkg-deb --build --root-owner-group cipher-welcome-1.0.0

# Inspect the built archive
ar t cipher-welcome-1.0.0.deb

# Install
sudo dpkg -i cipher-welcome-1.0.0.deb

# Confirm package record
dpkg -l | grep cipher-welcome
apt show cipher-welcome

# Clean removal
sudo dpkg -r cipher-welcome
```

## Scenarios Practised

**Problem:** `dpkg-deb --build` failed with `package architecture is missing or empty`.
**investigate:** Checked the `control` file - a required field (`Architecture`) was missing or malformed from the initial write.
**Fix:** Rewrote `control` file with all required fields present and correctly spelled, including `Architecture: amd64`
**Key Lesson:** `dpkg-deb` is strict - every required control field must exist and be exactly spelled, or the build fails outright with no partial output.

**Problem:** Build succeeded but with a warning: `root directory cipher-welcome-1.0.0 has unusual owner or group 1000:1000`.
**Investigate:** The build folder was created via `mkdir` as the regular user (UID 1000), but packages conventionally represent root-owned system files since `dpkg` installs them system-wide as root.
**Fix:** Ran `sudo chown -R root:root cipher-welcome-1.0.0` and rebuilt using `dpkg-deb --build --root-owner-group`.
**Key Lesson:** Ownership matters even for a test package - real `.deb` builds should always enforce root ownership regardless of who's building it.

**Problem:** After installing, running the script threw, `unexpected EOF while looking for matching quote`.
**Investigate:** Ran `cat -A` on the installed script to reveal hidden characters and located the exact broken line: `echo "Kernel" $(uname -r)"` - a closing quote landed right after `"Kernel"`, leaving `$(uname -r)` unquoted and a stray trailing quote with nothing to close it.
**Fix:** Corrected the line to `echo "Kernel: $(uname -r)"`, rebuilt, and reinstalled.
**Key Lesson:** Bash quote mismatches the interpreter to read to end-of-file waiting for a closing quote - `cat -A` is the fastest way to catch hidden/mismatched characters that plain `cat` won't show clearly.

**Problem:** After `sudo dpkg -r cipher-welcome`, a warning appeared: `directory '/usr/local' not empty so not removed`.
**Investigate:** Confirmed whether the `Maintainer` field requires domain ownership or verification.
**Fix:** Used a personal Gmail address instead perfectly valid for local/early-stage package development.
**Key Lesson:** The `Maintainer` field is just a contact reference with no domain verification requirement; it can be updated with a one-line change and rebuild once CIPHER Linux has its own domain.

##Key Commands Table

| Command | Purpose |
|---|---|
| `dpkg-deb --build --root-owner-group <dir>` | Build a `.deb` from a folder, enforcing root ownership |
| `ar t <file>.deb` | List the three internal components of a built `.deb` |
| `sudo dpkg -i <file>.deb` | Install a local `.deb` package |
| `dpkg -l | grep <name>` | Confirm a package is registered as installed | 
| `apt show <name>` | View full package metadata after install | 
| `sudo dpkg -r <name>` | Remove an installed package cleanly |  
| `cat -A <file>` | Reveal hidden/special characters to debug quoting issues | 


## Golden Rules 

- Every required `control` filed must be present and exactly spelled, or the build fails.
- Always build with `--root-owner-group` after `chown -R root:root` - packages should never carry a regular user's UID/GID.
- The build folder's internal path structure IS the install path - there's no seperate mapping steps.
- `dpkg` never deletes pre-existing, non-empty shared directories like `/usr/local`, even on full removal.
- `cat -A` is the go-to tool for catching invisible/mismatched quote characters in script.
- `Maintainer` needs no domain - any real contact email works during any development.


## Skills Gained

- Building a `.deb` packages from scratch using `dpkg-deb`
- Writing and validating a Debian `control` file
- Debugging build-time errors from missing/malformed control fields
- Understanding and correcting file ownership issues in package builds
- Diagnosing bash quoting bugs using `cat -A`
- Verifying package install/removal state via `dpkg -l` and `apt show`


## Environment used

| Component | Details | 
|---|---|
| Host Machine | Kali Linux |
| Shell | ZSH | 
| Packaged tool | `dpkg-deb`, `dpkg`, `apt` |
| Working directory | `/run/media/neo/Games/cipher-linux` (ext4) |


