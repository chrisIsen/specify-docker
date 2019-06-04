#!make

PWD := $(shell pwd)
UID := $(shell id -u)
GID := $(shell id -g)
URL_VNC := https://raw.githubusercontent.com/danielguerra69/alpine-vnc/3.6/x11vnc/APKBUILD

init:
	@mkdir -p x11vnc && test -f x11vnc/APKBUILD || \
		wget -qO x11vnc/APKBUILD $(URL_VNC)

build:
	docker build -t recraft/alpine-vnc-build:3.6 .
	mkdir -p dist
	docker run -d --name alpine-vnc-build \
			-u $(UID):$(GID) \
			recraft/alpine-vnc-build:3.6
	docker cp alpine-vnc-build:/home/sdk/.abuild/ dist/
	docker cp alpine-vnc-build:/home/sdk/packages/unmaintained/x86_64/ dist/
#		-v $(PWD)/dist/build:/home/sdk/.abuild \
#		-v $(PWD)/dist/apk:/home/sdk/packages/unmaintained/x86_64 
	docker rm alpine-vnc-build
	mv dist/x86_64/* dist
	mv dist/.abuild/* dist
	rm -rf dist/.abuild dist/x86_64
