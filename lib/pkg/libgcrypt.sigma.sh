#!/bin/sh

p_source="$p_dist_dir/libgcrypt-1.5.3.tar.bz2"

use_env target

pkg_prepare() {
    p_patch "libgcrypt-1.5.0-uscore"
    p_patch "libgcrypt-multilib-syspath"
    p_run autoreconf -vif
}

pkg_build() {
    p_run ./configure \
        --host="mipsel-linux" \
        --prefix="" \
        --disable-dependency-tracking \
        --disable-static \
        --enable-shared \
        --enable-ciphers=cast5,aes \
        --enable-pubkey-ciphers=rsa \
        --enable-digests=sha256 \
        --disable-padlock-support \
        --disable-aesni-support \
        --disable-O-flag-munging \
        --with-sysroot="$sdk_rootfs_prefix"

    p_run make
}

pkg_install() {
    p_run make DESTDIR="$sdk_rootfs_prefix" install
}