#!/usr/bin/env bash
set -eu

# proj src make_extra [config_option...]
build() {
    local proj="$1"
    local src="$(realpath "$2")"
    local make_extra="$3" # watch out!
    shift 3

    p="$build_root/$proj/bin:$newpath"

    mkdir -p "$build/$proj"
    pushd "$build/$proj" >/dev/null
    if ! [[ -e "$build/$proj.configure.stamp" ]]; then
        rm -f "$root/$proj.stamp"
        PATH="$p" "$src/configure" \
            --build="$arch_build" \
            --host="$arch_host" \
            --prefix="$root/all" \
            "$@"
        touch "$build/$proj.configure.stamp"
    fi
    if ! [[ -e "$root/$proj.stamp" ]]; then
        echo "### $proj ###"
        PATH="$p" make -j $THREADS $make_extra
        PATH="$p" make install $make_extra
        touch "$root/$proj.stamp"
    fi
    popd >/dev/null
}

THREADS=3

build_root="$(realpath build-root)"

build="$(realpath -m build)"
root="$(realpath -m root)"
newpath="$root/all/bin:$build_root/all/bin"
arch_build=x86_64-linux-gnu
arch_host=x86_64-linux-gnu
arch_target=$arch_host

build grep grep-3.1 ""
build ncurses ncurses-6.1 "" \
    --with-shared --with-termlib
build make make-4.2.1 ""
build binutils binutils-2.32 "MAKEINFO=true" \
    --target=$arch_target --disable-multilib
build bash bash-4.4 ""
ln -fs bash $root/all/bin/sh
build gcc gcc-8.2.0 "" \
    --target=$arch_target --enable-languages=c,c++,lto --disable-multilib \
    --disable-bootstrap
build gawk gawk-4.2.1 ""
build m4 m4-1.4.18 ""
build bison bison-3.2 ""
build gzip gzip-1.9 ""
build glibc glibc-2.28 "" \
    --target=$arch_target --disable-multi-arch \
    --with-headers="$(realpath -m linux-5.0.2/include)" \
    --without-selinux
echo "PATH=\"$newpath\" \"\$@\"" >"$root/run" && chmod +x "$root/run"
