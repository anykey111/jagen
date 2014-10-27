#!/bin/sh

pworkdir="$EZSDK/component-sources/linuxutils_3_22_00_02"
rules="$EZSDK/Rules.make"

interface_dir="$pworkdir/packages/ti/sdo/linuxutils/cmem/src/interface"
module_dir="$pworkdir/packages/ti/sdo/linuxutils/cmem/src/module"
MAKE="make RULES_MAKE=$rules"

pkg_unpack_target() {
    p_cmd $MAKE -C $interface_dir clean
    p_cmd $MAKE -C $module_dir clean
}

pkg_build_target() {
    p_cmd $MAKE -C $interface_dir ../../lib/cmem.a470MV
    p_cmd $MAKE -C $module_dir
}

pkg_install_target() {
    local dest="$rootfsdir/lib/modules/$kernel_version/kernel/drivers/dsp"

    p_cmd install -d "$dest"
    p_cmd install -m644 "$module_dir/cmemk.ko" "$dest"
}