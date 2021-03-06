#!/bin/sh

set -eu
set -x

telem=${TELEMETRY-false}
plugins=${PLUGINS-xuqingfeng/caddy-rate-limit,pyed/ipfilter,caeret/caddy-prometheus,nicolasazrak/caddy-cache,captncraig/cors,epicagency/caddy-expires,captncraig/caddy-realip,github.com/caddyserver/dnsproviders/cloudflare,captncraig/cors/caddy,caddyserver/forwardproxy}

echo 'go init mod caddy' && {
    mkdir /tmp/build
    cp main.go /tmp/build
    cd /tmp/build
    go mod init caddy  
}

echo 'go get' && {
    go get github.com/lucas-clemente/quic-go
    go get -v github.com/caddyserver/caddy"${VERSION+@}${VERSION-}"
    cat go.mod
}

echo 'modify main.go' && {
    nl=$(printf '\n')
    ht=$(printf '\t')
    sed -i -re "s/(EnableTelemetry =) .*/\\1 $telem/" main.go
    IFS=,
    if [ -n "$plugins" ]; then
        for p in $plugins; do
            first=${p%%/*}
            case "$first" in
            *.*)
                ;;
            *)
                p=github.com/$p
            esac
            sed -i -e "/plug in plugins here/a\\$nl${ht}_ \"$p\"$nl" main.go
        done
    fi
    unset IFS
    cat main.go
}

echo 'go build (static)' && {
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -tags DISABLE_QUIC,netgo -ldflags '-w'
}

echo 'done' && {
    ls -l caddy
    # the `cp` command below assumes /output is bound to the host directory
    # with e.g. `docker run -v $(pwd):/output`
    cp -a caddy /output
}
