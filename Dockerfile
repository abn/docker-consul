FROM fedora:latest
MAINTAINER Arun Neelicattu <arun.neelicattu@gmail.com>

ARG VERSION
ENV PACKAGE github.com/hashicorp/consul
ENV VERSION ${VERSION}

ENV URL_PREFIX https://releases.hashicorp.com/consul/${VERSION}
ENV URL_BINARY ${URL_PREFIX}/consul_${VERSION}_linux_amd64.zip
ENV URL_WEBUI  ${URL_PREFIX}/consul_${VERSION}_web_ui.zip

COPY ./loadbins /usr/bin/loadbins

RUN dnf -y upgrade \
        && dnf -y install unzip findutils \
        && dnf -y clean all

ENV WORKSPACE  /build-workspace
ENV ROOTFS ${WORKSPACE}/rootfs
ENV BIN_DIR ${ROOTFS}/usr/bin
ENV WEBUI_DIR ${ROOTFS}/usr/share/consul-ui
RUN mkdir -p ${WORKSPACE} ${ROOTFS} ${BIN_DIR} ${WEBUI_DIR}

WORKDIR ${WORKSPACE}
RUN curl -L -s -o consul.zip ${URL_BINARY} && unzip consul.zip -d ${BIN_DIR}
RUN curl -L -s -o ui.zip ${URL_WEBUI} && unzip ui.zip -d ${WEBUI_DIR}

ENV DEST ${ROOTFS}
RUN loadbins ${BIN_DIR}/consul
RUN find ${ROOTFS} -name "*.so" -exec loadbins {} \;

# create any extra directories required
RUN mkdir -p ${ROOTFS}/var/lib/consul ${ROOTFS}/etc/consul

# build image
COPY Dockerfile.final Dockerfile
CMD docker build -t alectolytic/consul ${PWD}

