package main

import (
	"github.com/MHmorgan/reminders/reminder"
	"github.com/MHmorgan/reminders/scanner"
)

type scanResult struct {
	path      string
	reminders <-chan reminder.Reminder
}

// Scan for reminders in all the files received from the `files` channel.
//
// Each file is scanned in a separate goroutine, using a separate channel
// (passed to `reminders`) which is clased when the scanning of the file is
// completed.
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
		_ = res.file.Close()
		close(reminders)
	}
}
