#!/usr/bin/env bash
set -eu

THREADS=3

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

mkdir -p "$build/gcc"
mkdir -p "$root/gcc"

cd "$build/grep"
export PATH="$build_root/grep/bin:$build_root/all/bin"
if ! [[ -e Makefile ]]; then
    ../../grep-3.1/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --prefix="$root/grep"
fi
make -j $THREADS
make install
prevroot="$root/grep/bin"

cd "$build/make"
export PATH="$build_root/make/bin:$prevroot:$build_root/all/bin"
if ! [[ -e Makefile ]]; then
    ../../make-4.2/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --prefix="$root/make"
fi
make -j $THREADS
make install
prevroot="$prevroot:$root/make/bin"

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
make -j $THREADS MAKEINFO=true
make install MAKEINFO=true
prevroot="$prevroot:$root/binutils/bin:$root/binutils/x86_64-linux-gnu/bin"

cd "$build/bash"
export PATH="$build_root/bash/bin:$prevroot:$build_root/all/bin"
if ! [[ -e Makefile ]]; then
    ../../bash-4.4/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --prefix="$root/bash"
fi
make -j $THREADS
make install
cd "$root/bash/bin"
ln -fs bash sh
prevroot="$prevroot:$root/bash/bin"

cd "$build/gcc"
export PATH="$build_root/gcc/bin:$prevroot:$build_root/all/bin"
if ! [[ -e Makefile ]]; then
    ../../gcc-8.2.0/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --target=x86_64-linux-gnu \
        --enable-languages=c,c++,lto \
        --disable-multilib \
        --disable-bootstrap \
        --prefix="$root/bash"
fi
make -j $THREADS
make install
