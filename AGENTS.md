# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Custom NGINX Docker image based on Alpine Linux 3.23, compiled from source with two additional modules:

- **nginx-sticky-module-ng** — sticky session support for upstream load balancing ([fabianofurtado/nginx_sticky_module_ng](https://github.com/fabianofurtado/nginx_sticky_module_ng) fork, maintained for modern nginx)
- **nginx-upstream-dynamic-servers** — dynamic DNS resolution for upstream servers ([DawtCom fork](https://github.com/DawtCom/nginx-upstream-dynamic-servers))

IPv6 is explicitly disabled via `--with-cc-opt="-DNGX_HAVE_INET6=0"`.

Used as the base image for FashionUnited's reverse proxy (`/proxy` repo).

## Build

```bash
docker build -t alpine-nginx-sticky .
```

## Key Versions

Defined as `ENV` variables at the top of the Dockerfile:

- `NGINX_VERSION` — currently 1.26.3 (previous stable, compatible with sticky module)
- `NGINX_STICKY_MODULE_NG_VERSION` — GitHub commit hash (currently `544beae6`, tested against nginx 1.26.0)
- `NGINX_UPSTREAM_DYNAMIC_SERVERS_VERSION` — GitHub branch (currently `master`)

## Architecture

Single-stage Dockerfile that:

1. Downloads and GPG-verifies the NGINX source tarball
2. Downloads both third-party module source archives
3. Compiles NGINX with the full standard module set plus the two add-on modules
4. Strips binaries and removes build dependencies to minimize image size
5. Keeps only `envsubst` from gettext (for runtime config templating)
6. Forwards access/error logs to stdout/stderr for Docker log collection

Exposes ports 80 and 443.
