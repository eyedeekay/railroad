//go:build !windows
// +build !windows

package main

import (
	"fmt"
	"log"
	"os"
	"strings"

	goi2pbrowser "github.com/eyedeekay/go-i2pbrowser"
	"i2pgit.org/idk/railroad/configuration"
)

func addrString(addr string) string {
	if strings.HasPrefix(addr, ":") {
		return fmt.Sprintf("127.0.0.1%s", addr)
	}
	return addr
}

func LaunchView() error {
	if err := os.Setenv("NO_PROXY", "127.0.0.1:7672"); err != nil {
		return err
	}
	addr := addrString(configuration.Config().HttpHostAndPort)
	log.Println("http://" + addr + "/admin")
	goi2pbrowser.BrowseApp("railroad-admin", "http://"+addr+"/admin")
	return nil
}
