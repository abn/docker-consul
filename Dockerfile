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

ARG VERSION

ENV PACKAGE github.com/hashicorp/consul
ENV VERSION ${VERSION}
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

ENV ROOTFS rootfs

ENV DEST ${ROOTFS}
RUN loadbins ./bin/consul
RUN find ${ROOTFS} -name "*.so" -exec loadbins {} \;

RUN mkdir -p ${ROOTFS}/var/lib/consul ${ROOTFS}/etc/consul ${ROOTFS}/usr/bin
RUN cp ./bin/consul ${ROOTFS}/usr/bin/consul

# install ui build requirements
RUN dnf -y install \
    make ruby rubygems ruby-devel rubygem-bundler gcc-c++ redhat-rpm-config

# build ui
RUN cd ./ui && bundle && make dist

# prepare ui files
RUN mkdir -p ${ROOTFS}/usr/share
RUN mv ./ui/dist ${ROOTFS}/usr/share/consul-ui

# build image
COPY Dockerfile.final Dockerfile
CMD docker build -t alectolytic/consul ${PWD}
