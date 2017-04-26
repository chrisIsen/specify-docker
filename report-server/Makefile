PWD := $(shell pwd)

all: init build up test
.PHONY: all

init:
#	@echo "Getting Specify report runner service code from GitHub"
	@test -d report-runner-service || git clone --depth=1 https://github.com/specify/report-runner-service.git

	@echo "Changing Jetty setting to allow access from other containers"	
	@cd report-runner-service && sed 's/name="jetty\.host" default="localhost"/name="jetty.host" default="0.0.0.0"/g' jetty.xml > jetty.xml.tmp && mv jetty.xml.tmp jetty.xml

	@echo "Changing the pom-file to depend on 1.9-dev of barbecue!"
	@cd report-runner-service && sed 's/1.5-beta1/1.9-dev/g' pom.xml > pom.xml.tmp && mv pom.xml.tmp pom.xml
	
build: init
	docker build --tag dina/reportserver:latest .

up:
	docker run --rm --name report -it \
		-p 8080:8080 -v $(PWD)/m2:/root/.m2 \
		dina/reportserver:latest

test:
	firefox http://localhost:8080/ & 

clean:
	docker stop report
	docker rm -vf report
