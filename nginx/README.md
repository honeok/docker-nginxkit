# nginx

<img src="https://cdn.jsdelivr.net/gh/marwin1991/profile-technology-icons@7fe6a09977843ed4636e297fd97d90eee5a1fa76/icons/nginx.png" alt="nginx" width="250">

[![GitHub Release](https://img.shields.io/github/v/tag/nginx/nginx.svg?label=release&logo=github&color=blue)](https://github.com/nginx/nginx/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/honeok/nginx.svg?color=blue&logoColor=white)](https://hub.docker.com/r/honeok/nginx)
[![Docker Image Size](https://img.shields.io/docker/image-size/honeok/nginx.svg?color=blue&logoColor=white)](https://hub.docker.com/r/honeok/nginx)
[![License](https://img.shields.io/badge/License-BSD%202--Clause-blue.svg)](https://github.com/honeok/docker-nginxkit)

nginx ("engine x") is an HTTP web server, reverse proxy, content cache, load balancer, TCP/UDP proxy server, and mail proxy server. Originally written by [Igor Sysoev][1] and distributed under the [2-clause BSD License][2].

## Introduction

- Built from source based on the Alpine build configuration from the official NGINX packaging sources.
- All images are built exclusively on Alpine Linux; no other base distributions are provided.
- Keeps the final image small by removing build dependencies and unnecessary files after compilation.
- Keeps the filesystem layout and configuration paths aligned with the official NGINX Alpine image.
- Includes Brotli, Zstandard, and Headers More as built-in modules, along with other commonly used third-party functionality as dynamically loadable modules.

## Quick Start

```shell
docker run -d --name nginx -p 80:80 honeok/nginx:alpine
```

### Dynamic modules

Bundled dynamic modules are installed in `/usr/lib/nginx/modules`, with `/etc/nginx/modules` linked to the same location, following the layout of the official NGINX Alpine image.

To enable a bundled dynamic module, edit the NGINX configuration file:

```shell
vim /etc/nginx/nginx.conf
```

```nginx
load_module modules/<module>.so;
```

For configuration details, see the official [documentation][3].

## Acknowledgements

Thanks to the NGINX team and the maintainers of the third-party modules included in this image.

This is an independent, unofficial build and is not affiliated with or endorsed by [F5, Inc.][4] or the NGINX project.

NGINX® is a registered trademark of [F5, Inc.][4].

[1]: http://sysoev.ru
[2]: https://nginx.org/LICENSE
[3]: https://nginx.org/en/docs
[4]: https://www.f5.com
