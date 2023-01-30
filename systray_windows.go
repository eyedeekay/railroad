package main

import (
	"log"
	"strings"
	"time"

	"fyne.io/systray"
	"github.com/atotto/clipboard"
	"i2pgit.org/idk/railroad/configuration"
	"i2pgit.org/idk/railroad/icon"
)

func onReady() {
	systray.SetIcon(icon.Data)
	systray.SetTitle("Railroad Blog")
	systray.SetTooltip("Blog is running on I2P: http://" + host)
	mShowUrl := systray.AddMenuItem("Copy Address", "copy blog address to clipboard")
	mEditUrl := systray.AddMenuItem("Edit your blog", "Edit your blog in it's own webview")
	if strings.HasSuffix(configuration.Config().HttpsUrl, "i2p") {
		if !strings.HasSuffix(configuration.Config().HttpsUrl, "b32.i2p") {
			mCopyUrl := systray.AddMenuItem("Copy blog address helper", "copy blog addresshelper to clipboard")
			go func() {
				<-mCopyUrl.ClickedCh
				log.Println("Requesting copy short address helper:", configuration.Config().HttpsUrl+"/i2paddresshelper="+host)
				clipboard.WriteAll(configuration.Config().HttpsUrl + "/?i2paddresshelper=" + host)
				log.Println("Finished copy short address helper")
			}()
		}
	}
	mQuit := systray.AddMenuItem("Quit", "Quit the whole app")

	// Sets the icon of a menu item. Only available on Mac and Windows.
	mQuit.SetIcon(icon.Data)

	for {
		go func() {
			<-mQuit.ClickedCh
			log.Println("Requesting quit")
			systray.Quit()
			log.Println("Finished quitting")
		}()
		time.Sleep(time.Second)
		go func() {
			<-mEditUrl.ClickedCh
			err := LaunchView()
			if err != nil {
				log.Fatal(err)
			}
		}()
		time.Sleep(time.Second)
		go func() {
			<-mShowUrl.ClickedCh
			log.Println("Waiting for password = ", passStat())
			log.Println("Requesting copy base32", host)
			clipboard.WriteAll("http://" + host)
			log.Println("Finished copy base32")
		}()
		time.Sleep(time.Second * 3)
	}
}

func onExit() {
	// clean up here
}

func RunSystray() {
	systray.Run(onReady, onExit)
}
