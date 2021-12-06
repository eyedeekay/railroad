//go:build osxalt
// +build osxalt

package main

import (
	"flag"
	"github.com/webview/webview"
	"i2pgit.org/idk/railroad/configuration"
	"log"
	"os"
)

var socksPort = flag.String("socksport", "8082", "Proxy any outgoing requests in the webview over a SOCKS proxy(will start one if there isn't one ready)")
var uiOnly = flag.Bool("uionly", true, "Launch the UI blindly, with no checks to make sure the blog is running")

func main() {
	if err := os.Setenv("NO_PROXY", "127.0.0.1:8084"); err != nil {
		log.Fatal(err)
	}
	if err := os.Setenv("ALL_PROXY", "socks5://127.0.0.1:"+*socksPort); err != nil {
		log.Fatal(err)
	}
	debug := true
	addr := configuration.Config.HttpHostAndPort
	webView := webview.New(debug)
	defer webView.Destroy()
	webView.SetTitle("Railroad Blog - Administration")
	webView.SetSize(800, 600, webview.HintNone)
	log.Println("http://" + addr + "/admin")
	webView.Navigate("http://" + addr + "/admin")
	webView.Run()
	return
}
