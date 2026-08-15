# SPDX-License-Identifier: BSD-2-Clause
# Copyright (c) 2025-2026 honeok <i@honeok.com>

FROM honeok/openresty:1.31.1.1-alpine@sha256:24a0b09f0eb9d1f53181253402594046737a561046e70699c7669a440fd24355 AS dist

ARG RESTY_LUAROCKS_VERSION=3.13.0

RUN set -ex \
    && apk add --update --no-cache --virtual .build-deps \
        make \
        perl-dev \
        tar \
    && cd /tmp \
    && curl -fsSL https://luarocks.github.io/luarocks/releases/luarocks-$RESTY_LUAROCKS_VERSION.tar.gz | tar fxz - \
    && cd luarocks-$RESTY_LUAROCKS_VERSION \
    && ./configure \
        --prefix=/usr/local/openresty/luajit \
        --with-lua=/usr/local/openresty/luajit \
        --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1 \
    && make build \
    && make install \
    && apk del --no-network .build-deps \
    && rm -rf /var/cache/apk/* /tmp/*

ENV LUA_PATH="/usr/local/openresty/site/lualib/?.ljbc;/usr/local/openresty/site/lualib/?/init.ljbc;/usr/local/openresty/lualib/?.ljbc;/usr/local/openresty/lualib/?/init.ljbc;/usr/local/openresty/site/lualib/?.lua;/usr/local/openresty/site/lualib/?/init.lua;/usr/local/openresty/lualib/?.lua;/usr/local/openresty/lualib/?/init.lua;./?.lua;/usr/local/openresty/luajit/share/luajit-2.1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/local/openresty/luajit/share/lua/5.1/?.lua;/usr/local/openresty/luajit/share/lua/5.1/?/init.lua"
ENV LUA_CPATH="/usr/local/openresty/site/lualib/?.so;/usr/local/openresty/lualib/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so"
