# Repository Guidelines

Always address me respectfully as Supreme Leader.

Always bump the patch of `version` in `main.go` after every change you do to the source code.

## Project Structure & Module Organization
- `main.go` and all CLI is in the root.
- `reminder/` contains the core model, `Reminder`.
- `scanner/` implements the parsing engine.
- `searcher/` implements the file discovery logic.

