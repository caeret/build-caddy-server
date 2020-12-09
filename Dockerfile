FROM golang:1.13-alpine

LABEL maintainer "NODA, Kai <nodakai@gmail.com>"

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

RUN apk add --no-cache git sed

WORKDIR /app
ENV GO111MODULE=on
ENV GOPROXY="https://goproxy.io,direct"

CMD /app/build.sh
