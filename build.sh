#!/usr/bin/env bash
set -eu

# proj src make_extra [config_option...]
build() {
    local proj="$1"
    local src="$(realpath "$2")"
    local make_extra="$3" # watch out!
    shift 3

    mkdir -p "$build/$proj"
    pushd "$build/$proj" >/dev/null
    if ! [[ -e "$build/$proj.configure.stamp" ]]; then
        rm -f "$dest/$proj.stamp"
        PATH="$p" "$src/configure" \
            --build="$arch_build" \
            --host="$arch_host" \
            --prefix="$dest/all" \
            "$@"
        touch "$build/$proj.configure.stamp"
    fi
    if ! [[ -e "$dest/$proj.stamp" ]]; then
        echo "### $proj ###"
        PATH="$p" make -j $THREADS $make_extra
        PATH="$p" make install $make_extra
        touch "$dest/$proj.stamp"
    fi
    popd >/dev/null
}

THREADS=3

ext_bin="$(realpath ext-bin)"

build="$(realpath -m build)"
dest="$(realpath -m root)"
p="$ext_bin"
arch_build=x86_64-linux-gnu
arch_host=x86_64-linux-gnu
arch_target=$arch_host

# stuff needed in ext_bin:
# `busybox --install [-s] .`
# cc as ld
# make
# ar
# strip

build bash bash-4.4 "" \
    && ln -fs bash $root/all/bin/sh
build binutils binutils-2.32 "MAKEINFO=true" \
    --target=$arch_target --disable-multilib
build bison bison-3.2 ""
build gawk gawk-4.2.1 ""
build gcc gcc-8.2.0 "" \
    --target=$arch_target --enable-languages=c,c++,lto --disable-multilib \
    --disable-bootstrap
build glibc glibc-2.28 "" \
    --target=$arch_target --disable-multi-arch \
    --with-headers="$(realpath -m linux-5.0.2/include)" \
    --without-selinux
build grep grep-3.1 ""
build gzip gzip-1.9 ""
build m4 m4-1.4.18 ""
build make make-4.2.1 ""
build ncurses ncurses-6.1 "" \
    --with-shared --with-termlib
