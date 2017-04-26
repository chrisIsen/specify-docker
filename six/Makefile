#!make
PWD := $(shell pwd)
NAME := dina/specify-desktop:v6.6.05
XSOCK := /tmp/.X11-unix/X0
SRC_SW := http://update.specifysoftware.org/Specify_unix_64.sh

all: clean init build
.PHONY: all

init:
	@echo "Caching downloads locally..."
	@test -f Specify_unix_64.sh || \
		(wget $(SRC_SW) && chmod +x $(SRC_SW))

	@test -f wait-for-it.sh || \
		(wget https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && \
		chmod +x wait-for-it.sh)

build:
	@docker build --tag $(NAME) .

debug-ui:
	xhost +local:
	docker exec -it \
		specifydesktopdocker_ui_1 bash

get-ui-shell:
	@docker exec -it specifydesktopdocker_ui_1 \
		bash

clean:
	rm -f Specify_unix_64.sh wait-for-it.sh

release:
	docker push $(NAME)
