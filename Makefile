XPRA_VERSION = "0.14.10"
XPRA_REVISION = "r7980"

PRODUCT_VERSION="0.0.1"
PACKAGE_DESKTOP_DEPS=-d "libgtk2.0-0 (>= 2.24.0)" -d "xpra (= $(XPRA_VERSION)-1)"
WIN32_CC="i686-w64-mingw32-gcc"
WIN64_CC="x86_64-w64-mingw32-gcc"
GENERAL=--license "MIT" --vendor "bit4bit@riseup.net" -m "bit4bit@riseup.net"

remoton-src:
	go get github.com/bit4bit/remoton

deps-bundle:
	wget -c "https://www.xpra.org/dists/windows/Xpra_Setup_$(XPRA_VERSION)-$(XPRA_REVISION).exe" -O vendor/windows/xpra_setup.exe

deps-win32:
	wget -c http://ftp.gnome.org/pub/gnome/binaries/win32/gtk+/2.24/gtk+-bundle_2.24.10-20120208_win32.zip -O vendor/windows/gtk+-2.0-win32.zip
	unzip -d vendor/windows/gtk+-2.0-win32 -u vendor/windows/gtk+-2.0-win32.zip
	bash fix_pkg.sh windows/gtk+-2.0-win32

deps-win64:
	wget -c http://ftp.gnome.org/pub/gnome/binaries/win64/gtk+/2.22/gtk+-bundle_2.22.1-20101229_win64.zip -O vendor/windows/gtk+-2.0-win64.zip
	unzip -d vendor/windows/gtk+-2.0-win64 -u vendor/windows/gtk+-2.0-win64.zip
	bash fix_pkg.sh windows/gtk+-2.0-win64

remoton-client-desktop:
	go build -o $@ github.com/bit4bit/remoton/cmd/remoton-client-desktop
	zip $@.zip $@
	rm $@

remoton-client-desktop-x86_64:
	GOOS=linux GOARCH=amd64 go build -o $@ github.com/bit4bit/remoton/cmd/remoton-client-desktop
	zip $@.zip $@
	rm $@

remoton-client-desktop-deb:
	go build -o $@ github.com/bit4bit/remoton/cmd/remoton-client-desktop
	fpm -s dir -t deb -n $@ -v 0.0.1 $(GENERAL) $(PACKAGE_DESKTOP_DEPS) $@=/usr/bin/$@

remoton-client-desktop-x86_64-deb:
	GOOS=linux GOARCH=amd64 go build -o $@ github.com/bit4bit/remoton/cmd/remoton-client-desktop
	fpm -s dir -t deb -n $@ -v 0.0.1 $(GENERAL) $(PACKAGE_DESKTOP_DEPS) $@=/usr/bin/$@

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
	cp remoton-client-desktop-win32.exe installer-win32/remoton-client-desktop.exe
	cp scripts/installer-remoton-client-desktop.nsi installer-win32/
	cp res/icon.ico installer-win32/
	wine "C:\Program Files\NSIS\makensis.exe"  /DPRODUCT_VERSION=$(PRODUCT_VERSION) /DXPRA_VERSION=$(XPRA_VERSION) /DXPRA_REVISION=$(XPRA_REVISION) ./installer-win32/installer-remoton-client-desktop.nsi
	cp installer-win32/installer.exe ./$@.exe
	rm -rf installer-win32

remoton-client-desktop-win32-bundle-setup: deps-bundle deps-win32 remoton-client-desktop-win32.exe
	mkdir -p installer-win32
	cp vendor/windows/xpra_setup.exe installer-win32/
	cp vendor/windows/gtk+-2.0-win32/bin/*.dll installer-win32/
	cp remoton-client-desktop-win32.exe installer-win32/remoton-client-desktop.exe
	cp scripts/installer-remoton-client-desktop.nsi installer-win32/
	cp res/icon.ico installer-win32/
	wine "C:\Program Files\NSIS\makensis.exe"  /DBUNDLE="true" /DPRODUCT_VERSION=$(PRODUCT_VERSION) /DXPRA_VERSION=$(XPRA_VERSION) /DXPRA_REVISION=$(XPRA_REVISION) ./installer-win32/installer-remoton-client-desktop.nsi
	cp installer-win32/installer.exe ./$@.exe
	rm -rf installer-win32

remoton-client-desktop-win64.exe: deps-win64
	PKG_CONFIG_PATH=$(PWD)/vendor/windows/gtk+-2.0-win64/lib/pkgconfig CC=$(WIN64_CC) CGO_CFLAGS=$(pkg-config --cflags gtk+-2.0) CGO_LDFLAGS=$(pkg-config --libs gtk+-2.0) CGO_ENABLED=1 GOOS=windows GOARCH=amd64 go build -o $@ -ldflags -H=windowsgui github.com/bit4bit/remoton/cmd/remoton-client-desktop

remoton-client-desktop-win64-runtime: remoton-client-desktop-win64.exe
	mkdir -p release-$@
	cp remoton-client-desktop-win64.exe release-$@/
	cp vendor/windows/gtk+-2.0-win64/bin/*.dll release-$@
	zip -r $@.zip release-$@/*
	rm -rf release-$@
	rm -f $@

remoton-client-desktop-win64-setup: deps-win64 remoton-client-desktop-win64.exe
	mkdir -p installer-win64
	cp vendor/windows/gtk+-2.0-win64/bin/*.dll installer-win64/	
	cp remoton-client-desktop-win64.exe installer-win64/remoton-client-desktop.exe
	cp scripts/installer-remoton-client-desktop.nsi installer-win64/
	cp res/icon.ico installer-win64/
	wine "C:\Program Files\NSIS\makensis.exe" /DPRODUCT_VERSION=$(PRODUCT_VERSION) /DXPRA_VERSION=$(XPRA_VERSION) /DXPRA_REVISION=$(XPRA_REVISION) ./installer-win64/installer-remoton-client-desktop.nsi
	cp installer-win64/installer.exe ./$@.exe
	rm -rf installer-win64

remoton-client-desktop-win64-bundle-setup: deps-bundle deps-win64 remoton-client-desktop-win64.exe
	mkdir -p installer-win64
	cp vendor/windows/xpra_setup.exe installer-win64/
	cp vendor/windows/gtk+-2.0-win64/bin/*.dll installer-win64
	cp remoton-client-desktop-win64.exe installer-win64/remoton-client-desktop.exe
	cp scripts/installer-remoton-client-desktop.nsi installer-win64/
	cp res/icon.ico installer-win64/
	wine "C:\Program Files\NSIS\makensis.exe" /DX64="true" /DBUNDLE="true" /DPRODUCT_VERSION=$(PRODUCT_VERSION) /DXPRA_VERSION=$(XPRA_VERSION) /DXPRA_REVISION=$(XPRA_REVISION) ./installer-win64/installer-remoton-client-desktop.nsi
	cp installer-win64/installer.exe ./$@.exe
	rm -rf installer-win64


remoton-support-desktop:
	go build -o $@ github.com/bit4bit/remoton/cmd/remoton-support-desktop
	zip $@.zip $@
	rm $@

remoton-support-desktop-x86_64:
	GOOS=linux GOARCH=amd64 go build -o $@ github.com/bit4bit/remoton/cmd/remoton-support-desktop
	zip $@.zip $@
	rm $@

remoton-support-desktop-deb:
	go build -o $@ github.com/bit4bit/remoton/cmd/remoton-support-desktop
	fpm -s dir -t deb -n $@ -v 0.0.1 $(GENERAL) $(PACKAGE_DESKTOP_DEPS) $@=/usr/bin/remoton-support-desktop
	rm $@

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
	cp remoton-support-desktop-win32.exe support-setup-win32/remoton-support-desktop.exe
	cp scripts/installer-remoton-support-desktop.nsi support-setup-win32/installer.nsi
	cp res/icon.ico support-setup-win32/
	wine "C:\Program Files\NSIS\makensis.exe" /DPRODUCT_VERSION=$(PRODUCT_VERSION) /DXPRA_VERSION=$(XPRA_VERSION) /DXPRA_REVISION=$(XPRA_REVISION) ./support-setup-win32/installer.nsi
	cp support-setup-win32/installer.exe ./$@.exe
	rm -rf support-setup-win32

remoton-support-desktop-win32-bundle-setup: deps-bundle deps-win32 remoton-support-desktop-win32.exe
	mkdir -p support-setup-win32
	cp vendor/windows/xpra_setup.exe support-setup-win32/
	cp vendor/windows/gtk+-2.0-win32/bin/*.dll support-setup-win32/
	cp remoton-support-desktop-win32.exe support-setup-win32/remoton-support-desktop.exe
	cp scripts/installer-remoton-support-desktop.nsi support-setup-win32/installer.nsi
	cp res/icon.ico support-setup-win32/
	wine "C:\Program Files\NSIS\makensis.exe" /DBUNDLE="true" /DPRODUCT_VERSION=$(PRODUCT_VERSION) /DXPRA_VERSION=$(XPRA_VERSION) /DXPRA_REVISION=$(XPRA_REVISION) ./support-setup-win32/installer.nsi
	cp support-setup-win32/installer.exe ./$@.exe
	rm -rf support-setup-win32

remoton-support-desktop-win64.exe: deps-win64
	PKG_CONFIG_PATH=$(PWD)/vendor/windows/gtk+-2.0-win64/lib/pkgconfig CC=$(WIN64_CC) CGO_CFLAGS=$(pkg-config --cflags gtk+-2.0) CGO_LDFLAGS=$(pkg-config --libs gtk+-2.0) CGO_ENABLED=1 GOOS=windows GOARCH=amd64 go build -o $@ -ldflags -H=windowsgui github.com/bit4bit/remoton/cmd/remoton-support-desktop

remoton-support-desktop-win64-runtime: remoton-support-desktop-win64.exe
	mkdir -p release-$@
	cp remoton-support-desktop-win64.exe release-$@/
	cp vendor/windows/gtk+-2.0-win64/bin/*.dll release-$@/
	zip -r $@.zip release-$@/*
	rm -rf release-$@
	rm -f $@

remoton-support-desktop-win64-setup: remoton-support-desktop-win64.exe
	mkdir -p support-setup-win64
	cp vendor/windows/gtk+-2.0-win64/bin/*.dll support-setup-win64/
	cp remoton-support-desktop-win64.exe support-setup-win64/remoton-support-desktop.exe
	cp scripts/installer-remoton-support-desktop.nsi support-setup-win64/installer.nsi
	cp res/icon.ico support-setup-win64/
	wine "C:\Program Files\NSIS\makensis.exe" /DX64="true" /DPRODUCT_VERSION=$(PRODUCT_VERSION) /DXPRA_VERSION=$(XPRA_VERSION) /DXPRA_REVISION=$(XPRA_REVISION) ./support-setup-win64/installer.nsi
	cp support-setup-win64/installer.exe ./$@.exe
	rm -rf support-setup-win64

remoton-support-desktop-win64-bundle-setup: deps-bundle remoton-support-desktop-win64.exe
	mkdir -p support-setup-win64
	cp vendor/windows/xpra_setup.exe support-setup-win64/
	cp vendor/windows/gtk+-2.0-win64/bin/*.dll support-setup-win64/
	cp remoton-support-desktop-win64.exe support-setup-win64/remoton-support-desktop.exe
	cp res/icon.ico support-setup-win64/
	cp scripts/installer-remoton-support-desktop.nsi support-setup-win64/installer.nsi
	wine "C:\Program Files\NSIS\makensis.exe" /DBUNDLE="true" /DX64="true" /DPRODUCT_VERSION=$(PRODUCT_VERSION) /DXPRA_VERSION=$(XPRA_VERSION) /DXPRA_REVISION=$(XPRA_REVISION) ./support-setup-win64/installer.nsi
	cp support-setup-win64/installer.exe ./$@.exe
	rm -rf support-setup-win64

remoton-server:
	go build -o $@ github.com/bit4bit/remoton/cmd/remoton-server
	zip $@.zip $@
	rm $@

remoton-server-x86_64:
	GOOS=linux GOARCH=amd64 go build -o $@ github.com/bit4bit/remoton/cmd/remoton-server
	zip $@.zip $@
	rm $@

remoton-server-deb:
	go build -o $@ github.com/bit4bit/remoton/cmd/remoton-server
	go build -o $@-cert github.com/bit4bit/remoton/cmd/remoton-server-cert
	fpm -s dir -t deb -n $@ -v 0.0.1 $(GENERAL) $@=/usr/bin/remoton-server remoton-server-deb-cert=/usr/bin/remoton-server-cert
	rm $@
	rm $@-cert

remoton-server-win32.exe:
	GOOS=windows GOARCH=386 go build -o $@ github.com/bit4bit/remoton/cmd/remoton-server

remoton-server-win32-runtime: remoton-server-win32.exe
	zip $@.zip remoton-server-win32.exe
	rm remoton-server-win32.exe

remoton-server-win64.exe:
	GOOS=windows GOARCH=amd64 go build -o $@ github.com/bit4bit/remoton/cmd/remoton-server

remoton-server-win64-runtime: remoton-server-win64.exe
	zip $@.zip remoton-server-win64.exe
	rm remoton-server-win64.exe



all-win32: remoton-client-desktop-win32-runtime remoton-client-desktop-win32-setup remoton-client-desktop-win32-bundle-setup remoton-support-desktop-win32-runtime remoton-support-desktop-win32-setup remoton-support-desktop-win32-bundle-setup remoton-server-win32-runtime

all-win64: remoton-client-desktop-win64-runtime remoton-client-desktop-win64-setup remoton-client-desktop-win64-bundle-setup remoton-support-desktop-win64-runtime remoton-support-desktop-win64-setup remoton-support-desktop-win64-bundle-setup remoton-server-win64-runtime

all-gnu: remoton-client-desktop-deb remoton-support-desktop-deb remoton-server-deb

all: all-gnu all-win32 all-win64

clean:
	go clean github.com/bit4bit/remoton/cmd/...
	rm -f *.deb
	rm -f *.exe
	rm -f *.zip
