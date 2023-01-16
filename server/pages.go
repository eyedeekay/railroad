package server

import (
	"log"
	"net/http"
	"path/filepath"
	"strings"

	"github.com/dimfeld/httptreemux"
	"i2pgit.org/idk/railroad/filenames"
	"i2pgit.org/idk/railroad/helpers"
)

func setHeader(p func(w http.ResponseWriter, r *http.Request, params map[string]string)) func(w http.ResponseWriter, r *http.Request, params map[string]string) {
	wrappedHandler := func(w http.ResponseWriter, r *http.Request, params map[string]string) {
		path := filepath.Join(filenames.PagesFilepath, params["filepath"])
		switch filepath.Ext(path) {
		case "js":
			log.Println("Is JS", path)
			w.Header().Set("content-type", "application/javascript")
		case "css":
			log.Println("Is CSS", path)
			w.Header().Set("content-type", "text/stylesheet")
		}
		path2 := filepath.Join(filenames.PagesFilepath, r.URL.Path)
		switch filepath.Ext(path2) {
		case "js":
			log.Println("Is JS", path2)
			w.Header().Set("content-type", "application/javascript")
		case "css":
			log.Println("Is CSS", path)
			w.Header().Set("content-type", "text/stylesheet")
		}
		p(w, r, params)
	}
	return wrappedHandler
}

func pagesHandler(w http.ResponseWriter, r *http.Request, params map[string]string) {
	path := filepath.Join(filenames.PagesFilepath, params["filepath"])
	// If the path points to a directory, add a trailing slash to the path (needed if the page loads relative assets).
	if helpers.IsDirectory(path) && !strings.HasSuffix(r.RequestURI, "/") {
		http.Redirect(w, r, r.RequestURI+"/", 301)
		return
	}
	http.ServeFile(w, r, path)
	return
}

func InitializePages(router *httptreemux.TreeMux) {
	// For serving standalone projects or pages saved in in content/pages
	router.GET("/pages/*filepath", setHeader(pagesHandler))
}
