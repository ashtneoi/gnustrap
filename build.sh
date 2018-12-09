#!/usr/bin/env bash
set -eu

build="$(realpath -m build)"
build_root="$(realpath build-root)"
root="$(realpath -m root)"

mkdir -p "$build/grep"
mkdir -p "$root/grep"

mkdir -p "$build/bash"
mkdir -p "$root/bash"

mkdir -p "$build/binutils"
mkdir -p "$root/binutils"

mkdir -p "$build/make"
mkdir -p "$root/make"

# phase A

cd "$build/grep"
export PATH="$build_root/grep/bin:$build_root/all/bin"
if ! [[ -e Makefile ]]; then
    ../../grep-3.1/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --prefix="$root/grep"
fi
make
make install

# phase B

prevroot="$root/grep/bin"

cd "$build/make"
export PATH="$build_root/make/bin:$prevroot:$build_root/all/bin"
if ! [[ -e Makefile ]]; then
    ../../make-4.2/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --prefix="$root/make"
fi
make
make install

# phase C

prevroot="$root/grep/bin:$root/make/bin"

cd "$build/binutils"
export PATH="$build_root/binutils/bin:$prevroot:$build_root/all/bin"
if ! [[ -e Makefile ]]; then
    ../../binutils-2.31/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --target=x86_64-linux-gnu \
        --disable-multilib \
        --prefix="$root/binutils"
fi
make MAKEINFO=true
make install MAKEINFO=true

cd "$build/bash"
export PATH="$build_root/bash/bin:$prevroot:$build_root/all/bin"
if ! [[ -e Makefile ]]; then
    ../../bash-4.4/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --prefix="$root/bash"
fi
make
make install

#../gcc-8.2.0/configure \
    #--build=x86_64-linux-gnu \
    #--host=x86_64-linux-gnu \
    #--target=x86_64-linux-gnu \
    #--enable-languages=c,lto \
    #--disable-multilib \
