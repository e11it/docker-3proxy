FROM alpine:3.7
MAINTAINER Ilya Makarov <im@e11it.ru>

LABEL version="0.8.11"

ENV PROXY_VER=0.8.11

RUN adduser -S -H -u 4000 3proxy &&\
    mkdir -p /etc/3proxy &&\
    chown 3proxy /etc/3proxy

# Add config file
ADD 3proxy.cfg /etc/3proxy/3proxy.cfg
ADD .proxyauth /etc/3proxy/.proxyauth

RUN apk add --update ca-certificates git wget gcc make libc-dev linux-headers && \
    wget https://github.com/z3APA3A/3proxy/archive/${PROXY_VER}.tar.gz -P / &&\
    tar xvzf /${PROXY_VER}.tar.gz -C /tmp &&\
	# Enable anonymous mode
    echo '#define ANONYMOUS 1' >> /tmp/3proxy-${PROXY_VER}/src/3proxy.h &&\
    # Make and intall 3proxy
    make -C /tmp/3proxy-${PROXY_VER}/ -f Makefile.Linux &&\
    make -C /tmp/3proxy-${PROXY_VER}/ -f Makefile.Linux install &&\
    apk del git wget gcc make libc-dev linux-headers &&\
    rm /${PROXY_VER}.tar.gz &&\
    rm -rf /tmp/3proxy-${PROXY_VER}/ &&\
    rm /var/cache/apk/*

# Ports
EXPOSE 8080 3128

STOPSIGNAL SIGTERM

CMD [ "/usr/local/bin/3proxy", "/etc/3proxy/3proxy.cfg" ]
