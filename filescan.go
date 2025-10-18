package main

import (
	"context"
	"fmt"
	"os"
	"sync"

	"github.com/MHmorgan/reminders/reminder"
	"github.com/MHmorgan/reminders/scanner"
)

func scanFiles(ctx context.Context, cancel context.CancelFunc, paths <-chan string, out chan<- reminder.Reminder) error {
	var wg sync.WaitGroup
	errCh := make(chan error, 1)

	sendError := func(err error) {
		if err == nil {
			return
		}
		select {
		case errCh <- err:
		default:
		}
	}

	launch := func(path string) {
		wg.Add(1)
		go func(p string) {
			defer wg.Done()

			select {
			case <-ctx.Done():
				return
			default:
			}

			data, err := os.ReadFile(p)
			if err != nil {
				sendError(fmt.Errorf("read %s: %w", p, err))
				cancel()
				return
			}

			scn, err := scanner.NewScanner(p, data, out)
			if err != nil {
				sendError(fmt.Errorf("scanner %s: %w", p, err))
				cancel()
				return
			}

			scn.Scan()
		}(path)
	}

	for {
		select {
		case <-ctx.Done():
			wg.Wait()
			select {
			case err := <-errCh:
				return err
			default:
				return ctx.Err()
			}
		case err := <-errCh:
			if err != nil {
				cancel()
				wg.Wait()
				return err
			}
		case path, ok := <-paths:
			if !ok {
				wg.Wait()
				select {
				case err := <-errCh:
					return err
				default:
					return nil
				}
			}
			launch(path)
		}
	}
}
