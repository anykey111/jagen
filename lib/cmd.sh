#!/bin/sh

S=$(printf '\t')

mode=''

die() {
    unset IFS
    printf "jagen${mode:+ $mode}: %s\n" "$*"
    exit 1
}

assert_ninja_found() {
    if [ -z "$(command -v ninja)" ]; then
        die "A 'ninja' command is not found in your PATH. You need to install \
Ninja build system (https://ninja-build.org) to run 'build' or 'rebuild'"
    fi
}

on_interrupt() { :; }

maybe_sync() {
    if [ "$show_progress" -o "$show_all" ]; then
        sync
    fi
}

cmd_build() {
    local IFS="$(printf '\n\t')"
    local dry_run show_progress show_all
    local targets logs sts arg i
    local cmd_log="$jagen_log_dir/$mode.log"

    assert_ninja_found

    while [ $# -gt 0 ]; do
        case $1 in
            -dry-run|--dry-run)
                dry_run=1 ;;
            -progress|--progress)
                show_progress=1 ;;
            -all-progress|--all-progress)
                show_all=1 ;;
            -from|--from)
                build_from=1 ;;
            -only|--only)
                build_only=1 ;;
            --*)
                die "invalid option '$1'" ;;
            -*) arg="${1#-}"
                while [ "$arg" ]; do
                    i=$(echo $arg | cut -c1)
                    case $i in
                        n) dry_run=1 ;;
                        p) show_progress=1 ;;
                        P) show_all=1 ;;
                        f) build_from=1 ;;
                        o) build_only=1 ;;
                        *) die "invalid flag '$i' in '$1'" ;;
                    esac
                    arg=${arg#$i}
                done ;;
             *) targets="${targets}${S}${1}"
                logs="${logs}${S}${jagen_log_dir}/${1}.log" ;;
        esac
        shift
    done

    if [ "$dry_run" ]; then
        set -- $targets
        if [ $# != 0 ]; then
            printf "$*\n"
        fi
        return 0
    fi

    cd "$jagen_build_dir" || return

    : > "$cmd_log" || return
    for log in $logs; do
        : > "$log" || return
    done

    if [ "$build_from" ]; then
        rm -f $targets || return
    fi

    if [ "$show_progress" ]; then
        tail -qFn+1 "$cmd_log" $logs 2>/dev/null &
    elif [ "$show_all" ]; then
        tail -qFn0 *.log 2>/dev/null &
    else
        tail -qFn+1 "$cmd_log" &
    fi

    # catch SIGINT to kill background tail process and exit cleanly
    trap on_interrupt INT

    # It is hard to reliably reproduce but testing shows that both syncs are
    # necessary to avoid losing log messages from console. When neither of
    # 'show_*' options are supplied we do not sync assuming non-interactive run
    # (build server) not caring about console logs that much.

    maybe_sync
    if [ "$build_only" ]; then
        ninja $targets > "$cmd_log"; sts=$?
    else
        ninja > "$cmd_log"; sts=$?
    fi
    maybe_sync

    kill $!

    return $sts
}

case $1 in
    build)
        mode="$1"; shift
        cmd_build "$@"
        ;;
    *)
        die "unknown wrapper command: $1"
        ;;
esac
