#!/bin/sh

p_source="$pkg_dist_dir/zlib-1.2.8.tar.gz"

use_toolchain target

p_prefix="$target_prefix"
p_dest_dir="$target_dir"

pkg_build() {
    p_run ./configure \
        --prefix="$p_prefix" \
        --libdir="$p_prefix/lib"

    p_run make
}

cleanup_headers() {
    p_run sed -i -r 's:\<(O[FN])\>:_Z_\1:g' "$@"
}

pkg_install() {
    p_run make DESTDIR="$p_dest_dir" LDCONFIG=: install
    p_run cleanup_headers "$p_dest_dir$p_prefix"/include/*.h
}