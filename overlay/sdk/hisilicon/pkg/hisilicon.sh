#!/bin/sh

jagen_pkg_build() {
    use_env lunch || return
    pkg_run make bigfish_emmc
}