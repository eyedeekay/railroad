package main

import (
	"embed"
	"path/filepath"

	"github.com/eyedeekay/unembed"
)

//go:embed content/*
var content embed.FS

//go:embed built-in/*
var builtin embed.FS

func unpack() error {
	contentPath := filepath.Join(directory, ".")
	err := unembed.Unembed(content, contentPath)
	if err != nil {
		return err
	}
	builtinPath := filepath.Join(directory, ".")
	err = unembed.Unembed(builtin, builtinPath)
	if err != nil {
		return err
	}
	return nil
}
