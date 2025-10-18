package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"strings"
	"syscall"

	"github.com/MHmorgan/reminders/reminder"
)

func main() {
	flag.Parse()
	filters := normalizeArgs(flag.Args())

	rootCtx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	ctx, cancel := context.WithCancel(rootCtx)
	defer cancel()

	fileCh := make(chan string)
	reminderCh := make(chan reminder.Reminder)
	errCh := make(chan error, 2)

	go func() {
		err := findFiles(ctx, ".", fileCh)
		close(fileCh)
		if err != nil && !errors.Is(err, context.Canceled) {
			select {
			case errCh <- err:
			default:
			}
			cancel()
		}
	}()

	go func() {
		err := scanFiles(ctx, cancel, fileCh, reminderCh)
		close(reminderCh)
		if err != nil && !errors.Is(err, context.Canceled) {
			select {
			case errCh <- err:
			default:
			}
			cancel()
		}
	}()

	var runErr error
	var ctxErr error

	for {
		select {
		case r, ok := <-reminderCh:
			if !ok {
				goto drainErrors
			}
			if !shouldEmit(r, filters) {
				continue
			}
			fmt.Printf("%s:%d [%s] %s\n", r.File(), r.Line(), strings.Join(r.Tags(), ", "), r.Text())
		case err := <-errCh:
			if err != nil && runErr == nil {
				runErr = err
			}
		case <-ctx.Done():
			if ctxErr == nil {
				ctxErr = ctx.Err()
			}
		}
	}

drainErrors:
	for {
		select {
		case err := <-errCh:
			if err != nil && runErr == nil {
				runErr = err
			}
		default:
			goto finalize
		}
	}

finalize:
	if runErr != nil {
		fmt.Fprintf(os.Stderr, "%v\n", runErr)
		os.Exit(1)
	}
	if ctxErr != nil && !errors.Is(ctxErr, context.Canceled) {
		fmt.Fprintf(os.Stderr, "%v\n", ctxErr)
		os.Exit(1)
	}
}

func normalizeArgs(args []string) map[string]struct{} {
	if len(args) == 0 {
		return nil
	}

	filters := make(map[string]struct{}, len(args))
	for _, a := range args {
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

func shouldEmit(r reminder.Reminder, filters map[string]struct{}) bool {
	if len(filters) == 0 {
		return true
	}

	for _, tag := range r.Tags() {
		if _, ok := filters[strings.ToLower(tag)]; ok {
			return true
		}
	}
	return false
}
