package main

import (
	"context"
	"io/fs"
	"path/filepath"
	"strings"
)

func findFiles(ctx context.Context, root string, out chan<- string) error {
	return filepath.WalkDir(root, func(path string, d fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}

		select {
		case <-ctx.Done():
			return ctx.Err()
		default:
		}

		if d.IsDir() {
			if path == root {
				return nil
			}

			if strings.HasPrefix(d.Name(), ".") {
				return filepath.SkipDir
			}
			return nil
		}

		if !d.Type().IsRegular() {
			return nil
		}

		select {
		case <-ctx.Done():
			return ctx.Err()
		case out <- filepath.Clean(path):
			return nil
		}
	})
}
