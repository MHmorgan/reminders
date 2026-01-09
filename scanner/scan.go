package scanner

import (
	"sync"

	"github.com/MHmorgan/reminders/reminder"
	"github.com/MHmorgan/reminders/searcher"
)

// Scan for reminders in all the search results received from the
// input channel.
//
// For each scanned file, a single [Result] is passed
// to the output channel.
func Scan(nWorkers int, in <-chan searcher.Result) <-chan Result {
	out := make(chan Result, nWorkers)

	go func() {
		defer close(out)

		var wg sync.WaitGroup
		wg.Add(nWorkers)

		for range nWorkers {
			go func() {
				defer wg.Done()
				work(in, out)
			}()
		}

		wg.Wait()
	}()

	return out
}

func work(in <-chan searcher.Result, out chan<- Result) {
	var scn Scanner

	for res := range in {
		reminders := make(chan reminder.Reminder, 1)
		out <- Result{res.Path, reminders}

		scn.Init(res.Path, res.File, reminders)
		scn.Scan()
		res.File.Close()
		close(reminders)
	}
}
