package main

import (
	"fmt"

	"github.com/MHmorgan/reminders/reminder"
	"github.com/MHmorgan/reminders/scanner"
)

// The results of scanning a single file for reminders.
//
// Includes the path of the scanned file and a channel
// of reminders which is closed when scanning of the file
// is completed.
type scanResult struct {
	path      string
	reminders <-chan reminder.Reminder
}

// Scan for reminders in all the search results received from the
// input channel.
//
// For each scanned file, a single [scanResult] is passed
// to the output channel.
func fileScanning(
	in <-chan searchResult,
	out chan<- scanResult,
	errors chan<- error,
) {
	defer close(out)

	var scn scanner.Scanner

	for res := range in {
		reminders := make(chan reminder.Reminder, 1)
		out <- scanResult{res.path, reminders}

		scn.Init(res.path, res.file, reminders)
		scn.Scan()
		if err := scn.Err(); err != nil {
			errors <- fmt.Errorf("scan %s: %w", res.path, err)
		}
		_ = res.file.Close()
		close(reminders)
	}
}
