# Zig, C/C++ Compilation Utility Functions

## Introduction
`ccpputilz` is a lightweight utility library to help with building C/C++ projects utilizing Zig's built-in buildsystem. Zig provides a zero-dependency, drop-in C/C++ compiler, making cross-compilation of C/C++ projects much easier than having to vendor build tools manually. This library levels up Zig's support for C/C++ compilation and focuses on unifying the build process with quality of life features.

For more information about the Zig programming language, you can visit the [Official Zig langugage website](https://ziglang.org/). For a full documentation of Zig's built-in build system and other functionality of the standard library.

## License
`ccpputilz` is distributed under the very permissive MIT license. See [LICENSE.md](LICENSE.md) for details.

## Features
The library contains three types of modules, `internal`, `builtin`, and `extensions`. 

## Installation and Basic Usage
Installation is trivial when using the `zig fetch` command.

```bash
zig fetch git+https://github.com/anthony-j-g/ccpputilz.git
```
Once installed, using functions in the library is as simple as importing them into your `build.zig` script. Here is a snipped of a modified version of the build script that results from running `zig init` for a new project except with the `*.zig` files replaced with `*.cpp` files. For the full example see [this build script](examples/zig-init-c/build.zig) or the [example overview](examples/zig-init-c/README.md).

```rust
// ... Other Imports here
const ccpputilz = @import("ccpputilz");

fn build(b: *std.Build) {

}
```

For more granularity in fetching the library, you can modify the `zig fetch` command in one of the following ways:

```bash
zig fetch --save=<alias> git+https://github.com/anthony-j-g/ccpputilz.git
```

```bash
zig fetch git+https://github.com/anthony-j-g/ccpputilz#<branch name>
```

```bash
zig fetch git+https://github.com/anthony-j-g/ccpputilz#<commit SHA256 hash>
```


