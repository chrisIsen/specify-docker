#!make
include .env
PWD := $(shell pwd)
XSOCK := /tmp/.X11-unix/X0

all: clean init build up
.PHONY: all

init:
	@test -f data.sql || \
		(curl --progress-bar -L $(SRC_DATA) -o data.sql.gz && \
		gunzip data.sql.gz)

	@test -d AttachmentStorage || \
		(curl --progress-bar -L $(SRC_IMAGES) -o AttachmentStorage.zip && \
		unzip AttachmentStorage.zip)

	@test -f wait-for-it.sh || \
		(wget https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && \
		chmod +x wait-for-it.sh)

	@test -f user.properties || \
		cp user.properties.init user.properties

build:
	cd six && make build
	cd seven && make build
	cd web-asset-server && make build
	cd report-server && make build

debug-ui:
	docker-compose up -d ui
	xhost +local:
	docker exec -it \
		specifydocker_ui_1 bash

up:
	@echo "Launching services"
	docker-compose up -d 

get-db-shell:
	@docker exec -it specifydocker_db_1 \
		sh -c "mysql -u root -p$(MYSQL_ROOT_PASSWORD) -D$(MYSQL_DATABASE)"

get-ui-shell:
	@docker exec -it specifydocker_ui_1 \
		bash

get-s6-login:
	@echo "Getting Specify 6 username from db... did you export the .env?"
	#@export $(cat .env | xargs) > /dev/null
	@docker exec -it specifydocker_db_1 \
		sh -c "mysql --silent -u root -p$(MYSQL_ROOT_PASSWORD) -D$(MYSQL_DATABASE) \
		-e 'select name, password from specifyuser where SpecifyUserID = 1;'"


clean:
	#rm -f Specify_unix_64.sh
	docker-compose stop
	docker-compose rm -vf

down:
	docker-compose down

