//go:build !windows
// +build !windows

package main

import (
	"log"
	"os"

	goi2pbrowser "github.com/eyedeekay/go-i2pbrowser"
	"i2pgit.org/idk/railroad/configuration"
)

func LaunchView() error {
	if err := os.Setenv("NO_PROXY", "127.0.0.1:7672"); err != nil {
		return err
	}
	if err := os.Setenv("ALL_PROXY", "socks5://127.0.0.1:"+*socksPort); err != nil {
		return err
	}
	addr := configuration.Config.HttpHostAndPort
	log.Println("http://" + addr + "/admin")
	goi2pbrowser.BrowseApp("railroad-admin", "http://"+addr+"/admin")
	return nil
}
