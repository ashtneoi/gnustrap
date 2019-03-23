#!/usr/bin/env bash
set -eu

# proj src make_extra [config_option...]
build() {
    local proj="$1"
    local src="$(realpath "src/$2")"
    local make_extra="$3" # watch out!
    shift 3

    mkdir -p "$build/$proj"
    pushd "$build/$proj" >/dev/null
    if ! [[ -e "$build/$proj.configure.stamp" ]]; then
        echo "### $proj ###"
        rm -f "$dest/$proj.stamp"
        PATH="$p" "$src/configure" \
            --build="$arch_build" \
            --host="$arch_host" \
            --prefix="$dest/root" \
            "$@"
        touch "$build/$proj.configure.stamp"
    fi
    if ! [[ -e "$dest/$proj.stamp" ]]; then
        echo "### $proj ###"
        if [[ "$proj" == make ]]; then
            PATH="$p" sh build.sh
            PATH="$p" ./make -j $THREADS $make_extra
            PATH="$p" ./make install $make_extra
        else
            PATH="$p" make -j $THREADS $make_extra
            PATH="$p" make install $make_extra
        fi
        touch "$dest/$proj.stamp"
    fi
    popd >/dev/null
}

THREADS=3

ext_bin="$(realpath ext-bin)"

# Stage 1

p="$ext_bin"

build="$(realpath -m build/1)"
dest="$(realpath -m dest/1)"
arch_build=x86_64-linux-gnu
arch_host=x86_64-linux-gnu
arch_target=$arch_host

build make make-4.2.1 ""

# Stage 2

p="$p:$dest/root/bin"

build="$(realpath -m build/2)"
dest="$(realpath -m dest/2)"
arch_build=x86_64-linux-gnu
arch_host=x86_64-linux-gnu
arch_target=$arch_host

build gawk gawk-4.2.1 ""
build m4 m4-1.4.18 ""

# Stage 3

p="$p:$dest/root/bin"

build="$(realpath -m build/3)"
dest="$(realpath -m dest/3)"
arch_build=x86_64-linux-gnu
arch_host=x86_64-linux-gnu
arch_target=$arch_host

build m4 m4-1.4.18 ""
build bash bash-4.4 "" \
    && ln -fs bash $dest/root/bin/sh
build binutils binutils-2.32 "MAKEINFO=true" \
    --target=$arch_target --disable-multilib
build gcc gcc-8.2.0 "" \
    --target=$arch_target --enable-languages=c,c++,lto --disable-multilib \
    --disable-bootstrap
# glibc wants gawk and bison
build glibc glibc-2.28 "" \
    --target=$arch_target --disable-multi-arch \
    --with-headers="$(realpath -m linux-5.0.2/include)" \
    --without-selinux
build grep grep-3.1 ""
build gzip gzip-1.9 ""
build ncurses ncurses-6.1 "" \
    --with-shared --with-termlib

# Stage 3

p="$p:$dest/root/bin"

build="$(realpath -m build3)"
dest="$(realpath -m dest3)"
arch_build=x86_64-linux-gnu
arch_host=x86_64-linux-gnu
arch_target=$arch_host

# bison wants m4
build bison bison-3.2 ""

# stuff needed in ext_bin:
# `busybox --install [-s] .`
# cc (gcc)
# c++ (gcc)
# as (binutils)
# ld (binutils)
# ar (binutils)
# strip (binutils)
