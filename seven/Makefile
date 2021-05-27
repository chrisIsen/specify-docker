#!make

SRC_DATA :=  http://archive.org/download/dw-collectionsdata/dina_web.sql.gz
SRC_SW := http://update.specifysoftware.org/Specify_unix_64.sh
SRC_S7 := https://github.com/specify/specify7/archive/v7.5.0.tar.gz


all: build up

init:
	@echo "Caching downloads locally..."
	@test -f Specify_unix_64.sh || \
		(wget $(SRC_SW) && chmod +x Specify_unix_64.sh)

	@echo "Caching downloads locally..."
#	@test -f v7.5.0.tar.gz || \
#		(wget $(SRC_S7) && chmod +x v7.5.0.tar.gz)
	@test -d specify7 || git clone -b 'production' --single-branch --depth=1 \
		https://github.com/specify/specify7

	@echo "Caching db dump from IA..."
	@test -f data.sql || \
		(curl --progress-bar -L $(SRC_DATA) -o data.sql.gz && \
		gunzip data.sql.gz)


build:
	docker build -t kulturutveckling/specify-server:v7.5.0 .

up:
	docker-compose up -d

down:
	docker-compose down

clean:
	rm -rf specify7
	rm -f data.sql Specify_unix_64.sh

release:
	docker push kulturutveckling/specify-server:v7.5.0

get-specify-login:
	@docker-compose run db \
		sh -c "mysql --silent -u root -p$(MYSQL_ROOT_PASSWORD) -D$(MYSQL_DATABASE) \
		-e 'select name, password from specifyuser where SpecifyUserID = 1;'"

debug:
	docker run --rm -it kulturutveckling/specify-server:v7.5.0 bash

config:
	docker cp kulturutveckling/specify-server:v7.5.0:specifyweb/settings/specify_settings.py .

