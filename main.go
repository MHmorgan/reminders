package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"path"
	"runtime"
	"runtime/pprof"
	"strings"

	"github.com/MHmorgan/reminders/reminder"
	"github.com/MHmorgan/reminders/tio"
)

var (
	cpuprofile = flag.String("cpuprofile", "", "write cpu profile to `file`")
	memprofile = flag.String("memprofile", "", "write memory profile to `file`")
)

// @Todo Only search text files
// @Todo Handle formatting only when printing

func main() {
	flag.Parse()
	filters := normalizeTags(flag.Args())

	// Start profiling, if requested
	if *cpuprofile != "" {
		f, err := os.Create(*cpuprofile)
		if err != nil {
			log.Fatal("could not create CPU profile: ", err)
		}
		defer f.Close() // error handling omitted for example
		if err := pprof.StartCPUProfile(f); err != nil {
			log.Fatal("could not start CPU profile: ", err)
		}
		defer pprof.StopCPUProfile()
	}

	searchRes := make(chan searchResult, 1)
	scanRes := make(chan scanResult, 1)
	errors := make(chan error, 1)

	cwd, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}
	fsys := os.DirFS(cwd)

	go fileSearch(fsys, searchRes, errors)
	go fileScanning(searchRes, scanRes, errors)

	// Consume and print results
	nFiles := 0
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

		printErr(errors, "walk error")
		nFiles++
	}

	printErr(errors, "walk error")

	// Do memory profiling, if requested
	if *memprofile != "" {
		f, err := os.Create(*memprofile)
		if err != nil {
			log.Fatal("could not create memory profile: ", err)
		}
		defer f.Close() // error handling omitted for example
		runtime.GC()    // get up-to-date statistics
		// Lookup("allocs") creates a profile similar to go test -memprofile.
		// Alternatively, use Lookup("heap") for a profile
		// that has inuse_space as the default index.
		if err := pprof.Lookup("allocs").WriteTo(f, 0); err != nil {
			log.Fatal("could not write memory profile: ", err)
		}
	}

	fmt.Printf("\nScanned %d files.\n", nFiles)
}

func printErr(errors <-chan error, label string) {
	select {
	case err := <-errors:
		fmt.Fprintf(os.Stderr, "%s: %v\n", label, err)
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
		if _, ok := filters[tag]; ok {
			return true
		}
	}
	return false
}
