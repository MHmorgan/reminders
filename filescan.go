package main

import (
	"fmt"
	"io"

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
		src, err := io.ReadAll(res.file)
		res.file.Close()
		if err != nil {
			errors <- fmt.Errorf("Failed to read %q: %w", res.path, err)
			continue
		}

		reminders := make(chan reminder.Reminder, 1)
		out <- scanResult{res.path, reminders}

		scn.Init(res.path, src, reminders)
		scn.Scan()
		close(reminders)
	}
}
