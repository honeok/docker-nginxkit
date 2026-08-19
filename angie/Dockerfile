# SPDX-License-Identifier: BSD-2-Clause
# Copyright (c) 2026 honeok <i@honeok.com>

# References:
# https://cn.angie.software/angie/docs/installation/sourcebuild
# https://github.com/nginx/docker-nginx

FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS base

FROM base AS dist

LABEL org.opencontainers.image.authors="honeok <i@honeok.com>"

## angie version.
ARG ANGIE_VERSION=
ENV ANGIE_VERSION=$ANGIE_VERSION

## third-party modules.
# https://cn.angie.software/angie/docs/installation/external-modules

# https://github.com/leev/ngx_http_geoip2_module
ARG NGX_GEOIP2_MODULE=

# https://github.com/openresty/headers-more-nginx-module
ARG RESTY_HEADERS_MORE_MODULE=

# https://github.com/facebook/zstd
ARG ZSTD_VERSION=

# https://github.com/GetPageSpeed/zstd-nginx-module
ARG NGX_ZSTD_MODULE=

## Build arguments.
# https://github.com/webserver-llc/angie/blob/master/auto/options
# https://hg.angie.software/angie/file/e8ff538b1b72/auto/options
# parameter order follows `./configure --help`.
ARG ANGIE_CONFIGURE_OPTIONS="\
    --prefix=/etc/angie \
    --sbin-path=/usr/sbin/angie \
    --modules-path=/usr/lib/angie/modules \
    --conf-path=/etc/angie/angie.conf \
    --error-log-path=/var/log/angie/error.log \
    --pid-path=/run/angie.pid \
    --lock-path=/run/angie.lock \
    --user=angie \
    --group=angie \
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
    --with-http_slice_module \
    --with-http_stub_status_module \
    --with-http_acme_module \
    --http-log-path=/var/log/angie/access.log \
    --http-client-body-temp-path=/var/cache/angie/client_temp \
    --http-proxy-temp-path=/var/cache/angie/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/angie/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/angie/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/angie/scgi_temp \
    --http-acme-client-path=/var/lib/angie/acme \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_acme_module \
    --with-stream_realip_module \
    --with-stream_ssl_preread_module \
    --with-stream_mqtt_preread_module \
    --with-stream_rdp_preread_module \
    --with-compat \
    "

ARG ANGIE_ADD_MODULE_OPTIONS="\
    --add-module=../ngx-brotli-module \
    --add-module=../ngx_http_geoip2_module-$NGX_GEOIP2_MODULE \
    --add-module=../headers-more-nginx-module-$RESTY_HEADERS_MORE_MODULE \
    --add-module=../zstd-nginx-module-$NGX_ZSTD_MODULE \
    "

ARG ANGIE_TOOLCHAIN_OPTIONS="\
    --with-ld-opt='-Wl,--as-needed,-O1,--sort-common -Wl,-z,pack-relative-relocs' \
    "

ARG ANGIE_STRIP_BINARIES=

RUN set -ex \
    && addgroup -g 101 -S angie \
    && adduser -S -D -H -u 101 -h /var/cache/angie -s /sbin/nologin -G angie -g angie angie \
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
    && curl -fsSL https://github.com/openresty/headers-more-nginx-module/archive/v$RESTY_HEADERS_MORE_MODULE.tar.gz | tar fxz - \
    && curl -fsSL https://github.com/facebook/zstd/releases/download/v$ZSTD_VERSION/zstd-$ZSTD_VERSION.tar.gz | tar fxz - \
    && make -j$(getconf _NPROCESSORS_ONLN) -C zstd-$ZSTD_VERSION/lib \
        MOREFLAGS="-fPIC" libzstd.a \
    && export ZSTD_INC="/tmp/zstd-$ZSTD_VERSION/lib" \
    && export ZSTD_LIB="/tmp/zstd-$ZSTD_VERSION/lib" \
    && curl -fsSL https://github.com/GetPageSpeed/zstd-nginx-module/archive/$NGX_ZSTD_MODULE.tar.gz | tar fxz - \
##############################
# Build angie.
    && curl -fsSL https://github.com/webserver-llc/angie/archive/Angie-$ANGIE_VERSION.tar.gz | tar xz --strip-components=1 --one-top-level="angie-$ANGIE_VERSION" \
    && cd angie-$ANGIE_VERSION \
    && eval ./configure $ANGIE_CONFIGURE_OPTIONS $ANGIE_ADD_MODULE_OPTIONS $ANGIE_TOOLCHAIN_OPTIONS \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
##############################
# https://github.com/nginx/pkg-oss/blob/master/alpine/alpine/APKBUILD-base.in
# `/var/lib/angie` ported from official container build parameters for storing acme certificates.
    && mkdir -p \
        /var/cache/angie \
        /var/lib/angie \
        /usr/share/angie \
        /usr/lib/angie/modules \
    && mv /etc/angie/html /usr/share/angie \
    && ln -sf /usr/lib/angie/modules /etc/angie/modules \
    && ln -sf /usr/sbin/angie /usr/sbin/nginx \
    && rm -f \
        /etc/angie/*.default \
        /etc/angie/koi-utf \
        /etc/angie/koi-win \
        /etc/angie/win-utf \
# forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/angie/access.log \
    && ln -sf /dev/stderr /var/log/angie/error.log \
# create a docker-entrypoint.d directory
    && mkdir /docker-entrypoint.d \
##############################
# strip installed ELF executables and shared objects.
# https://gitlab.alpinelinux.org/alpine/abuild/-/blob/master/abuild.in
    && if [ -n "$ANGIE_STRIP_BINARIES" ]; then \
        scanelf --recursive --nobanner --osabi --etype 'ET_DYN,ET_EXEC' \
            /usr/sbin/angie \
            /usr/lib/angie/modules \
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
            /usr/sbin/angie \
            /usr/lib/angie/modules \
        | tr ',' '\n' \
        | sort -u \
        | sed '/^$/d; s/^/so:/' \
    )" \
    && apk add --no-network --virtual .runDeps $runDeps \
    && apk del --no-network .build-deps \
    && rm -rf /var/cache/apk/* /tmp/*

# Copy nginx configuration files.
# https://github.com/nginx/pkg-oss/blob/master/alpine/alpine
COPY angie.conf /etc/angie/angie.conf
COPY angie.vh.default.conf /etc/angie/conf.d/default.conf

# https://github.com/nginx/docker-nginx/tree/master/entrypoint
COPY --chmod=755 docker-entrypoint.sh /
COPY --chmod=755 10-listen-on-ipv6-by-default.sh /docker-entrypoint.d
COPY --chmod=755 15-local-resolvers.envsh /docker-entrypoint.d
COPY --chmod=755 20-envsubst-on-templates.sh /docker-entrypoint.d
COPY --chmod=755 30-tune-worker-processes.sh /docker-entrypoint.d
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

# https://github.com/ammnt/angie
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD ["angie", "-qt"]

# Use SIGQUIT instead of default SIGTERM to cleanly drain requests.
# See https://github.com/nginx/docker-nginx/issues/377
STOPSIGNAL SIGQUIT

CMD ["angie", "-g", "daemon off;"]
