# based on the original stable alpine image
# https://github.com/nginxinc/docker-nginx/blob/014e624239987a0a46bee5b44088a8c5150bf0bb/stable/alpine/Dockerfile

FROM alpine:3.23

ENV NGINX_VERSION 1.26.3
ENV NGINX_STICKY_MODULE_NG_VERSION 544beae626f20276e3ecea18395b158bd995000e
ENV NGINX_UPSTREAM_DYNAMIC_SERVERS_VERSION 6c6335add8f4b9b6310b22fa656a47a0d30243ec

RUN CONFIG="\
	--prefix=/etc/nginx \
	--sbin-path=/usr/sbin/nginx \
	--modules-path=/usr/lib/nginx/modules \
	--conf-path=/etc/nginx/nginx.conf \
	--error-log-path=/var/log/nginx/error.log \
	--http-log-path=/var/log/nginx/access.log \
	--pid-path=/var/run/nginx.pid \
	--lock-path=/var/run/nginx.lock \
	--http-client-body-temp-path=/var/cache/nginx/client_temp \
	--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
	--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
	--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
	--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
	--user=nginx \
	--group=nginx \
	--with-http_ssl_module \
	--with-http_realip_module \
	--with-http_addition_module \
	--with-http_sub_module \
	--with-http_dav_module \
	--with-http_flv_module \
	--with-http_mp4_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_random_index_module \
	--with-http_secure_link_module \
	--with-http_stub_status_module \
	--with-http_auth_request_module \
	--with-http_xslt_module=dynamic \
	--with-http_image_filter_module=dynamic \
	--with-http_geoip_module=dynamic \
	--with-http_perl_module=dynamic \
	--with-threads \
	--with-stream \
	--with-stream_ssl_module \
	--with-http_slice_module \
	--with-mail \
	--with-mail_ssl_module \
	--with-file-aio \
	--with-cc-opt="-DNGX_HAVE_INET6=0" \
	--add-module=/usr/src/nginx_sticky_module_ng-$NGINX_STICKY_MODULE_NG_VERSION \
	--add-module=/usr/src/nginx-upstream-dynamic-servers-$NGINX_UPSTREAM_DYNAMIC_SERVERS_VERSION \
	" \
	&& addgroup -S nginx \
	&& adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
	&& apk add --no-cache --virtual .build-deps \
	gcc \
	libc-dev \
	make \
	openssl-dev \
	pcre-dev \
	zlib-dev \
	linux-headers \
	curl \
	gnupg \
	libxslt-dev \
	gd-dev \
	geoip-dev \
	perl-dev \
	&& curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
	&& curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc -o nginx.tar.gz.asc \
	&& curl -fSL https://github.com/fabianofurtado/nginx_sticky_module_ng/archive/$NGINX_STICKY_MODULE_NG_VERSION.tar.gz -o nginx-sticky-module-ng.tar.gz \
	&& curl -fSL https://github.com/DawtCom/nginx-upstream-dynamic-servers/archive/$NGINX_UPSTREAM_DYNAMIC_SERVERS_VERSION.tar.gz -o nginx-upstream-dynamic-servers.tar.gz \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& curl -fSL https://nginx.org/keys/nginx_signing.key | gpg --import \
	&& curl -fSL https://nginx.org/keys/pluknet.key | gpg --import \
	&& gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
	&& rm -r "$GNUPGHOME" nginx.tar.gz.asc \
	&& mkdir -p /usr/src \
	&& tar -zxC /usr/src -f nginx.tar.gz \
	&& tar -zxC /usr/src -f nginx-sticky-module-ng.tar.gz \
	&& tar -zxC /usr/src -f nginx-upstream-dynamic-servers.tar.gz \
	&& rm nginx.tar.gz \
	&& rm nginx-sticky-module-ng.tar.gz \
	&& rm nginx-upstream-dynamic-servers.tar.gz \
	&& cd /usr/src/nginx-$NGINX_VERSION \
	&& ./configure $CONFIG \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& rm -rf /etc/nginx/html/ \
	&& mkdir /etc/nginx/conf.d/ \
	&& mkdir -p /usr/share/nginx/html/ \
	&& install -m644 html/index.html /usr/share/nginx/html/ \
	&& install -m644 html/50x.html /usr/share/nginx/html/ \
	&& ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
	&& strip /usr/sbin/nginx* \
	&& strip /usr/lib/nginx/modules/*.so \
	&& rm -rf /usr/src/nginx-$NGINX_VERSION \
	&& rm -rf /usr/src/nginx_sticky_module_ng-$NGINX_STICKY_MODULE_NG_VERSION \
	&& rm -rf /usr/src/nginx-upstream-dynamic-servers-$NGINX_UPSTREAM_DYNAMIC_SERVERS_VERSION \
	\
	# Bring in gettext so we can get `envsubst`, then throw
	# the rest away. To do this, we need to install `gettext`
	# then move `envsubst` out of the way so `gettext` can
	# be deleted completely, then move `envsubst` back.
	&& apk add --no-cache --virtual .gettext gettext \
	&& mv /usr/bin/envsubst /tmp/ \
	\
	&& runDeps="$( \
	scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
	| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
	| sort -u \
	| xargs -r apk info --installed \
	| sort -u \
	)" \
	&& apk add --no-cache --virtual .nginx-rundeps $runDeps \
	&& apk del .build-deps \
	&& apk del .gettext \
	&& mv /tmp/envsubst /usr/local/bin/ \
	\
	# forward request and error logs to docker log collector
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
