# Microverse

[Microverse](https://rickandmorty.fandom.com/wiki/Microverse_Battery) is a thin virtualization app for macOS, which allows running Linux _(and, soon, macOS)_ guest virtual machines, achieved with [macOS' own virtualization framework](https://developer.apple.com/documentation/virtualization).

Note that this does not do any _emulation_—the virtual machines run on the same hardware as the host machine (and therefore have the same architecture). This is particularly useful to create sandbox environments with minimal performance impact.

## Requirements

This project makes use of APIs from the macOS 12 (Monterey) [beta](https://beta.apple.com/sp/betaprogram/). macOS 11 (Big Sur) is unsupported.

## License and credit

Released under the [MIT license](LICENSE). [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm) is used as a dependency.

I'm indebted to @KhaosT' [MacVM](https://github.com/KhaosT/MacVM) and [SimpleVM](https://github.com/KhaosT/SimpleVM) projects for demonstrating [`Virtualization.framework`](https://developer.apple.com/documentation/virtualization) usage.
