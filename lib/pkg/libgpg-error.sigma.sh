#!/bin/sh

p_source="$p_dist_dir/libgpg-error-1.17.tar.bz2"

use_env target

pkg_build() {
    p_run ./configure \
        --host="mipsel-linux" \
        --prefix="" \
        --disable-nls \
        --disable-rpath \
        --disable-languages

    p_run make
}

pkg_install() {
    p_run make DESTDIR="$sdk_rootfs_prefix" install
    # p_fix_la "$sdk_rootfs_prefix/lib/libgpg-error.la"
}