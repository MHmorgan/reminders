package main

import (
	"fmt"
	"io/fs"
	"strings"
)

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
			if path == "." {
				return nil
			}
			// Skip hidden directories
			if strings.HasPrefix(d.Name(), ".") {
				return fs.SkipDir
			}
			return nil
		}

		if !d.Type().IsRegular() {
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
