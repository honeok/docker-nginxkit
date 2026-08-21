# freenginx

[![freenginx](https://cdn.jsdelivr.net/gh/freenginx/nginx-site@28f4a341fdfd502d58894f8391c371237e965f89/binary/nginx.png)](https://freenginx.org)

[![GitHub Release](https://img.shields.io/github/v/tag/freenginx/nginx.svg?label=release&logo=github&color=blue)](https://freenginx.org/hg/nginx)
[![Docker Pulls](https://img.shields.io/docker/pulls/honeok/freenginx.svg?color=blue&logoColor=white)](https://hub.docker.com/r/honeok/freenginx)
[![Docker Image Size](https://img.shields.io/docker/image-size/honeok/freenginx.svg?color=blue&logoColor=white)](https://hub.docker.com/r/honeok/freenginx)
[![License](https://img.shields.io/badge/License-BSD%202--Clause-blue.svg)](https://github.com/honeok/docker-nginxkit)

freenginx is an effort to preserve free and open development of nginx [engine x], an HTTP and reverse proxy server, a mail proxy server, and a generic TCP/UDP proxy server, originally written by [Igor Sysoev][1].

The sources and documentation are distributed under the [2-clause BSD-like license][2].

## Introduction

- Built from FreeNginx source based on the Alpine build configuration from the official NGINX packaging sources.
- All images are built exclusively on Alpine Linux; no other base distributions are provided.
- Keeps the final image small by removing build dependencies and unnecessary files after compilation.
- Includes GeoIP2 for geolocation, Brotli and Zstandard for compression, and Headers More for additional control over HTTP headers.

## Quick Start

```shell
docker run -d --name nginx -p 80:80 honeok/freenginx:alpine
```

For configuration details, see the official [documentation][3].

## Acknowledgements

Special thanks to [Maxim Dounin][4] for his long-standing contributions to NGINX and for creating and maintaining [FreeNginx][5].

Thanks to the maintainers of the third-party modules included in this image.

This is an independent, unofficial build and is not affiliated with or endorsed by [Maxim Dounin][4] or the FreeNginx project.

[1]: http://sysoev.ru
[2]: https://freenginx.org/LICENSE
[3]: https://freenginx.org/en/docs
[4]: https://mdounin.ru
[5]: https://freenginx.org/pipermail/nginx/2024-February/000000.html
