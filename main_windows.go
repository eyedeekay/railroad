package main

import (
	"log"
	"os"

	webview "github.com/jchv/go-webview2"
	"i2pgit.org/idk/railroad/configuration"
)

func LaunchView() error {
	if err := os.Setenv("NO_PROXY", "127.0.0.1:7672"); err != nil {
		return err
	}
	if err := os.Setenv("ALL_PROXY", "socks5://127.0.0.1:"+*socksPort); err != nil {
		return err
	}
	debug := true
	addr := configuration.Config.HttpHostAndPort
	webView := webview.NewWithOptions(webview.WebViewOptions{
		Debug:     true,
		AutoFocus: true,
		WindowOptions: webview.WindowOptions{
			Title:  "Railroad Blog - Administration",
			Width:  800,
			Height: 600,
			Center: true,
		},
	})
	if webView == nil {
		log.Fatalln("Failed to load webview.")
	}
	defer webView.Destroy()
	webView.SetTitle("Railroad Blog - Administration")
	webView.SetSize(800, 600, webview.HintNone)
	log.Println("http://" + addr + "/admin")
	webView.Navigate("http://" + addr + "/admin")
	webView.Run()

	return nil
}

//func LaunchView() error {
/* Ignore this on Windows since we're not using a WebView anymore and Windows hates this.
if err := os.Setenv("NO_PROXY", "127.0.0.1:7672"); err != nil {
	return err
}
if err := os.Setenv("ALL_PROXY", "socks5://127.0.0.1:"+*socksPort); err != nil {
	return err
}*/
/*	addr := "http://" + configuration.Config.HttpHostAndPort + "/admin"
	sizeConfig := &gowebview.Point{X: 800, Y: 600}
	windowconfig := &gowebview.WindowConfig{
		Title: "Railroad Blog - Administration",
		Size:  sizeConfig,
		//Path:  directory,
	}
	httpProxy := &gowebview.HTTPProxy{
		IP:   "127.0.0.1",
		Port: *socksPort,
	}
	transportconfig := &gowebview.TransportConfig{
		Proxy:                  httpProxy,
		IgnoreNetworkIsolation: true,
	}
	viewconfig := &gowebview.Config{
		URL:             addr,
		WindowConfig:    windowconfig,
		TransportConfig: transportconfig,
		Debug:           true,
	}
	webView, err := gowebview.New(viewconfig)
	if err != nil {
		return err
	}
	defer webView.Destroy()
	webView.SetTitle("Railroad Blog - Administration")
	//webView.SetSize(800, 600, webview.HintNone)
	log.Println(addr)
	//webView.Navigate("http://" + addr + "/admin")
	webView.Run()

	return nil
}
*/
