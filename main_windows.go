package main

import (
	"embed"
	"log"
	"os"
	"os/exec"

	webview "github.com/jchv/go-webview2"
	"i2pgit.org/idk/railroad/configuration"
)

// embed MicrosoftEdgeWebview2Setup.exe in the executable

//go:embed MicrosoftEdgeWebview2Setup.exe
var f embed.FS

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
		Debug:     debug,
		AutoFocus: true,
		WindowOptions: webview.WindowOptions{
			Title:  "Railroad Blog - Administration",
			Width:  800,
			Height: 600,
			Center: true,
		},
	})
	if webView == nil {
		egbdir, err := f.ReadDir(".")
		if err != nil {
			return err
		}
		log.Println("egbdir", egbdir)
		for _, e := range egbdir {
			log.Println("found:", e.Name())
			if e.Name() == "MicrosoftEdgeWebview2Setup.exe" {
				cmd := exec.Command(e.Name())
				cmd.Stdout = os.Stdout
				cmd.Stderr = os.Stderr
				err := cmd.Run()
				if err != nil {
					return err
				}
			}
		}

	}
	defer webView.Destroy()
	webView.SetTitle("Railroad Blog - Administration")
	webView.SetSize(800, 600, webview.HintNone)
	log.Println("http://" + addr + "/admin")
	webView.Navigate("http://" + addr + "/admin")
	webView.Run()

	return nil
}
