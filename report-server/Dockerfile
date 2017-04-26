FROM maven:3-jdk-7-alpine

RUN apk update && apk add git

COPY report-runner-service /usr/src/app

WORKDIR /usr/src/app

# add a font extension jar to src/main/webapp/WEB-INF/lib/
# COPY fonts.jar src/main/webapp/WEB-INF/lib/

RUN git clone https://github.com/barbecue-sf/barbecue.git \
	&& cd barbecue/barbecue \
	&& mvn compile \
	&& mvn install \
	&& cd ../.. && mvn compile

CMD ["mvn", "jetty:run", "-Djetty.host=0.0.0.0"]
