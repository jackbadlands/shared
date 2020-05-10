#!/usr/bin/env make

default: build

capscreen: capscreen.c pmalloc.c visproc.c xcap.c utils.c
	gcc capscreen.c pmalloc.c visproc.c xcap.c utils.c -O2 \
		`pkg-config --cflags --libs x11` -lnetpbm -o capscreen

findpats: utils.c findpats.c pmalloc.c visproc.c utils.c
	gcc findpats.c pmalloc.c utils.c visproc.c -O2 -lnetpbm -o findpats

findpat: utils.c findpat.c pmalloc.c visproc.c utils.c
	gcc findpat.c pmalloc.c utils.c visproc.c -O2 -lnetpbm -o findpat

findpattm: utils.c findpattm.c pmalloc.c visproc.c utils.c
	gcc findpattm.c pmalloc.c utils.c visproc.c -O2 -lnetpbm -o findpattm

build: capscreen findpats findpat findpattm

clean:
	-rm capscreen
	-rm findpats
	-rm findpat
	-rm findpattm
	-rm img.ppm
	-rm out.ppm
	-rm test1/out1.ppm
	-rm test1/out2.ppm
	-rm *~

distclean: clean
	-rm -f slackware_pkg/xvisualprocessing*.tgz


test: build
	./findpats -v test1/pats1 test1/img.ppm test1/out1.ppm
	./findpats -v test1/pats2 test1/img.ppm test1/out2.ppm

run: build
	./capscreen img.ppm
	./findpats -v test1/pats2 img.ppm out.ppm

slack:
	make clean
	make build
	cp capscreen slackware_pkg/
	cp findpats slackware_pkg/
	cp findpat slackware_pkg/
	cp findpattm slackware_pkg/
	pushd slackware_pkg && \
		./build-package && \
		rm capscreen && \
		rm findpats && \
		rm findpat && \
		rm findpattm && \
		popd
	make clean

slackinstall: slack
	-make slackremove
	installpkg slackware_pkg/xvisualprocessing*.tgz

slackremove:
	removepkg xvisualprocessing

