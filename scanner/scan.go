package scanner

import (
	"github.com/MHmorgan/reminders/reminder"
	"github.com/MHmorgan/reminders/searcher"
)

// Scan for reminders in all the search results received from the
// input channel.
//
// For each scanned file, a single [scanResult] is passed
// to the output channel.
func Scan(nWorkers int, in <-chan searcher.Result) <-chan Result {
	out := make(chan Result, 1)

	go func() {
		defer close(out)

		// Start all worker goroutines
		cs := make([]chan Result, nWorkers)
		for i := range nWorkers {
			c := make(chan Result, 1)
			cs[i] = c
			go work(in, c)
		}

		done := 0
		for done < nWorkers {
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
	}()

	return out
}

func work(in <-chan searcher.Result, out chan<- Result) {
	defer close(out)

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
