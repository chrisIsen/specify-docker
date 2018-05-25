FROM danielguerra/alpine-sdk-build:3.6 as builder
RUN docker-entrypoint.sh
USER root
RUN apk add libxtst-dev xorg-server-dev
RUN mkdir -p /tmp/aports/unmaintained/x11vnc
COPY x11vnc/APKBUILD /tmp/aports/unmaintained/x11vnc/APKBUILD
RUN chown -R sdk:sdk /tmp/aports
USER sdk
RUN build unmaintained x11vnc
VOLUME /home/sdk/.abuild /home/sdk/packages/unmaintained/x86_64

