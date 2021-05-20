
export GOPATH=$(HOME)/go
GOPATH=$(HOME)/go
VERSION=0.0.02

releases: $(GOPATH)/src/i2pgit.org/idk/railroad clean linux-releases windows-releases copy sums

linux-releases: linux linzip

windows-releases: windows winzip

linux:
	go build -o railroad
	make checkinstall

linzip:
	rm -rfv $(GOPATH)/src/i2pgit.org/idk/railroad-releases
	cp -rv $(GOPATH)/src/i2pgit.org/idk/railroad $(GOPATH)/src/i2pgit.org/idk/railroad-releases
	rm -rf $(GOPATH)/src/i2pgit.org/idk/railroad-releases/.git \
		$(GOPATH)/src/i2pgit.org/idk/railroad-releases/*.private \
		$(GOPATH)/src/i2pgit.org/idk/railroad-releases/*.public.txt
	cd ../ && \
		tar --exclude=railroad/.git -zcvf railroad.tar.gz railroad

windows:
	xgo --targets=windows/amd64 . && mv railroad-windows-4.0-amd64.exe railroad.exe
	wget -O WebView2Loader.dll https://github.com/webview/webview/raw/master/dll/x64/WebView2Loader.dll
	wget -O webview.dll https://github.com/webview/webview/raw/master/dll/x64/webview.dll
	make nsis

winzip:
	rm -rfv $(GOPATH)/src/i2pgit.org/idk/railroad-releases
	cp -rv $(GOPATH)/src/i2pgit.org/idk/railroad $(GOPATH)/src/i2pgit.org/idk/railroad-releases
	rm -rf $(GOPATH)/src/i2pgit.org/idk/railroad-releases/.git \
		$(GOPATH)/src/i2pgit.org/idk/railroad-releases/*.private \
		$(GOPATH)/src/i2pgit.org/idk/railroad-releases/*.public.txt
	cd ../ && \
		zip -x=railroad/.git -r railroad.zip railroad-releases

copy:
	mv ../railroad.tar.gz .
	mv ../railroad.zip .
	mv ../*railroad*.deb .
	mv ../railroad-installer.exe .

$(GOPATH)/src/i2pgit.org/idk/railroad:
	mkdir -p $(GOPATH)/src/i2pgit.org/idk/railroad
	git clone https://i2pgit.org/idk/railroad $(GOPATH)/src/i2pgit.org/idk/railroad

clean:
	rm -rf *.private railroad *.public.txt *.tar.gz *.deb *.zip *.exe
sums:
	sha256sum *.tar.gz *.zip *.deb *-installer.exe
	ls -lah *.tar.gz *.zip *.deb *-installer.exe

install:
	mkdir -p /usr/local/lib/railroad/config
	rm -rf /usr/local/lib/railroad/config/content \
		/usr/local/lib/railroad/config/built-in
	cp -R content /usr/local/lib/railroad/config/content
	cp -R built-in /usr/local/lib/railroad/config/built-in
	install -m755 railroad.sh /usr/local/bin/railroad
	install -m755 railroad /usr/local/lib/railroad/railroad
	cp res/desktop/i2prailroad.desktop /usr/share/applications

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
		--pakdir=".." \
		--backup=no

index:
	@echo "<!DOCTYPE html>" > index.html
	@echo "<html>" >> index.html
	@echo "<head>" >> index.html
	@echo "  <title>Railroad, anonymous blogging based on Journey</title>" >> index.html
	@echo "  <link rel=\"stylesheet\" type=\"text/css\" href =\"home.css\" />" >> index.html
	@echo "</head>" >> index.html
	@echo "<body>" >> index.html
	markdown README.md | tee -a index.html
	@echo "</body>" >> index.html
	@echo "</html>" >> index.html

nsis:
	makensis railroad.nsi
	cp ../railroad-installer.exe .
