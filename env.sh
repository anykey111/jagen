#!/bin/sh

export jagen_root="$PWD"
export jagen_build_root="$PWD"

. "$jagen_root/lib/env.sh" ||
    { echo "Failed to load environment"; return 1; }

add_PATH "$target_bin_dir"
add_PATH "$pkg_private_dir/bin"
add_PATH "$jagen_root/bin"
