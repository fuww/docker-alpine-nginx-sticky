# docker-alpine-nginx-sticky

Alpine-based nginx Docker image with sticky session support and upstream dynamic servers module.

## Components

- **Alpine Linux**: 3.23
- **nginx**: 1.28.0 (stable)
- **nginx-sticky-module-ng**: [fabianofurtado/nginx_sticky_module_ng](https://github.com/fabianofurtado/nginx_sticky_module_ng) (with nginx 1.26+ compatibility patches)
- **nginx-upstream-dynamic-servers**: [DawtCom/nginx-upstream-dynamic-servers](https://github.com/DawtCom/nginx-upstream-dynamic-servers)

## Usage

Pull from GitHub Container Registry:
```bash
docker pull ghcr.io/fuww/docker-alpine-nginx-sticky:latest
```

Or build locally:
```bash
docker build -t nginx-sticky .
```

## Features

- Session persistence using cookies (sticky module)
- Dynamic upstream server resolution
- Standard nginx modules (SSL, HTTP/2, gzip, etc.)
- IPv6 disabled for compatibility
