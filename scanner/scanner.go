package scanner

import (
	"slices"
	"strings"

	"github.com/MHmorgan/reminders/reminder"
)

var (
	htmlOpen   = []byte("<!--")
	htmlClose  = []byte("-->")
	blockClose = []byte("*/")
)

func NewScanner(
	file string,
	src []byte,
	out chan<- reminder.Reminder,
) (*Scanner, error) {
	s := &Scanner{
		src:       src,
		file:      file,
		line:      1,
		reminders: out,
	}
	return s, nil
}

// A Scanner holds the scanner's internal state while scanning
// a source file for reminders.
type Scanner struct {
	src []byte

	ch   byte
	pos  int
	line int
	file string

	reminders chan<- reminder.Reminder
}

func (s *Scanner) Scan() {
	for !s.eof() {
		switch s.next(); {
		case s.ch == '/' && s.peek() == '/':
			s.next()
			s.scanCppComment()
		case s.ch == '/' && s.peek() == '*':
			s.next()
			s.scanCComment()
		case s.ch == '#':
			s.scanHashComment()
		case s.ch == '-' && s.peek() == '-':
			s.scanDashComment()
		case s.ch == '<' && s.match(htmlOpen):
			s.scanHtmlComment()
		}
	}
}

// next moves the scanner to the next byte in the source,
// updating `ch` and `pos`.
func (s *Scanner) next() {
	if s.pos >= len(s.src) {
		s.ch = 0
		return
	}

	s.ch = s.src[s.pos]
	s.pos++

	if s.ch == '\n' {
		s.line++
	}
}

// skip the next `n` bytes, setting the `n+1` byte as current.
func (s *Scanner) skip(n int) {
	for i := 0; i <= n; i++ {
		s.next()
	}
}

// peek returns the next byte without advancing the scanner.
// If the scanner is at EOF, peek returns 0.
func (s *Scanner) peek() byte {
	if s.pos < len(s.src) {
		return s.src[s.pos]
	}
	return 0
}

// match checks if any of the given patterns (byte-slices)
// matches the scanner source at the current position.
func (s *Scanner) match(patterns ...[]byte) bool {
ptnLoop:
	for _, bytes := range patterns {
		for i, b := range bytes {
			idx := s.pos - 1 + i
			if idx >= len(s.src) || s.src[idx] != b {
				continue ptnLoop
			}
		}
		return true
	}
	return false
}

func (s *Scanner) eof() bool {
	return s.pos >= len(s.src)
}

func (s *Scanner) scanCppComment() {
	line := s.line
	s.next()
	raw := s.collectUntil(func() bool { return s.ch == '\n' })
	s.emitReminder(line, raw)
}

func (s *Scanner) scanCComment() {
	line := s.line
	s.next()
	raw := s.collectUntilPattern(blockClose)
	s.emitReminder(line, raw)
}

func (s *Scanner) scanHashComment() {
	line := s.line
	s.next()
	raw := s.collectUntil(func() bool { return s.ch == '\n' })
	s.emitReminder(line, raw)
}

func (s *Scanner) scanDashComment() {
	line := s.line
	s.next()
	if s.ch == '-' {
		s.next()
	}
	raw := s.collectUntil(func() bool { return s.ch == '\n' })
	s.emitReminder(line, raw)
}

func (s *Scanner) scanHtmlComment() {
	line := s.line
	s.skip(3)
	raw := s.collectUntilPattern(htmlClose)
	s.emitReminder(line, raw)
}

func (s *Scanner) collectUntil(stop func() bool) string {
	if s.ch == 0 {
		return ""
	}

	var b strings.Builder
	for {
		if s.ch == 0 || stop() {
			break
		}
		b.WriteByte(s.ch)
		s.next()
		if s.ch == 0 {
			break
		}
	}
	return b.String()
}

func (s *Scanner) collectUntilPattern(pattern []byte) string {
	if len(pattern) == 0 {
		return ""
	}

	var b strings.Builder
	for !s.eof() {
		if s.match(pattern) {
			s.skip(len(pattern) - 1)
			break
		}

		if s.ch == 0 {
			break
		}

		b.WriteByte(s.ch)
		s.next()
	}

	return b.String()
}

func (s *Scanner) emitReminder(line int, raw string) {
	text, tags := parseComment(raw)
	if len(tags) == 0 {
		return
	}

	rem := reminder.New(s.file, line, text, tags)
	s.reminders <- rem
}

func parseComment(raw string) (string, []string) {
	if raw == "" {
		return "", nil
	}

	var (
		builder   strings.Builder
		tags      []string
		lastSpace = true
		prev      byte
	)

	for i := 0; i < len(raw); {
		c := raw[i]

		switch {
		// Normalize whitespaces into space
		case c == '\r' || c == '\n' || c == '\t':
			if !lastSpace && builder.Len() > 0 {
				builder.WriteByte(' ')
				lastSpace = true
			}
			prev = ' '
			i++
		// Consume tags
		case c == '@' && isTagBoundary(prev) && i+1 < len(raw) && isTagChar(raw[i+1]):
			start := i + 1
			j := start
			for j < len(raw) && isTagChar(raw[j]) {
				j++
			}
			tag := raw[start:j]
			if tag != "" && !slices.Contains(tags, tag) {
				tags = append(tags, tag)
			}
			i = j
			// Skip trailing colon
			if i < len(raw) && raw[i] == ':' {
				i++
			}
			if !lastSpace && builder.Len() > 0 {
				builder.WriteByte(' ')
			}
			lastSpace = true
			prev = ' '
		// Collapse consecutive spaces
		case c == ' ':
			if !lastSpace && builder.Len() > 0 {
				builder.WriteByte(' ')
			}
			lastSpace = true
			prev = ' '
			i++
		default:
			builder.WriteByte(c)
			lastSpace = false
			prev = c
			i++
		}
	}

	text := strings.TrimSpace(builder.String())
	return text, tags
}

func isTagBoundary(prev byte) bool {
	if prev == 0 {
		return true
	}
	return !isTagChar(prev)
}

func isTagChar(b byte) bool {
	switch {
	case b >= 'a' && b <= 'z':
		return true
	case b >= 'A' && b <= 'Z':
		return true
	case b >= '0' && b <= '9':
		return true
	case b == '_' || b == '-':
		return true
	default:
		return false
	}
}
