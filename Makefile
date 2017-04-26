#!make
include .env
PWD := $(shell pwd)
NAME := dina/specify-desktop:v6.6.05
XSOCK := /tmp/.X11-unix/X0
#SRC_DATA :=  http://archive.org/download/dw-collectionsdata/dina_web.sql.gz
SRC_DATA := https://github.com/DINA-Web/datasets/blob/master/specify/DemoDatawImages.sql.gz?raw=true
SRC_IMAGES := https://github.com/DINA-Web/datasets/blob/master/specify/AttachmentStorage.zip?raw=true
SRC_SW := http://update.specifysoftware.org/Specify_unix_64.sh

all: clean init build up
.PHONY: all

init:
	@echo "Caching downloads locally..."
	@test -f Specify_unix_64.sh || \
		(wget $(SRC_SW) && chmod +x Specify_unix_64.sh)

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
	@docker build --tag $(NAME) .

debug-ui:
	xhost +local:
	docker exec -it \
		specifydesktopdocker_ui_1 bash

up:
	@echo "Launching services"
	docker-compose up -d 

get-db-shell:
	@docker exec -it specifydesktopdocker_db_1 \
		sh -c "mysql -u root -p$(MYSQL_ROOT_PASSWORD) -D$(MYSQL_DATABASE)"

get-ui-shell:
	@docker exec -it specifydesktopdocker_ui_1 \
		bash

get-s6-login:
	@echo "Getting Specify 6 username from db... did you export the .env?"
	#@export $(cat .env | xargs) > /dev/null
	@docker exec -i specifydesktopdocker_db_1 \
		sh -c "mysql --silent -u root -p$(MYSQL_ROOT_PASSWORD) -D$(MYSQL_DATABASE) \
		-e 'select name, password from specifyuser where SpecifyUserID = 1;'"


clean:
	#rm -f Specify_unix_64.sh
	docker-compose stop
	docker-compose rm -vf

release:
	docker push $(NAME)
