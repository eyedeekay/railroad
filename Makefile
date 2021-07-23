
REPO_NAME=railroad
export GOPATH=$(HOME)/go
GOPATH=$(HOME)/go
VERSION=0.0.033
LAST_VERSION=0.0.032

releases: $(GOPATH)/src/i2pgit.org/idk/railroad clean linux-releases windows-releases copy sums

linux-releases: linux linzip

windows-releases: windows winzip

linux:
	go build -o railroad
	
linux-release: linux
	make checkinstall

linzip:
	rm -rfv $(GOPATH)/src/i2pgit.org/idk/railroad-releases
	cp -rv $(GOPATH)/src/i2pgit.org/idk/railroad $(GOPATH)/src/i2pgit.org/idk/railroad-releases
	rm -rf $(GOPATH)/src/i2pgit.org/idk/railroad-releases/.git \
		$(GOPATH)/src/i2pgit.org/idk/railroad-releases/*.private \
		$(GOPATH)/src/i2pgit.org/idk/railroad-releases/*.public.txt
	cd ../ && \
		tar --exclude=railroad/.git -zcvf railroad-$(VERSION).tar.gz railroad

windows: railroad.exe

railroad.exe:
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
		zip -x=railroad/.git -r railroad-$(VERSION).zip railroad-releases

copy:
	cp -v ../railroad-$(VERSION).tar.gz .
	cp -v ../railroad-$(VERSION).zip .
	cp -v ../i2p-railroad_$(VERSION)-1_amd64.deb .
	cp -v ../railroad-installer.exe railroad-installer-$(VERSION).exe

$(GOPATH)/src/i2pgit.org/idk/railroad:
	mkdir -p $(GOPATH)/src/i2pgit.org/idk/railroad
	git clone https://i2pgit.org/idk/railroad $(GOPATH)/src/i2pgit.org/idk/railroad

clean:
	rm -rf *.private railroad *.public.txt *.tar.gz *.deb *.zip *.exe plugin-config/WebView2Loader.dll plugin-config/webview.dll

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

nsis: pc
	makensis railroad.nsi
	cp ../railroad-installer.exe .
	cp ../railroad-installer.exe ../railroad-installer-$(VERSION).exe

zip:
	cd ../ && \
		zip railroad.zip -r railroad

osx:
	go build -o railroad
	go build -tags osxalt -o railroad-ui

macapp:
	mkdir -p railroad.app/Contents/MacOS/content
	cp -r content/* railroad.app/Contents/MacOS/content/
	go build -o railroad.app/Contents/MacOS/railroad
	go build -tags osxalt -o railroad.app/Contents/MacOS/railroad-ui

fmt:
	find . -name '*.go' -exec gofmt -w -s {} \;

check:
	ls "../railroad-$(VERSION).zip" \
	"../railroad-installer-$(VERSION).exe" \
	"../railroad-$(VERSION).tar.gz" \
	"../i2p-railroad_$(VERSION)-1_amd64.deb"

release-upload: check
	cat desc changelog | grep -B 10 "$(LAST_VERSION)" | gothub release -p -u eyedeekay -r $(REPO_NAME) -t $(VERSION) -n $(VERSION) -d -; true
#	gothub upload -R -u eyedeekay -r "$(REPO_NAME)" -t $(VERSION) -n "$(REPO_NAME)(Windows Zip)" -f "../railroad-$(VERSION).zip"
	gothub upload -R -u eyedeekay -r "$(REPO_NAME)" -t $(VERSION) -n "$(REPO_NAME)(Windows Installer)" -f "../railroad-installer-$(VERSION).exe"
#	gothub upload -R -u eyedeekay -r "$(REPO_NAME)" -t $(VERSION) -n "$(REPO_NAME)(Linux .tar.gz)" -f "../railroad-$(VERSION).tar.gz"
	gothub upload -R -u eyedeekay -r "$(REPO_NAME)" -t $(VERSION) -n "$(REPO_NAME)(Debian/Ubuntu Linux .deb)" -f "../i2p-railroad_$(VERSION)-1_amd64.deb"
#	gothub upload -R -u eyedeekay -r "$(REPO_NAME)" -t $(VERSION) -n "" -f ""
#	gothub upload -R -u eyedeekay -r "$(REPO_NAME)" -t $(VERSION) -n "" -f ""
#	gothub upload -R -u eyedeekay -r "$(REPO_NAME)" -t $(VERSION) -n "" -f ""

plugins: pc plugin-linux plugin-windows

pc: plugin-config/WebView2Loader.dll plugin-config/webview.dll

plugin-config/WebView2Loader.dll:
	wget -O plugin-config/WebView2Loader.dll https://github.com/webview/webview/raw/master/dll/x64/WebView2Loader.dll

plugin-config/webview.dll:
	wget -O plugin-config/webview.dll https://github.com/webview/webview/raw/master/dll/x64/webview.dll

plugin-linux: linux
	i2p.plugin.native -name=railroad \
		-signer=hankhill19580@gmail.com \
		-version "$(VERSION)" \
		-author=hankhill19580@gmail.com \
		-autostart=true \
		-clientname=railroad \
		-consolename="Railroad Blog" \
		-delaystart="1" \
		-desc="`cat desc)`" \
		-exename=railroad \
		-command="\$$PLUGIN/lib/railroad -socksport 8082" \
		-license=MIT \
		-res=plugin-config
	cp -v railroad.su3 ../railroad-linux.su3
	unzip -o railroad.zip -d railroad-zip

plugin-windows: windows
	i2p.plugin.native -name=railroad \
		-signer=hankhill19580@gmail.com \
		-version "$(VERSION)" \
		-author=hankhill19580@gmail.com \
		-autostart=true \
		-clientname=railroad.exe \
		-consolename="Railroad Blog" \
		-delaystart="1" \
		-desc="`cat desc)`" \
		-exename=railroad.exe \
		-command="\$$PLUGIN/lib/railroad -socksport 8082" \
		-license=MIT \
		-targetos="windows" \
		-res=plugin-config
	cp -v railroad.su3 ../railroad-windows.su3
	unzip -o railroad.zip -d railroad-zip-win

export sumrrlinux=`sha256sum "../railroad-linux.su3"`
export sumrrwindows=`sha256sum "../railroad-windows.su3"`

upload-plugins:
	gothub upload -R -u eyedeekay -r "$(REPO_NAME)" -t v$(VERSION) -l "$(sumrrlinux)" -n "brb-linux.su3" -f "../brb-linux.su3"
	gothub upload -R -u eyedeekay -r "$(REPO_NAME)" -t v$(VERSION) -l "$(sumrrwindows)" -n "brb-windows.su3" -f "../brb-windows.su3"