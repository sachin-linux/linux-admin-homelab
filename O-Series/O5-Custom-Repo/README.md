# O5 - Custom Repo

### Why it Matters

A real Linux distro needs its own package repository so users can run `apt install <package>` and get distro-specific tools automatically - signed, versioned, and updatable - instead of manually installing `.deb` files by hand. This module builds that repository infrastructure of CIPHER Linux and wires it directly into the O3 live-build pipeline, so every future ISO rebuild pulls CIPHER packages the same way a real distro does.

### Key Concepts

| Components | Purpose | 
|---|---|
| `pool` | Actual `.deb`a files, organized by source package |
| `dists/<codename>/` | Metadata for a specific release (e.g. `stable`) |
| `Packages` | Index of all packages + metadata + checksums |
| `Releases` | Repo-level metadata + checksums of `Packages` | 
| `InRelease` / `Release.gpg` | Signed version, proves authenticity | 
| GPG key | Signs the repo so `apt` trusts it, no warnings |
| `reprepro` | Tool that automates building/maintaining the repo structure |
| `Sources.list.d/cipher.list` | What users add to point `apt` at the repo | 

### Core Commands

```bash
# Install repo loading
sudo apt install reporepro gnupg -y

# Generate a 4096-bit RSA signing key
gpg --full-generate-key

# Add a package to the repo
reprepro -b <repo-path> includedeb stable <package>.deb

# Serve the repo locally for testing
python3 -m http.sever 8000

# Point apt at the repo
echo "deb http://localhost:8000 stable main" | sudo tee /etc/apt/sources.list.d/cipher.list

# Import the repo's GPG key for real signatures verification
gpg --armor --export <KEY_ID> | sudo tee /etc/apt trusted.gpg.d/cipher-linux.asc
```

### Wiring the Repo into O3's live-build

Standing up the repo alone isn't enough - the real goal is future ISOs pulling CIPHER packages automatically. Three files added to the live-build config:

| File | Role|
|---|---|
| `config/archives/cipher.list.chroot` | Adds the repo as an apt source during the chroot build stage only | 
| `config/archives/cipher.key.chroot` | GPG public key, auto-imported by live-build before using the `list.chroot` source |
| `config/package-lists/cipher.list.chroot` | Adds `cipher-welcome` to the list of package live-build installs |

```bash
mkdir -p <build-dir>config/archives

echo "deb http://localhost:8000 stable main" | sudo tee <build-dir>/config/archives/cipher.list.chroot

gpg --armor --export <KEY_ID> | sudo tee <build-dir>/config.archives/cipher.key.chroot

echo "cipher-welcome" | sudo tee -a <build-dir>/config/package-lists/cipher.list.chroot
```

The `.chroot` suffix scopes the source to the build stage only - `localhost:8000` won't exist on someone else's machine when they boot the final ISO.

### Scenarios Practised

## Scenario 1 - Config parsing errors in `reprepro`

- **Problem:** `conf/distributions` failed with `Unknown header` errors.
- **Investigate:** Ran `cat -A conf/distributions` to reveal hidden characters instead of guessing from a normal `cat` / `nano` view - found typos (`Lable` instead of `Label`, `Architecture` instead of `Architectures`) and a raw GPG key dump pasted into `SignWith` instead of just the key ID.
- **Fix:** Corrected each header exaclty, extracted the correct key ID fromt the pasted `gpg --list-secret-keys` output.
- **Key Lessons:** `reprepro` treats config errors as hard failures by design - a silently-ignored typo could mean packages ship unsigned or unindexed.

## Scenario 2 - Wrong apt source path

- **Problem:** `apt install cipher-welcome` failed with `unable to locate package` after removing the package, despite `apt update` reporting no errors.
- **Investigate:** Reviewed the exact `tee` command user earlier and found it targeted `/etc/apt/sources.list/cipher.list` -  a nonexistent path (`source.list` is a file, not a directory) - so the source file was never actually created; `apt update`'s "up to date" message was true only for the sources it did know about.
- **Fix:** Re-ran the command targetting `/etc/apt/sources.list.d/cipher.list`, confirmed with a `Get:`/`Hit:` line for `localhost:8000` in the next `apt update`.
- **Key Lesson:** A clean `apt update` doesn't guarantee your source was actually registered - verify with a line referencing your repo URL, not just the absence of errors.

## Scenario 3- Stale live-build stage makers (bootstrap)

- ** Problem:** `lb build` printed `W:Skipping bootstrap, already done` then failed with `cannot create chroot/etc/debian_chroot: Directory nonexistent`.
- **Investigate:** Checked `.build/` and found `bootstrap` and `bootstrap_cache.restore` markers still present, despite `chroot/` having just been deleted by `lb clean --chroot` - a mismatch between tracked state and actual filesystem state. Removing only `bootstrap` first wasn't enough; the build still failed with `the following stage is required to be done first: bootstrap`,showing `bootstrap_cache.restore` was the marker actually gating the unpack step.
- **Fix:** Removed `.build/bootstrap_cache.restore` specifically, letting live-build re-extract the cached bootstrap tarball into a fresh `chroot/`
- **Key Lesson:** `live-build`'s clean commands don't always fully reset stage-tracking state-after cleaning, inspect `.build/` directly rather than assuming which marker is blocking a stage.

## Scenario 4 - `nodev` mount blocking chroot package installs

- **Problem:** `lb build` failed during package configuration with `cannot create /dev/null: Permission denied`, cascading into ~50 dependency failures (`xserver-xorg-core`, `dbus`, `xfce4-pamnel`, etc).
- **Investigate:** Recognized the repeated `/dev/null` permission error as a device-node creation issue, then ran `mount | grep Games` and found the build directory's external drive mounted with `nodev` via `udisk2` - a default security flag on auto-mounted removable drives.
- **Fix:** `sudo mount -o remount,dev /run/media/neo/Games` to allow device node creation for the session (temporary - resets on umount/reboot).
- **Key Lesson:** One blocked low-level operation can cascade into dozen of unrelated-looking dependency errors - trace to the first failure in the log, not the last, and check mount flags on any non-standard build location.


## Sceanrio 5 - Stale binary stage / squashfs not regenerated

- **Problem:** `lb build` reported success and `cipher-welcome` showed `install ok installed` in the chroot's dpkg status, but `dpkg -l | grep cipher-welcome` returned empty inside the booted CIPHER Linux instance.
- **Investigate:** Comapred `filesystem.squashfs`'s timestamp against the actual rebuild time - squashfs was dated 3 days earlier, proving the binary/packaging stage never re-ran despite the "Successful" build message. Ran `sudo unsquashfs -l filesystem.squashfs | grep cipher-welcome` and got no output, confirming the package was genuinly absent from the bootable image. `lb clean --binary` didn't clear the relevant `.built/binary_*` markers as expected.
- **Fix:** Manually removed all `.build/binary_*` marker files, forcing a full binary-stage rebuild that correctly regenerated the squashfs - reconfirmed with a fresh `unsquashfs -l` showing `usr/local/bin/cipher-welcome` present.
- **Key Lesson:** A "successful" build exit code doesn't guarantee every stage re-ran - always verify the actual artifact (file timestamps + `unsquashfs -l` contents), not just the exit status.


### Verified Chain

1. `grep "^Package:cipher-welcome" chroot/var/lib/dpkg/status` -> confirmed `Install ok Installed` in the chroot
2. First `unsquashfs -l | grep cipher-welcome` -> empty, proved the package was NOT in the bootable image despite a "successful" build
3. Compared `filesystem.squashfs` timestamp to the rebuild time -> confirmed it was stale
4. Cleared `.build/binary_*` markers, rebuilt -> squashfs timestamp updated to match
5. Final `unsquashfs -l` -> confirmed `usr/local/bin/cipher-welcome`, `var/lib/dpkg/cipher-welcome.list`, `var/lib/dpkg/info/cipher-welcome.md5sums` all present
6. Booted the fresh ISO, ran `cipher-welcome` directly in terminal -> confirmed working
7. SSH'd from the kali host into the booted CIPHER Linux instance -> confirmed networking/sshd functional on the rebuilt image

### Key Commands Table

| Command | Purpose |
|---|---|
| `reprepro -b <path> includedeb <dist> <deb>` | Add a package to the custom repo |
| `mount \| grep <name>` | Check mount flags (e.g.detect `nodev` | 


