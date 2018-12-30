# rpi-toolchain

A gcc cross toolchain for all Raspberry Pi models with multiarch support.

Linaro toolchains are built using a tool called ABE. This is similar to
crosstool-ng. After building it produces a manifest which can be used to
reproduce the build.

This toolchain is built by taking the Linaro release manifest and modifying
the compiler configuration to produce armv6 compatible binaries which can
run on all models of Raspberry Pi.

The changes required for this are very small. In the manifest, only the
variables `gcc_stage1_flags` and `gcc_stage2_flags` are modified.

The flags:

    --with-fpu=vfpv3-d16 --with-mode=thumb --with-tune=cortex-a9 --with-arch=armv7-a

are replaced by:

    --with-fpu=vfp --with-arch=armv6
