package scanner

import (
	"slices"
	"strings"
	"testing"

	"github.com/MHmorgan/reminders/reminder"
)

const fTest = "langly-falls.go"

func testScanner(t *testing.T, source string, sz int) (*Scanner, <-chan reminder.Reminder, error) {
	t.Helper()

	out := make(chan reminder.Reminder, sz)

	var scn Scanner
	scn.Init(fTest, strings.NewReader(source), out)
	return &scn, out, nil
}

func drain(out <-chan reminder.Reminder) []reminder.Reminder {
	n := len(out)
	results := make([]reminder.Reminder, 0, n)
	for range n {
		results = append(results, <-out)
	}
	return results
}

// -----------------------------------------------------------------------------
//
// Basic tests
//
// -----------------------------------------------------------------------------

func TestBasics(t *testing.T) {
	t.Helper()

	var (
		fLine = 1
		fText = "TODO TEST TEXT"
		fTag  = "todo"
		fTmpl = "@" + fText
		fSpan = []reminder.Span{{Start: 0, End: 4}}
	)

	var tests = []struct {
		name   string
		source string
	}{
		{name: "cpp", source: "// " + fTmpl},
		{name: "hash", source: "# " + fTmpl},
		{name: "dash", source: "-- " + fTmpl},
		{name: "c", source: "/* " + fTmpl + " */"},
		{name: "html", source: "<!-- " + fTmpl + " -->"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			scn, out, err := testScanner(t, tt.source, 1)
			if err != nil {
				t.Fatalf("NewScanner error: %v", err)
			}
			scn.Scan()

			results := drain(out)
			nRes := len(results)
			if nRes != 1 {
				t.Fatalf("expected 1 reminder, got %d", nRes)
			}

			r := results[0]
			if r.File() != fTest {
				t.Fatalf("expected file %s, got %s", fTest, r.File())
			}
			if r.Line() != fLine {
				t.Fatalf("expected line %d, got %d", fLine, r.Line())
			}
			if r.Text() != fText {
				t.Fatalf("expected text %q, got %q", fText, r.Text())
			}
			fTags := []string{fTag}
			if !slices.Equal(r.Tags(), fTags) {
				t.Fatalf("expected tags %v, got %v", fTags, r.Tags())
			}
			if !slices.Equal(r.Spans(), fSpan) {
				t.Fatalf("expected spans %v, got %v", fSpan, r.Spans())
			}
		})
	}
}

// -----------------------------------------------------------------------------
//
// Composite tests
//
// -----------------------------------------------------------------------------

const compositeSource = `
// @Todo Clean this up
def foo() {
	-- @Todo @Later: Do more?
	echo "Hello world!" # @Bug @Fix Wrong text!
}

<!-- @Next Remove this -->
foo()
`

var expect = []struct {
	line  int
	tags  []string
	text  string
	spans []reminder.Span
}{
	{line: 2, tags: []string{"todo"}, text: "Todo Clean this up", spans: []reminder.Span{{Start: 0, End: 4}}},
	{line: 4, tags: []string{"todo", "later"}, text: "Todo Later Do more?", spans: []reminder.Span{{Start: 0, End: 4}, {Start: 5, End: 10}}},
	{line: 5, tags: []string{"bug", "fix"}, text: "Bug Fix Wrong text!", spans: []reminder.Span{{Start: 0, End: 3}, {Start: 4, End: 7}}},
	{line: 8, tags: []string{"next"}, text: "Next Remove this", spans: []reminder.Span{{Start: 0, End: 4}}},
}

func TestComposite(t *testing.T) {
	nExp := len(expect)
	scn, out, err := testScanner(t, compositeSource, nExp)
	if err != nil {
		t.Fatalf("NewScanner error: %v", err)
	}
	scn.Scan()

	results := drain(out)
	nRes := len(results)
	if nRes != nExp {
		t.Fatalf("expected %d reminder, got %d", nExp, nRes)
	}

	for i := range nRes {
		e := expect[i]
		r := results[i]
		if r.File() != fTest {
			t.Fatalf("expected file %s, got %s", fTest, r.File())
		}
		if r.Line() != e.line {
			t.Fatalf("expected line %d, got %d", e.line, r.Line())
		}
		if r.Text() != e.text {
			t.Fatalf("expected text %q, got %q", e.text, r.Text())
		}
		if !slices.Equal(r.Tags(), e.tags) {
			t.Fatalf("expected tags %v, got %v", e.tags, r.Tags())
		}
		if !slices.Equal(r.Spans(), e.spans) {
			t.Fatalf("expected spans %v, got %v", e.spans, r.Spans())
		}
	}
}
