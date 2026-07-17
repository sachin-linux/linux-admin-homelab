# O3 - Live-build / ISO

## What is live-build & ISO Creation?

`live-build` is Debian's official tooling for turning a base system definition (distribution, architecture, package list, branding) into a real, bootable ISO image - the same tooling Kali and Ubuntu use to produce their own installers and live systems. It automates three stages: **bootstrap** (build a minimal base system with `debootstrap`), **chroot** (install the full package set and run any hooks inside that base system), and **binary** (assemble everything into a compressed filesystem plus bootloader, producing the final `.iso`). This is the module where CIPHER Linux stops being a folder of packages (O2) and becomes an actual file a user flash to USB and boot.

## Why it Matters?

- **Distributability** -a `.deb` package (O2) only means somehing once it's installed onto something; the ISO is the actual product a user downloads and boots
- **Build reproducibility** - `live-build` config is version-controllable and rerunnable, unlike manually partitioning and installing a disk by hand
- **Foundation for O4-O7** - kernel customization, custom repos, and branding all get baked in through this same `live-build` config going forward
- **Interview relevance** - `live-build`, `debootstrap`, and ISO 9660 constraints are real distro-engineering topics, not just "ran a script" trivia

## Key Concepts

| Term | Meaning |
|---|---|
| `debootstrap` | Bootstrap a minimal base Debian/Kali system into a chroot - the first real stage of any build |
| `chroot` | A fake root - a directory that behaves like a seperate OS while build scripts and package installs run inside it |
| `config/package-lists/` | Defines which APT packages get installed during the build | 
| `config/packages.chroot/` | Local `.deb` files (like O2's `cipher-welcome`) installed directly, no APT repo required | 
| `config/includes.chroot/` | Files copied verbatim into the final filesystem at the exact path given |
| `build/` | Internal stage-tracking markers - wiped by `lb clean`, which means `lb config` must be rerun afterward | 
| `LB_MIRROR_BOOTSTRAP` vs `LB_PARENT_MIRROR_BOOTSTRAP` | `live-build` treats an unrecognized distro name (like `kali-rolling`) as a derivative with an assumed Debian parent - both mirror variables must be set correctly or `debootstrap` fetches from the wrong place | 
| `iso-hybrid` | Binary image type that makes the ISO bootable from both USB and optical media | 
| `nodev` (mount flag) | Blocks device files like `/dev/null` from working on that filesystem - fatal for chroot operations if the build directory sits on a drive mounted this way |
| ISO 9660 | The filesystem format ISOs use - has a hard 32-character limit on the volume label |

## Core Commands

```bash
# Configure the build
lb config --iso-volume "CIPHER-LINUX" \
 --linux-packages linux-image \
 --distribution kali-rolling \
 --architecture amd64 \
 --binary-images iso-hybrid \
 --mirror-bootstrap http://kali.org/kali \
 --parent-mirror-bootstrap http://http.kali.org/kali	# Set up config/ tree with correct mirrors and kernel handling

# Run the build
sudo lb build		# Executes -> chroot -> binary stages

# Reset between attempts
sudo lb clean 		# Clears build artifacts, keeps config/ intact (requires rerunning lb config)
sudo lb clean --purge 		# Also clears cached bootstrap/chroot data - full reset

# Verify mount flags before building
mount | grep <path>		# Confirm the build directory isn't mounted with nodev

# Verify the result
ls -lh *.iso		# Confirm the ISO file exists and check its size
file *.iso		# Confirm it's a valid, bootable ISO 9660 image
```

## Scenarios Practiced

### Scenario 1 - Wrong Mirror for a Non-Standard Distro Name
- **Problem:** `debootstrap` failed with "Failed getting release file" while trying to fetch `kali-rolling` from `deb.debian.org`
- **Investigate:** `live-build` doesn't recognize `kali-rolling` as an official Debian suite name, so it defaults to Debia's mirror - which has no idea what `kali-rolling` is.
- **Fix:** set `--mirror-bootstrap` and `--mirror-binary` to `http://http.kali.org/kali`. When the error persisted, discovered `live-build` also uses a seperate `--parent-mirror-bootstrap` variable for distro names it treats as derivatives - had to set that too.
- **Key Lesson:** For any non-standard/rolling distro name, both the regular and parent mirror flags need to point at the correct mirror, or `deboostrap` silenlty tries the wrong source.

### Scenario 2 - Nonexistent Security/Updates Suites
- **Problem:** 404 errors on `kali-rolling-security` and `kali-rolling-updates` during chroot setup.
- **Investigate:** `live-build` assumes every distro has seperate `-security` and `-updates` suites, which is true for versioned Debian releases but not for Kali, which is a rolling release with everything in one suite.
- **Fix:** `--security false --updates false` to disable those suite lookups entirely.
- **Key Lesson:** Rolling-release distros don't follow the same suite-splitting convention as versioned Debian - check this before assuming a Debian-oriented flag applies university.

### Scenario 3 - Mass Package Failures from a Mount Flag
- **Problem:** Dozens of unrelated packages failed during chroot with "cannot create /dev/null: Permission denied" in their postinst scripts.
- **Investigate:** The build directory sat on an external drive that was auto-mounted with the `nodev` flag (via udisks2) `nodev` blocks device files like `/dev/null` from functioning, and a huge number of Debian/Kali postinst scripts redirect output to `/dev/null` as routine practice.
- **Fix:** Unmounted the auto-mounted drive and remounted it manually at `/mnt/games` with `-o rw,dev,suid,exec`.
- **Key Lesson:** A single filesystem mount flag can cascade into dozens of failures that look like unrelated package bugs - check mount flags on the build directory before debugging individual packages,

### Scenario 4 - Kernel Never Actually Installed
- **Problem:** Binary stage failed with `cp: cannot stat `chroot/boot/vmlinuz-*'` - no kernel existed in the built system at all.
- **Investigate:** `live-build`'s automatic kernel-detection doesn't trigger for a distro name it doesn't recognize as standard Debian, so no kernel package ever got scheduled for install.
- **Fix:** `--linux-packages linux-image` so `live-build` explicity schedules the correct kernel package.
- **Key Lesson:** Don't assume kernel installation is automatic - verify `chroot/boot/` actually contains `vmlinuz` and `initrd` files before moving on the top of binary stage.

### Scenario 5 - Duplicate Package Name from a Stale Append-Only File
- **Problem:** `apt` failed with `Unable to locate package linux-image-amd64-amd64` even after the `--linux-packages` flag was corrected.
- **Investigate:** `chroot/root/packages.chroot` is written using `>>` (append), so every partial or failed rebuild attempt kept staccking new lines instead of overwriting old ones. An earlier bad attempt (passing `linux-image-amd64` instead of `linux-image`, which `live-build` then double-suffixed) had left a broken line permanently sitting in that file.
- **Fix:** Manually deteted `chroot/root/packages.chroot` and its stage marker `.build/chroot_linux-image` to force a clean, correct regeration.
- **Key Lesson:** Some `live-build` state files are append-only across reruns - when a stage keeps producing a stale-looking result after a config fix, check whether the underlying file needs to be deleted directly, not just regenerated.

### Scenaro 6 - ISO Volume Lable Too long
- **Problem:** The build reached the final `xorriso` stage and failed with `-volid: Text too long (34 > 32)`. 
- **Investigate:** ISO 9660 caps volume labels at 32 characters, and `live-build`'s auto-generated label exceeded that.
- **Fix:** Set an explicit short label with `--iso-volume "CIPHER_LINUX"`.
- **Key Lesson:** Set `--iso-volume` explicitly from the start - failing at the very last stage after bootstrap, chroot and package installation have all already succeeded is an expensive place to catch this.

### Scenario 7 - Build Corrupted by Backgrounding Without a Real Terminal
- **Problem:** When the build was background with `sudo lb build > build.log 2>&1&` to survive a disconnect, `dpkg` started failing packages with `tcsetattr: Input/output error`.
- **Investigate:** Detaching the process from the terminal this way still lets `dpkg` try to write terminal control codes for its progress output, which breaks when there's no real TTY attached.
- **Fix:** Used `tmux new -s cipherbuild` instead -a persistent real terminal session that survives disconnects without breaking `dpkg`'s TTY interaction.
- **Key Lesson:** For ling-running builds that need to survive a disconnect, use `tmux` / `screen`, not `&` with output redirection - they solve different problems and the wrong one silently corrupts package installs.

## Golden Rules 

- Always set both the mirror and parent mirror flags when building on a non-standard/rolling distro name - `live-build` silently falls backs to Debains's mirror otherwise
- Check the build directory's mount flags before a long build - `nodev` on an external/auto-mounted drive breaks chroot with confusing, unrelated-looking errors
- Never list a package in both `--linux-packages` and the package list manually - pick one, or you get duplicate/malformed entries
- Some `live-build` state files (like `packages.chroot`) are append-only across reruns - if a bad entry gets written once, delete the file and its `.build/` stage marker before rebuilding
- Keep ISO volume labels under 32 characters - set `--iso-volume` explicitly instead of trusting the auto-generated one
- Use `tmux` for any build expected to run longer than a few minutes - never `&` plus log redirection
- After any `lb clean`, rerun `lb config` again before `lb build` - cleaning wipes the stage tracker, including the config-done marker

## Skills Gained

- Configuring `live-build` for a non-standard/rolling-release distro base
- Diagnosing a filesystem mount flag as the root cause of dozens of seemingly unrelated package failures
- Reading `live-build`'s own shell scripts directly to trace a bug to its actual source instead of guessing
- Managing long-running builds safely across disconnects using `tmux`
- Understanding ISO 9660 constraints and hybrid (USB + optical) bootable images
- Distinguishing a stale cached state issue from a genuine config error when the same failure persists after a fix

## Environment Used

| Component | Detail |
|---|---|
| Host Machine | Kali Linux, run directly on host (VM was used only for O1; O2 and O3 both done on the host directly) |
| Build Drive | External HDD, ext4, mounted at `/mnt/games/cipher-linux/` |
| Base Distribution | `kali-rolling`, amd64 |
| Tooling | `live-build 20250814+kali3`, `debootstrap` |
| Output | `live-image-amd64.hybrid.iso` - 1.4GB, boot-tested in VirtualBox |
| Remote Repo | `github.com/sachin-linux/linux-admin-homelab` |
| Key Tools | `lb config`, `lb build`, `lb clean`, `mount`, `xorriso` | 


