FROM ubuntu:18.04

ENV PYTHONUNBUFFERED 1

# REM: non-interactive build -> configure tzdata

ENV TZ=Europe/Stockholm
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone

# REM: libs required for build

RUN apt-get -y update && apt-get install -y \
	curl \
	unzip \
	git \
	build-essential \		
	libmariadbclient-dev \
	apache2 \
	openjdk-11-jre-headless \
	libapache2-mod-wsgi-py3 \
	libldap2-dev \
	libsasl2-dev \
	nodejs \
	npm \
	python3.6 \
	python3-dev \
	python3-lxml \
	python3-venv
	
RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# REM: system user for running specify7 behind apache web server

RUN groupadd -g 999 specify && \
    useradd -r -u 999 -g specify specify

RUN mkdir -p /home/specify /opt/specify7 && \
	chown -R specify.specify /home/specify /opt/specify7

# REM: install specify 7
		
USER specify
COPY --chown=specify:specify ./specify7 /opt/specify7

WORKDIR /opt/specify7

ENV VIRTUAL_ENV /env
ENV PATH /env/bin:$PATH

RUN python3.6 -m venv ve && \
	ve/bin/pip install wheel && \
	ve/bin/pip install --no-cache-dir -r requirements.txt

RUN . ve/bin/activate && make specifyweb/settings/build_version.py specifyweb/settings/secret_key.py frontend && \
    rm -rf specifyweb/frontend/js_src/bower_components specifyweb/frontend/js_src/node_modules && \
    rm -rf /home/specify/.npm /home/specify/.cache && \
	mkdir -p /home/specify/wb_upload_logs /home/specify/specify_depository

# REM: install web-asset-server, inspired from ...
# https://github.com/specify/specify7-docker/blob/master/Dockerfile

USER root

#RUN cd /opt/ && \
#	git clone --depth=1 https://github.com/specify/web-asset-server/ && \
#	chown -R specify:specify web-asset-server

#WORKDIR /opt/web-asset-server

#USER specify

#RUN python3.6 -m venv ve && . ve/bin/activate && \
#	ve/bin/pip install -r requirements.txt 
	
#RUN sed -i "s/'test_attachment_key'/None/" settings.py && \
#	sed -i "s/8080/8081/" settings.py

# REM: enable apache2 integration for specify7

#USER root

RUN rm /etc/apache2/sites-enabled/* && \
	ln -s /opt/specify7/specifyweb_apache.conf /etc/apache2/sites-enabled/

# REM: add Specify 6 installer
ADD Specify_unix_64.sh /opt

RUN chmod +x /opt/Specify_unix_64.sh && \ 
	bash -c "/opt/Specify_unix_64.sh -q -console" && \
	rm /opt/Specify_unix_64.sh && \
	ln -s /usr/local/Specify/ /opt/Specify

RUN ln -sf /dev/stderr /var/log/apache2/error.log && \
	ln -sf /dev/stdout /var/log/apache2/access.log

#COPY web-asset-server.wsgi /opt/web-asset-server/
#RUN ln -s /opt/web-asset-server/web-asset-server_apache.conf /etc/apache2/sites-enabled/

EXPOSE 80
#EXPOSE 8081
CMD . ve/bin/activate && apachectl -D FOREGROUND
