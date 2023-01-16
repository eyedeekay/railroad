//go:build !windows
// +build !windows

package main

import (
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"

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
	os.MkdirAll("railroad-admin/", 0755)
	dira, _ := ioutil.ReadDir("railroad-admin/i2p.firefox.usability.profile/extensions/")
	for _, v := range dira {
		if !v.IsDir() {
			path := filepath.Join("railroad-admin/i2p.firefox.usability.profile/extensions/", v.Name())
			if strings.Contains(path, "localcdn") {
				os.RemoveAll(path)
			}
			if strings.Contains(path, "https") {
				os.RemoveAll(path)
			}
			if strings.Contains(path, "{b86e4813-687a-43e6-ab65-0bde4ab75758}") {
				os.RemoveAll(path)
			}
			log.Println(path)
			os.Chmod(path, 0664)
		}
	}
	dire, _ := ioutil.ReadDir("railroad-admin/i2p.firefox.usability.profile/")
	for _, v := range dire {
		if !v.IsDir() {
			path := filepath.Join("railroad-admin/i2p.firefox.usability.profile/", v.Name())
			log.Println(path)
			os.Chmod(path, 0664)
		}
	}
	goi2pbrowser.BrowseApp("railroad-admin", "http://"+addr+"/admin")
	return nil
}

func writeable() {

}
