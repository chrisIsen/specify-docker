#! make

include .env
PWD := $(shell pwd)

NOW := $(shell date +%Y%m%d-%H%M%S)
UID = $(shell id -u)
GID = $(shell id -g)

SRC_DATA := https://github.com/DINA-Web/datasets/blob/master/specify/DemoDatawImages.sql.gz?raw=true
SRC_IMAGES := https://github.com/DINA-Web/datasets/blob/master/specify/AttachmentStorage.zip?raw=true
SRC_SW := http://update.specifysoftware.org/Specify_unix_64.sh

all: clean init build up
.PHONY: all

init:
	@echo "Caching downloads locally..."
	@test -f Specify_unix_64.sh || \
		(wget $(SRC_SW) && chmod +x Specify_unix_64.sh) && \
		cp Specify_unix_64.sh six && \
		cp Specify_unix_64.sh seven


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
	cd six && make init && make build
	cd seven && make init && make build
	cd web-asset-server && make build
	cd report-server && make build

up:
	@echo "Launching services"
	docker-compose up -d 

get-db-shell:
	@docker exec -it specifydocker_db_1 \
		sh -c "mysql -u root -p$(MYSQL_ROOT_PASSWORD) -D$(MYSQL_DATABASE)"

get-s6-login:
	@echo "Getting Specify 6 username from db... did you export the .env?"
	#@export $(cat .env | xargs) > /dev/null
	@docker exec -it specifydocker_db_1 \
		sh -c "mysql --silent -u root -p$(MYSQL_ROOT_PASSWORD) -D$(MYSQL_DATABASE) \
		-e 'select name, password from specifyuser where SpecifyUserID = 1;'"

s7-notifications:
	@echo "Running Specify 7 django migrations to support Notifications"
	@docker cp $(PWD)/s7init.sql specifydocker_db_1:/tmp/s7init.sql
	@docker exec -it specifydocker_db_1 \
		bash -c "mysql --silent -u root -p$(MYSQL_ROOT_PASSWORD) -D$(MYSQL_DATABASE) < /tmp/s7init.sql"

	@docker exec -it specifydocker_as_1 \
		bash -c ". ve/bin/activate && make django_migrations"

	@docker exec -it specifydocker_as_1 \
		bash -c ". ve/bin/activate && python manage.py migrate"

clean:
	#rm -f Specify_unix_64.sh
	docker-compose stop
	docker-compose rm -vf

down:
	docker-compose down

ssl-certs:
	@echo "Generating SSL certs using https://hub.docker.com/r/paulczar/omgwtfssl/"
	docker run -v /tmp/certs:/certs \
		-e SSL_SUBJECT=bioatlas.se \
		-e SSL_DNS=specify6.bioatlas.se,specify7.bioatlas.se,reports.bioatlas.se,media.bioatlas.se \
	paulczar/omgwtfssl
	cp /tmp/certs/cert.pem certs/bioatlas.se.crt
	cp /tmp/certs/key.pem certs/bioatlas.se.key

	@echo "Using self-signed certificates will require either the CA cert to be imported system-wide or into apps"
	@echo "if you don't do this, apps will fail to request data using SSL (https)"
	@echo "WARNING! You now need to import the /tmp/certs/ca.pem file into Firefox/Chrome etc"
	@echo "WARNING! For curl to work, you need to provide '--cacert /tmp/certs/ca.pem' switch or SSL requests will fail."

ssl-certs-clean:
	rm -f certs/bioatlas.se.crt certs/bioatlas.se.key
	rm -f /tmp/certs

ssl-certs-show:
	#openssl x509 -in certs/dina-web.net.crt -text
	openssl x509 -noout -text -in certs/bioatlas.se.crt

backup:
	mkdir -p backups
	docker run --rm --volumes-from specifydocker_media_1 \
		-v $(PWD)/backups:/tmp alpine \
		sh -c "tar czf /tmp/specify-files-$(NOW).tgz -C /root/Specify/AttachmentStorage ./"

	docker exec specifydocker_db_1 bash -c \
		"mysqldump -u $(MYSQL_USER) -p'$(MYSQL_PASSWORD)' -h 127.0.0.1 $(MYSQL_DATABASE)" | gzip > backups/specify-db-$(NOW).sql.gz

	cp backups/specify-files-$(NOW).tgz specify-files-latest.tgz
	cp backups/specify-db-$(NOW).sql.gz specify-db-latest.sql.gz

restore:
	docker run --rm --volumes-from specifydocker_media_1 \
		-v $(PWD):/tmp alpine \
		sh -c "cd /root/Specify/AttachmentStorage && tar xvf /tmp/specify-files-latest.tgz"

	gunzip -c specify-db-latest.sql.gz | docker exec -i specifydocker_db_1 \
		mysql -u $(MYSQL_USER) -p'$(MYSQL_PASSWORD)' -h 127.0.0.1 $(MYSQL_DATABASE)

restore-otherbackup:
	cat s6init_gnm.sql | docker exec -i specifydocker_db_1 mysql -u root -p'$(MYSQL_ROOT_PASSWORD)' -h 127.0.0.1
	gunzip -c specify-db-latest.sql.gz | docker exec -i specifydocker_db_1 mysql -u root -p'$(MYSQL_ROOT_PASSWORD)' -h 127.0.0.1



