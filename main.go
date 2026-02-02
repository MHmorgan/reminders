package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"runtime"

	"github.com/MHmorgan/reminders/scanner"
	"github.com/MHmorgan/reminders/searcher"
)

const version = "1.0.2"

var (
	printVersion = flag.Bool("version", false, "print app version")
	cpuprofile   = flag.String("cpuprofile", "", "write cpu profile to `file`")
	memprofile   = flag.String("memprofile", "", "write memory profile to `file`")
)

// @Next @Use viper for config?
// @Next @Use log (charmbracelet) for application logging
// @Next @Use lipgloss/bubbletea for application output
// @Todo @Handle formatting only when printing

var include = map[string]bool{
	".bash": true,
	".c":    true,
	".cpp":  true,
	".css":  true,
	".go":   true,
	".html": true,
	".java": true,
	".js":   true,
	".kt":   true,
	".lua":  true,
	".nu":   true,
	".pl":   true,
	".py":   true,
	".rb":   true,
	".rs":   true,
	".sql":  true,
	".ts":   true,
	".yaml": true,
	".zig":  true,
	".zsh":  true,
}

var exclude = map[string]bool{
	".DS_Store": true,
	".git":      true,
	".gradle":   true,
	".idea":     true,
	"build":     true,
	"dist":      true,
	"target":    true,
	"venv":      true,
}

func main() {
	flag.Parse()

	if *printVersion {
		fmt.Println(version)
		return
	}

	if *cpuprofile != "" {
		startCpuProfiling(*cpuprofile)
	}

	cwd, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}
	fsys := os.DirFS(cwd)

	srch := searcher.New(include, exclude)
	srchRes := srch.Search(fsys)

	nWorkers := max(1, runtime.NumCPU()-2)
	scanRes := scanner.Scan(nWorkers, srchRes)

	printResults(flag.Args(), scanRes)

	if *memprofile != "" {
		startMemProfiling(*memprofile)
	}
}
