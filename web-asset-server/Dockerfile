FROM python:2-alpine
RUN apk update && apk add --no-cache \
	imagemagick
ADD requirements.txt /
ADD settings.py /
ADD server.py /
ADD views /views/
RUN pip install bottle
RUN pip install -r requirements.txt
EXPOSE 8080
CMD ["python", "server.py"]
