# Microverse

[Microverse](https://rickandmorty.fandom.com/wiki/Microverse_Battery) is a thin virtualization app for running macOS guest virtual machines on M1/Apple Silicon (arm64) processors, achieved with [Apple's `Virtualization.framework`](https://developer.apple.com/documentation/virtualization).

Note that this does not do any _emulation_—the virtual machines run on the same hardware as the host machine (and therefore have the same architecture). This is particularly useful to create sandbox environments with minimal performance impact.

## Requirements

This project makes use of APIs from the macOS 12 (Monterey) [beta](https://beta.apple.com/sp/betaprogram/).

macOS 11 (Big Sur) is unsupported.

## Known limitations

For installing into the VM, only [macOS 12 (Monterey) ipsw files](https://mrmacintosh.com/apple-silicon-m1-full-macos-restore-ipsw-firmware-files-database/) are known to work.

There's a known issue where the App Store cannot be contacted from within a VM. Any applications you want to run will need to be downloaded from the web, or imported into the VM using a disk image in UDRW format (see `man hdiutil` for details).

For other known issues, please see the [GitHub issues list](https://github.com/jspahrsummers/Microverse/issues).

## License and credit

Released under the [MIT license](LICENSE). [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm) is used as a dependency.

I'm indebted to @KhaosT' [MacVM](https://github.com/KhaosT/MacVM) and [SimpleVM](https://github.com/KhaosT/SimpleVM) projects for demonstrating [`Virtualization.framework`](https://developer.apple.com/documentation/virtualization) usage.
