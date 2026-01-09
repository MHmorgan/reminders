package searcher

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
)

type StringSet map[string]bool

// Searcher finds the source code files which should be scanned for reminders.
type Searcher struct {
	include StringSet
	exclude StringSet
}

func New(include, exclude StringSet) Searcher {
	return Searcher{include, exclude}
}

func (s *Searcher) Search(fsys fs.FS) <-chan Result {
	out := make(chan Result, 1)

	go func() {
		defer close(out)
		s.search(out, fsys)
	}()

	return out
}

func (s *Searcher) search(out chan<- Result, fsys fs.FS) {
	err := fs.WalkDir(fsys, ".", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		if d.IsDir() {
			name := d.Name()
			if path == "." {
				return nil
			}
			if s.exclude[name] {
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
		if !s.include[ext] && ext != "" {
			return nil
		}

		if f, err := fsys.Open(path); err != nil {
			fmt.Fprintf(os.Stderr, "Failed to open %q: %v", path, err)
		} else {
			out <- Result{path, f}
		}
		return nil
	})

	if err != nil {
		fmt.Fprintf(os.Stderr, "Search error: %v\n", err)
	}
}
