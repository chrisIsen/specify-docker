#!make

SRC_DATA :=  http://archive.org/download/dw-collectionsdata/dina_web.sql.gz
SRC_SW := http://update.specifysoftware.org/Specify_unix_64.sh

all: build up

init:
	@echo "Caching downloads locally..."
	@test -f Specify_unix_64.sh || \
		(wget $(SRC_SW) && chmod +x Specify_unix_64.sh)

	@echo "Caching db dump from IA..."
	@test -f data.sql || \
		(curl --progress-bar -L $(SRC_DATA) -o data.sql.gz && \
		gunzip data.sql.gz)

	@test -d specify7 || git clone --depth=1 \
		https://github.com/specify/specify7

build:
	docker build -t dina/specify-server:v7 .

up:
	docker-compose up -d

down:
	docker-compose down

clean:
	rm -rf specify7
	rm -f data.sql Specify_unix_64.sh

release:
	docker push $(NAME)

get-specify-login:
	@docker-compose run db \
		sh -c "mysql --silent -u root -p$(MYSQL_ROOT_PASSWORD) -D$(MYSQL_DATABASE) \
		-e 'select name, password from specifyuser where SpecifyUserID = 1;'"

debug:
	docker run --rm -it dina/specify-server:v7 bash

config:
	docker cp dina/specify-server:v7:specifyweb/settings/specify_settings.py .

