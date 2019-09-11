#!make
PWD := $(shell pwd)
NAME := recraft/specify-desktop:v6.7.03
XSOCK := /tmp/.X11-unix/X0
SRC_SW := http://update.specifysoftware.org/Specify_unix_64.sh
#SRC_SW := https://github.com/specify/specify6/releases/download/v6.7.03/Specify_unix_64.sh

all: clean init build
.PHONY: all

init:
	@echo "Caching downloads locally..."
	@test -f Specify_unix_64.sh || \
		(wget $(SRC_SW) && chmod +x Specify_unix_64.sh)

	@test -f wait-for-it.sh || \
		(wget https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && \
		chmod +x wait-for-it.sh)

	@test -d novnc || \
		git clone --depth=1 https://github.com/kanaka/noVNC.git novnc && \
		cd novnc && cp vnc.html index.html

build:
#	cd alpine-vnc-builder; make init build
#	@docker -e DISPLAY=$DISPLAY -v $XSOCK:/tmp/.X11-unix -build --tag $(NAME) .
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
