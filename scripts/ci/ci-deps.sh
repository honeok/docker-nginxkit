#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (c) 2026 honeok <i@honeok.com>

set -eEuxo pipefail

NGX_ACME_MODULE="$(gh api --paginate repos/nginx/nginx-acme/tags --jq '.[].name | sub("^v"; "")' | sort -V | tail -n 1)"
NGX_AUTH_JWT_MODULE="$(gh api --paginate repos/kjdev/nginx-auth-jwt/tags --jq '.[].name | sub("^v"; "")' | sort -V | tail -n 1)"
NGX_CACHE_PURGE_MODULE="$(gh api --paginate repos/nginx-modules/ngx_cache_purge/tags --jq '.[].name | sub("^v"; "")' | sort -V | tail -n 1)"
NGX_GEOIP2_MODULE="$(gh api --paginate repos/leev/ngx_http_geoip2_module/tags --jq '.[].name | sub("^v"; "")' | sort -V | tail -n 1)"
RESTY_HEADERS_MORE_MODULE="$(gh api --paginate repos/openresty/headers-more-nginx-module/tags --jq '.[].name | sub("^v"; "")' | sort -V | tail -n 1)"
ZSTD_VERSION="$(gh api repos/facebook/zstd/releases/latest --jq '.tag_name | sub("^v"; "")')"
NGX_ZSTD_MODULE="$(gh api --paginate repos/GetPageSpeed/zstd-nginx-module/tags --jq '.[].name | sub("^v"; "")' | sort -V | tail -n 1)"

{
    echo "NGX_ACME_MODULE=$NGX_ACME_MODULE"
    echo "NGX_AUTH_JWT_MODULE=$NGX_AUTH_JWT_MODULE"
    echo "NGX_CACHE_PURGE_MODULE=$NGX_CACHE_PURGE_MODULE"
    echo "NGX_GEOIP2_MODULE=$NGX_GEOIP2_MODULE"
    echo "RESTY_HEADERS_MORE_MODULE=$RESTY_HEADERS_MORE_MODULE"
    echo "ZSTD_VERSION=$ZSTD_VERSION"
    echo "NGX_ZSTD_MODULE=$NGX_ZSTD_MODULE"
} \
    >> "$GITHUB_ENV"
