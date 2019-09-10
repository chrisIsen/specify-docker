FROM python:2.7-stretch

ENV PYTHONUNBUFFERED 1

RUN apt-get -y update && apt-get install -y \
	curl \
	default-libmysqlclient-dev \
	build-essential

RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
#RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

RUN mkdir /code
ADD ./specify7 /code/

WORKDIR /code

RUN apt-get install -y \
	libsasl2-dev python-dev libldap2-dev libssl-dev

RUN pip install -r requirements.txt

# attempt to fix some complaints from frontend JS dependencies installs
RUN npm install minimatch@3.0.2
RUN echo '{ "allow_root": true }' > /root/.bowerrc

RUN pip install virtualenv && virtualenv ve && . ve/bin/activate && make build

ADD Specify_unix_64.sh /opt

VOLUME /code

EXPOSE 8000
EXPOSE 9000
EXPOSE 9191

RUN apt-get -y update && apt-get install -y \
	uwsgi \
	uwsgi-plugin-python

RUN sed -i "s/127\.0\.0\.1/0\.0\.0\.0/g" specifyweb/settings/__init__.py
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
#CMD ["uwsgi", "/code/uwsgi.ini"]

COPY ./uwsgi.ini /code/uwsgi.ini
#CMD ["uwsgi", "--master", "--plugin", "python", "--ini", "/code/uwsgi.ini", "--chdir", "/code"]

