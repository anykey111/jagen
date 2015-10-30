#!/bin/sh

pkg_source_dir="$jagen_src_dir/sigma-rootfs"
pkg_run_jobs=1

jagen_pkg_build() {
    use_env tools

    PATH="$SMP86XX_TOOLCHAIN_PATH/bin:$PATH"

    pkg_run cp -f config.release .config
    pkg_run make

    # contains cyclic symlinks
    rm -rf "package/udev/udev-114/test/sys"

    # cleanup while bin dir is almost empty, doing this in install script
    # confuses the shell for some reason (maybe [ [[ filenames from busybox?)
    pkg_run rm -f "$sdk_rootfs_root"/bin/*.bash

    pkg_run cd "$sdk_rootfs_root/bin"
    pkg_run rm -f setxenv unsetxenv
    pkg_run ln -fs setxenv2_mipsel setxenv2
    pkg_run ln -fs setxenv2_mipsel unsetxenv2
}

install_alsa() {
    pkg_run mkdir -p "$sdk_rootfs_root/var/lib/alsa"
    pkg_run mkdir -p "$sdk_rootfs_root/share/alsa/ucm"

    pkg_run mkdir -p "$sdk_rootfs_root/etc/modprobe.d"
    pkg_run cp -f \
        "$jagen_private_dir/cfg/alsa.conf" \
        "$sdk_rootfs_root/etc/modprobe.d"

    pkg_run cp -a \
        "$sdk_rootfs_prefix/bin/alsa"* \
        "$sdk_rootfs_prefix/bin/amixer" \
        "$sdk_rootfs_prefix/bin/aplay" \
        "$sdk_rootfs_prefix/bin/arecord" \
        "$sdk_rootfs_root/bin"
    pkg_run cp -a \
        "$sdk_rootfs_prefix/sbin/alsactl" \
        "$sdk_rootfs_root/sbin"
    pkg_run cp -a \
        "$sdk_rootfs_prefix/lib/alsa-lib" \
        "$sdk_rootfs_prefix/lib/libasound"* \
        "$sdk_rootfs_root/lib"
    pkg_run cp -a \
        "$sdk_rootfs_prefix/share/alsa" \
        "$sdk_rootfs_root/share"
}

install_timezone() {
    pkg_run rm -f "$sdk_rootfs_root/etc/TZ"
    pkg_run install -m644 \
        "$TOOLCHAIN_RUNTIME_PATH/usr/share/zoneinfo/Europe/Moscow" \
        "$sdk_rootfs_root/etc/localtime"
}

install_keys() {
    pkg_run mkdir -p "$sdk_rootfs_root/lib/firmware"
    pkg_run cp -a \
        "$jagen_private_dir/keys/keyfile.gpg" \
        "$sdk_rootfs_root/lib/firmware"
}

install_gpg() {
    pkg_run cp -a \
        "$sdk_rootfs_prefix/bin/gpg" \
        "$sdk_rootfs_root/bin"
    pkg_run cp -a \
        "$sdk_rootfs_prefix"/lib/libgpg*.so* \
        "$sdk_rootfs_prefix"/lib/libassuan.so* \
        "$sdk_rootfs_root/lib"
}

install_losetup() {
    pkg_run cp -a \
        "$sdk_rootfs_prefix/sbin/losetup" \
        "$sdk_rootfs_root/sbin"
}

install_ldconfig() {
    pkg_run cp -a \
        "$TOOLCHAIN_RUNTIME_PATH/usr/lib/bin/ldconfig" \
        "$sdk_rootfs_root/sbin"
}

install_utils() {
    pkg_run cp -a \
        "$sdk_rootfs_prefix"/lib/libblkid.so* \
        "$sdk_rootfs_prefix"/lib/libmount.so* \
        "$sdk_rootfs_root/lib"
    pkg_run cp -a \
        "$sdk_rootfs_prefix/sbin/mkswap" \
        "$sdk_rootfs_prefix/sbin/swapoff" \
        "$sdk_rootfs_prefix/sbin/swapon" \
        "$sdk_rootfs_root/sbin"
}

install_files() {
    local root_dir="$sdk_rootfs_root"
    local flags_dir="$root_dir/etc/flags"

    pkg_run cp -rf "$jagen_private_dir"/rootfs/* "$root_dir"
    pkg_run mkdir -p "$flags_dir"

    if in_flags devenv; then
        pkg_run cp -rf "$jagen_private_dir"/rootfs-dev/* "$root_dir"
        rm -f "$root_dir/var/service/dropbear/down"
        touch "$flags_dir/devenv"
    fi

    if in_flags sigma_persist_logs; then
        touch "$flags_dir/persist_logs"
    fi
}

jagen_pkg_install() {
    use_toolchain target

    pkg_run cd "$sdk_rootfs_root"

    pkg_run rm -fr dev opt proc sys root tmp usr var/run
    pkg_run install -m 700 -d root
    pkg_run rm -f init linuxrc
    pkg_run ln -s /bin/busybox init

    pkg_run cd "$sdk_rootfs_root/etc"

    pkg_run rm -fr init.d network cs_rootfs_*
    pkg_run rm -f inputrc ld.so.cache mtab
    for d in up down pre-up post-down; do
        pkg_run mkdir -p network/if-${d}.d
    done

    pkg_run cd "$sdk_rootfs_root/lib"

    pkg_run rm -f libnss_compat* libnss_hesiod* libnss_nis*
    find "$sdk_rootfs_root/lib" \( -name "*.a" -o -name "*.la" \) -delete

    if in_flags with_alsa; then
        install_alsa
    fi
    install_timezone
    install_keys
    install_gpg
    install_losetup
    install_ldconfig
    install_utils
    install_files

    pkg_strip_dir "$sdk_rootfs_root"
}
