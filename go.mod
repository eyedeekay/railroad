module i2pgit.org/idk/railroad

go 1.16

require (
	fyne.io/systray v1.10.0
	github.com/atotto/clipboard v0.1.4
	github.com/dimfeld/httptreemux v5.0.1+incompatible
	github.com/eyedeekay/checki2cp v0.0.21
	github.com/eyedeekay/i2pkeys v0.0.0-20220804220722-1048b5ce6ba7
	github.com/eyedeekay/sam3 v0.33.4
	github.com/eyedeekay/unembed v0.0.0-20220521030224-e33fac302930
	github.com/fsnotify/fsnotify v1.4.9 // indirect
	github.com/godbus/dbus/v5 v5.1.0 // indirect
	github.com/gorilla/securecookie v1.1.1
	github.com/jchv/go-webview2 v0.0.0-20220506072306-ae3fc72a5edd
	github.com/jchv/go-winloader v0.0.0-20210711035445-715c2860da7e // indirect
	github.com/kabukky/feeds v0.0.0-20151110114325-c7025aca4568
	github.com/kabukky/httpscerts v0.0.0-20150320125433-617593d7dcb3
	github.com/kardianos/osext v0.0.0-20190222173326-2bc1f35cddc0
	github.com/mattn/go-sqlite3 v1.14.14
	github.com/patrickmn/go-cache v2.1.0+incompatible // indirect
	github.com/phayes/freeport v0.0.0-20220201140144-74d24b5ae9f5
	github.com/russross/blackfriday v1.6.0
	github.com/satori/go.uuid v1.2.0
	github.com/txthinking/runnergroup v0.0.0-20220212043759-8da8edb7dae8 // indirect
	github.com/txthinking/socks5 v0.0.0-20220615051428-39268faee3e6
	github.com/txthinking/x v0.0.0-20210326105829-476fab902fbe // indirect
	github.com/webview/webview v0.0.0-20220729131735-25e7f41b8bbf
	github.com/yuin/gopher-lua v0.0.0-20220504180219-658193537a64
	golang.org/x/crypto v0.0.0-20220722155217-630584e8d5aa
	golang.org/x/sys v0.0.0-20220808155132-1c4a2a72c664 // indirect
	gopkg.in/check.v1 v1.0.0-20201130134442-10cb98267c6c // indirect
	gopkg.in/fsnotify.v1 v1.4.7
)

replace github.com/txthinking/socks5 => github.com/eyedeekay/socks5 v0.0.0-20210312233714-7d95dbdbcc0f

replace github.com/txthinking/x => github.com/eyedeekay/x v0.0.0-20210312211721-5efa05df800e

replace github.com/kabukky/journey => i2pgit.org/idk/railroad v0.0.0-20210521045638-9a9fc77a8b37

replace fyne.io/systray v1.9.0 => fyne.io/systray v1.9.1-0.20220508132247-214b548ccb52
