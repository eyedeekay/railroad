package main

import (
	"embed"
	"log"
	"path/filepath"

	"github.com/eyedeekay/unembed"
	flags "i2pgit.org/idk/railroad/common"
)

//go:embed content/*
var content embed.FS

//go:embed built-in/*
var builtin embed.FS

func unpack() error {
	contentPath := filepath.Join(flags.CustomPath, ".")
	log.Println("Unpacking built-in themes", contentPath)
	err := unembed.Unembed(content, contentPath)
	if err != nil {
		return err
	}
	builtinPath := filepath.Join(flags.CustomPath, ".")
	log.Println("Unpacking built-in themes", builtinPath)
	err = unembed.Unembed(builtin, builtinPath)
	if err != nil {
		return err
	}
	return nil
}
