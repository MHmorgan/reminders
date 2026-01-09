package main

import (
	"fmt"
	"path"
	"strings"

	"github.com/MHmorgan/reminders/reminder"
	"github.com/MHmorgan/reminders/scanner"
	"github.com/MHmorgan/reminders/tio"
)

// Print all the received scan results, using the given
// tags slice as a filter.
func printResults(
	tags []string,
	scanRes <-chan scanner.Result,
) {
	filters := normalizeTags(tags)
	nFiles := 0
	for res := range scanRes {
		base := path.Base(res.Path)
		dir := path.Dir(res.Path)
		printPath := true

		for r := range res.Reminders {
			if !shouldPrint(r, filters) {
				continue
			}
			if printPath {
				fmt.Printf("\n%s%s%s%s/%s%s%s\n", tio.Bold, tio.Dim, dir, tio.Reset, tio.Bold, base, tio.Reset)
				printPath = false
			}
			fmt.Printf("%4d: %s\n", r.Line(), r.Format())
		}

		nFiles++
	}

	fmt.Printf("\nScanned %d files.\n", nFiles)
}

// Normalize the given tags input to a map of tags which should
// be used when filtering reminders to print.
func normalizeTags(tags []string) map[string]struct{} {
	if len(tags) == 0 {
		return map[string]struct{}{
			"bug":      {},
			"consider": {},
			"fix":      {},
			"later":    {},
			"next":     {},
			"todo":     {},
		}
	}

	filters := make(map[string]struct{}, len(tags))
	for _, a := range tags {
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

// Return true if the reminder should be printed,
// based on the given filters.
func shouldPrint(r reminder.Reminder, filters map[string]struct{}) bool {
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
