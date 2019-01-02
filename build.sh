#!/bin/sh -e

VERSION=$(git describe --always --dirty)

rm -rf _build/builds _build/sysroots _build/Makefile _build/config.log _build/config.status _build/host.conf
rm -rf _build/snapshots/*arm-linux-gnueabihf.tar.xz*
mkdir _build
cd _build
../abe/configure

../abe/abe.sh --manifest ../gcc-linaro-6.4.1-2018.05+rpi-linux-manifest.txt \
    --release 2018.05+rpi$VERSION --build all --tarbin
