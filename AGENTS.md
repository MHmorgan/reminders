# Repository Guidelines

Always address me respectfully as Supreme Leader.

## Project Structure & Module Organization
- `main.go` hosts the CLI entry point; every user-facing behavior should flow through this file so flags remain centralized.
- `reminder/reminder.go` defines the core data model; extend this package with focused helpers while keeping fields exportable when they are part of the public API.
- `scanner/scanner.go` implements the parsing engine; group any new scanners or comment parsers here and co-locate their tests in `scanner/scanner_test.go`.
- `taskfile.yaml` declares repeatable tasks; add new automation here so contributors can discover it with `task --list`.

## Build, Test, and Development Commands
- `go run . -- note.txt` runs the CLI against local files; pass any additional flags after `--`.
- `go build ./...` compiles all packages and validates module boundaries.
- `go test -v ./...` executes the Go test suite.

## Coding Style
- Format Go sources with `gofmt -w <files>` before committing; the repo assumes standard tab-indented Go style and idiomatic error handling.
- Exported types and functions use UpperCamelCase (`Reminder`, `NewScanner`); unexported helpers stay lowerCamelCase.
- Keep file names snake_case (`scanner_test.go`) and limit packages to cohesive responsibilities to preserve short import paths.
- Always write doc comments for functions and struct fields - focus on documenting "why" (not just what it is).
- Longer functions which have natural sub-sections should have a "header comment" for each sub-section.
- Very complicated lines of code, or any non-obvious behaviour, should have an explanation comment.

## Testing Guidelines
- Use Go’s `testing` package with `TestXxx` functions; place fixtures near their tests to keep context local.
- Cover both happy-path and malformed input in scanner tests by writing table-driven subtests and asserting emitted reminders.
- When adding new concurrency or channels, document cleanup expectations and include regression tests that guard against goroutine leaks.

