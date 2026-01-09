package searcher

import "io/fs"

// Result is one entry found by Searcher when searching through
// a file hierarchy for source code files which should be scanned.
type Result struct {
	Path string
	File fs.File
}
