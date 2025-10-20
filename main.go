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

/*
@Todo Review codex comments on profiling results:

• Findings

  - CPU is now dominated by synchronous file reads: the hottest stack is io.ReadAll invoked from fileScanning (filescan.go:31), which issues repeated read syscalls. This shows the scanner loads whole files into memory before processing, causing I/O stalls and large single
    allocations.
  - Garbage collection remains in the top stacks (runtime.gcDrain, gcBgMarkWorker): the large byte slices created per file by io.ReadAll quickly become garbage once scanner.Init finishes, so GC threads burn CPU reclaiming them.
  - Filesystem walking/opening still consumes noticeable samples (fs.WalkDir via fileSearch, filesearch.go:58 and os.Open/os.ReadDir): directory traversal and per-file open/close overhead is still significant, especially if the scan runs over many files each invocation.
  - Scheduler activity (runtime.mcall, park_m, wakep) suggests the goroutine-per-file pattern in fileScanning produces short-lived workers that block on I/O and keep the scheduler busy without much parallel work.

  Potential Improvements

  - Switch from io.ReadAll to a streaming reader (e.g., wrap the fs.File in a buffered reader and feed scanner line or chunk at a time) so scans avoid loading entire files into memory and reduce GC churn.
  - If whole-buffer processing is required, reuse a byte slice between files (e.g., via sync.Pool) so successive scans avoid fresh allocations and cut GC load.
  - Coalesce filesystem access: narrow the walk roots, cache prior results for repeated runs, or batch file opens to lower the os.Open/ReadDir overhead hitting filesearch.go:58.
  - Reconsider the goroutine strategy in fileScanning: use a bounded worker pool or synchronous scanning when I/O dominates, reducing the scheduler wake/sleep overhead observed in the profile.
  - For very large directories, consider incremental or prioritized scanning so active file processing finishes before starting new goroutines, improving cache locality and reducing open-file churn.

  Next steps: decide whether to prototype a streaming scanner or buffer pooling first, then re-profile to confirm reduced io.ReadAll and GC hotspots.

---

• Concurrency Model

  - The current pipeline uses two goroutines total: fileSearch produces descriptors while fileScanning consumes them. Files are still scanned one at a time (io.ReadAll happens on a single goroutine), so you don’t actually get many files scanning in parallel; at best the walker can
    stay one file ahead thanks to the buffered channel.

  Memory Impact

  - io.ReadAll loads each file into a fresh []byte slice the size of the file. That slice lives until the next GC cycle, so memory spikes toward the size of the largest file you touch and the collector has to reclaim it every iteration.
  - Because only one scan runs at once, the goroutine split doesn’t add extra copies, but it also means GC work is tightly coupled to whichever file is being read.

  Why the First Run Is Slow

  - On a cold run the OS must hit the filesystem for every ReadDir/Open and stream each file’s contents from disk, so io.ReadAll dominates CPU while waiting on I/O.
  - Subsequent runs benefit from the kernel page cache: directories and file contents are already in memory, so reads return immediately and the profile shifts toward CPU-bound GC and parsing work, which feels “much faster.”

  Next Steps

  1. Replace io.ReadAll with a streaming reader (e.g., bufio.Reader feeding the scanner) so large files don’t need full-buffer allocations and GC becomes lighter.
  2. If keeping the whole buffer is unavoidable, pool and reuse byte slices via sync.Pool to cut per-file allocations and keep GC stable between cold and warm runs.
  3. Increase useful parallelism carefully: for example, a bounded worker pool (N scanners) can overlap disk I/O without overwhelming memory, provided each worker streams rather than calls ReadAll.

*/

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
