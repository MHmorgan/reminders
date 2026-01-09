package scanner

import "github.com/MHmorgan/reminders/reminder"

// The results of scanning a single file for reminders.
//
// Includes the path of the scanned file and a channel
// of reminders which is closed when scanning of the file
// is completed.
type Result struct {
	Path      string
	Reminders <-chan reminder.Reminder
}
