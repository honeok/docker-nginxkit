#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (c) 2026 honeok <i@honeok.com>

set -eEuxo pipefail

NGX_ACME_VERSION="$(gh api --paginate repos/nginx/nginx-acme/tags --jq '.[].name | sub("^v"; "")' | sort -V | tail -n 1)"
NGX_GEOIP2_VERSION="$(gh api --paginate repos/leev/ngx_http_geoip2_module/tags --jq '.[].name | sub("^v"; "")' | sort -V | tail -n 1)"
HEADERS_MORE_VERSION="$(gh api --paginate repos/openresty/headers-more-nginx-module/tags --jq '.[].name | sub("^v"; "")' | sort -V | tail -n 1)"
NGX_VTS_VERSION="$(gh api --paginate repos/vozlt/nginx-module-vts/tags --jq '.[].name | sub("^v"; "")' | sort -V | tail -n 1)"
NGX_ZSTD_VERSION="$(gh api repos/facebook/zstd/releases/latest --jq '.tag_name | sub("^v"; "")')"

{
    echo "NGX_ACME_VERSION=$NGX_ACME_VERSION"
    echo "NGX_GEOIP2_VERSION=$NGX_GEOIP2_VERSION"
    echo "HEADERS_MORE_VERSION=$HEADERS_MORE_VERSION"
    echo "NGX_VTS_VERSION=$NGX_VTS_VERSION"
    echo "NGX_ZSTD_VERSION=$NGX_ZSTD_VERSION"
} \
    >> "$GITHUB_ENV"
