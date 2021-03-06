#!/bin/sh

jagen_pkg_patch() {
    pkg_run sed -ri 's|^(CFLAGS.*ENABLE_DEBUG)|# \1|' Makefile
    pkg_run sed -ri 's|^(CFLAGS.*ENABLE_REPLAY)|# \1|' Makefile
}

jagen_pkg_compile_target() {
    use_env target_toolchain
    pkg_run make
}

jagen_pkg_install() {
    local dest="$pkg_sysroot/bin"
    pkg_run install -vd "$dest"
    pkg_run install -vm755 ntpclient "$dest"
}
