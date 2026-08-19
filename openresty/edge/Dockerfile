# SPDX-License-Identifier: BSD-2-Clause
# Copyright (c) 2025-2026 honeok <i@honeok.com>
#
# References:
# https://github.com/openresty/docker-openresty
# https://github.com/nginx/docker-nginx
# https://github.com/teddysun/openresty

FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS base

FROM base AS deps

# openresty version.
ARG RESTY_VERSION=

# https://github.com/openresty/openresty-packaging/blob/master/alpine/openresty-zlib/APKBUILD
ARG RESTY_ZLIB_VERSION=1.3.2

# https://github.com/openresty/openresty-packaging/blob/master/alpine/openresty-openssl3/APKBUILD
ARG RESTY_OPENSSL_VERSION=3.5.7
ARG RESTY_OPENSSL_PATCH_VERSION=3.5.7
ARG RESTY_OPENSSL_CONFIGURE_OPTIONS="\
    enable-camellia enable-cms enable-fips enable-ktls enable-md2 enable-rc5 enable-rfc3779 enable-seed enable-ssl3 enable-ssl3-method enable-weak-ssl-ciphers \
    "

# https://github.com/openresty/openresty-packaging/blob/master/alpine/openresty-pcre2/APKBUILD
ARG RESTY_PCRE_VERSION=10.47
ARG RESTY_PCRE_CONFIGURE_OPTIONS="\
    --disable-bsr-anycrlf --disable-coverage --disable-ebcdic --disable-fuzz-support --disable-jit-sealloc --disable-never-backslash-C --disable-pcre2grep-libbz2 --disable-pcre2grep-libz \
    --disable-pcre2test-libedit --disable-rebuild-chartables --disable-silent-rules --disable-static --disable-valgrind --enable-jit --enable-newline-is-lf --enable-pcre2-8 --enable-pcre2-16 \
    --enable-pcre2-32 --enable-pcre2grep-callout --enable-pcre2grep-callout-fork --enable-pcre2grep-jit --enable-percent-zt --enable-shared --enable-unicode \
    "

## third-party modules.
# https://github.com/nginx/nginx-acme
ARG NGX_ACME_MODULE=

# https://github.com/leev/ngx_http_geoip2_module
ARG NGX_GEOIP2_MODULE=

# https://github.com/facebook/zstd
ARG ZSTD_VERSION=

# https://github.com/GetPageSpeed/zstd-nginx-module
ARG NGX_ZSTD_MODULE=

ARG RESTY_ADD_DYNAMIC_MODULE_OPTIONS="\
    --with-http_ssl_module \
    --with-stream \
    --add-dynamic-module=../ngx-brotli-module \
    --add-dynamic-module=../ngx_http_geoip2_module-$NGX_GEOIP2_MODULE \
    --add-dynamic-module=../nginx-acme-$NGX_ACME_MODULE \
    --add-dynamic-module=../zstd-nginx-module-$NGX_ZSTD_MODULE \
    --with-compat \
    "

# These are not intended to be user-specified
ARG RESTY_TOOLCHAIN_OPTIONS="\
    --with-cc-opt='\
        -I/usr/local/openresty/zlib/include \
        -I/usr/local/openresty/openssl3/include \
        -I/usr/local/openresty/pcre2/include' \
    --with-ld-opt='\
        -L/usr/local/openresty/zlib/lib \
        -L/usr/local/openresty/openssl3/lib \
        -L/usr/local/openresty/pcre2/lib \
        -Wl,-rpath,/usr/local/openresty/zlib/lib:/usr/local/openresty/openssl3/lib:/usr/local/openresty/pcre2/lib' \
    "

ARG RESTY_STRIP_BINARIES=

RUN set -ex \
    && apk add --no-cache --virtual .build-deps \
        build-base \
        cargo \
        clang-dev \
        cmake \
        curl \
        git \
        libmaxminddb-dev \
        linux-headers \
        lz4-dev \
        perl-dev \
        tar \
        xz-dev \
##############################
# Build zlib.
    && cd /tmp \
    && curl -fsSL https://github.com/madler/zlib/releases/download/v$RESTY_ZLIB_VERSION/zlib-$RESTY_ZLIB_VERSION.tar.gz | tar fxz - \
    && cd zlib-$RESTY_ZLIB_VERSION \
    && ./configure \
        --prefix=/usr/local/openresty/zlib \
    && make -j$(getconf _NPROCESSORS_ONLN) \
        CFLAGS='-O3 -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN -g3' \
        SFLAGS='-O3 -fPIC -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN -g3' \
    && make install \
##############################
# Build openssl.
    && cd /tmp \
    && curl -fsSL https://github.com/openssl/openssl/releases/download/openssl-$RESTY_OPENSSL_VERSION/openssl-$RESTY_OPENSSL_VERSION.tar.gz | tar fxz - \
    && cd openssl-$RESTY_OPENSSL_VERSION \
    && curl -fsSL https://github.com/teddysun/openresty/raw/main/patches/openssl-$RESTY_OPENSSL_PATCH_VERSION-sess_set_get_cb_yield.patch | patch -p1 \
    && ./config \
        shared zlib -g \
        --prefix=/usr/local/openresty/openssl3 \
        --libdir=lib \
        -I/usr/local/openresty/zlib/include \
        -L/usr/local/openresty/zlib/lib \
        -Wl,-rpath,/usr/local/openresty/zlib/lib:/usr/local/openresty/openssl3/lib \
        $RESTY_OPENSSL_CONFIGURE_OPTIONS \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install_sw \
    && export OPENSSL_DIR="/usr/local/openresty/openssl3" \
##############################
# Build pcre2.
    && cd /tmp \
    && curl -fsSL https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$RESTY_PCRE_VERSION/pcre2-$RESTY_PCRE_VERSION.tar.gz | tar fxz - \
    && cd pcre2-$RESTY_PCRE_VERSION \
    && CFLAGS="-g -O3" ./configure \
        --prefix=/usr/local/openresty/pcre2 \
        --libdir=/usr/local/openresty/pcre2/lib \
        $RESTY_PCRE_CONFIGURE_OPTIONS \
    && CFLAGS="-g -O3" make -j$(getconf _NPROCESSORS_ONLN) \
    && CFLAGS="-g -O3" make install \
##############################
# Install third-party modules.
    && cd /tmp \
    && curl -fsSL https://github.com/nginx/nginx-acme/releases/download/v$NGX_ACME_MODULE/nginx-acme-$NGX_ACME_MODULE.tar.gz | tar fxz - \
    && git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli ngx-brotli-module \
    && cmake \
        -S ngx-brotli-module/deps/brotli \
        -B ngx-brotli-module/deps/brotli/out \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
    && cmake \
        --build ngx-brotli-module/deps/brotli/out \
        --target brotlienc \
        --parallel $(getconf _NPROCESSORS_ONLN) \
    && curl -fsSL https://github.com/leev/ngx_http_geoip2_module/archive/$NGX_GEOIP2_MODULE.tar.gz | tar fxz - \
    && curl -fsSL https://github.com/facebook/zstd/releases/download/v$ZSTD_VERSION/zstd-$ZSTD_VERSION.tar.gz | tar fxz - \
    && cd zstd-$ZSTD_VERSION \
    && make clean \
    && CPPFLAGS="-I/usr/local/openresty/zlib/include" \
        CFLAGS="-fPIC" \
        LDFLAGS="-L/usr/local/openresty/zlib/lib -Wl,-rpath,/usr/local/openresty/zlib/lib" \
        make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && cd /tmp \
    && curl -fsSL https://github.com/GetPageSpeed/zstd-nginx-module/archive/$NGX_ZSTD_MODULE.tar.gz | tar fxz - \
##############################
# Build modules.
    && cd /tmp \
    && curl -fsSL https://github.com/teddysun/openresty/releases/download/v$RESTY_VERSION/openresty-$RESTY_VERSION.tar.gz | tar fxz - \
    && cd openresty-$RESTY_VERSION \
    && eval ./configure -j$(getconf _NPROCESSORS_ONLN) $RESTY_ADD_DYNAMIC_MODULE_OPTIONS $RESTY_TOOLCHAIN_OPTIONS \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && if [ -n "$RESTY_STRIP_BINARIES" ]; then \
        strip --strip-unneeded build/nginx-*/objs/*.so || exit 1; \
    fi \
    && apk del --no-network .build-deps

FROM base AS build

# openresty version.
ARG RESTY_VERSION=

# https://github.com/openresty/openresty-packaging/blob/master/alpine/openresty/APKBUILD
ARG RESTY_CONFIGURE_OPTIONS="\
    --pid-path=/run/nginx.pid \
    --lock-path=/run/nginx.lock \
    --user=nginx \
    --group=nginx \
    --without-select_module \
    --without-poll_module \
    --with-threads \
    --with-file-aio \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_v3_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    `# --with-http_flv_module` \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_auth_request_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    `# --with-http_degradation_module` \
    --with-http_slice_module \
    --with-http_stub_status_module \
    --http-client-body-temp-path=/var/cache/openresty/client_temp \
    --http-proxy-temp-path=/var/cache/openresty/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/openresty/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/openresty/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/openresty/scgi_temp \
    `# --with-mail` \
    `# --with-mail_ssl_module` \
    `# --with-stream` \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_ssl_preread_module \
    --with-compat \
    --without-lua_rds_parser \
    "

ARG RESTY_LUAJIT_CONFIGURE_OPTIONS="\
    --with-luajit-xcflags='-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT' \
    "

# These are not intended to be user-specified
ARG RESTY_TOOLCHAIN_OPTIONS="\
    --with-pcre \
    --with-cc-opt='\
        -I/usr/local/openresty/zlib/include \
        -I/usr/local/openresty/openssl3/include \
        -I/usr/local/openresty/pcre2/include' \
    --with-ld-opt='\
        -L/usr/local/openresty/zlib/lib \
        -L/usr/local/openresty/openssl3/lib \
        -L/usr/local/openresty/pcre2/lib \
        -Wl,-rpath,/usr/local/openresty/zlib/lib:/usr/local/openresty/openssl3/lib:/usr/local/openresty/pcre2/lib' \
    "

ARG RESTY_STRIP_BINARIES=

COPY --from=deps /tmp/openresty-$RESTY_VERSION/build/nginx-*/objs/*.so /usr/local/openresty/nginx/modules/
COPY --from=deps /usr/local/openresty/zlib /usr/local/openresty/zlib
COPY --from=deps /usr/local/openresty/openssl3 /usr/local/openresty/openssl3
COPY --from=deps /usr/local/openresty/pcre2 /usr/local/openresty/pcre2

RUN set -ex \
    && apk add --no-cache --virtual .build-deps \
        build-base \
        curl \
        linux-headers \
        perl-dev \
        tar \
##############################
# Build openresty.
    && cd /tmp \
    && curl -fsSL https://github.com/teddysun/openresty/releases/download/v$RESTY_VERSION/openresty-$RESTY_VERSION.tar.gz | tar fxz - \
    && cd openresty-$RESTY_VERSION \
    && eval ./configure -j$(getconf _NPROCESSORS_ONLN) $RESTY_CONFIGURE_OPTIONS $RESTY_LUAJIT_CONFIGURE_OPTIONS $RESTY_TOOLCHAIN_OPTIONS \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
##############################
# Add default openresty welcome pages.
    && curl -fsSL https://github.com/teddysun/openresty/raw/main/html/index.html -o /usr/local/openresty/nginx/html/index.html \
    && curl -fsSL https://github.com/teddysun/openresty/raw/main/html/50x.html -o /usr/local/openresty/nginx/html/50x.html \
# https://github.com/nginx/pkg-oss/blob/master/alpine/alpine/APKBUILD-base.in
    && mkdir -p \
        /usr/local/openresty/nginx/modules \
    && rm -f \
        /usr/local/openresty/nginx/conf/*.default \
        /usr/local/openresty/nginx/conf/koi-utf \
        /usr/local/openresty/nginx/conf/koi-win \
        /usr/local/openresty/nginx/conf/win-utf \
##############################
# https://gitlab.alpinelinux.org/alpine/abuild/-/blob/master/abuild.in
    && if [ -n "$RESTY_STRIP_BINARIES" ]; then \
        rm -rf \
            /usr/local/openresty/zlib/include \
            /usr/local/openresty/zlib/lib/*.a \
            /usr/local/openresty/zlib/lib/pkgconfig \
            /usr/local/openresty/zlib/share \
            /usr/local/openresty/openssl3/bin/c_rehash \
            /usr/local/openresty/openssl3/include \
            /usr/local/openresty/openssl3/lib/*.a \
            /usr/local/openresty/openssl3/lib/cmake \
            /usr/local/openresty/openssl3/lib/pkgconfig \
            /usr/local/openresty/pcre2/bin \
            /usr/local/openresty/pcre2/include \
            /usr/local/openresty/pcre2/lib/*.la \
            /usr/local/openresty/pcre2/lib/pkgconfig \
            /usr/local/openresty/pcre2/share \
            /usr/local/openresty/luajit/lib/*.a \
            /usr/local/openresty/luajit/lib/pkgconfig \
            /usr/local/openresty/luajit/share/man \
        && scanelf --recursive --nobanner --osabi --etype 'ET_DYN,ET_EXEC' \
            /usr/local/openresty \
        | while read -r type osabi filename; do \
            [ -e "$filename" ] || continue; \
            [ "$osabi" != "STANDALONE" ] || continue; \
            strip --strip-unneeded "$filename" || exit 1; \
        done; \
    fi \
    && apk del --no-network .build-deps \
    && rm -rf /var/cache/apk/* /tmp/*

FROM base AS dist

LABEL org.opencontainers.image.authors="honeok <i@honeok.com>"

# openresty version.
ARG RESTY_VERSION=
ENV RESTY_VERSION=$RESTY_VERSION

COPY --from=build /usr/local/openresty /usr/local/openresty

RUN set -ex \
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/openresty -s /sbin/nologin -G nginx -g nginx nginx \
    && apk add --no-cache \
        curl \
        gettext-envsubst \
        tzdata \
##############################
# https://github.com/nginx/pkg-oss/blob/master/alpine/alpine/APKBUILD-base.in
    && mkdir -p \
        /var/cache/openresty \
    && ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/sbin/nginx \
# forward request and error logs to docker log collector
    && ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log \
# create a docker-entrypoint.d directory
    && mkdir /docker-entrypoint.d \
##############################
# resolve runtime shared library deps.
    && runDeps="$( \
        scanelf --recursive --nobanner --needed --format '%n#p' \
            /usr/local/openresty \
        | tr ',' '\n' \
        | sort -u \
        | while IFS= read -r so; do \
            [ -n "$so" ] || continue; \
            for libdir in \
                /usr/local/lib \
                /usr/local/openresty/zlib/lib \
                /usr/local/openresty/openssl3/lib \
                /usr/local/openresty/pcre2/lib \
                /usr/local/openresty/luajit/lib \
            ; do \
                [ -e "$libdir/$so" ] && continue 2; \
            done; \
            printf 'so:%s\n' "$so"; \
        done \
    )" \
    && apk add --no-cache --virtual .runDeps $runDeps

# Add openresty utilities and LuaJIT binaries into PATH.
ENV PATH=$PATH:/usr/local/openresty/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/openssl3/bin:/usr/local/openresty/luajit/bin

# Copy nginx configuration files.
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

# https://github.com/nginx/docker-nginx/tree/master/entrypoint
COPY --chmod=755 docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

# Use SIGQUIT instead of default SIGTERM to cleanly drain requests.
# See https://github.com/nginx/docker-nginx/issues/377
STOPSIGNAL SIGQUIT

CMD ["openresty", "-g", "daemon off;"]
