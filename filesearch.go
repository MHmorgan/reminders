package main

import (
	"fmt"
	"io/fs"
	"path/filepath"
	"strings"
)

var includedFileTypes = map[string]struct{}{
	".bash": {},
	".c":    {},
	".cpp":  {},
	".css":  {},
	".go":   {},
	".html": {},
	".java": {},
	".js":   {},
	".kt":   {},
	".lua":  {},
	".nu":   {},
	".pl":   {},
	".py":   {},
	".rb":   {},
	".rs":   {},
	".sql":  {},
	".ts":   {},
	".yaml": {},
	".zig":  {},
	".zsh":  {},
}

var excludedDirectories = map[string]struct{}{
	".DS_Store": {},
	".git":      {},
	".gradle":   {},
	".idea":     {},
	"build":     {},
	"dist":      {},
	"target":    {},
	"venv":      {},
}

type searchResult struct {
	path string
	file fs.File
}

// Search for files in `fsys`.
//
// Any encountered files are opened and passed to `files`.
//
// If opening a file fails or walking the filesystem fails,
// the error is passed to `errors`.
func fileSearch(fsys fs.FS, files chan<- searchResult, errors chan<- error) {
	defer close(files)

	err := fs.WalkDir(fsys, ".", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		if d.IsDir() {
			name := d.Name()
			if path == "." {
				return nil
			}
			if _, ok := excludedDirectories[name]; ok {
				return fs.SkipDir
			}
			// Skip hidden directories
			if strings.HasPrefix(name, ".") {
				return fs.SkipDir
			}
			return nil
		}

		if !d.Type().IsRegular() {
			return nil
		}

		ext := filepath.Ext(path)
		if _, ok := includedFileTypes[ext]; !ok && ext != "" {
			return nil
		}

		if f, err := fsys.Open(path); err != nil {
			errors <- fmt.Errorf("Failed to open %q: %w", path, err)
		} else {
			files <- searchResult{path, f}
		}
		return nil
	})

	if err != nil {
		errors <- err
	}
}
