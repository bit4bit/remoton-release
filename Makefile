XPRA_VERSION = "0.17.5"
XPRA_REVISION = "r13487"

DESCRIPTION="Own remote desktop - platform"
PRODUCT_VERSION="0.0.1"
PACKAGE_DESKTOP_DEPS=-d "libgtk2.0-0 (>= 2.24.0)" -d "xpra (= $(XPRA_VERSION)-1)"
WIN32_CC="i686-w64-mingw32-gcc"
WIN64_CC="x86_64-w64-mingw32-gcc"
GENERAL=--license "MIT" --vendor "bit4bit@riseup.net" -m "bit4bit@riseup.net"
GENERAL_SUPPORT=--description "Support - Own remote desktop platform"
GENERAL_CLIENT=--description "Client - Own remote desktop platform"
GENERAL_SERVER=--description "Server - Own remote desktop platform"

remoton-src:
	go get github.com/bit4bit/remoton/...

deps-bundle:
	wget -c "https://www.xpra.org/dists/windows/Xpra_Setup_$(XPRA_VERSION)-$(XPRA_REVISION).exe" -O vendor/windows/xpra_setup.exe

deps-win32:
	wget -c http://ftp.gnome.org/pub/gnome/binaries/win32/gtk+/2.24/gtk+-bundle_2.24.10-20120208_win32.zip -O vendor/windows/gtk+-2.0-win32.zip
	unzip -d vendor/windows/gtk+-2.0-win32 -u vendor/windows/gtk+-2.0-win32.zip
	bash fix_pkg.sh windows/gtk+-2.0-win32

deps-win64exp:
	wget -c http://ftp.gnome.org/pub/gnome/binaries/win64/gtk+/2.22/gtk+-bundle_2.22.1-20101229_win64.zip -O vendor/windows/gtk+-2.0-win64exp.zip
	unzip -d vendor/windows/gtk+-2.0-win64exp -u vendor/windows/gtk+-2.0-win64exp.zip
	bash fix_pkg.sh windows/gtk+-2.0-win64exp

remoton-client-desktop:
	GOOS=linux GOARCH=386 CGO_ENABLED=1 go build -o $@ github.com/bit4bit/remoton/cmd/remoton-client-desktop
	gzip -k $@

remoton-client-desktop-x86_64:
	GOOS=linux GOARCH=amd64 go build -o $@ github.com/bit4bit/remoton/cmd/remoton-client-desktop
	gzip -k $@

remoton-client-desktop.deb: remoton-client-desktop
	fpm -a i386 -s dir -t deb -n remoton-client-desktop -v $(PRODUCT_VERSION) $(GENERAL) $(GENERAL_CLIENT) $(PACKAGE_DESKTOP_DEPS) remoton-client-desktop=/usr/bin/remoton-client-desktop res/icon.png=/usr/share/icons/remoton-client.png res/remoton-client-desktop.desktop=/usr/share/applications/remoton-client-desktop.desktop

remoton-client-desktop-x86_64.deb: remoton-client-desktop-x86_64
	fpm -a amd64 -s dir -t deb -n remoton-client-desktop -v $(PRODUCT_VERSION) $(GENERAL) $(GENERAL_CLIENT) $(PACKAGE_DESKTOP_DEPS) remoton-client-desktop-x86_64=/usr/bin/remoton-client-desktop res/icon.png=/usr/share/icons/remoton-client.png res/remoton-client-desktop.desktop=/usr/share/applications/remoton-client-desktop.desktop

remoton-client-desktop-win32.exe: deps-win32
	PKG_CONFIG_PATH=$(PWD)/vendor/windows/gtk+-2.0-win32/lib/pkgconfig CC=$(WIN32_CC) CGO_CFLAGS=$(pkg-config --cflags gtk+-2.0) CGO_LDFLAGS=$(pkg-config --libs gtk+-2.0) CGO_ENABLED=1 GOOS=windows GOARCH=386 go build -o $@ -ldflags -H=windowsgui github.com/bit4bit/remoton/cmd/remoton-client-desktop

remoton-client-desktop-win32-runtime: remoton-client-desktop-win32.exe
	mkdir -p release-$@
	cp remoton-client-desktop-win32.exe release-$@/
	cp vendor/windows/gtk+-2.0-win32/bin/*.dll release-$@
	zip -r $@.zip release-$@/*
	rm -rf release-$@
	rm -f $@

remoton-client-desktop-win32-setup: remoton-client-desktop-win32.exe
	mkdir -p installer-win32
	cp vendor/windows/gtk+-2.0-win32/bin/*.dll installer-win32/	
	cp remoton-client-desktop-win32.exe installer-win32/remoton.exe
	cp scripts/installer-remoton-client-desktop.nsi installer-win32/
	cp res/icon.ico installer-win32/
	cp res/LICENSE installer-win32/
	makensis -DPRODUCT_VERSION=$(PRODUCT_VERSION) -DXPRA_VERSION=$(XPRA_VERSION) -DXPRA_REVISION=$(XPRA_REVISION) ./installer-win32/installer-remoton-client-desktop.nsi
	cp installer-win32/installer.exe ./$@.exe
	rm -rf installer-win32

remoton-client-desktop-win32-bundle-setup: deps-bundle deps-win32 remoton-client-desktop-win32.exe
	mkdir -p installer-win32
	cp vendor/windows/xpra_setup.exe installer-win32/
	cp vendor/windows/gtk+-2.0-win32/bin/*.dll installer-win32/
	cp remoton-client-desktop-win32.exe installer-win32/remoton.exe
	cp scripts/installer-remoton-client-desktop.nsi installer-win32/
	cp res/icon.ico installer-win32/
	cp res/LICENSE	installer-win32/
	makensis -DBUNDLE="true" -DPRODUCT_VERSION=$(PRODUCT_VERSION) -DXPRA_VERSION=$(XPRA_VERSION) -DXPRA_REVISION=$(XPRA_REVISION) ./installer-win32/installer-remoton-client-desktop.nsi
	cp installer-win32/installer.exe ./$@.exe
	rm -rf installer-win32

remoton-client-desktop-win64exp.exe: deps-win64exp
	PKG_CONFIG_PATH=$(PWD)/vendor/windows/gtk+-2.0-win64exp/lib/pkgconfig CC=$(WIN64_CC) CGO_CFLAGS=$(pkg-config --cflags gtk+-2.0) CGO_LDFLAGS=$(pkg-config --libs gtk+-2.0) CGO_ENABLED=1 GOOS=windows GOARCH=amd64 go build -o $@ -ldflags -H=windowsgui github.com/bit4bit/remoton/cmd/remoton-client-desktop

remoton-client-desktop-win64exp-runtime: remoton-client-desktop-win64exp.exe
	mkdir -p release-$@
	cp remoton-client-desktop-win64exp.exe release-$@/
	cp vendor/windows/gtk+-2.0-win64exp/bin/*.dll release-$@
	zip -r $@.zip release-$@/*
	rm -rf release-$@
	rm -f $@

remoton-client-desktop-win64exp-setup: deps-win64exp remoton-client-desktop-win64exp.exe
	mkdir -p installer-win64exp
	cp vendor/windows/gtk+-2.0-win64exp/bin/*.dll installer-win64exp/	
	cp remoton-client-desktop-win64exp.exe installer-win64exp/remoton.exe
	cp scripts/installer-remoton-client-desktop.nsi installer-win64exp/
	cp res/icon.ico installer-win64exp/
	cp res/LICENSE installer-win64exp/
	makensis -DPRODUCT_VERSION=$(PRODUCT_VERSION) -DXPRA_VERSION=$(XPRA_VERSION) -DXPRA_REVISION=$(XPRA_REVISION) ./installer-win64exp/installer-remoton-client-desktop.nsi
	cp installer-win64exp/installer.exe ./$@.exe
	rm -rf installer-win64exp

remoton-client-desktop-win64exp-bundle-setup: deps-bundle deps-win64exp remoton-client-desktop-win64exp.exe
	mkdir -p installer-win64exp
	cp vendor/windows/xpra_setup.exe installer-win64exp/
	cp vendor/windows/gtk+-2.0-win64exp/bin/*.dll installer-win64exp
	cp remoton-client-desktop-win64exp.exe installer-win64exp/remoton.exe
	cp scripts/installer-remoton-client-desktop.nsi installer-win64exp/
	cp res/icon.ico installer-win64exp/
	cp res/LICENSE	installer-win64exp/
	makensis -DX64="true" -DBUNDLE="true" -DPRODUCT_VERSION=$(PRODUCT_VERSION) -DXPRA_VERSION=$(XPRA_VERSION) -DXPRA_REVISION=$(XPRA_REVISION) ./installer-win64exp/installer-remoton-client-desktop.nsi
	cp installer-win64exp/installer.exe ./$@.exe
	rm -rf installer-win64exp


remoton-support-desktop:
	GOOS=linux GOARCH=386 CGO_ENABLED=1 go build -o $@ github.com/bit4bit/remoton/cmd/remoton-support-desktop
	gzip -k $@

remoton-support-desktop-x86_64:
	GOOS=linux GOARCH=amd64 go build -o $@ github.com/bit4bit/remoton/cmd/remoton-support-desktop
	gzip -k $@

remoton-support-desktop.deb: remoton-support-desktop
	fpm -a i386 -s dir -t deb -n remoton-support-desktop -v $(PRODUCT_VERSION) $(GENERAL) $(GENERAL_SUPPORT) $(PACKAGE_DESKTOP_DEPS) remoton-support-desktop=/usr/bin/remoton-support-desktop res/icon.png=/usr/share/icons/remoton-support.png res/remoton-support-desktop.desktop=/usr/share/applications/remoton-support-desktop.desktop

remoton-support-desktop-x86_64.deb: remoton-support-desktop-x86_64
	fpm -a amd64 -s dir -t deb -n remoton-support-desktop -v $(PRODUCT_VERSION) $(GENERAL) $(GENERAL_SUPPORT) $(PACKAGE_DESKTOP_DEPS) remoton-support-desktop-x86_64=/usr/bin/remoton-support-desktop res/icon.png=/usr/share/icons/remoton-support.png res/remoton-support-desktop.desktop=/usr/share/applications/remoton-support-desktop.desktop

remoton-support-desktop-win32.exe: deps-win32
	PKG_CONFIG_PATH=$(PWD)/vendor/windows/gtk+-2.0-win32/lib/pkgconfig CC=$(WIN32_CC) CGO_CFLAGS=$(pkg-config --cflags gtk+-2.0) CGO_LDFLAGS=$(pkg-config --libs gtk+-2.0) CGO_ENABLED=1 GOOS=windows GOARCH=386 go build -o $@ -ldflags -H=windowsgui github.com/bit4bit/remoton/cmd/remoton-support-desktop

remoton-support-desktop-win32-runtime: remoton-support-desktop-win32.exe
	mkdir -p release-$@
	cp remoton-support-desktop-win32.exe release-$@/
	cp vendor/windows/gtk+-2.0-win32/bin/*.dll release-$@
	zip -r $@.zip release-$@/*
	rm -rf release-$@
	rm -f $@

remoton-support-desktop-win32-setup: deps-win32 remoton-support-desktop-win32.exe
	mkdir -p support-setup-win32
	cp vendor/windows/gtk+-2.0-win32/bin/*.dll support-setup-win32/
	cp remoton-support-desktop-win32.exe support-setup-win32/remoton.exe
	cp scripts/installer-remoton-support-desktop.nsi support-setup-win32/installer.nsi
	cp res/icon.ico support-setup-win32/
	cp res/LICENSE	support-setup-win32/
	makensis -DPRODUCT_VERSION=$(PRODUCT_VERSION) -DXPRA_VERSION=$(XPRA_VERSION) -DXPRA_REVISION=$(XPRA_REVISION) ./support-setup-win32/installer.nsi
	cp support-setup-win32/installer.exe ./$@.exe
	rm -rf support-setup-win32

remoton-support-desktop-win32-bundle-setup: deps-bundle deps-win32 remoton-support-desktop-win32.exe
	mkdir -p support-setup-win32
	cp vendor/windows/xpra_setup.exe support-setup-win32/
	cp vendor/windows/gtk+-2.0-win32/bin/*.dll support-setup-win32/
	cp remoton-support-desktop-win32.exe support-setup-win32/remoton.exe
	cp scripts/installer-remoton-support-desktop.nsi support-setup-win32/installer.nsi
	cp res/icon.ico support-setup-win32/
	cp res/LICENSE	support-setup-win32/
	makensis -DBUNDLE="true" -DPRODUCT_VERSION=$(PRODUCT_VERSION) -DXPRA_VERSION=$(XPRA_VERSION) -DXPRA_REVISION=$(XPRA_REVISION) ./support-setup-win32/installer.nsi
	cp support-setup-win32/installer.exe ./$@.exe
	rm -rf support-setup-win32

remoton-support-desktop-win64exp.exe: deps-win64exp
	PKG_CONFIG_PATH=$(PWD)/vendor/windows/gtk+-2.0-win64exp/lib/pkgconfig CC=$(WIN64_CC) CGO_CFLAGS=$(pkg-config --cflags gtk+-2.0) CGO_LDFLAGS=$(pkg-config --libs gtk+-2.0) CGO_ENABLED=1 GOOS=windows GOARCH=amd64 go build -o $@ -ldflags -H=windowsgui github.com/bit4bit/remoton/cmd/remoton-support-desktop

remoton-support-desktop-win64exp-runtime: remoton-support-desktop-win64exp.exe
	mkdir -p release-$@
	cp remoton-support-desktop-win64exp.exe release-$@/
	cp vendor/windows/gtk+-2.0-win64exp/bin/*.dll release-$@/
	zip -r $@.zip release-$@/*
	rm -rf release-$@
	rm -f $@

remoton-support-desktop-win64exp-setup: remoton-support-desktop-win64exp.exe
	mkdir -p support-setup-win64exp
	cp vendor/windows/gtk+-2.0-win64exp/bin/*.dll support-setup-win64exp/
	cp remoton-support-desktop-win64exp.exe support-setup-win64exp/remoton.exe
	cp scripts/installer-remoton-support-desktop.nsi support-setup-win64exp/installer.nsi
	cp res/icon.ico support-setup-win64exp/
	cp res/LICENSE support-setup-win64exp/
	makensis -DX64="true" -DPRODUCT_VERSION=$(PRODUCT_VERSION) -DXPRA_VERSION=$(XPRA_VERSION) -DXPRA_REVISION=$(XPRA_REVISION) ./support-setup-win64exp/installer.nsi
	cp support-setup-win64exp/installer.exe ./$@.exe
	rm -rf support-setup-win64exp

remoton-support-desktop-win64exp-bundle-setup: deps-bundle remoton-support-desktop-win64exp.exe
	mkdir -p support-setup-win64exp
	cp vendor/windows/xpra_setup.exe support-setup-win64exp/
	cp vendor/windows/gtk+-2.0-win64exp/bin/*.dll support-setup-win64exp/
	cp remoton-support-desktop-win64exp.exe support-setup-win64exp/remoton.exe
	cp res/icon.ico support-setup-win64exp/
	cp res/LICENSE support-setup-win64exp/
	cp scripts/installer-remoton-support-desktop.nsi support-setup-win64exp/installer.nsi
	makensis -DBUNDLE="true" -DX64="true" -DPRODUCT_VERSION=$(PRODUCT_VERSION) -DXPRA_VERSION=$(XPRA_VERSION) -DXPRA_REVISION=$(XPRA_REVISION) ./support-setup-win64exp/installer.nsi
	cp support-setup-win64exp/installer.exe ./$@.exe
	rm -rf support-setup-win64exp

remoton-server:
	GOOS=linux GOARCH=386 CGO_ENABLED=1 go build -o $@ github.com/bit4bit/remoton/cmd/remoton-server
	gzip -k $@

remoton-server-cert:
	GOOS=linux GOARCH=386 go build -o $@ github.com/bit4bit/remoton/cmd/remoton-server-cert
	gzip -k $@

remoton-server-cert-x86_64:
	GOOS=linux GOARCH=amd64 go build -o $@ github.com/bit4bit/remoton/cmd/remoton-server-cert
	gzip -k $@

remoton-server-x86_64:
	GOOS=linux GOARCH=amd64 go build -o $@ github.com/bit4bit/remoton/cmd/remoton-server
	gzip -k $@

remoton-server.deb: remoton-server remoton-server-cert
	fpm -a i386 -s dir -t deb -n remoton-server -v $(PRODUCT_VERSION) $(GENERAL) $(GENERAL_SERVER) remoton-server=/usr/bin/remoton-server remoton-server-cert=/usr/bin/remoton-server-cert
	rm remoton-server
	rm remoton-server-cert

remoton-server-x86_64.deb: remoton-server-x86_64 remoton-server-cert-x86_64
	fpm -a amd64 -s dir -t deb -n remoton-server -v $(PRODUCT_VERSION) $(GENERAL) $(GENERAL_SERVER) remoton-server-x86_64=/usr/bin/remoton-server remoton-server-cert-x86_64=/usr/bin/remoton-server-cert
	rm remoton-server-x86_64
	rm remoton-server-cert-x86_64

remoton-server-win32.exe:
	GOOS=windows GOARCH=386 go build -o $@ github.com/bit4bit/remoton/cmd/remoton-server

remoton-server-win32-runtime: remoton-server-win32.exe
	zip $@.zip remoton-server-win32.exe
	rm remoton-server-win32.exe

remoton-server-win64exp.exe:
	GOOS=windows GOARCH=amd64 go build -o $@ github.com/bit4bit/remoton/cmd/remoton-server

remoton-server-win64exp-runtime: remoton-server-win64exp.exe
	zip $@.zip remoton-server-win64exp.exe
	rm remoton-server-win64exp.exe



all-win32: remoton-client-desktop-win32-runtime remoton-client-desktop-win32-setup remoton-client-desktop-win32-bundle-setup remoton-support-desktop-win32-runtime remoton-support-desktop-win32-setup remoton-support-desktop-win32-bundle-setup remoton-server-win32-runtime

all-win64exp: remoton-client-desktop-win64exp-runtime remoton-client-desktop-win64exp-setup remoton-client-desktop-win64exp-bundle-setup remoton-support-desktop-win64exp-runtime remoton-support-desktop-win64exp-setup remoton-support-desktop-win64exp-bundle-setup remoton-server-win64exp-runtime

all-gnu: remoton-client-desktop.deb remoton-support-desktop.deb remoton-server.deb remoton-client-desktop-x86_64.deb remoton-support-desktop-x86_64.deb remoton-server-x86_64.deb

all: all-gnu all-win32 all-win64exp
	mv remoton-* build/

clean:
	go clean github.com/bit4bit/remoton/cmd/...
	rm -rf build/*

