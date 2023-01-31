
REPO_NAME=railroad
export GOPATH=$(HOME)/go
GOPATH=$(HOME)/go
VERSION=0.1.7
LAST_VERSION=0.1.6
USER_GH=eyedeekay
CGO_ENABLED?=0

GOOS?="linux"
GOARCH?="amd64"

bin: $(GOPATH)/src/i2pgit.org/idk/railroad

releases: bin sums
	
build:
	go build -tags=sqlite_omit_load_extension,netgo,osusergo -ldflags "-s -w" -o railroad-$(GOOS)-$(GOARCH)

winbuild:
	GOOS=windows go build -tags="sqlite_omit_load_extension,netgo,osusergo" -ldflags="-H windowsgui -s -w" -o railroad-$(GOOS)-$(GOARCH).exe
	GOOS=windows go build -tags="sqlite_omit_load_extension,netgo,osusergo" -ldflags="-H windowsgui -s -w" -o railroad-$(GOOS)-$(GOARCH)

linux:
	GOOS=linux make build
	GOOS=linux GOARCH=arm64 make build

linux-release: linux

linzip: linux
	tar -zcvf ./railroad-$(VERSION).tar.gz built-in content railroad-linux-amd64 railroad-linux-arm64

windows: railroad-windows.exe

railroad-windows.exe:
	GOOS=windows make winbuild

winzip: windows nsis
	zip -r ./railroad-$(VERSION).zip built-in content railroad-windows-amd64.exe

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
	install -m755 railroad-$(GOOS)-$(GOARCH) /var/lib/$(REPO_NAME)/railroad
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
	install -m644 etc/systemd/system/$(REPO_NAME).service /etc/systemd/system/$(REPO_NAME).service

uninstall:
	rm -rf /usr/bin/railroad \
		/var/lib/$(REPO_NAME)/ \
		/etc/systemd/system/$(REPO_NAME).d/ \
		/etc/init.d/$(REPO_NAME)

checkinstall: linux preinstall-pak
	fakeroot checkinstall \
		--arch=$(GOARCH) \
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
	cp -v ../i2p-railroad_$(VERSION)-1_$(GOARCH).deb .

nsis: plugin-config windows
	makensis railroad.nsi
	cp ./railroad-installer.exe ../railroad-installer-$(VERSION).exe

darwin:
	GOOS=darwin make build
	GOOS=darwin GOARCH=arm64 make build

macapp: darwin
	mkdir -p railroad.app/Contents/MacOS/content
	cp -r content/* railroad.app/Contents/MacOS/content/
	cp railroad-$(GOOS)-$(GOARCH) railroad.app/Contents/MacOS/railroad

fmt:
	find . -name '*.go' -exec gofmt -w -s {} \;

check:
	ls -lah "./railroad-$(VERSION).zip" \
		"./railroad-windows-amd64-$(VERSION).exe" \
		"./railroad-$(VERSION).tar.gz" \
		"./i2p-railroad_$(VERSION)-1_amd64.deb" \
		"./i2p-railroad_$(VERSION)-1_arm64.deb" \
		"./railroad-linux-amd64.su3" \
		"./railroad-linux-arm64.su3" \
		"./railroad-darwin-amd64.su3" \
		"./railroad-darwin-arm64.su3" \
		"./railroad-windows-amd64.su3"
	echo "PRE RELEASE ARTIFACT CHECK PASSED."
	sleep 10s

copy:
	cp -v ./railroad-windows-amd64.exe railroad-windows-amd64-$(VERSION).exe

all: clean linzip winzip macapp debs plugins nsis copy

release: all check release-upload

file-release:
	cat desc changelog | grep -B 100 "$(LAST_VERSION)" | gothub release -p -u $(USER_GH) -r $(REPO_NAME) -t $(VERSION) -n $(VERSION) -d -; true
	sleep 3s

release-upload: check file-release basic-release upload-su3s upload-debs

basic-release:
	gothub upload -R -u $(USER_GH) -r "$(REPO_NAME)" -t $(VERSION) -l "`sha256sum ./railroad-$(VERSION).zip`" -n "railroad-$(VERSION).zip" -f "./railroad-$(VERSION).zip"
	gothub upload -R -u $(USER_GH) -r "$(REPO_NAME)" -t $(VERSION) -l "`sha256sum ./railroad-windows-amd64-$(VERSION).exe`" -n "railroad-windows-amd64-$(VERSION).exe" -f "./railroad-windows-amd64-$(VERSION).exe"
	gothub upload -R -u $(USER_GH) -r "$(REPO_NAME)" -t $(VERSION) -l "`sha256sum ./railroad-$(VERSION).tar.gz`" -n "railroad-$(VERSION).tar.gz" -f "./railroad-$(VERSION).tar.gz"

upload-single-deb:
	gothub upload -R -u $(USER_GH) -r "$(REPO_NAME)" -t $(VERSION) -l "`sha256sum ./i2p-railroad_$(VERSION)-1_$(GOARCH).deb`" -n "i2p-railroad_$(VERSION)-1_$(GOARCH).deb" -f "./i2p-railroad_$(VERSION)-1_$(GOARCH).deb"

upload-single-su3:
	echo gothub upload -R -u $(USER_GH) -r "$(REPO_NAME)" -t $(VERSION) -l "`sha256sum "./railroad-$(GOOS)-$(GOARCH).su3"`" -n "$(REPO_NAME)-$(GOOS)-$(GOARCH).su3" -f "./railroad-$(GOOS)-$(GOARCH).su3"

debs:
	GOOS=linux GOARCH=amd64 make checkinstall
	GOOS=linux GOARCH=arm64 make checkinstall

upload-debs:
	GOOS=linux GOARCH=amd64 make upload-single-deb
	GOOS=linux GOARCH=arm64 make upload-single-deb

upload-su3s:
	GOOS=windows make upload-single-su3
	GOOS=linux make upload-single-su3
	GOOS=linux GOARCH=arm64 make upload-single-su3
	GOOS=darwin make upload-single-su3
	GOOS=darwin GOARCH=arm64 make upload-single-su3

download-su3s:
	GOOS=windows make download-single-su3
	GOOS=linux make download-single-su3
	GOOS=linux GOARCH=arm64 make download-single-su3
	GOOS=darwin make download-single-su3
	GOOS=darwin GOARCH=arm64 make download-single-su3

download-single-su3:
	wget-ds "https://github.com/$(USER_GH)/$(REPO_NAME)/releases/download/$(VERSION)/$(REPO_NAME)-$(GOOS)-$(GOARCH).su3"

plugins: plugin-config plugin-linux plugin-darwin plugin-config plugin-windows

pc-clean:
	rm -rf plugin-config

plugin-config: pc-clean plugin-config/lib plugin-config/lib/content plugin-config/lib/built-in

plugin-config/lib:
	mkdir -p plugin-config/lib/
	cp LICENSE.md plugin-config/LICENSE

plugin-config/lib/content:
	cp -r content plugin-config/lib/content

plugin-config/lib/built-in:
	cp -r built-in plugin-config/lib/built-in

plugin-linux: plugin-linux-amd64 plugin-linux-arm64

plugin-build-linux:
	GOOS=linux make linux
	GOOS=linux make plugin-config
	GOOS=linux make plugin-pkg	

plugin-linux-amd64:
	GOOS=linux GOARCH=amd64 make plugin-build-linux

plugin-linux-arm64:
	GOOS=linux GOARCH=arm64 make plugin-build-linux

plugin-windows:
	GOOS=windows make railroad-windows.exe
	GOOS=windows make plugin-config
	GOOS=windows make plugin-pkg

plugin-darwin: plugin-darwin-amd64 plugin-darwin-arm64

plugin-build-darwin:
	GOOS=darwin make darwin
	GOOS=darwin make plugin-config
	GOOS=darwin make plugin-pkg	

plugin-darwin-amd64:
	GOOS=darwin GOARCH=amd64 make plugin-build-darwin

plugin-darwin-arm64:
	GOOS=darwin GOARCH=arm64 make plugin-build-darwin

SIGNER_DIR=$(HOME)/i2p-go-keys/

plugin-pkg:
	rm -f plugin.yaml client.yaml
	GOOS=windows i2p.plugin.native -name=railroad-$(GOOS)-$(GOARCH) \
		-signer=hankhill19580@gmail.com \
		-signer-dir=$(SIGNER_DIR) \
		-version "$(VERSION)" \
		-author=hankhill19580@gmail.com \
		-autostart=true \
		-clientname=railroad-$(GOOS)-$(GOARCH) \
		-consolename="Railroad Blog" \
		-consoleurl="http://127.0.0.1:7672" \
		-name="railroad-$(GOOS)-$(GOARCH)" \
		-delaystart="1" \
		-desc="`cat desc`" \
		-exename=railroad-$(GOOS)-$(GOARCH) \
		-icondata=icon/icon.png \
		-updateurl="http://idk.i2p/railroad/railroad-$(GOOS)-$(GOARCH).su3" \
		-website="http://idk.i2p/railroad/" \
		-command="railroad-$(GOOS)-$(GOARCH) -custompath \$$PLUGIN/" \
		-license=MIT \
		-targetos=$(GOOS)-$(GOARCH) \
		-res=plugin-config/
	cp -v railroad-$(GOOS)-$(GOARCH).su3 ./railroad-$(GOOS)-$(GOARCH)-$(VERSION).su3
	unzip -o railroad-$(GOOS)-$(GOARCH).zip -d railroad-$(GOOS)-$(GOARCH)-$(VERSION)-zip


index:
	edgar