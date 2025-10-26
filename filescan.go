package main

import (
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
	workers int,
	in <-chan searchResult,
	out chan<- scanResult,
) {
	defer close(out)

	cs := make([]chan scanResult, workers)
	for i := range workers {
		c := make(chan scanResult, 1)
		cs[i] = c
		go fileScanningWorker(in, c)
	}

	done := 0
	for done < workers {
		for i, c := range cs {
			if c == nil {
				continue
			}
			select {
			case res, ok := <-c:
				if ok {
					out <- res
				} else {
					cs[i] = nil
					done++
				}
			default:
			}
		}
	}
}

func fileScanningWorker(
	in <-chan searchResult,
	out chan<- scanResult,
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
