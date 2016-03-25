#!/bin/sh

jagen_pkg_prepare() {
    local pub_dir="$jagen_sdk_dir/pub"

    pkg_run install -d -m 755 \
        bin dev etc home lib libexec mnt proc run sbin share sys usr var
    pkg_run install -d -m 700 root
    pkg_run install -d -m 1777 tmp

    pkg_run rsync -vrtl "$jagen_sdk_dir/pub/rootfs/" "."
    pkg_run rsync -vrtl "$jagen_sdk_dir/pub/kmod/" "./kmod"
    pkg_run rsync -vrtl "$pub_dir/lib/share/" "lib"

    pkg_run rsync -vt "$jagen_private_dir/lib/libHA.AUDIO.PCM.decode.so" "lib"
}

jagen_pkg_hi_utils() {
    local src="$pkg_install_dir/bin"
    local dst="$pkg_build_dir/bin"
    local programs="gpio regrw dsp_tune"

    for name in $programs; do
        pkg_run install -vm 755 "$src/$name" "$dst"
    done
}

jagen_pkg_dropbear() {
    local src="$pkg_install_dir/sbin"
    local dst="$pkg_build_dir/sbin"
    local programs="dropbear"

    for name in $programs; do
        pkg_run install -vm 755 "$src/$name" "$dst"
    done
}

jagen_pkg_dropbear_key() {
    local src="${jagen_private_dir:?}/rootfs"
    local dst="$pkg_build_dir"

    pkg_run mkdir -p "$dst/etc/dropbear"
    pkg_run cp -fv "$src/etc/dropbear/"* "$dst/etc/dropbear"

    pkg_run cp -frv "$src/root/.ssh" "$dst/root/.ssh"
    pkg_run chmod 700 "$dst/root/.ssh"
}

install_libs() {
    local src="$pkg_install_dir"
    local dst="$pkg_build_dir"

    pkg_run rsync -vrtlm --include='*/' --include='*.so*' --exclude='*' \
        "$src/lib" "$dst"
}

install_chicken() {
    local src="$pkg_install_dir"
    local dst="$pkg_build_dir"
    local programs="csi"

    for name in $programs; do
        pkg_run install -vm 755 "$src/bin/$name" "$dst/bin"
    done

    pkg_run rsync -vrtl "$src/lib/chicken" "$dst/lib"

    if pkg_is_release; then
        pkg_run find "$dst/lib/chicken" -type f '(' \
            -name '*.import.*' -o \
            -name '*.scm' -o \
            -name 'types.db' ')' \
            -print -delete
    fi
}

install_chmod_libs() {
    local dst="$pkg_build_dir"

    find "$dst/lib" -name '*.so*' -exec chmod 755 '{}' \+ || die
}

install_karaoke_player() {
    local src="$pkg_install_dir"
    local dst="$pkg_build_dir"
    local programs="smplayer"

    for name in $programs; do
        pkg_run install -vm 755 "$src/bin/$name" "$dst/bin"
    done
}

install_modules() {
    local src="$pkg_install_dir$jagen_kernel_modules_install_dir"
    local dst="$pkg_build_dir$jagen_kernel_modules_install_dir"

    pkg_run mkdir -p "$dst"
    pkg_run rsync -vrtlp "$src/" "$dst"
}

install_debug_utils() {
    local src="$pkg_install_dir"
    local dst="$pkg_build_dir"
    local programs='strace'

    for name in $programs; do
        pkg_run install -vm 755 "$src/bin/$name" "$dst/bin"
    done
}

jagen_pkg_install() {
    local src="$pkg_install_dir"
    local dst="$pkg_build_dir"

    install_libs || return
    install_chicken || return
    install_chmod_libs || return
    install_karaoke_player || return
    install_modules || return
    if in_flags debug; then
        install_debug_utils || return
    fi

    if pkg_is_release; then
        _jagen src status > "$dst/heads" || return
    fi
}
