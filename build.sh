#!/usr/bin/env bash
set -eu

THREADS=3

build="$(realpath -m build)"
build_root="$(realpath build-root)"
root="$(realpath -m root)"

mkdir -p "$build/grep"
mkdir -p "$root/grep"
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
    echo "### grep ###"
    make -j $THREADS
    make install
    touch "$root/grep.stamp"
fi
prevroot="$root/grep/bin"

mkdir -p "$build/make"
mkdir -p "$root/make"
cd "$build/make"
export PATH="$build_root/make/bin:$prevroot:$build_root/all/bin"
if ! [[ -e "$build/make.configure.stamp" ]]; then
    echo "### make ###"
    rm -f "$root/make.stamp"
    ../../make-4.2/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --prefix="$root/make"
    touch "$build/make.configure.stamp"
fi
if ! [[ -e "$root/make.stamp" ]]; then
    echo "### make ###"
    make -j $THREADS
    make install
    touch "$root/make.stamp"
fi
prevroot="$root/make/bin:$prevroot"

mkdir -p "$build/binutils"
mkdir -p "$root/binutils"
cd "$build/binutils"
export PATH="$build_root/binutils/bin:$prevroot:$build_root/all/bin"
if ! [[ -e "$build/binutils.configure.stamp" ]]; then
    echo "### binutils ###"
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
    echo "### binutils ###"
    make -j $THREADS MAKEINFO=true
    make install MAKEINFO=true
    touch "$root/binutils.stamp"
fi
prevroot="$root/binutils/bin:$root/binutils/x86_64-linux-gnu/bin:$prevroot"

mkdir -p "$build/bash"
mkdir -p "$root/bash"
cd "$build/bash"
export PATH="$build_root/bash/bin:$prevroot:$build_root/all/bin"
if ! [[ -e "$build/bash.configure.stamp" ]]; then
    echo "### bash ###"
    rm -f "$root/bash.stamp"
    ../../bash-4.4/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --prefix="$root/bash"
    touch "$build/bash.configure.stamp"
fi
if ! [[ -e "$root/bash.stamp" ]]; then
    echo "### bash ###"
    make -j $THREADS
    make install
    cd "$root/bash/bin"
    ln -fs bash sh
    touch "$root/bash.stamp"
fi
prevroot="$root/bash/bin:$prevroot"

mkdir -p "$build/gcc"
mkdir -p "$root/gcc"
cd "$build/gcc"
export PATH="$build_root/gcc/bin:$prevroot:$build_root/all/bin"
if ! [[ -e "$build/gcc.configure.stamp" ]]; then
    echo "### gcc ###"
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
    echo "### gcc ###"
    make -j $THREADS
    make install
    touch "$root/gcc.stamp"
fi
prevroot="$root/gcc/bin:$prevroot"

mkdir -p "$build/gawk"
mkdir -p "$root/gawk"
cd "$build/gawk"
export PATH="$build_root/gawk/bin:$prevroot:$build_root/all/bin"
if ! [[ -e "$build/gawk.configure.stamp" ]]; then
    echo "### gawk ###"
    rm -f "$root/gawk.stamp"
    ../../gawk-4.2.1/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --prefix="$root/gawk"
    touch "$build/gawk.configure.stamp"
fi
if ! [[ -e "$root/gawk.stamp" ]]; then
    echo "### gawk ###"
    make -j $THREADS
    make install
    touch "$root/gawk.stamp"
fi
prevroot="$root/gawk/bin:$prevroot"

mkdir -p "$build/m4"
mkdir -p "$root/m4"
cd "$build/m4"
export PATH="$build_root/m4/bin:$prevroot:$build_root/all/bin"
if ! [[ -e "$build/m4.configure.stamp" ]]; then
    echo "### m4 ###"
    rm -f "$root/m4.stamp"
    ../../m4-1.4.18/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --prefix="$root/m4"
    touch "$build/m4.configure.stamp"
fi
if ! [[ -e "$root/m4.stamp" ]]; then
    echo "### m4 ###"
    make -j $THREADS
    make install
    touch "$root/m4.stamp"
fi
prevroot="$root/m4/bin:$prevroot"

mkdir -p "$build/bison"
mkdir -p "$root/bison"
cd "$build/bison"
export PATH="$build_root/bison/bin:$prevroot:$build_root/all/bin"
if ! [[ -e "$build/bison.configure.stamp" ]]; then
    echo "### bison ###"
    rm -f "$root/bison.stamp"
    ../../bison-3.2/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --prefix="$root/bison"
    touch "$build/bison.configure.stamp"
fi
if ! [[ -e "$root/bison.stamp" ]]; then
    echo "### bison ###"
    make -j $THREADS
    make install
    touch "$root/bison.stamp"
fi
prevroot="$root/bison/bin:$prevroot"

mkdir -p "$build/gzip"
mkdir -p "$root/gzip"
cd "$build/gzip"
export PATH="$build_root/gzip/bin:$prevroot:$build_root/all/bin"
if ! [[ -e "$build/gzip.configure.stamp" ]]; then
    echo "### gzip ###"
    rm -f "$root/gzip.stamp"
    ../../gzip-1.9/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --prefix="$root/gzip"
    touch "$build/gzip.configure.stamp"
fi
if ! [[ -e "$root/gzip.stamp" ]]; then
    echo "### gzip ###"
    make -j $THREADS
    make install
    touch "$root/gzip.stamp"
fi
prevroot="$root/gzip/bin:$prevroot"

mkdir -p "$build/glibc"
mkdir -p "$root/glibc"
cd "$build/glibc"
export PATH="$build_root/glibc/bin:$prevroot:$build_root/all/bin"
if ! [[ -e "$build/glibc.configure.stamp" ]]; then
    echo "### glibc ###"
    rm -f "$root/glibc.stamp"
    ../../glibc-2.28/configure \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --prefix="$root/glibc"
    touch "$build/glibc.configure.stamp"
fi
if ! [[ -e "$root/glibc.stamp" ]]; then
    echo "### glibc ###"
    make -j $THREADS
    make install
    touch "$root/glibc.stamp"
fi
prevroot="$root/glibc/bin:$prevroot"
