module i2pgit.org/idk/railroad

go 1.16

require (
	github.com/atotto/clipboard v0.1.4
	github.com/dimfeld/httptreemux v5.0.1+incompatible
	github.com/eyedeekay/checki2cp v0.0.18-0.20210415001943-02b65fb958e5
	github.com/eyedeekay/sam3 v0.32.33-0.20210313224934-b9e4186119b8
	github.com/fsnotify/fsnotify v1.4.9 // indirect
	github.com/getlantern/systray v1.1.0
	github.com/gorilla/securecookie v1.1.1 // indirect
	github.com/kabukky/feeds v0.0.0-20151110114325-c7025aca4568
	github.com/kabukky/httpscerts v0.0.0-20150320125433-617593d7dcb3
	github.com/kabukky/journey v0.2.0
	github.com/kardianos/osext v0.0.0-20190222173326-2bc1f35cddc0
	github.com/mattn/go-sqlite3 v1.14.6 // indirect
	github.com/patrickmn/go-cache v2.1.0+incompatible // indirect
	github.com/phayes/freeport v0.0.0-20180830031419-95f893ade6f2
	github.com/russross/blackfriday v1.6.0 // indirect
	github.com/satori/go.uuid v1.2.0 // indirect
	github.com/txthinking/runnergroup v0.0.0-20210326110939-37fc67d0da7c // indirect
	github.com/txthinking/socks5 v0.0.0-20210326104807-61b5745ff346
	github.com/txthinking/x v0.0.0-20210326105829-476fab902fbe // indirect
	github.com/webview/webview v0.0.0-20210330151455-f540d88dde4e
	github.com/yuin/gopher-lua v0.0.0-20200816102855-ee81675732da // indirect
	golang.org/x/crypto v0.0.0-20210322153248-0c34fe9e7dc2 // indirect
	gopkg.in/check.v1 v1.0.0-20201130134442-10cb98267c6c // indirect
	gopkg.in/fsnotify.v1 v1.4.7 // indirect
	i2pgit.org/idk/zerocontrol v0.0.0-20210415002655-ac2964c74407
)

replace github.com/txthinking/socks5 v0.0.0-20210326104807-61b5745ff346 => github.com/eyedeekay/socks5 v0.0.0-20210312233714-7d95dbdbcc0f

replace github.com/txthinking/x v0.0.0-20210326105829-476fab902fbe => github.com/eyedeekay/x v0.0.0-20210312211721-5efa05df800e

replace github.com/kabukky/journey => i2pgit.org/idk/railroad v0.0.0-20210521045638-9a9fc77a8b37
