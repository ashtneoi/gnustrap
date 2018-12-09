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
if ! [[ -e "$build/grep.configure.stamp" ]]; then
    rm -f "$root/make.stamp"
    ../../grep-3.1/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --prefix="$root/grep"
    touch "$build/grep.configure.stamp"
fi
if ! [[ -e "$root/grep.stamp" ]]; then
    make -j $THREADS
    make install
    touch "$root/grep.stamp"
fi
prevroot="$root/grep/bin"

cd "$build/make"
export PATH="$build_root/make/bin:$prevroot:$build_root/all/bin"
if ! [[ -e "$build/make.configure.stamp" ]]; then
    rm -f "$root/make.stamp"
    ../../make-4.2/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --prefix="$root/make"
    touch "$build/make.configure.stamp"
fi
if ! [[ -e "$root/make.stamp" ]]; then
    make -j $THREADS
    make install
    touch "$root/make.stamp"
fi
prevroot="$prevroot:$root/make/bin"

cd "$build/binutils"
export PATH="$build_root/binutils/bin:$prevroot:$build_root/all/bin"
if ! [[ -e "$build/binutils.configure.stamp" ]]; then
    rm -f "$root/binutils.stamp"
    ../../binutils-2.31/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --target=x86_64-linux-gnu \
        --disable-multilib \
        --prefix="$root/binutils"
    touch "$build/binutils.configure.stamp"
fi
if ! [[ -e "$root/binutils.stamp" ]]; then
    make -j $THREADS MAKEINFO=true
    make install MAKEINFO=true
    touch "$root/binutils.stamp"
fi
prevroot="$prevroot:$root/binutils/bin:$root/binutils/x86_64-linux-gnu/bin"

cd "$build/bash"
export PATH="$build_root/bash/bin:$prevroot:$build_root/all/bin"
if ! [[ -e "$build/bash.configure.stamp" ]]; then
    rm -f "$root/bash.stamp"
    ../../bash-4.4/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --prefix="$root/bash"
    touch "$build/bash.configure.stamp"
fi
if ! [[ -e "$root/bash.stamp" ]]; then
    make -j $THREADS
    make install
    cd "$root/bash/bin"
    ln -fs bash sh
    touch "$root/bash.stamp"
fi
prevroot="$prevroot:$root/bash/bin"

cd "$build/gcc"
export PATH="$build_root/gcc/bin:$prevroot:$build_root/all/bin"
if ! [[ -e "$build/gcc.configure.stamp" ]]; then
    rm -f "$root/gcc.stamp"
    ../../gcc-8.2.0/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --target=x86_64-linux-gnu \
        --enable-languages=c,c++,lto \
        --disable-multilib \
        --disable-bootstrap \
        --prefix="$root/gcc"
    touch "$build/gcc.configure.stamp"
fi
if ! [[ -e "$root/gcc.stamp" ]]; then
    make -j $THREADS
    make install
    touch "$root/gcc.stamp"
fi

# then glibc, then everything again except into a common root
