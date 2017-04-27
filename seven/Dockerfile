FROM python:2.7

ENV PYTHONUNBUFFERED 1

RUN apt-get -y update && apt-get install -y \
	curl \
	libmysqlclient-dev \
	build-essential

RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get install -y nodejs

RUN mkdir /code
ADD ./specify7 /code/

WORKDIR /code

RUN pip install -r requirements.txt

# attempt to fix some complainst from frontend JS dependencies installs
RUN npm install minimatch@3.0.2
RUN echo '{ "allow_root": true }' > /root/.bowerrc

RUN make

VOLUME /code
EXPOSE 8000

#RUN sed -i "s/127\.0\.0\.1/0\.0\.0\.0/g" specifyweb/settings/__init__.py

CMD ["python", "specifyweb/manage.py", "runserver", "0.0.0.0:8000"]
