# ---
# Go Builder Image
FROM golang:1.11.1-alpine AS builder

#RUN apk update && apk add curl git

#RUN apk --no-cache add 'librdkafka-dev=0.11.5-r0' build-base

#ARG LIBRDKAFKA_VERSION=0.11.5-r0

#RUN apk add librdkafka=${LIBRDKAFKA_VERSION} --update-cache --repository http://nl.alpinelinux.org/alpine/edge/community && \
#    apk add librdkafka-dev=${LIBRDKAFKA_VERSION} --update-cache --repository http://nl.alpinelinux.org/alpine/edge/community 

#RUN go get github.com/confluentinc/confluent-kafka-go/kafka

RUN apk add --update --no-cache alpine-sdk bash ca-certificates \
      libressl \
      tar \
      git openssh openssl yajl-dev zlib-dev cyrus-sasl-dev openssl-dev build-base coreutils
WORKDIR /root
RUN git clone https://github.com/edenhill/librdkafka.git
WORKDIR /root/librdkafka
RUN /root/librdkafka/configure
RUN make
RUN make install
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

RUN go get -d -v github.com/confluentinc/confluent-kafka-go/kafka


# set build arguments: GitHub user and repository
ARG GH_USER
ARG GH_REPO

# Create and set working directory
RUN mkdir -p /go/src/github.com/$GH_USER/$GH_REPO
WORKDIR /go/src/github.com//$GH_USER/$GH_REPO

# copy sources
COPY . .

# Run tests, skip 'vendor'
# RUN go test -v $(go list ./... | grep -v /vendor/)

# Build application
RUN go build -v -o "dist/myapp"

# ---
# Application Runtime Image
#FROM alpine:3.8

# set build arguments: GitHub user and repository
#ARG GH_USER
#ARG GH_REPO

# copy file from builder image
#COPY --from=builder /go/src/github.com/$GH_USER/$GH_REPO/dist/myapp /usr/bin/myapp

EXPOSE 8080

CMD ["dist/myapp", "--help"]