//go:build !osxalt
// +build !osxalt

package main

import (
	"encoding/json"
	"flag"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"time"

	"github.com/atotto/clipboard"
	"github.com/dimfeld/httptreemux"
	checksam "github.com/eyedeekay/checki2cp/samcheck"
	sam "github.com/eyedeekay/sam3/helper"
	"github.com/eyedeekay/sam3/i2pkeys"
	"github.com/getlantern/systray"
	"github.com/webview/webview"
	flags "i2pgit.org/idk/railroad/common"
	"i2pgit.org/idk/railroad/configuration"
	"i2pgit.org/idk/railroad/database"
	"i2pgit.org/idk/railroad/filenames"
	"i2pgit.org/idk/railroad/https"
	"i2pgit.org/idk/railroad/icon"
	"i2pgit.org/idk/railroad/plugins"
	"i2pgit.org/idk/railroad/server"
	"i2pgit.org/idk/railroad/structure/methods"
	"i2pgit.org/idk/railroad/templates"
	"i2pgit.org/idk/zerocontrol"
)

func save(c *configuration.Configuration) error {
	data, err := json.Marshal(c)
	if err != nil {
		return err
	}
	return ioutil.WriteFile(filenames.ConfigFilename, data, 0600)
}

func httpsRedirect(w http.ResponseWriter, r *http.Request, _ map[string]string) {
	http.Redirect(w, r, configuration.Config.HttpsUrl+r.RequestURI, http.StatusMovedPermanently)
	return
}

var configjson = `{
	"HttpHostAndPort":"127.0.0.1:8084",
	"HttpsHostAndPort":"127.0.0.1:8085",
	"HttpsUsage":"None",
	"Url":"http://127.0.0.1:8084",
	"HttpsUrl":"https://127.0.0.1:8085",
	"UseLetsEncrypt":false
}`

func onReady() {
	systray.SetIcon(icon.Data)
	systray.SetTitle("Railroad Blog")
	systray.SetTooltip("Blog is running on I2P: http://" + listener.Addr().(i2pkeys.I2PAddr).Base32())
	host := "http://" + strings.Split(listener.Addr().(i2pkeys.I2PAddr).Base32(), ":")[0]
	mShowUrl := systray.AddMenuItem(host, "copy blog address to clipboard")
	mEditUrl := systray.AddMenuItem("Edit your blog", "Edit your blog in it's own webview")
	if strings.HasSuffix(configuration.Config.HttpsUrl, "i2p") {
		if !strings.HasSuffix(configuration.Config.HttpsUrl, "b32.i2p") {
			mCopyUrl := systray.AddMenuItem("Copy blog address helper", "copy blog addresshelper to clipboard")
			go func() {
				<-mCopyUrl.ClickedCh
				log.Println("Requesting copy short address helper")
				clipboard.WriteAll(configuration.Config.HttpsUrl + "/i2paddresshelper=" + listener.Addr().(i2pkeys.I2PAddr).Base32())
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
		go func() {
			<-mEditUrl.ClickedCh
			log.Println("Requesting edit")
			cmd := exec.Command(findMe(), "-uionly=true")
			var out []byte
			var err error
			if out, err = cmd.CombinedOutput(); err != nil {
				log.Println("COMMAND", err)
			} else {
				log.Println(string(out))
			}
			log.Println("Finished requesting edit")
		}()
		go func() {
			<-mShowUrl.ClickedCh
			log.Println("Requesting copy base32")
			clipboard.WriteAll("http://" + strings.Split(listener.Addr().(i2pkeys.I2PAddr).Base32(), ":")[0])
			log.Println("Finished copy base32")
		}()
		time.Sleep(time.Second)
	}
}

func onExit() {
	// clean up here
}

//var webView webview.WebView

var url string

func fileExists(filename string) bool {
	info, err := os.Stat(filename)
	if os.IsNotExist(err) {
		return false
	}
	return !info.IsDir()
}

var listener net.Listener

var domainhelp = `You haven't configured an I2P hostname for your site.
If you want to, edit config.json and change the value of "HttpsUrl:" to your desired human-readable name, ending in .i2p.
For example:

{
	"HttpHostAndPort":"127.0.0.1:8084",
	"HttpsHostAndPort":"127.0.0.1:8085",
	"HttpsUsage":"None",
	"Url":"http://127.0.0.1:8084",
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

func findMe() string {
	if runtime.GOOS == "darwin" {
		file, err := filepath.Abs(os.Args[0] + "-ui")
		if err != nil {
			log.Fatal(err)
		}
		log.Println(file)
		return file
	}
	file, err := filepath.Abs(os.Args[0])
	if err != nil {
		log.Fatal(err)
	}
	log.Println(file)
	return file
}

var socksPort = flag.String("socksport", "8082", "Proxy any outgoing requests in the webview over a SOCKS proxy(will start one if there isn't one ready)")
var uiOnly = flag.Bool("uionly", false, "Launch the UI blindly, with no checks to make sure the blog is running")

func LaunchView() error {
	if err := os.Setenv("NO_PROXY", "127.0.0.1:8084"); err != nil {
		return err
	}
	if err := os.Setenv("ALL_PROXY", "socks5://127.0.0.1:"+*socksPort); err != nil {
		return err
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
	return nil
}

func main() {
	flag.StringVar(&flags.CustomPath, "custompath", "", "Change to custom path for running the blog")
	flag.Parse()
	if *uiOnly {
		err := LaunchView()
		if err != nil {
			log.Fatal(err)
		}
	}

	// Setup
	var err error
	err = os.Chdir(flags.CustomPath)
	if err != nil {
		log.Fatal(err)
	}
	if err = zerocontrol.ZeroMain(); err != nil {
		log.Println(err)
	}
	defer zerocontrol.Close()

	if err = os.Setenv("NO_PROXY", "127.0.0.1:8084"); err != nil {
		panic(err)
	}
	if err = os.Setenv("ALL_PROXY", "socks5://127.0.0.1:"+*socksPort); err != nil {
		panic(err)
	}
	time.Sleep(time.Second * 3)

	//	if err = os.Setenv("http_proxy", "http://127.0.0.1:"+*socksPort); err != nil {
	//		panic(err)
	//	}

	for !checksam.CheckSAMAvailable("127.0.0.1:7656") {
		time.Sleep(time.Second * 15)
		log.Println("Waiting for SAM")
	}

	if status, _, err := portCheck("127.0.0.1:" + *socksPort); err != nil {
		go socksmain()
	} else {
		if status == false {
			go socksmain()
		}
	}

	if status, _, err := portCheck(configuration.Config.HttpHostAndPort); err == nil {
		if status == true {
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
	if configuration.Config.HttpHostAndPort == ":8084" {
		configuration.Config.HttpHostAndPort = "127.0.0.1:8084"
	}
	if configuration.Config.HttpsHostAndPort == ":8085" {
		configuration.Config.HttpsHostAndPort = "127.0.0.1:8085"
	}
	configuration.Config.UseLetsEncrypt = false
	listener, err = sam.I2PListener("railroad", "127.0.0.1:7656", "railroad")
	if err != nil {
		panic(err)
	}

	defer listener.Close()

	if !strings.HasSuffix(configuration.Config.HttpsUrl, "i2p") {
		configuration.Config.HttpsUrl = "https://" + listener.Addr().(i2pkeys.I2PAddr).Base32()
		log.Println(domainhelp)
	}

	save(configuration.Config)

	// GOMAXPROCS - Maybe not needed
	runtime.GOMAXPROCS(runtime.NumCPU())

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
	httpPort := configuration.Config.HttpHostAndPort
	httpsPort := configuration.Config.HttpsHostAndPort
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
	switch configuration.Config.HttpsUsage {
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
		go func() {
			if err := https.StartServer(listener, httpsRouter); err != nil {
				log.Fatal("Error: Couldn't start the HTTPS server:", err)
			}
		}()
		// Start http server
		log.Println("Starting http server on port " + httpPort + "...")
		go func() {
			if err := http.Serve(listener, httpRouter); err != nil {
				log.Fatal("Error: Couldn't start the I2P server:", err)
			}
		}()
		go func() {
			if err := http.ListenAndServe(httpPort, httpRouter); err != nil {
				log.Fatal("Error: Couldn't start the HTTP server:", err)
			}
		}()
		systray.Run(onReady, onExit)
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
		log.Println("Starting https server on port " + httpsPort + "...")
		go func() {
			if err := https.StartServer(listener, httpsRouter); err != nil {
				log.Fatal("Error: Couldn't start the HTTPS server:", err)
			}
		}()
		// Start http server
		log.Println("Starting http server on port " + httpPort + "...")
		go func() {
			if err := http.Serve(listener, httpRouter); err != nil {
				log.Fatal("Error: Couldn't start the I2P server:", err)
			}
		}()
		if err := http.ListenAndServe(httpPort, httpRouter); err != nil {
			log.Fatal("Error: Couldn't start the HTTP server:", err)
		}
		systray.Run(onReady, onExit)
	default: // This is configuration.HttpsUsage == "None"
		httpRouter := httptreemux.New()
		// Blog and pages as http
		server.InitializeBlog(httpRouter)
		server.InitializePages(httpRouter)
		// Admin as http
		server.InitializeAdmin(httpRouter)
		// Start http server
		log.Println("Starting server without HTTPS support. Please enable HTTPS in " + filenames.ConfigFilename + " to improve security.")
		log.Println("Starting http server on port " + httpPort + "...")
		go func() {
			if err := http.Serve(listener, httpRouter); err != nil {
				log.Fatal("Error: Couldn't start the I2P server:", err)
			}
		}()
		go func() {
			if err := http.ListenAndServe(httpPort, httpRouter); err != nil {
				log.Fatal("Error: Couldn't start the HTTP server:", err)
			}
		}()
		systray.Run(onReady, onExit)
	}
}
