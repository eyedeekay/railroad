package filenames

import (
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/kardianos/osext"
	flags "i2pgit.org/idk/railroad/common"
)

func logString(name, asset string) string {
	//log.Println(name, asset)
	return asset
}

// Determine the path the Journey executable is in - needed to load relative assets
func ExecutablePath() string { return logString("ExecutablePath", determineExecutablePath()) }

// Determine the path to the assets folder (default: Journey root folder)
func AssetPath() string { return logString("AssetPath", determineAssetPath()) }

// var (
// For assets that are created, changed, our user-provided while running journey
func ConfigFilename() string {
	return logString("ConfigFilename", filepath.Join(AssetPath(), "config.json"))
}
func ContentFilepath() string {
	return logString("ContentFilepath", filepath.Join(AssetPath(), "content"))
}
func DatabaseFilepath() string {
	return logString("DatabaseFilepath", filepath.Join(ContentFilepath(), "data"))
}
func DatabaseFilename() string {
	return logString("DatabaseFilename", filepath.Join(ContentFilepath(), "data", "journey.db"))
}
func ThemesFilepath() string {
	return logString("ThemesFilepath", filepath.Join(ContentFilepath(), "themes"))
}
func ImagesFilepath() string {
	return logString("ImagesFilepath", filepath.Join(ContentFilepath(), "images"))
}
func PluginsFilepath() string {
	return logString("PluginsFilepath", filepath.Join(ContentFilepath(), "plugins"))
}
func PagesFilepath() string {
	return logString("PagesFilepath", filepath.Join(ContentFilepath(), "pages"))
}

// For https
func HttpsFilepath() string {
	return logString("HttpsFilepath", filepath.Join(ContentFilepath(), "https"))
}
func HttpsCertFilename() string {
	return logString("HttpsCertFilename", filepath.Join(ContentFilepath(), "https", "cert.pem"))
}
func HttpsKeyFilename() string {
	return logString("HttpsKeyFilename", filepath.Join(ContentFilepath(), "https", "key.pem"))
}

// For built-in files (e.g. the admin interface)
func AdminFilepath() string {
	return logString("AdminFilepath", filepath.Join(ExecutablePath(), "built-in", "admin"))
}
func PublicFilepath() string {
	return logString("PublicFilepath", filepath.Join(ExecutablePath(), "built-in", "public"))
}
func HbsFilepath() string {
	return logString("HbsFilepath", filepath.Join(ExecutablePath(), "built-in", "hbs"))
}

// For blog  (this is a url string)
// TODO: This is not used at the moment because it is still hard-coded into the create database string
func DefaultBlogLogoFilename() string  { return "/public/images/blog-logo.jpg" }
func DefaultBlogCoverFilename() string { return "/public/images/blog-cover.jpg" }

// For users (this is a url string)
func DefaultUserImageFilename() string { return "/public/images/user-image.jpg" }
func DefaultUserCoverFilename() string { return "/public/images/user-cover.jpg" }

//)

func CreateDirs() {
	// Create content directories if they are not created already
	err := createDirectories()
	if err != nil {
		log.Fatal("Error: Couldn't create directories:", err)
	}

}

func createDirectories() error {
	paths := []string{DatabaseFilepath(), ThemesFilepath(), ImagesFilepath(), HttpsFilepath(), PluginsFilepath(), PagesFilepath()}
	for _, path := range paths {
		if _, err := os.Stat(path); os.IsNotExist(err) {
			log.Println("Creating " + path)
			err := os.MkdirAll(path, 0776)
			if err != nil {
				return err
			}
		}
	}
	return nil
}

func bashPath(contentPath string) string {
	if strings.HasPrefix(contentPath, "~") {
		return strings.Replace(contentPath, "~", os.Getenv("HOME"), 1)
	}
	return contentPath
}

func determineAssetPath() string {
	if flags.CustomPath != "" {
		contentPath, err := filepath.Abs(bashPath(flags.CustomPath))
		if err != nil {
			log.Fatal("Error: Couldn't read from custom path:", err)
		}
		return contentPath
	}
	return determineExecutablePath()
}

func determineExecutablePath() string {
	// Get the path this executable is located in
	executablePath, err := osext.ExecutableFolder()
	if err != nil {
		log.Fatal("Error: Couldn't determine what directory this executable is in:", err)
	}
	return executablePath
}
