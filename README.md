# Microverse

[Microverse](https://rickandmorty.fandom.com/wiki/Microverse_Battery) is a thin virtualization app for macOS, which allows running Linux and macOS* guest virtual machines, achieved with [Apple's `Virtualization.framework`](https://developer.apple.com/documentation/virtualization).

Note that this does not do any _emulation_—the virtual machines run on the same hardware as the host machine (and therefore have the same architecture). This is particularly useful to create sandbox environments with minimal performance impact.

_* Note that macOS is only supported as a guest VM on arm64 processors. This is a limitation of the virtualization framework._

## Requirements

This project makes use of APIs from the macOS 12 (Monterey) [beta](https://beta.apple.com/sp/betaprogram/).

macOS 11 (Big Sur) is unsupported.

## macOS

macOS is supported as a guest OS **on arm64 only**. Only [macOS 12 (Monterey) ipsw files](https://mrmacintosh.com/apple-silicon-m1-full-macos-restore-ipsw-firmware-files-database/) are known to work.

There's a known issue where the App Store cannot be contacted from within a VM. Any applications you want to run will need to be downloaded from the web, or imported into the VM using a disk image in UDRW format (see `man hdiutil` for details).

## Linux

[`VZLinuxBootLoader`](https://developer.apple.com/documentation/virtualization/vzlinuxbootloader) is quite picky about its inputs. I had the best luck with [Ubuntu cloud images](https://cloud-images.ubuntu.com/), based on [this helpful comment by @droidix on `evansm7/vftool`](https://github.com/evansm7/vftool/issues/2#issuecomment-735455161).

The following examples assume arm64, but x86_64 should work similarly (presuming you get the correct downloads).

### Kernel

1. Download a `vmlinuz`, like https://cloud-images.ubuntu.com/releases/focal/release/unpacked/ubuntu-20.04-server-cloudimg-arm64-vmlinuz-generic
2. Add `.gz` to the extension of the downloaded file
3. Unpack with `gunzip` in the Terminal

### Initial RAM disk

The corresponding `initrd` can be used as-is: https://cloud-images.ubuntu.com/releases/focal/release/unpacked/ubuntu-20.04-server-cloudimg-arm64-initrd-generic

### Attached disk

The startup disk image can be used as-is: https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-arm64.img

## License and credit

Released under the [MIT license](LICENSE).

I'm indebted to @KhaosT' [MacVM](https://github.com/KhaosT/MacVM) and [SimpleVM](https://github.com/KhaosT/SimpleVM) projects for demonstrating [`Virtualization.framework`](https://developer.apple.com/documentation/virtualization) usage.
