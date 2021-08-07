# Microverse

[Microverse](https://rickandmorty.fandom.com/wiki/Microverse_Battery) is a thin virtualization app for macOS, which allows running Linux _(and, soon, macOS)_ guest virtual machines, achieved with [macOS' own virtualization framework](https://developer.apple.com/documentation/virtualization).

Note that this does not do any _emulation_—the virtual machines run on the same hardware as the host machine (and therefore have the same architecture). This is particularly useful to create sandbox environments with minimal performance impact.

## Requirements

This project makes use of APIs from the macOS 12 (Monterey) [beta](https://beta.apple.com/sp/betaprogram/). ARM and Intel Macs should both work.

macOS 11 (Big Sur) is unsupported.

<!--
## Running Linux

[`VZLinuxBootLoader`](https://developer.apple.com/documentation/virtualization/vzlinuxbootloader) is quite picky about its inputs. I had the best luck with [Ubuntu cloud images](https://cloud-images.ubuntu.com/), based on [this helpful comment by @droidix on `evansm7/vftool`](https://github.com/evansm7/vftool/issues/2#issuecomment-735455161).

The following examples assume arm64, but x86_64 should work similarly (presuming you get the correct downloads).

### Kernel

1. Download a `vmlinuz`, like https://cloud-images.ubuntu.com/releases/focal/release/unpacked/ubuntu-20.04-server-cloudimg-arm64-vmlinuz-generic
2. Add `.gz` to the extension of the downloaded file
3. Unpack with `gunzip` in the Terminal

### Initial RAM disk

The corresponding `initrd` can be used as-is: https://cloud-images.ubuntu.com/releases/focal/release/unpacked/ubuntu-20.04-server-cloudimg-arm64-initrd-generic

### Startup disk image

The startup image can be used as-is: https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-arm64.img
-->

## License and credit

Released under the [MIT license](LICENSE). [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm) is used as a dependency.

I'm indebted to @KhaosT' [MacVM](https://github.com/KhaosT/MacVM) and [SimpleVM](https://github.com/KhaosT/SimpleVM) projects for demonstrating [`Virtualization.framework`](https://developer.apple.com/documentation/virtualization) usage.
