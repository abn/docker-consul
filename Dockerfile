FROM fedora:latest
MAINTAINER Arun Neelicattu <arun.neelicattu@gmail.com>

RUN dnf -y upgrade

# install base requirements
RUN dnf -y install golang git hg 
RUN dnf -y install findutils

# prepare gopath
ENV GOPATH /go
ENV PATH /go/bin:${PATH}
RUN mkdir -p ${GOPATH}

ENV PACKAGE github.com/hashicorp/consul
ENV VERSION 0.5.2
ENV GO_BUILD_TAGS netgo
ENV CGO_ENABLED 1

COPY ./loadbins /usr/bin/loadbins

RUN go get ${PACKAGE}

WORKDIR ${GOPATH}/src/${PACKAGE}
RUN git checkout -b v${VERSION} v${VERSION}

RUN mkdir bin
RUN go build \
        -tags "${GO_BUILD_TAGS}" \
        -ldflags "-s -w -X ${PACKAGE}/version.Version ${VERSION}" \
        -v -a \
        -installsuffix cgo \
        -o ./bin/consul

ENV DEST rootfs
RUN loadbins ./bin/consul
RUN find ./rootfs -name "*.so" -exec loadbins {} \;
RUN mkdir rootfs/data
RUN ls -all rootfs
COPY Dockerfile.final ./Dockerfile

CMD docker build -t alectolytic/consul ${PWD}
