#!/usr/bin/env bash
set -eu


place="${1-}"
if [[ "$place" != in && "$place" != out ]]; then
    echo >&2 "usage: $0 in|out"
    exit
fi


# proj src make_extra [config_option...]
build() {
    local proj="$1"
    local src="$(realpath "src/$2")"
    local make_extra="$3" # watch out!
    shift 3

    prefix=
    destdir="$dest/root"
    if [[ "$place" == out ]]; then
        prefix="$dest/root"
        destdir=
    fi

    build="$(realpath -m build-$place/$n)"
    dest="$(realpath -m dest-$place/$n)"

    mkdir -p "$build/$proj"
    pushd "$build/$proj" >/dev/null
    if ! [[ -e "$build/$proj.configure.stamp" ]]; then
        echo "### $proj ###"
        rm -f "$dest/$proj.stamp"
        PATH="$p" "$src/configure" \
            --build="$arch_build" \
            --host="$arch_host" \
            --prefix="$prefix" \
            --exec-prefix="$prefix/arch" \
            "$@"
        touch "$build/$proj.configure.stamp"
    fi
    if ! [[ -e "$dest/$proj.stamp" ]]; then
        echo "### $proj ###"
        if [[ "$proj" == make ]]; then
            PATH="$p" sh build.sh
            PATH="$p" ./make -j $THREADS $make_extra
            PATH="$p" ./make install DESTDIR="$destdir" $make_extra
        else
            PATH="$p" make -j $THREADS $make_extra
            PATH="$p" make install DESTDIR="$destdir" $make_extra
        fi
        touch "$dest/$proj.stamp"
    fi
    popd >/dev/null
}

THREADS=3
#CHROOT="unshare -Ur chroot"

ext_bin="$(realpath ext-bin)"
prefix=

# Stage 1
n=1

p="$ext_bin"

dest="$(realpath -m dest-$place/$n)"
arch_build=x86_64-linux-gnu
arch_host=x86_64-linux-gnu
arch_target=$arch_host

build make make-4.2.1 ""

# Stage 2
n=2

p="$p:$(realpath -m dest-out/1/root/arch/bin)"

dest="$(realpath -m dest-$place/$n)"
arch_build=x86_64-linux-gnu
arch_host=x86_64-linux-gnu
arch_target=$arch_host

# gawk and m4 want make
build gawk gawk-4.2.1 ""
build m4 m4-1.4.18 ""

# Stage 3
n=3

p="$p:$(realpath -m dest-out/2/root/arch/bin)"

dest="$(realpath -m dest-$place/$n)"
arch_build=x86_64-linux-gnu
arch_host=x86_64-linux-gnu
arch_target=$arch_host

# bison wants m4
build bison bison-3.2 ""

# Stage 4
n=4

p="$p:$(realpath -m dest-out/3/root/arch/bin)"

dest="$(realpath -m dest-$place/$n)"
arch_build=x86_64-linux-gnu
arch_host=x86_64-linux-gnu
arch_target=$arch_host

build bash bash-4.4 "" \
    && ln -fs bash $dest/root/arch/bin/sh
build binutils binutils-2.32 "MAKEINFO=true" \
    --target=$arch_target --disable-multilib
build gcc gcc-8.2.0 "" \
    --target=$arch_target --enable-languages=c,c++,lto --disable-multilib \
    --disable-bootstrap
# glibc wants bison
build glibc glibc-2.28 "" \
    --target=$arch_target --disable-multi-arch \
    --with-headers="$(realpath -m src/linux-5.0.2/include)" \
    --without-selinux
build grep grep-3.1 ""
build gzip gzip-1.9 ""
build ncurses ncurses-6.1 "" \
    --with-shared --with-termlib

# Stage 5
n=5

dest="$(realpath -m dest-$place/$n)"
arch_build=x86_64-linux-gnu
arch_host=x86_64-linux-gnu
arch_target=$arch_host

#p="$dest/root/arch/bin"

if ! [[ -e "$dest/stamp" ]]; then
    echo "Combining roots..."
    mkdir -p "$dest/root"
    for i in $(seq 1 $(($n-1))); do
        cp -fr "dest-$place/$i/root/"* "$dest/root/"
    done
    touch "$dest/stamp"
fi

if [[ "$place" == out ]]; then
    "$0" 'in'
fi

#gcc_path="$dest/root/arch/bin/gcc"
#interp="$(readelf "$gcc_path" -p.interp -W | sed -nr 's/[^]]+\]\s*(.*)$/\1/p')"
#mkdir -p "$(dirname "$dest/root$interp")"
#ln -s /lib/x86_64/ld-glibc.so.2 "$dest/root$interp"

#mkdir -p "$dest/root/home/builder"
#cp -r src "$dest/root/home/builder/"

#echo attempting to chroot
#$CHROOT "$dest/root" /arch/bin/gcc --version

# stuff needed in ext_bin:
# `busybox --install [-s] .`
# cc (gcc)
# c++ (gcc)
# as (binutils)
# ld (binutils)
# ar (binutils)
# nm (binutils)
# strip (binutils)
# perl (perl)
