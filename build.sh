#!/usr/bin/env bash
set -eu

build_bash="$(realpath -m build/bash)"
build_root_bash="$(realpath build-root/bash)"
root_bash="$(realpath -m root/bash)"

mkdir -p "$build_bash"
mkdir -p "$root_bash"

build_binutils="$(realpath -m build/binutils)"
build_root_binutils="$(realpath build-root/binutils)"
root_binutils="$(realpath -m root/binutils)"

mkdir -p "$build_binutils"
mkdir -p "$root_binutils"

build_make="$(realpath -m build/make)"
build_root_make="$(realpath build-root/make)"
root_make="$(realpath -m root/make)"

mkdir -p "$build_make"
mkdir -p "$root_make"

# phase A

export PATH="$build_root_make/bin"

cd "$build_make"
if ! [[ -e Makefile ]]; then
    ../../make-4.2/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --prefix="$root_make"
fi
make
make install

exit # !!!

cd "$build_binutils"
if ! [[ -e Makefile ]]; then
    ../../binutils-2.31/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --target=x86_64-linux-gnu \
        --disable-multilib \
        --prefix="$root_binutils"
fi
make MAKEINFO=true
make install MAKEINFO=true

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
