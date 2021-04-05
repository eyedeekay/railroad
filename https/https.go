package https

import (
	"log"
	"net"
	"net/http"

	"github.com/kabukky/httpscerts"
	"github.com/kabukky/journey/configuration"
	"github.com/kabukky/journey/filenames"
)

func checkCertificates() {
	// Check https certificates. If they are not available generate temporary ones for testing.
	if err := httpscerts.Check(filenames.HttpsCertFilename, filenames.HttpsKeyFilename); err != nil {
		log.Println("Warning: couldn't load https certs. Generating new ones. Replace " + filenames.HttpsCertFilename + " and " + filenames.HttpsKeyFilename + " with your own certificates as soon as possible!")
		if err := httpscerts.Generate(filenames.HttpsCertFilename, filenames.HttpsKeyFilename, configuration.Config.HttpsUrl); err != nil {
			log.Fatal("Error: Couldn't create https certificates.")
			return
		}
	}
}

func StartServer(listener net.Listener, handler http.Handler) error {
	checkCertificates()
	return http.ServeTLS(listener, handler, filenames.HttpsCertFilename, filenames.HttpsKeyFilename)
}
