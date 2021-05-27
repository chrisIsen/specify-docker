FROM python:3.8.10-alpine

RUN apk update && apk add --no-cache \
	uwsgi-python3 \
	imagemagick \
	ghostscript
	
RUN pip3 install virtualenv

RUN mkdir -p /var/www/bottlebase

WORKDIR /var/www/bottlebase

COPY requirements.txt .
COPY settings.py .
COPY server.py .
COPY views .

RUN mkdir /opt/venv && \
	virtualenv /opt/venv/bottlebase -p python3 && \
	/opt/venv/bottlebase/bin/pip3 install bottle && \
	/opt/venv/bottlebase/bin/pip3 install -r /var/www/bottlebase/requirements.txt

#RUN pip3 install bottle
#RUN pip3 install --no-cache-dir -r requirements.txt

EXPOSE 8081
EXPOSE 80

#CMD python3 server.py

CMD [ "uwsgi", \
	"--socket", "0.0.0.0:8081", \
	"--uid", "uwsgi", \
	"--plugins", "python3", \
	"--protocol", "uwsgi", \
	"--virtualenv", "/opt/venv/bottlebase", \
	"--wsgi-file", "server.py" ]

