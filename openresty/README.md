# OpenResty

<img src="https://cdn.jsdelivr.net/gh/marwin1991/profile-technology-icons@7fe6a09977843ed4636e297fd97d90eee5a1fa76/icons/openresty.png" alt="openresty" width="250">

[![GitHub Release](https://img.shields.io/github/v/tag/openresty/openresty.svg?label=stable&logo=github&color=blue)](https://github.com/openresty/openresty)
[![GitHub Release](https://img.shields.io/github/v/tag/teddysun/openresty.svg?label=edge&logo=github&color=blue)](https://github.com/teddysun/openresty)
[![Docker Pulls](https://img.shields.io/docker/pulls/honeok/openresty.svg?color=blue&logoColor=white)](https://hub.docker.com/r/honeok/openresty)
[![Docker Image Size](https://img.shields.io/docker/image-size/honeok/openresty.svg?color=blue&logoColor=white)](https://hub.docker.com/r/honeok/openresty)
[![License](https://img.shields.io/badge/License-BSD%202--Clause-blue.svg)](https://github.com/honeok/docker-nginxkit)

[OpenResty][1]® is a full-fledged web platform that integrates an enhanced version of the Nginx core, an enhanced version of [LuaJIT][2], many carefully written Lua libraries, lots of high-quality 3rd-party Nginx modules, and most of their external dependencies. It is designed to help developers easily build scalable web applications, web services, and dynamic web gateways.

Maintained by [honeok][3]. Source code is available at [honeok/docker-nginxkit][4].

## Introduction

- Built from source based on the build configuration used by the official OpenResty Alpine image.
- All images are built exclusively on Alpine Linux; no other base distributions are provided.
- Keeps the final image small by removing build dependencies and unnecessary files after compilation.
- Adds Brotli, Zstandard, GeoIP2, and ACME as dynamically loadable modules.

## Quick Start

### stable

Built from official OpenResty sources.

```shell
docker run -d --name openresty -p 80:80 honeok/openresty:alpine
```

### edge

Based on the OpenResty version maintained by [teddysun][5], with the goal of tracking the latest NGINX core.

```shell
docker run -d --name openresty -p 80:80 honeok/openresty:alpine-edge
```

### Dynamic module

To enable the bundled dynamic modules, edit the OpenResty configuration file:

```shell
vim /usr/local/openresty/nginx/conf/nginx.conf
```

```nginx
load_module modules/ngx_http_acme_module.so;
load_module modules/ngx_http_brotli_filter_module.so;
load_module modules/ngx_http_brotli_static_module.so;
load_module modules/ngx_http_geoip2_module.so;
load_module modules/ngx_stream_geoip2_module.so;
load_module modules/ngx_http_zstd_filter_module.so;
load_module modules/ngx_http_zstd_static_module.so;
```

For configuration details, see the official [documentation][6].

## Acknowledgements

Thanks to [Yichun Zhang][7] (agentzh), the OpenResty team, [teddysun][8], and the maintainers of the third-party modules included in this image.

This is an independent, unofficial build and is not affiliated with or endorsed by [OpenResty Inc.][9] or the OpenResty project.

OpenResty® is a registered trademark owned by [OpenResty Inc.][9].

[1]: https://openresty.org
[2]: https://github.com/openresty/luajit2
[3]: https://honeok.dev
[4]: https://github.com/honeok/docker-nginxkit
[5]: https://github.com/teddysun/openresty
[6]: https://openresty.org/en/getting-started.html
[7]: https://agentzh.org
[8]: https://teddysun.com
[9]: https://openresty.com
