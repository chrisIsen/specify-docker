FROM openjdk:8-jdk-alpine

ENV HOME=/root \
	DEBIAN_FRONTEND=noninteractive \
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8 \
	LC_ALL=C.UTF-8 \
	DISPLAY=:0.0 \
	DISPLAY_WIDTH=1024 \
	DISPLAY_HEIGHT=768

#COPY alpine-vnc-builder/dist/ /tmp/.abuild
#RUN find /tmp/.abuild -name "*.pub" -exec cp {} /etc/apk/keys \;
#RUN apk --no-cache --update add /tmp/.abuild/x11vnc-0.9.13-r0.apk

#RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.6/main" > /etc/apk/repositories
#RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.6/community" >> /etc/apk/repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk update && apk upgrade 

RUN apk --no-cache add \
	bash tini autocutsel \
	x11vnc ttf-dejavu \
	fluxbox \
	git \
	socat \
	supervisor \
	xvfb

# Clone noVNC from github
RUN git clone https://github.com/kanaka/noVNC.git /root/noVNC \
	&& git clone https://github.com/kanaka/websockify /root/noVNC/utils/websockify \
	&& rm -rf /root/noVNC/.git \
	&& rm -rf /root/noVNC/utils/websockify/.git \
	&& apk del git

# Modify the launch script 'ps -p'
RUN sed -i -- "s/ps -p/ps -o pid | grep/g" /root/noVNC/utils/launch.sh

RUN apk add --no-cache unzip gzip xterm

# add Specify
ADD ./Specify_unix_64.sh /usr/src/specify/
ADD ./wait-for-it.sh /usr/src/specify/
WORKDIR /usr/src/specify
RUN chmod +x Specify_unix_64.sh
RUN bash -c "./Specify_unix_64.sh -q -console"
RUN rm ./Specify_unix_64.sh
RUN mkdir -p /opt && ln -s /usr/local/Specify/ /opt/Specify
VOLUME /opt/Specify

RUN cp /etc/X11/xinit/xinitrc /root/.xinitrc
RUN mkdir ~/.vnc && x11vnc -storepasswd 1234 ~/.vnc/passwd

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 8083
ENTRYPOINT [ "tini", "--" ]

WORKDIR /usr/src/Specify

RUN cp /root/noVNC/vnc.html /root/noVNC/index.html

CMD exec /usr/src/specify/wait-for-it.sh --timeout=10 db:3306 -- \
	/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

