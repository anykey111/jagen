#!/bin/sh

pworkdir="$ja_srcdir/$pname"

if [ "$target_board" = "ti_evm" ]; then
    config="ti8168_evm_config_sd"
    config_min="ti8168_evm_min_sd"
    boot_scipt="boot_nfs_evm.txt"
elif [ "$target_board" = "ast200" ]; then
    config="ast200_sd"
    config_min="ast200_sd_min"
    boot_scipt="boot_nfs.txt"
fi

mkimage="./tools/mkimage -A arm -O linux -T script -C none -n TI_script -d"

pkg_build_min() {
    local dest="$rootfsdir/boot"

    use_env target

    p_cmd $CROSS_MAKE distclean
    p_cmd $CROSS_MAKE $config_min
    p_cmd $CROSS_MAKE u-boot.ti

    p_cmd install -d "$dest"
    p_cmd install -m644 u-boot.min.sd "$dest/MLO"
}

pkg_build_target() {
    local dest="$rootfsdir/boot"

    p_cmd $CROSS_MAKE distclean
    p_cmd $CROSS_MAKE $config
    p_cmd $CROSS_MAKE u-boot.ti

    p_cmd install -d "$dest"
    p_cmd install -m644 u-boot.bin "$dest"
}

pkg_mkimage_target() {
    p_cmd $mkimage "${ja_srcdir}/misc/boot/${boot_scipt}" "${rootfsdir}/boot/boot.scr"
}