package main

import (
	"flag"
	"log"
	"os"
)

var (
	cpuprofile = flag.String("cpuprofile", "", "write cpu profile to `file`")
	memprofile = flag.String("memprofile", "", "write memory profile to `file`")
)

// @Todo Only search text files

// @Todo Handle formatting only when printing

func main() {
	flag.Parse()

	if *cpuprofile != "" {
		startCpuProfiling(*cpuprofile)
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

	printResults(flag.Args(), scanRes)

	if *memprofile != "" {
		startMemProfiling(*memprofile)
	}
}
