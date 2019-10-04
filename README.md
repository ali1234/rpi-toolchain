# rpi-toolchain

A gcc cross toolchain for all Raspberry Pi models with multiarch support.

This toolchain is built with crosstool-ng. It includes the Debian specific
patch for multiarch support in binutils.

To build it, clone the repository and run `make` or `make indocker` to
run the build inside Docker. Check the Dockerfile to see the dependencies
for a local build. To build from the release source, untar them inside
the `src` directory.

