# Angie

[![angie](https://cdn.jsdelivr.net/gh/webserver-llc/angie@e35a7a1253b374d5df4a9cd1535ba20be0e72e6b/misc/logo.gif)](https://en.angie.software)

[![GitHub Release](https://img.shields.io/github/v/tag/webserver-llc/angie.svg?label=release&logo=github&color=blue)](https://github.com/webserver-llc/angie/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/honeok/angie.svg?color=blue&logoColor=white)](https://hub.docker.com/r/honeok/angie)
[![Docker Image Size](https://img.shields.io/docker/image-size/honeok/angie.svg?color=blue&logoColor=white)](https://hub.docker.com/r/honeok/angie)
[![License](https://img.shields.io/badge/License-BSD%202--Clause-blue.svg)](https://github.com/honeok/docker-nginxkit)

**Angie** /ˈendʒi/ is an efficient, powerful, and scalable web server that was forked from **nginx** to act as a drop-in replacement, so you can use existing setups without major changes to module layout or configuration.

The project was conceived by ex-devs from the original **nginx** team to venture beyond the earlier vision.

## Introduction

- Built from Angie source following the official Angie source build configuration.
- All images are built exclusively on Alpine Linux; no other base distributions are provided.
- Keeps the final image small by removing build dependencies and unnecessary files after compilation.
- Keeps the filesystem layout and configuration paths aligned with the official Angie image.
- Includes Brotli, Zstandard, and Headers More as built-in modules, along with other commonly used third-party functionality as dynamically loadable modules.

## Quick Start

```shell
docker run -d --name angie -p 80:80 honeok/angie:alpine
```

### Dynamic modules

Bundled dynamic modules are installed in `/usr/lib/angie/modules`, with `/etc/angie/modules` linked to the same location, following the layout of the official Angie image.

To enable a bundled dynamic module, edit the Angie configuration file:

```shell
vim /etc/angie/angie.conf
```

```nginx
load_module modules/<module>.so;
```

For configuration details, see the official [documentation][3].

## Acknowledgements

Thanks to the Angie team and the maintainers of the third-party modules included in this image.

This is an independent, unofficial build and is not affiliated with or endorsed by [Angie Software][4] or the Angie project.

Angie is developed and maintained by [Angie Software][4] (Web Server, LLC).

[1]: http://sysoev.ru
[2]: https://raw.githubusercontent.com/webserver-llc/angie/master/LICENSE
[3]: https://en.angie.software/angie/docs/configuration/configfile
[4]: https://en.angie.software/company
