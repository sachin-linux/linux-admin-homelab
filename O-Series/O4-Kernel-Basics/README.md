# O4 - Kernel Basics

### What is the Kernel?

The kernel is the core of Linux sitting directly between hardware and every program that runs on top of it. It handles process scheduling, memory allocation, device/driver management, and system calls - the interface every piece of userspace software (shell, desktop environment, apt, browsers? goes through to actually talk to hardware. It lives on disk as a compiled image (`vmlinux`) plus a seperate tree of loaded modules, and it's what GRUB hands off to at the end of the boot process covered in O1

### Why it Matters?

- **Troubleshooting** - Hardware not detected, a driver not loading, a device behaving oddly - all of it traces to the kernel and module layer, not the application layer
- **Distro building** - CIPHER Linux's hardware compatibility (WiFi, GPU, USB) depends entirely on which kernel version and modules ship by default
- **Recovery skills** - Knowing the difference between "hardware is dead" and "driver just isn't loaded" turns a multi-hour debugging session into a two-command check 
- **Interview relevance** - `lsmod`, `modprobe`, `dmesg`, and kernel versioning are standard Linux Admin/SysAdmin interview topics, especially around driver and hardware issues\

### Key Concepts

| Term | Meaning |
|---|---|
| Kernel | Core program managing hardware, processes, memory, and system calls - everything else runs on top of it |
| vmlinuz | The compiled kernel binary, stored in `/boot`, loaded directly by GRUB |
| initrd.ing | Temporary in_RAM filesystem used before the real root mounts - paired per-kernel-version, same as covered in O1 | 
| Kernel module | A driver or feature loaded into the kernel on demand, instead of being built permanently into the kernel image | 
| Lsmod | Lists modules currently loaded into the running kernel | 
| modprobe | Loads a module plus its dependencies into the running kernel |
| modprobe -r | Unloads a module - risky on a live host if the module is tied to active hardware (GPU, storage, network) | 
| dmesg | The kernel's own log - real-time record of hardware detection, driver load attempts, and errors | 
| vermaic | A compatibility fingerprint on each module tying it to one exact kernel build - prevents loading a mismatched module | 
| uname -r | Shows the exact kernel version currently running | 

### Core Commands

```bash 
# identify running kernel 
uname -r	# exact kernel version currently running
ls -lh /boot/	   # list installed kernels + matching initrd images

# Module inspection
lsmod		# list currently loaded modules 
modinfo <module> 	# module details - author, deps, vermagic

# Module load/unload
sudo modprobe <module> 		# load a module + its dependencies
sudo modprobe -r <module>	# unload a module

# Kernel log
dmesg | tail -50	# recent kernel log - hardware/driver events
dmesg -w	   # watch kernel log live
```

### Scenarios Practised

## Scenario 1 - Identifying the Running Kernel

- **Problem:** Need to confirm exactly which kernel is active before doing any module work, since modules are version-specific.
- **Investigate:** Ran `uname -r` - result was `7.0.12+kali-amd64`. Cross-checked against `/boot` and found three complete kernel sets installed (`6.19.11`, `6.19.14`, `7.0.12`).
- **Fix:** No fix needed - observation exercise.
- **Key Lesson:** Old kernels aren't deleted on update, they're kept alongside the new one - same rollback safety net pattern as GRUB's multiple boot entries from O1.

## Scenario 2 - Reading Loaded Modules and Dependencies

- **Problem:** Need to see what's actually loaded into the running kernel right now, and understand module interdependency.
- **Investigate:** Ran `lsmod` - found modules like `bridge` with `stp` and `lic` lised as dependents underneath in the "Used by" column.
- **Fix:** No fix needed - observation exercise.
- **Key Lesson:** "Used by" isn't just informational - it's a dependency lock. A module can't be unloaded while other loaded moudles still depend on it.

## Scenario 3 - Module Detail and Version Compatibility

- **Problem:** Need to confirm a module is actually compatible with the running kernel before trusting it to load correctly.
- **Investigate:** Ran `modinfo nf_tables` - found `vermagic: 7.0.12+kali-amd64`, matching the output of `uname -r` exactly.
- **Fix:** No fix needed - observation exercise.
- **Key Lesson:** vermagic is the kernel's own compatibility check - a module built against one kernel version can reference internals that don't exist in another, so the kernel refuses a mismatch rather than risk a crash.

## Scenario 4 - Kernel Log as a Hardware Diagnostic

- **Problem:** Need a way to tell "hardware not detected" apart from "hardware detected but driver not loaded" without guessing.
- **Investigate:** Ran `dmesg | tail -50` and `dmesg -w` while attaching/detaching a USB device, watching the kernel log the event live.
- **Fix:** No fix needed - observation exercise.
- **Key Lesson:** This is the exact diagnostic that would've saved time on the RTL8821CE WiFi failure- `dmesg` shows definitively whether the kernel ever saw the hardware at all, before touching drivers.

## Scenario 5 - Capstone: Live Module Load and Unload

- **Problem:** Need to prove a module can be loaded and removed from a running kernel without a reboot, and confirm nothing else breaks.
- **Investigate:** Ran `sudo modprobe dummy`, confirmed via `lsmod | grep dummy` that it loaded. Ran `sudo modprobe -r dummy`, confirmed via `lsmod` that it was gone. Noted `snd_seq_dummy` and `snd_seq` remained loaded throughout - a seperate, pre-existing auto module unrelated to the test.
- **Fix:** No fix needed - test module chosen specifically because it's safe to load/unload on a live boot.
- **Key Lesson:** This is the real fix path for a "driver just isn't loaded" hardware issue- `modprobe` on a live system, no reboot required. Also a reminder to read `lsmod` output carefully rather than skimming, since unrelated modules can look similar at a glance.


### Golden Rules

- Always check `dmesg` before `lsmod` when hardware isn't working- `dmesg` tells you if the kernel even saw the hardware
- Never assume a module load failure is a driver bug before checking `vermagic` /kernel version match first
- `modprobe -r` is a safe on a disposable VM, but never unload an unrecognized module tied to active hardware on a live host
- Kernel and module versions are paired the same way kernel and initramfs are paired (O1) - never mix versions
- Old kernels in `/boot` are a safety net, not clutter - leave them unless disk space is a genuine constraint


### SKills Gained

- Identifying the exact running kernel version and matching it against installed modules
- Reading `lsmod` output for real dependency relationships, not just a flat list
- Using `vermagic` to understand why a module can fail to load even when the file itself is fine
- Diagnosing hardware issues via `dmesg` before jumping to driver-level-fixes
- Loading and unloading kernel modules live on a running system, safely, without a reboot


### Environment Used

| Component | Detail |
|---|---|
| Host Machine | Kali Linux | 
| Kernel | `7.0.12+kali-amd64` (latest of 3 installed kernel sets) |
| Key tools | `uname`, `lsmod`, `modinfo`, `dmesg`
| Test Module Used | `dummy` (safe load/unload test module) | 
| Remote Repo | github.com\sachin-linux/linux-admin-homelab |
