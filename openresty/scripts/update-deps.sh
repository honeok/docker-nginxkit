#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (c) 2026 honeok <i@honeok.com>

set -eExuo pipefail

# MAJOR.MINOR.PATCH
# shellcheck disable=SC2034
readonly SCRIPT_VERSION='2.0.0'

SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

die() {
    printf '[%s] %s\n' "$(date '+%F %T')" "[ERROR] $*"
    exit 1
}

curl() {
    local rc i

    # 添加 --fail 不然404退出码也为0
    # 32位cygwin已停止更新, 证书可能有问题, 添加 --insecure
    # centos7 curl 不支持 --retry-connrefused --retry-all-errors 因此手动 retry
    for ((i = 1; i <= 5; i++)); do
        if command curl --connect-timeout 10 --fail --insecure "$@"; then
            return
        else
            rc="$?"
        fi
        # HTTP错误或达到重试次数
        if [ "$rc" -eq 22 ] || [ "$i" -eq 5 ]; then
            return "$rc"
        fi
        sleep 5
    done
}

update_arg() {
    local arg latest_ver

    arg="$1"
    latest_ver="$2"

    [[ -n "$latest_ver" && "$latest_ver" != *$'\n'* ]] || die "Invalid latest version for $arg: $latest_ver"

    grep -Fxq \
        -e "ARG $arg=$latest_ver" \
        -e "ARG $arg=\"$latest_ver\"" \
        ./Dockerfile || sed -Ei "s#^(ARG $arg=)(\"?)[^\"]*(\"?)\$#\1\2${latest_ver}\3#" ./Dockerfile
}

# https://github.com/openresty/openresty-packaging/tree/master/alpine
update_stable_ver() {
    local zlib_apkbuild openssl_apkbuild pcre2_apkbuild
    local latest_zlib_ver latest_openssl_ver latest_openssl_patch_ver latest_pcre2_ver

    pushd stable || exit 1
    zlib_apkbuild="$(curl -fsSL https://github.com/openresty/openresty-packaging/raw/master/alpine/openresty-zlib/APKBUILD)"
    openssl_apkbuild="$(curl -fsSL https://github.com/openresty/openresty-packaging/raw/master/alpine/openresty-openssl3/APKBUILD)"
    pcre2_apkbuild="$(curl -fsSL https://github.com/openresty/openresty-packaging/raw/master/alpine/openresty-pcre2/APKBUILD)"

    latest_zlib_ver="$(sed -En 's#^[[:space:]]*(sha512sums[[:space:]]*=[[:space:]]*")?[[:xdigit:]]{128}[[:space:]]+zlib-([0-9]+(\.[0-9]+)*)\.tar\.gz"?[[:space:]]*$#\2#p' <<< "$zlib_apkbuild" | sort -u)"
    latest_openssl_ver="$(sed -En 's#^[[:space:]]*(sha512sums[[:space:]]*=[[:space:]]*")?[[:xdigit:]]{128}[[:space:]]+openssl-([0-9]+(\.[0-9]+)*)\.tar\.gz"?[[:space:]]*$#\2#p' <<< "$openssl_apkbuild" | sort -u)"
    latest_openssl_patch_ver="$(sed -En 's#^[[:space:]]*(sha512sums[[:space:]]*=[[:space:]]*")?[[:xdigit:]]{128}[[:space:]]+openssl-([0-9]+(\.[0-9]+)*)-[^[:space:]]+\.patch"?[[:space:]]*$#\2#p' <<< "$openssl_apkbuild" | sort -u)"
    latest_pcre2_ver="$(sed -En 's#^[[:space:]]*(sha512sums[[:space:]]*=[[:space:]]*")?[[:xdigit:]]{128}[[:space:]]+pcre2-([0-9]+(\.[0-9]+)*)\.tar\.gz"?[[:space:]]*$#\2#p' <<< "$pcre2_apkbuild" | sort -u)"

    update_arg RESTY_ZLIB_VERSION "$latest_zlib_ver"
    update_arg RESTY_OPENSSL_VERSION "$latest_openssl_ver"
    update_arg RESTY_OPENSSL_PATCH_VERSION "$latest_openssl_patch_ver"
    update_arg RESTY_PCRE_VERSION "$latest_pcre2_ver"
    popd || exit 1
}

update_luarocks_ver() {
    local luarocks_dockerfile latest_luarocks_ver

    pushd luarocks || exit 1
    luarocks_dockerfile="$(curl -fsSL https://github.com/openresty/docker-openresty/raw/master/alpine/Dockerfile.fat)"
    latest_luarocks_ver="$(sed -En 's#^[[:space:]]*ARG[[:space:]]+RESTY_LUAROCKS_VERSION="?([0-9]+(\.[0-9]+)*)"?[[:space:]]*$#\1#p' <<< "$luarocks_dockerfile" | sort -u)"
    update_arg RESTY_LUAROCKS_VERSION "$latest_luarocks_ver"
    popd || exit 1
}

# https://github.com/teddysun/openresty/blob/main/util/build-win32.sh
update_edge_ver() {
    local build_script
    local latest_zlib_ver latest_openssl_ver latest_openssl_patch_ver latest_pcre2_ver

    pushd edge || exit 1
    build_script="$(curl -fsSL https://github.com/teddysun/openresty/raw/main/util/build-win32.sh)"

    latest_zlib_ver="$(sed -En 's#^[[:space:]]*ZLIB=zlib-([0-9]+(\.[0-9]+)*)[[:space:]]*$#\1#p' <<< "$build_script" | sort -u)"
    latest_openssl_ver="$(sed -En 's#^[[:space:]]*OPENSSL=openssl-([0-9]+(\.[0-9]+)*)[[:space:]]*$#\1#p' <<< "$build_script" | sort -u)"
    latest_openssl_patch_ver="$(sed -En 's#.*patches/openssl-([0-9]+(\.[0-9]+)*)-[^[:space:]]+\.patch.*#\1#p' <<< "$build_script" | sort -u)"
    latest_pcre2_ver="$(sed -En 's#^[[:space:]]*PCRE=pcre2-([0-9]+(\.[0-9]+)*)[[:space:]]*$#\1#p' <<< "$build_script" | sort -u)"

    update_arg RESTY_ZLIB_VERSION "$latest_zlib_ver"
    update_arg RESTY_OPENSSL_VERSION "$latest_openssl_ver"
    update_arg RESTY_OPENSSL_PATCH_VERSION "$latest_openssl_patch_ver"
    update_arg RESTY_PCRE_VERSION "$latest_pcre2_ver"
    popd || exit 1
}

cd "$PARENT_DIR" || exit 1
update_stable_ver
update_luarocks_ver
update_edge_ver
