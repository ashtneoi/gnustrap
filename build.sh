#!/usr/bin/env bash
set -eu

THREADS=3

build="$(realpath -m build)"
build2="$(realpath -m build2)"
build_root="$(realpath build-root)"
root="$(realpath -m root)"
root2="$(realpath -m root2)"

mkdir -p "$root/all"

# build-root build root proj src make_extra [config_option...]
build() {
    local build_root="$1"
    local build="$2"
    local root="$3"
    local proj="$4"
    local src="$5"
    local make_extra="$6" # watch out!
    shift 6

    mkdir -p "$build/$proj"
    cd "$build/$proj"
    export PATH="$build_root/$proj/bin:$root/all/bin:$build_root/all/bin"
    if ! [[ -e "$build/$proj.configure.stamp" ]]; then
        rm -f "$root/$proj.stamp"
        ../../$src/configure \
            --build="$arch_build" \
            --host="$arch_host" \
            --prefix="$root/all" \
            "$@"
        touch "$build/$proj.configure.stamp"
    fi
    if ! [[ -e "$root/$proj.stamp" ]]; then
        echo "### $proj ###"
        make -j $THREADS $make_extra
        make install $make_extra
        touch "$root/$proj.stamp"
    fi
}

mkdir -p "$root/all"
arch_build=x86_64-linux-gnu
arch_host=x86_64-linux-gnu
arch_target=$arch_host

build $build_root $build $root grep grep-3.1 ""
build $build_root $build $root make make-4.2 ""
build $build_root $build $root binutils binutils-2.31 "MAKEINFO=true" \
    --target=$arch_target --disable-multilib
build $build_root $build $root bash bash-4.4 ""
ln -fs bash $root/all/bin/sh
build $build_root $build $root gcc gcc-8.2.0 "" \
    --target=$arch_target --enable-languages=c,c++,lto --disable-multilib \
    --disable-bootstrap
build $build_root $build $root gawk gawk-4.2.1 ""
build $build_root $build $root m4 m4-1.4.18 ""
build $build_root $build $root bison bison-3.2 ""
build $build_root $build $root gzip gzip-1.9 ""
build $build_root $build $root glibc glibc-2.28 "" \
    --target=$arch_target --disable-multi-arch

mkdir -p "$root2/all"
arch_target=avr

build $build_root $build2 $root2 binutils binutils-2.31 "MAKEINFO=true" \
    --target=$arch_target --disable-multilib
build $build_root $build $root gcc gcc-8.2.0 "" \
    --target=$arch_target --enable-languages=c,c++,lto --disable-multilib \
    --disable-bootstrap
