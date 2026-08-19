# SPDX-License-Identifier: BSD-2-Clause
# Copyright (c) 2024-2026 honeok <i@honeok.com>

FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS base

FROM base AS build

## nginx version.
ARG NGINX_VERSION=

## dynamic modules.
ARG NGX_ACME_VERSION=

ARG NGX_ADD_DYNAMIC_MODULE_OPTIONS="\
    --with-http_ssl_module \
    --with-stream \
    --add-dynamic-module=../nginx-acme-$NGX_ACME_VERSION \
    --with-compat \
    "

ARG NGX_STRIP_BINARIES=

RUN set -ex \
    && apk add --no-cache --virtual .build-deps \
        build-base \
        cargo \
        clang-dev \
        curl \
        openssl-dev \
        pcre2-dev \
        tar \
    && cd /tmp \
##############################
# install dynamic modules.
    && curl -fsSL https://github.com/nginx/nginx-acme/releases/download/v$NGX_ACME_VERSION/nginx-acme-$NGX_ACME_VERSION.tar.gz | tar fxz - \
##############################
# build.
    && curl -fsSL https://github.com/nginx/nginx/releases/download/release-$NGINX_VERSION/nginx-$NGINX_VERSION.tar.gz | tar fxz - \
    && cd nginx-$NGINX_VERSION \
    && eval ./configure $NGX_ADD_DYNAMIC_MODULE_OPTIONS \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && if [ -n "$NGX_STRIP_BINARIES" ]; then \
        strip --strip-unneeded objs/*.so || exit 1; \
    fi \
    && apk del --no-network .build-deps

FROM base AS dist

LABEL org.opencontainers.image.authors="honeok <i@honeok.com>"

## nginx version.
ARG NGINX_VERSION=
ENV NGINX_VERSION=$NGINX_VERSION

## third-party modules.
# https://github.com/leev/ngx_http_geoip2_module
ARG NGX_GEOIP2_VERSION=

# https://github.com/openresty/headers-more-nginx-module
ARG HEADERS_MORE_VERSION=

# https://github.com/facebook/zstd
ARG NGX_ZSTD_VERSION=

# https://github.com/nginx/pkg-oss/blob/master/alpine/Makefile
# parameter order follows `./configure --help`.
ARG NGX_CONFIGURE_OPTIONS="\
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
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
    --http-log-path=/var/log/nginx/access.log \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_ssl_preread_module \
    --with-compat \
    "

ARG NGX_ADD_MODULE_OPTIONS="\
    --add-module=../ngx_brotli \
    --add-module=../ngx_http_geoip2_module-$NGX_GEOIP2_VERSION \
    --add-module=../headers-more-nginx-module-$HEADERS_MORE_VERSION \
    --add-module=../zstd-nginx-module \
    "

# https://github.com/nginx/pkg-oss/blob/master/alpine/alpine/APKBUILD-base.in
ARG NGX_TOOLCHAIN_OPTIONS="\
    --with-cc-opt='-Os -fstack-clash-protection -Wformat -Werror=format-security -fno-plt' \
    --with-ld-opt='-Wl,--as-needed,-O1,--sort-common -Wl,-z,pack-relative-relocs' \
    "

ARG NGX_STRIP_BINARIES=

# Copy prebuilt dynamic modules.
COPY --from=build /tmp/nginx-$NGINX_VERSION/objs/*.so /usr/lib/nginx/modules/

RUN set -ex \
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && apk add --no-cache --virtual .build-deps \
        build-base \
        cmake \
        git \
        libmaxminddb-dev \
        linux-headers \
        openssl-dev \
        pcre2-dev \
        tar \
        zlib-dev \
    && apk add --no-cache \
        curl \
        gettext-envsubst \
        tzdata \
    && cd /tmp \
##############################
# Install third-party modules.
    && git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli \
# Fix https://github.com/google/ngx_brotli/issues/97
    && curl -fsSL https://salsa.debian.org/nginx-team/libnginx-mod-http-brotli/raw/debian/latest/debian/patches/0001-Fix-Vary-header.patch | patch -d ngx_brotli -p1 \
    && cmake \
        -S ngx_brotli/deps/brotli \
        -B ngx_brotli/deps/brotli/out \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
    && cmake \
        --build ngx_brotli/deps/brotli/out \
        --target brotlienc \
        --parallel $(getconf _NPROCESSORS_ONLN) \
    && curl -fsSL https://github.com/leev/ngx_http_geoip2_module/archive/$NGX_GEOIP2_VERSION.tar.gz | tar fxz - \
    && curl -fsSL https://github.com/openresty/headers-more-nginx-module/archive/v$HEADERS_MORE_VERSION.tar.gz | tar fxz - \
    && curl -fsSL https://github.com/facebook/zstd/releases/download/v$NGX_ZSTD_VERSION/zstd-$NGX_ZSTD_VERSION.tar.gz | tar fxz - \
    && make -j$(getconf _NPROCESSORS_ONLN) -C zstd-$NGX_ZSTD_VERSION/lib \
        MOREFLAGS="-fPIC" libzstd.a \
    && export ZSTD_INC="/tmp/zstd-$NGX_ZSTD_VERSION/lib" \
    && export ZSTD_LIB="/tmp/zstd-$NGX_ZSTD_VERSION/lib" \
    && git clone --depth=10 https://github.com/tokers/zstd-nginx-module \
##############################
# Build nginx.
    && curl -fsSL https://github.com/nginx/nginx/releases/download/release-$NGINX_VERSION/nginx-$NGINX_VERSION.tar.gz | tar fxz - \
    && cd nginx-$NGINX_VERSION \
    && eval ./configure $NGX_CONFIGURE_OPTIONS $NGX_ADD_MODULE_OPTIONS $NGX_TOOLCHAIN_OPTIONS \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
##############################
# https://github.com/nginx/pkg-oss/blob/master/alpine/alpine/APKBUILD-base.in
    && mkdir -p \
        /var/cache/nginx \
        /usr/share/nginx \
        /usr/lib/nginx/modules \
    && mv /etc/nginx/html /usr/share/nginx \
    && ln -sf /usr/lib/nginx/modules /etc/nginx/modules \
    && rm -f \
        /etc/nginx/*.default \
        /etc/nginx/koi-utf \
        /etc/nginx/koi-win \
        /etc/nginx/win-utf \
# forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
# create a docker-entrypoint.d directory
    && mkdir /docker-entrypoint.d \
##############################
# strip installed ELF executables and shared objects.
# https://gitlab.alpinelinux.org/alpine/abuild/-/blob/master/abuild.in
    && if [ -n "$NGX_STRIP_BINARIES" ]; then \
        scanelf --recursive --nobanner --osabi --etype 'ET_DYN,ET_EXEC' \
            /usr/sbin/nginx \
            /usr/lib/nginx/modules \
        | while read -r type osabi filename; do \
            [ -e "$filename" ] || continue; \
            [ "$osabi" != "STANDALONE" ] || continue; \
            strip --strip-unneeded "$filename" || exit 1; \
        done; \
    fi \
##############################
# resolve runtime shared library deps.
    && runDeps="$( \
        scanelf --recursive --nobanner --needed --format '%n#p' \
            /usr/sbin/nginx \
            /usr/lib/nginx/modules \
        | tr ',' '\n' \
        | sort -u \
        | sed '/^$/d; s/^/so:/' \
    )" \
    && apk add --no-network --virtual .runDeps $runDeps \
    && apk del --no-network .build-deps \
    && rm -rf /var/cache/apk/* /tmp/*

# Copy nginx configuration files.
# https://github.com/nginx/pkg-oss/blob/master/alpine/alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.default.conf /etc/nginx/conf.d/default.conf

# https://github.com/nginx/docker-nginx/tree/master/entrypoint
COPY --chmod=755 docker-entrypoint.sh /
COPY --chmod=755 10-listen-on-ipv6-by-default.sh /docker-entrypoint.d
COPY --chmod=755 15-local-resolvers.envsh /docker-entrypoint.d
COPY --chmod=755 20-envsubst-on-templates.sh /docker-entrypoint.d
COPY --chmod=755 30-tune-worker-processes.sh /docker-entrypoint.d
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

# Use SIGQUIT instead of default SIGTERM to cleanly drain requests.
# See https://github.com/nginx/docker-nginx/issues/377
STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
