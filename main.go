package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/dimfeld/httptreemux"
	checksam "github.com/eyedeekay/checki2cp/samcheck"
	"github.com/eyedeekay/i2pkeys"
	sam "github.com/eyedeekay/sam3/helper"
	flags "i2pgit.org/idk/railroad/common"
	"i2pgit.org/idk/railroad/configuration"
	"i2pgit.org/idk/railroad/database"
	"i2pgit.org/idk/railroad/filenames"
	"i2pgit.org/idk/railroad/https"
	"i2pgit.org/idk/railroad/plugins"
	"i2pgit.org/idk/railroad/server"
	"i2pgit.org/idk/railroad/structure/methods"
	"i2pgit.org/idk/railroad/templates"
)

func save(c *configuration.Configuration) error {
	data, err := json.Marshal(c)
	if err != nil {
		return err
	}
	return ioutil.WriteFile(filenames.ConfigFilename(), data, 0600)
}

func httpsRedirect(w http.ResponseWriter, r *http.Request, _ map[string]string) {
	http.Redirect(w, r, configuration.Config().HttpsUrl+r.RequestURI, http.StatusMovedPermanently)
}

var configjson = `{
	"HttpHostAndPort":"127.0.0.1:7672",
	"HttpsHostAndPort":"127.0.0.1:7673",
	"HttpsUsage":"None",
	"Url":"http://127.0.0.1:7672",
	"HttpsUrl":"https://127.0.0.1:7673",
	"UseLetsEncrypt":false
}`

var host string

//var directory string

var domainhelp = `You haven't configured an I2P hostname for your site.
If you want to, edit config.json and change the value of "HttpsUrl:" to your desired human-readable name, ending in .i2p.
For example:

{
	"HttpHostAndPort":"127.0.0.1:7672",
	"HttpsHostAndPort":"127.0.0.1:7673",
	"HttpsUsage":"None",
	"Url":"http://127.0.0.1:7672",
	"HttpsUrl":"https://blog.idk.i2p",
	"UseLetsEncrypt":false
}

Your site will still be available by it's cryptographic address.
Setting Url to an .i2p domain name will also set HttpsUrl to the
same domain name.`

// Check if we're already running. If we are, run a webview to edit and admin the blog.
func portCheck(addr string) (status bool, faddr string, err error) {
	host, port, err := net.SplitHostPort(addr)
	if err != nil {
		log.Fatal("Invalid address")
	}
	if host == "" {
		host = "127.0.0.1"
	}
	timeout := time.Second * 5
	conn, err := net.DialTimeout("tcp", net.JoinHostPort(host, port), timeout)
	if err != nil {
		if strings.Contains(err.Error(), "refused") {
			err = nil
		}
		log.Println("Connecting error:", err)
	}
	if conn != nil {
		defer conn.Close()
		status = true
		faddr = net.JoinHostPort(host, port)
		log.Println("Opened", net.JoinHostPort(host, port))
	}
	return
}

// var socksPort = flag.String("socksport", "7674", "Proxy any outgoing requests in the webview over a SOCKS proxy(will start one if there isn't one ready)")
var uiOnly = flag.Bool("uionly", false, "Launch the UI blindly, with no checks to make sure the blog is running")
var notray = flag.Bool("notray", false, "Don't launch the systray icon")

func passStat() bool {
	_, err := database.RetrieveUser(1)
	if err != nil {
		fmt.Println("Error retrieving user, probably unset.")
	} else {
		fmt.Println("User exists, ready to go.")
		return true
	}
	time.Sleep(time.Second * 5)
	return false
}

func waitPass(aftername string) (bool, net.Listener, error) {
	_, err := database.RetrieveUser(1)
	if err != nil {
		fmt.Println("Error retrieving user, probably unset.")
		listener, err := sam.I2PListener("railroad"+aftername, "127.0.0.1:7656", "railroad"+aftername)
		if err != nil {
			panic(err)
		}
		host = strings.Split(listener.Addr().(i2pkeys.I2PAddr).Base32(), ":")[0]
		if !strings.HasSuffix(configuration.Config().HttpsUrl, "i2p") {
			configuration.Config().HttpsUrl = "https://" + listener.Addr().(i2pkeys.I2PAddr).Base32()
			log.Println(domainhelp)
		}
		if !strings.HasSuffix(configuration.Config().Url, "i2p") {
			configuration.Config().Url = "https://" + listener.Addr().(i2pkeys.I2PAddr).Base32()
			log.Println(domainhelp)
		}
		configuration.Config().Url = "http://" + listener.Addr().(i2pkeys.I2PAddr).Base32()
		save(configuration.Config())
		listener.Close()
		time.Sleep(time.Second * 10)
	} else {
		fmt.Println("User exists, ready to go.")
		listener, err := sam.I2PListener("railroad"+aftername, "127.0.0.1:7656", "railroad"+aftername)
		if err != nil {
			panic(err)
		}
		host = strings.Split(listener.Addr().(i2pkeys.I2PAddr).Base32(), ":")[0]
		if !strings.HasSuffix(configuration.Config().HttpsUrl, "i2p") {
			configuration.Config().HttpsUrl = "https://" + listener.Addr().(i2pkeys.I2PAddr).Base32()
			log.Println(domainhelp)
		}
		if !strings.HasSuffix(configuration.Config().Url, "i2p") {
			configuration.Config().Url = "https://" + listener.Addr().(i2pkeys.I2PAddr).Base32()
			log.Println(domainhelp)
		}
		configuration.Config().Url = "http://" + listener.Addr().(i2pkeys.I2PAddr).Base32()
		save(configuration.Config())
		return true, listener, err
	}
	return false, nil, nil
}

func defaultDir() string {
	// get the path to this executable and return the directory
	ex, err := os.Executable()
	if err != nil {
		panic(err)
	}
	exPath := filepath.Dir(ex)
	return exPath
}

func main() {
	flag.StringVar(&flags.CustomPath, "custompath", defaultDir(), "Change to custom path for running the blog")
	log.Println("Flags are not parsed yet")
	flag.Parse()
	log.Println("Flags are parsed")
	filenames.CreateDirs()
	if *uiOnly {
		err := LaunchView()
		if err != nil {
			log.Fatal(err)
		}
		return
	}
	// Setup
	var err error
	err = os.Chdir(flags.CustomPath)
	if err != nil {
		log.Fatal(err)
	}
	if err := unpack(); err != nil {
		log.Fatal(err)
	}

	if err = os.Setenv("NO_PROXY", "127.0.0.1:7672"); err != nil {
		panic(err)
	}
	time.Sleep(time.Second * 3)

	for !checksam.CheckSAMAvailable("127.0.0.1:7656") {
		log.Println("Checking SAM")
		time.Sleep(time.Second * 15)
		log.Println("Waiting for SAM")
	}

	if status, _, err := portCheck(configuration.Config().HttpHostAndPort); err == nil {
		if status {
			err := LaunchView()
			if err != nil {
				log.Fatal(err)
			}
			return
		}
	} else {
		log.Fatal(err)
	}
	// Enforce safe local configuration
	if configuration.Config().HttpHostAndPort == ":7672" {
		configuration.Config().HttpHostAndPort = "127.0.0.1:7672"
	}
	if configuration.Config().HttpsHostAndPort == ":7673" {
		configuration.Config().HttpsHostAndPort = "127.0.0.1:7673"
	}
	configuration.Config().UseLetsEncrypt = false

	// Write log to file if the log flag was provided
	if flags.Log != "" {
		logFile, err := os.OpenFile(flags.Log, os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
		if err != nil {
			log.Fatal("Error: Couldn't open log file: " + err.Error())
		}
		defer logFile.Close()
		log.SetOutput(logFile)
	}

	// Configuration is read from config.json by loading the configuration package

	// Database
	if err = database.Initialize(); err != nil {
		log.Fatal("Error: Couldn't initialize database:", err)
		return
	}

	// Global blog data
	if err = methods.GenerateBlog(); err != nil {
		log.Fatal("Error: Couldn't generate blog data:", err)
		return
	}

	// Templates
	if err = templates.Generate(); err != nil {
		log.Fatal("Error: Couldn't compile templates:", err)
		return
	}

	// Plugins
	if err = plugins.Load(); err == nil {
		// Close LuaPool at the end
		defer plugins.LuaPool.Shutdown()
		log.Println("Plugins loaded.")
	}

	// HTTP(S) Server
	httpPort := configuration.Config().HttpHostAndPort
	httpsPort := configuration.Config().HttpsHostAndPort
	// Check if HTTP/HTTPS flags were provided
	if flags.HttpPort != "" {
		components := strings.SplitAfterN(httpPort, ":", 2)
		httpPort = components[0] + flags.HttpPort
	}
	if flags.HttpsPort != "" {
		components := strings.SplitAfterN(httpsPort, ":", 2)
		httpsPort = components[0] + flags.HttpsPort
	}
	// Determine the kind of https support (as set in the config.json)
	switch configuration.Config().HttpsUsage {
	case "AdminOnly":
		httpRouter := httptreemux.New()
		httpsRouter := httptreemux.New()
		// Blog and pages as http
		server.InitializeBlog(httpRouter)
		server.InitializePages(httpRouter)
		// Blog and pages as https
		server.InitializeBlog(httpsRouter)
		server.InitializePages(httpsRouter)
		// Admin as https and http redirect
		// Add redirection to http router
		httpRouter.GET("/admin/", httpsRedirect)
		httpRouter.GET("/admin/*path", httpsRedirect)
		// Add routes to https router
		server.InitializeAdmin(httpsRouter)
		// Start https server
		log.Println("Starting https server on port " + httpsPort + "...")
		if !*notray {
			go func() {
				for con, listener, err := waitPass("-https"); con; con, listener, err = waitPass("-https") {
					if err != nil {
						panic(err)
					}
					defer listener.Close()
					log.Println("Starting https server on I2P " + httpsPort + "...")
					if err := https.StartServer(listener, httpsRouter); err != nil {
						log.Fatal("Error: Couldn't start the HTTPS server:", err)
					}
				}
			}()
			// Start http server
			go func() {
				for con, listener, err := waitPass(""); con; con, listener, err = waitPass("") {
					if err != nil {
						panic(err)
					}
					defer listener.Close()
					log.Println("Starting http server on I2P " + httpPort + "...")
					if err := http.Serve(listener, httpRouter); err != nil {
						log.Fatal("Error: Couldn't start the I2P server:", err)
					}
				}
			}()
			go func() {
				log.Println("Starting http server on port " + httpPort + "...")
				if err := http.ListenAndServe(httpPort, httpRouter); err != nil {
					log.Fatal("Error: Couldn't start the HTTP server:", err)
				}
			}()
			RunSystray()
		} else {
			go func() {
				for con, listener, err := waitPass("-https"); con; con, listener, err = waitPass("-https") {
					if err != nil {
						panic(err)
					}
					defer listener.Close()
					log.Println("Starting https server on I2P " + httpsPort + "...")
					if err := https.StartServer(listener, httpsRouter); err != nil {
						log.Fatal("Error: Couldn't start the HTTPS server:", err)
					}
				}
			}()
			// Start http server
			go func() {
				for con, listener, err := waitPass(""); con; con, listener, err = waitPass("") {
					if err != nil {
						panic(err)
					}
					defer listener.Close()
					log.Println("Starting http server on I2P " + httpPort + "...")
					if err := http.Serve(listener, httpRouter); err != nil {
						log.Fatal("Error: Couldn't start the I2P server:", err)
					}
				}
			}()
			log.Println("Starting http server on port " + httpPort + "...")
			if err := http.ListenAndServe(httpPort, httpRouter); err != nil {
				log.Fatal("Error: Couldn't start the HTTP server:", err)
			}
		}
	case "All":
		httpsRouter := httptreemux.New()
		httpRouter := httptreemux.New()
		// Blog and pages as https
		server.InitializeBlog(httpsRouter)
		server.InitializePages(httpsRouter)
		// Admin as https
		server.InitializeAdmin(httpsRouter)
		// Add redirection to http router
		httpRouter.GET("/", httpsRedirect)
		httpRouter.GET("/*path", httpsRedirect)
		// Start https server
		go func() {
			for con, listener, err := waitPass("-https"); con; con, listener, err = waitPass("-https") {
				if err != nil {
					panic(err)
				}
				defer listener.Close()
				log.Println("Starting https server on I2P " + httpsPort + "...")
				if err := https.StartServer(listener, httpsRouter); err != nil {
					log.Fatal("Error: Couldn't start the HTTPS server:", err)
				}
			}
		}()
		// Start http server
		if !*notray {
			go func() {
				for con, listener, err := waitPass(""); con; con, listener, err = waitPass("") {
					if err != nil {
						panic(err)
					}
					defer listener.Close()
					log.Println("Starting http server on I2P " + httpPort + "...")
					if err := http.Serve(listener, httpRouter); err != nil {
						log.Fatal("Error: Couldn't start the I2P server:", err)
					}
				}
			}()
			go func() {
				log.Println("Starting http server on port " + httpPort + "...")
				if err := http.ListenAndServe(httpPort, httpRouter); err != nil {
					log.Fatal("Error: Couldn't start the HTTP server:", err)
				}
			}()
			RunSystray()
		} else {
			go func() {
				for con, listener, err := waitPass(""); con; con, listener, err = waitPass("") {
					if err != nil {
						panic(err)
					}
					defer listener.Close()
					log.Println("Starting http server on I2P " + httpPort + "...")
					if err := http.Serve(listener, httpRouter); err != nil {
						log.Fatal("Error: Couldn't start the I2P server:", err)
					}
				}
			}()
			log.Println("Starting http server on port " + httpPort + "...")
			if err := http.ListenAndServe(httpPort, httpRouter); err != nil {
				log.Fatal("Error: Couldn't start the HTTP server:", err)
			}
		}
	default: // This is configuration.HttpsUsage == "None"
		httpRouter := httptreemux.New()
		// Blog and pages as http
		server.InitializeBlog(httpRouter)
		server.InitializePages(httpRouter)
		// Admin as http
		server.InitializeAdmin(httpRouter)
		// Start http server
		log.Println("Starting server without HTTPS support. Please enable HTTPS in " + filenames.ConfigFilename() + " to improve security.")
		log.Println("Starting http server on port " + httpPort + "...")
		go func() {
			for con, listener, err := waitPass(""); con; con, listener, err = waitPass("") {
				if err != nil {
					panic(err)
				}
				defer listener.Close()
				log.Println("Starting http server on I2P " + httpPort + "...")
				if err := http.Serve(listener, httpRouter); err != nil {
					log.Fatal("Error: Couldn't start the I2P server:", err)
				}
			}
		}()
		if !*notray {
			go func() {
				log.Println("Starting http server on port " + httpPort + "...")
				if err := http.ListenAndServe(httpPort, httpRouter); err != nil {
					log.Fatal("Error: Couldn't start the HTTP server:", err)
				}
			}()
			RunSystray()
		} else {
			log.Println("Starting http server on port " + httpPort + "...")
			if err := http.ListenAndServe(httpPort, httpRouter); err != nil {
				log.Fatal("Error: Couldn't start the HTTP server:", err)
			}
		}
	}
}

func addrString(addr string) string {
	if strings.HasPrefix(addr, ":") {
		return fmt.Sprintf("127.0.0.1%s", addr)
	}
	return addr
}
