#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (c) 2026 honeok <i@honeok.com>

set -eEuxo pipefail

CHANNEL="$1"

die() {
    printf '[%s] %s\n' "$(date '+%F %T')" "[ERROR] $*"
    exit 1
}

curl() {
    local rc i

    for ((i = 1; i <= 5; i++)); do
        if command curl --connect-timeout 10 --fail --insecure "$@"; then
            return
        else
            rc="$?"
        fi
        if [ "$rc" -eq 22 ] || [ "$i" -eq 5 ]; then
            return "$rc"
        fi
        sleep 5
    done
}

write_env() {
    printf '%s\n' "$@" >> "$GITHUB_ENV"
}

get_stable_ver() {
    local zlib_apkbuild openssl_apkbuild pcre2_apkbuild zlib_ver openssl_ver openssl_patch_ver pcre2_ver

    zlib_apkbuild="$(curl -fsSL https://github.com/openresty/openresty-packaging/raw/master/alpine/openresty-zlib/APKBUILD)"
    openssl_apkbuild="$(curl -fsSL https://github.com/openresty/openresty-packaging/raw/master/alpine/openresty-openssl3/APKBUILD)"
    pcre2_apkbuild="$(curl -fsSL https://github.com/openresty/openresty-packaging/raw/master/alpine/openresty-pcre2/APKBUILD)"

    zlib_ver="$(sed -En 's/^pkgver="?([0-9]+(\.[0-9]+)*)"?$/\1/p' <<< "$zlib_apkbuild")"
    openssl_ver="$(sed -En 's/^pkgver="?([0-9]+(\.[0-9]+)*)"?$/\1/p' <<< "$openssl_apkbuild")"
    openssl_patch_ver="$(sed -En 's/^[[:space:]]*openssl-([0-9]+(\.[0-9]+)*)-.*\.patch[[:space:]]*$/\1/p' <<< "$openssl_apkbuild" | sort -u)"
    pcre2_ver="$(sed -En 's/^pkgver="?([0-9]+(\.[0-9]+)*)"?$/\1/p' <<< "$pcre2_apkbuild")"

    write_env \
        "RESTY_ZLIB_VERSION=$zlib_ver" \
        "RESTY_OPENSSL_VERSION=$openssl_ver" \
        "RESTY_OPENSSL_PATCH_VERSION=$openssl_patch_ver" \
        "RESTY_PCRE_VERSION=$pcre2_ver"
}

get_edge_ver() {
    local build_script zlib_ver openssl_ver openssl_patch_ver pcre2_ver

    build_script="$(curl -fsSL https://github.com/teddysun/openresty/raw/main/util/build-win32.sh)"

    zlib_ver="$(sed -En 's#^[[:space:]]*ZLIB=zlib-([0-9]+(\.[0-9]+)*)[[:space:]]*$#\1#p' <<< "$build_script" | sort -u)"
    openssl_ver="$(sed -En 's#^[[:space:]]*OPENSSL=openssl-([0-9]+(\.[0-9]+)*)[[:space:]]*$#\1#p' <<< "$build_script" | sort -u)"
    openssl_patch_ver="$(sed -En 's#.*patches/openssl-([0-9]+(\.[0-9]+)*)-[^[:space:]]+\.patch.*#\1#p' <<< "$build_script" | sort -u)"
    pcre2_ver="$(sed -En 's#^[[:space:]]*PCRE=pcre2-([0-9]+(\.[0-9]+)*)[[:space:]]*$#\1#p' <<< "$build_script" | sort -u)"

    write_env \
        "RESTY_ZLIB_VERSION=$zlib_ver" \
        "RESTY_OPENSSL_VERSION=$openssl_ver" \
        "RESTY_OPENSSL_PATCH_VERSION=$openssl_patch_ver" \
        "RESTY_PCRE_VERSION=$pcre2_ver"
}

case "$CHANNEL" in
stable)
    get_stable_ver
    ;;
edge)
    get_edge_ver
    ;;
*)
    die "Error: args error."
    ;;
esac
