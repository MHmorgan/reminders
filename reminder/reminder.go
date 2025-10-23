package reminder

import (
	"strings"

	"github.com/MHmorgan/reminders/tio"
)

// Reminder stores the location, text, tags, and formatting ranges extracted
// from a source comment.
type Reminder struct {
	file  string
	line  int
	tags  []string
	text  string
	spans []Span
}

// Span marks the rune offsets of a tag within the reminder text.
// Start is inclusive and End is exclusive.
type Span struct {
	Start int
	End   int
}

// New constructs a Reminder for the given file, line, text, tags, and spans.
func New(file string, line int, text string, tags []string, spans []Span) Reminder {
	return Reminder{
		file:  file,
		line:  line,
		text:  text,
		tags:  tags,
		spans: spans,
	}
}

// File reports the file path that produced the reminder.
func (r Reminder) File() string {
	return r.file
}

// Line reports the line number where the reminder was found.
func (r Reminder) Line() int {
	return r.line
}

// Text returns the normalized reminder text.
func (r Reminder) Text() string {
	return r.text
}

// Tags returns the tags associated with the reminder.
func (r Reminder) Tags() []string {
	return r.tags
}

// Spans returns the formatting spans for the reminder's tags.
func (r Reminder) Spans() []Span {
	return r.spans
}

// SetTags replaces the reminder's tags in place.
func (r *Reminder) SetTags(tags []string) {
	r.tags = tags
}

func (r *Reminder) Format() string {
	spans := r.Spans()
	if len(spans) == 0 {
		return r.Text()
	}

	text := r.Text()
	if text == "" {
		return text
	}

	runes := []rune(text)
	var b strings.Builder
	b.Grow(len(text) + len(spans)*(len(tio.Bold)+len(tio.Reset)))

	spanIdx := 0
	active := false
	for i, rn := range runes {
		if spanIdx < len(spans) && spans[spanIdx].Start == i {
			if !active {
				b.WriteString(tio.Bold)
				active = true
			}
		}
		b.WriteRune(rn)
		if spanIdx < len(spans) && spans[spanIdx].End == i+1 {
			if active {
				b.WriteString(tio.Reset)
				active = false
			}
			spanIdx++
		}
	}

	if active {
		b.WriteString(tio.Reset)
	}

	return b.String()
}
