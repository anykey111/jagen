#!/bin/sh

pkg_build() {
    p_run ./configure \
        --host="$p_system" \
        --prefix="$p_prefix"

    p_run make
}

pkg_install() {
    p_run make DESTDIR="$p_dest_dir" install
    p_fix_la "$p_dest_dir$p_prefix/lib/libfontconfig.la" "$p_dest_dir"
}
