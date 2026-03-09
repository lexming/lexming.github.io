---
date: 2025-07-07
tags:
  - rust
---
Rust is known for building static binaries. All dependencies (or [crates](https://doc.rust-lang.org/book/ch07-01-packages-and-crates.html)) of a the target software will be condensed into a single executable binary file. This is commonly the result of a `cargo install` command.

However, Rust can also generate libraries of course. Crates can result in Rust-specific libraries or C-compatible libraries, both dynamic and static. All these options serve as [linkage options between crates](https://doc.rust-lang.org/reference/linkage.html) and are defined by `crate_type` property. The most common one is the so-called _"Rust library"_ (`rlib`) which is a Rust-specific static library used as an intermediate object in the compilation process. Nonetheless, crates can also generate C-compatible dynamic libraries with the familiar shared object format (`.so`) in Linux.

The `cargo install` command does **not work with libraries** though. Nothing will be installed. We have to content ourselves with building those crates that generate libraries with `cargo` and then manually placing the resulting library files in their installation directory.
```bash
cargo build --profile=release
cp target/release/*.so /path/to/lib
```

Tests can be run for libraries as well. In that case we need to explicitly enable both `--tests` and `--lib` in the build command
```bash
cargo build --profile=release --tests --lib
cargo test --profile=release
cp target/release/*.so /path/to/lib
```

> [!example]
> EasyConfig for RDP: [easybuilders/easybuild-easyconfigs#23344](https://github.com/easybuilders/easybuild-easyconfigs/pull/23344)