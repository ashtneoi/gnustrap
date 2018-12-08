#!/usr/bin/env bash
set -eu

build_bash="$(realpath -m build/bash)"
build_root_bash="$(realpath build-root/bash)"
root_bash="$(realpath -m root/bash)"

mkdir -p "$build_bash"
mkdir -p "$root_bash"

# phase A

export PATH="$build_root_bash/bin"

cd "$build_bash"
if ! [[ -e Makefile ]]; then
    ../../bash-4.4/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --prefix="$root_bash"
fi
make
make install

#cd build-gcc
#../gcc-8.2.0/configure \
    #--build=x86_64-linux-gnu \
    #--host=x86_64-linux-gnu \
    #--target=x86_64-linux-gnu \
    #--enable-languages=c,lto \
    #--disable-multilib \
