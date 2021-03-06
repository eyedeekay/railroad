
REPO_NAME=railroad
export GOPATH=$(HOME)/go
GOPATH=$(HOME)/go
VERSION=0.0.045
LAST_VERSION=0.0.044
USER_GH=eyedeekay

GOOS?=$(shell uname -s | tr A-Z a-z)
GOARCH?="amd64"

releases: $(GOPATH)/src/i2pgit.org/idk/railroad clean linux-releases windows-releases copy sums

linux-releases: linux linzip

windows-releases: windows winzip
	
linux: docker
#	GOOS=linux go build -tags="sqlite_omit_load_extension,netgo,osusergo" -ldflags "-s -w" -o railroad-$(GOOS)

rb:
	/usr/lib/go-1.16/bin/go build -tags="sqlite_omit_load_extension,netgo,osusergo" -ldflags "-s -w" -o $(REPO_NAME)-$(GOOS)

docker:
	docker build -t $(USER_GH)/$(REPO_NAME):$(VERSION) .
	docker run -it -v $(PWD):/home/user/go/src/i2pgit.org/idk/$(REPO_NAME) $(USER_GH)/$(REPO_NAME):$(VERSION)

linux-release: linux
	make checkinstall

linzip: clean
	tar --exclude=./*.crt --exclude=./*.crl --exclude=./*.pem \
		--exclude=./*.private --exclude=./*.public.txt \
		--exclude="./.git/*" -zcvf ../railroad-$(VERSION).tar.gz .

windows: railroad-windows.exe

railroad-windows.exe:
	GOOS=windows go build -tags="sqlite_omit_load_extension,netgo,osusergo" -ldflags="-H windowsgui -s -w" -o railroad-windows.exe
	#xgo --docker-repo crazymax/xgo --ldflags="-H windowsgui" --targets=windows/amd64 . && mv ../railroad-windows-4.0-amd64.exe railroad-windows.exe
	cp railroad-windows.exe railroad-windows
	#wget -O WebView2Loader.dll https://github.com/webview/webview/raw/master/dll/x64/WebView2Loader.dll
	#wget -O webview.dll https://github.com/webview/webview/raw/master/dll/x64/webview.dll

winzip: clean
	zip -x=./*.crt -x=./*.crl -x=./*.pem \
		-x=./*.private -x=./*.public.txt \
		-x="./.git/*" -r ../railroad-$(VERSION).zip .

copy:
	cp -v ../railroad-$(VERSION).tar.gz .
	cp -v ../railroad-$(VERSION).zip .
	cp -v ../i2p-railroad_$(VERSION)-1_amd64.deb .
	cp -v ./railroad-windows.exe railroad-windows-$(VERSION).exe

$(GOPATH)/src/i2pgit.org/idk/railroad:
	mkdir -p $(GOPATH)/src/i2pgit.org/idk/railroad
	git clone https://i2pgit.org/idk/railroad $(GOPATH)/src/i2pgit.org/idk/railroad

clean: pc-clean
	rm -rf *.private railroad railroad-* *.public.txt *.tar.gz *.deb *.zip railroad*.exe plugin-config/WebView2Loader.dll plugin-config/webview.dll I2P-Zero plugin vendor

sums:
	sha256sum *.tar.gz *.zip *.deb *-windows.exe
	ls -lah *.tar.gz *.zip *.deb *-windows.exe

preinstall-pak:
	@echo "adduser --system --group --home /var/lib/railroad --disabled-login --disabled-password railroad" > preinstall-pak

install:
	mkdir -p /var/lib/$(REPO_NAME)/ /var/lib/$(REPO_NAME)/icon/
	cp -R content /var/lib/$(REPO_NAME)/content
	cp -R built-in /var/lib/$(REPO_NAME)/built-in
	install -m755 railroad.sh /usr/bin/railroad
	install -m755 railroad-linux /var/lib/$(REPO_NAME)/railroad
	cp res/desktop/i2prailroad.desktop /usr/share/applications
	install -m644 etc/default/$(REPO_NAME) /etc/default/$(REPO_NAME)
	install -m755 etc/init.d/$(REPO_NAME) /etc/init.d/$(REPO_NAME)
	mkdir -p /etc/systemd/system/$(REPO_NAME).d/
	install -g railroad -o railroad -d /var/lib/$(REPO_NAME)/
	cp -r content /var/lib/$(REPO_NAME)/content
	cp -r built-in /var/lib/$(REPO_NAME)/built-in
	cp icon/icon.png /var/lib/$(REPO_NAME)/icon/icon.png
	chown -R railroad:railroad /var/lib/$(REPO_NAME)/
	install -m644 etc/systemd/system/$(REPO_NAME).d/$(REPO_NAME).conf /etc/systemd/system/$(REPO_NAME).d/$(REPO_NAME).conf
	install -m644 etc/systemd/system/$(REPO_NAME).d/$(REPO_NAME).service /etc/systemd/system/$(REPO_NAME).d/$(REPO_NAME).service

uninstall:
	rm -rf /usr/bin/railroad \
		/var/lib/$(REPO_NAME)/ \
		/etc/systemd/system/$(REPO_NAME).d/ \
		/etc/init.d/$(REPO_NAME)

checkinstall: docker preinstall-pak
	fakeroot checkinstall \
		--default \
		--install=no \
		--fstrans=yes \
		--pkgname=i2p-railroad \
		--pkgversion=$(VERSION) \
		--pkggroup=net \
		--pkgrelease=1 \
		--pkgsource="https://i2pgit.org/idk/railroad" \
		--maintainer="hankhill19580@gmail.com" \
		--requires="libgtk-3-dev,libappindicator3-dev,libwebkit2gtk-4.0-dev,xclip,wl-clipboard" \
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

nsis: pc-windows
	makensis railroad.nsi
	cp ./railroad-windows.exe ../railroad-windows-$(VERSION).exe

zip:
	cd ../ && \
		zip railroad.zip -r railroad

osx:
	go build -tags="sqlite_omit_load_extension,netgo,osusergo" -ldflags "-s -w" -o railroad-$(GOOS)
	go build -tags="sqlite_omit_load_extension,netgo,osusergo,osxalt" -ldflags "-s -w" -o railroad-$(GOOS)-ui

macapp:
	mkdir -p railroad.app/Contents/MacOS/content
	cp -r content/* railroad.app/Contents/MacOS/content/
	go build -o railroad.app/Contents/MacOS/railroad
	go build -tags="sqlite_omit_load_extension,netgo,osusergo,osxalt" -ldflags "-s -w" -o railroad.app/Contents/MacOS/railroad-ui

fmt:
	find . -name '*.go' -exec gofmt -w -s {} \;

check:
	ls -lah "../railroad-$(VERSION).zip" \
		"./railroad-windows-$(VERSION).exe" \
		"../railroad-$(VERSION).tar.gz" \
		"../i2p-railroad_$(VERSION)-1_amd64.deb" \
		"./railroad-linux.su3" \
		"./railroad-windows.su3"

export sumrrlinux=`sha256sum "./railroad-linux.su3"`
export sumrrwindows=`sha256sum "./railroad-windows.su3"`
export sumdeb=`sha256sum "../i2p-railroad_$(VERSION)-1_amd64.deb"`
export sumzip=`sha256sum "../railroad-$(VERSION).zip"`
export sumtar=`sha256sum "../railroad-$(VERSION).tar.gz"`
export sumexe=`sha256sum "./railroad-windows-$(VERSION).exe"`

upload-plugins:

all: clean linzip winzip checkinstall releases plugins

release: all release-upload

release-upload: check
	cat desc changelog | grep -B 10 "$(LAST_VERSION)" | gothub release -p -u $(USER_GH) -r $(REPO_NAME) -t $(VERSION) -n $(VERSION) -d -; true
	sleep 3s
	gothub upload -R -u $(USER_GH) -r "$(REPO_NAME)" -t $(VERSION) -l "$(sumzip)" -n "railroad-$(VERSION).zip" -f "../railroad-$(VERSION).zip"
	gothub upload -R -u $(USER_GH) -r "$(REPO_NAME)" -t $(VERSION) -l "$(sumexe)" -n "railroad-windows-$(VERSION).exe" -f "./railroad-windows-$(VERSION).exe"
	gothub upload -R -u $(USER_GH) -r "$(REPO_NAME)" -t $(VERSION) -l "$(sumtar)" -n "railroad-$(VERSION).tar.gz" -f "../railroad-$(VERSION).tar.gz"
	gothub upload -R -u $(USER_GH) -r "$(REPO_NAME)" -t $(VERSION) -l "$(sumdeb)" -n "i2p-railroad_$(VERSION)-1_amd64.deb" -f "../i2p-railroad_$(VERSION)-1_amd64.deb"
	gothub upload -R -u $(USER_GH) -r "$(REPO_NAME)" -t $(VERSION) -l "$(sumrrlinux)" -n "$(REPO_NAME)-linux.su3" -f "./railroad-linux.su3"
	gothub upload -R -u $(USER_GH) -r "$(REPO_NAME)" -t $(VERSION) -l "$(sumrrwindows)" -n "$(REPO_NAME)-windows.su3" -f "./railroad-windows.su3"
#	gothub upload -R -u $(USER_GH) -r "$(REPO_NAME)" -t $(VERSION) -n "" -f ""

upload-su3s: release-upload

download-su3s:
	GOOS=windows make download-single-su3
	GOOS=linux make download-single-su3

download-single-su3:
	wget-ds "https://github.com/$(USER_GH)/$(REPO_NAME)/releases/download/$(VERSION)/$(REPO_NAME)-$(GOOS).su3"

plugins: pc-linux plugin-linux pc-windows plugin-windows

pc-clean:
	rm -rf plugin-config

pc-windows: pc-clean plugin-config/lib plugin-config/lib/content plugin-config/lib/built-in plugin-config/lib/WebView2Loader.dll plugin-config/lib/webview.dll
pc-linux: pc-clean plugin-config/lib plugin-config/lib/content plugin-config/lib/built-in

plugin-config/lib:
	mkdir -p plugin-config/lib/
	cp LICENSE.md plugin-config/LICENSE

plugin-config/lib/content:
	cp -r content plugin-config/lib/content

plugin-config/lib/built-in:
	cp -r built-in plugin-config/lib/built-in

plugin-config/lib/WebView2Loader.dll:
	#get -O plugin-config/lib/WebView2Loader.dll https://github.com/webview/webview/raw/master/dll/x64/WebView2Loader.dll

plugin-config/lib/webview.dll:
	#wget -O plugin-config/lib/webview.dll https://github.com/webview/webview/raw/master/dll/x64/webview.dll

plugin-linux:
	make docker
	make pc-linux
	GOOS=linux make plugin-pkg

plugin-windows:
	make railroad-windows.exe
	make pc-windows
	GOOS=windows make plugin-pkg

SIGNER_DIR=$(HOME)/i2p-go-keys/

plugin-pkg:
	i2p.plugin.native -name=railroad-$(GOOS) \
		-signer=hankhill19580@gmail.com \
		-signer-dir=$(SIGNER_DIR) \
		-version "$(VERSION)" \
		-author=hankhill19580@gmail.com \
		-autostart=true \
		-clientname=railroad-$(GOOS) \
		-consolename="Railroad Blog" \
		-consoleurl="http://127.0.0.1:7672" \
		-name="railroad-$(GOOS)" \
		-delaystart="1" \
		-desc="`cat desc`" \
		-exename=railroad-$(GOOS) \
		-icondata=icon/icon.png \
		-updateurl="http://idk.i2p/railroad/railroad-$(GOOS).su3" \
		-website="http://idk.i2p/railroad/" \
		-command="railroad-$(GOOS) -custompath \$$PLUGIN/" \
		-license=MIT \
		-res=plugin-config/
	cp -v railroad-$(GOOS).su3 ../railroad-$(GOOS).su3
	unzip -o railroad-$(GOOS).zip -d railroad-$(GOOS)-zip
