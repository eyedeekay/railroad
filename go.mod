module i2pgit.org/idk/railroad

go 1.16

require (
	fyne.io/systray v1.10.0
	github.com/atotto/clipboard v0.1.4
	github.com/dimfeld/httptreemux v5.0.1+incompatible
	github.com/eyedeekay/checki2cp v0.0.21
	github.com/eyedeekay/go-i2pbrowser v0.0.8
	github.com/eyedeekay/i2pkeys v0.33.0
	github.com/eyedeekay/sam3 v0.33.5
	github.com/eyedeekay/unembed v0.0.0-20220521030224-e33fac302930
	github.com/gorilla/securecookie v1.1.1
	github.com/jchv/go-webview2 v0.0.0-20221223143126-dc24628cff85
	github.com/kabukky/feeds v0.0.0-20151110114325-c7025aca4568
	github.com/kabukky/httpscerts v0.0.0-20150320125433-617593d7dcb3
	github.com/kardianos/osext v0.0.0-20190222173326-2bc1f35cddc0
	github.com/patrickmn/go-cache v2.1.0+incompatible // indirect
	github.com/phayes/freeport v0.0.0-20220201140144-74d24b5ae9f5
	github.com/russross/blackfriday v1.6.0
	github.com/satori/go.uuid v1.2.0
	github.com/txthinking/runnergroup v0.0.0-20220212043759-8da8edb7dae8 // indirect
	github.com/txthinking/socks5 v0.0.0-20220615051428-39268faee3e6
	github.com/txthinking/x v0.0.0-00010101000000-000000000000 // indirect
	github.com/webview/webview v0.0.0-20230110200822-73aee3dae745
	github.com/yuin/gopher-lua v1.0.0
	golang.org/x/crypto v0.5.0
	gopkg.in/fsnotify.v1 v1.4.7
	modernc.org/sqlite v1.20.2
)

replace github.com/txthinking/socks5 => github.com/eyedeekay/socks5 v0.0.0-20210312233714-7d95dbdbcc0f

replace github.com/txthinking/x => github.com/eyedeekay/x v0.0.0-20210312211721-5efa05df800e

replace fyne.io/systray v1.9.0 => fyne.io/systray v1.9.1-0.20220508132247-214b548ccb52

replace github.com/artdarek/go-unzip v1.0.0 => github.com/eyedeekay/go-unzip v0.0.0-20230124015700-cc3131fd4ee0

replace github.com/eyedeekay/go-i2pbrowser => ../../../github.com/eyedeekay/go-i2pbrowser
