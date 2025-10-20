package main

import (
	"flag"
	"fmt"
	"os"
	"path"
	"strings"

	"github.com/MHmorgan/reminders/reminder"
	"github.com/MHmorgan/reminders/tio"
)

// @Todo Only search text files
// @Todo Don't search files with known non-code file extensions
// @Todo Handle formatting only when printing

func main() {
	flag.Parse()
	filters := normalizeTags(flag.Args())

	searchRes := make(chan searchResult)
	scanRes := make(chan scanResult)
	errors := make(chan error, 1)

	cwd, err := os.Getwd()
	if err != nil {
		panic(err)
	}
	fsys := os.DirFS(cwd)

	go fileSearch(fsys, searchRes, errors)
	go fileScanning(searchRes, scanRes, errors)

	// Consume and print results
	for res := range scanRes {
		base := path.Base(res.path)
		dir := path.Dir(res.path)
		printPath := true

		for r := range res.reminders {
			if !shouldEmit(r, filters) {
				continue
			}
			if printPath {
				fmt.Printf("\n%s%s%s%s/%s%s%s\n", tio.Bold, tio.Dim, dir, tio.Reset, tio.Bold, base, tio.Reset)
				printPath = false
			}
			fmt.Printf("%4d: %s\n", r.Line(), r.Text())
		}

		select {
		case err := <-errors:
			fmt.Fprintf(os.Stderr, "walk error: %v\n", err)
		default:
		}
	}

	select {
	case err := <-errors:
		fmt.Fprintf(os.Stderr, "walk error: %v\n", err)
	default:
	}
}

func normalizeTags(args []string) map[string]struct{} {
	if len(args) == 0 {
		return map[string]struct{}{
			"bug":      {},
			"consider": {},
			"fix":      {},
			"later":    {},
			"next":     {},
			"todo":     {},
		}
	}

	filters := make(map[string]struct{}, len(args))
	for _, a := range args {
		tag := strings.ToLower(strings.TrimSpace(a))
		if tag == "" {
			continue
		}
		filters[tag] = struct{}{}
	}
	if len(filters) == 0 {
		return nil
	}
	return filters
}

func shouldEmit(r reminder.Reminder, filters map[string]struct{}) bool {
	if len(filters) == 0 {
		return true
	}

	for _, tag := range r.Tags() {
		if _, ok := filters[strings.ToLower(tag)]; ok {
			return true
		}
	}
	return false
}
