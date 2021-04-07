
GOPATH=$(HOME)/go
VERSION=0.0.01

releases: $(GOPATH)/src/i2pgit.org/idk/railroad prep
	cd $(GOPATH)/src/i2pgit.org/idk/railroad
	go build -o railroad
	CC=/usr/bin/x86_64-w64-mingw32-gcc CGO_ENABLED=1 GOOS=windows go build -ldflags -H=windowsgui -o railroad.exe
	cd ../ && \
	tar -zcvf railroad.tar.gz railroad  && \
	wget -O railroad/WebView2Loader.dll https://github.com/webview/webview/raw/master/dll/x64/WebView2Loader.dll && \
	wget -O railroad/webview.dll https://github.com/webview/webview/raw/master/dll/x64/webview.dll && \
	zip -r railroad.zip railroad
	mv ../railroad.tar.gz railroad.tar.gz
	mv ../railroad.zip railroad.zip
	make unprep

$(GOPATH)/src/i2pgit.org/idk/railroad:
	mkdir -p $(GOPATH)/src/i2pgit.org/idk/railroad
	git clone https://i2pgit.org/idk/railroad $(GOPATH)/src/i2pgit.org/idk/railroad

prep:
	mv railroad.i2p.private ../; true

unprep:
	mv ../railroad.i2p.private .; true

install:
	mkdir -p /usr/local/lib/railroad/config
	rm -rf /usr/local/lib/railroad/config/content \
		/usr/local/lib/railroad/config/built-in
	cp -R content /usr/local/lib/railroad/config/content
	cp -R built-in /usr/local/lib/railroad/config/built-in
	install -m755 railroad.sh /usr/local/bin/railroad
	install -m755 railroad /usr/local/lib/railroad/railroad

uninstall:
	rm -rf /usr/local/bin/railroad \
		/usr/local/lib/railroad/

checkinstall:
	checkinstall \
		--default \
		--install=no \
		--fstrans=yes \
		--pkgname=i2p-railroad \
		--pkgversion=$(VERSION) \
		--pkggroup=net \
		--pkgrelease=1 \
		--pkgsource="https://i2pgit.org/idk/railroad" \
		--maintainer="hankhill19580@gmail.com" \
		--requires="libgtk-3-dev,libappindicator3-dev,libwebkit2gtk-4.0-dev,xclip,wl-clipboard,i2p,i2p-router" \
		--suggests="i2p,i2p-router,syndie,tor,tsocks" \
		--nodoc \
		--deldoc=yes \
		--deldesc=yes \
		--backup=no
