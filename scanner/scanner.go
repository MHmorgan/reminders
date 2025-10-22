package scanner

import (
	"bufio"
	"bytes"
	"io"
	"slices"
	"strings"

	"github.com/MHmorgan/reminders/reminder"
)

const eof rune = -1

var (
	htmlOpen   = []byte("<!--")
	htmlClose  = []byte("-->")
	blockClose = []byte("*/")
)

// A Scanner holds the scanner's internal state while scanning
// a source file for reminders.
type Scanner struct {
	rd *bufio.Reader

	ch      rune
	lineNum int
	file    string

	reminders chan<- reminder.Reminder

	comment strings.Builder
}

func (s *Scanner) Init(file string, rd io.Reader, out chan<- reminder.Reminder) {
	s.ch = 0
	s.lineNum = 1
	s.file = file
	s.reminders = out

	if s.rd == nil {
		s.rd = bufio.NewReaderSize(rd, 8192)
	} else {
		s.rd.Reset(rd)
	}
}

func (s *Scanner) Scan() {
	for s.ch != eof {
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

// next moves the scanner to the next rune in the source,
// updating the cached rune.
func (s *Scanner) next() {
	r, _, err := s.rd.ReadRune()
	if err != nil {
		s.ch = eof
		return
	}

	s.ch = r

	if s.ch == '\n' {
		s.lineNum++
	}
}

// skip the next `n` runes, setting the `n+1` rune as current.
func (s *Scanner) skip(n int) {
	for i := 0; i <= n; i++ {
		s.next()
	}
}

// peek returns the next rune without advancing the scanner.
// If the scanner is at EOF, peek returns eof.
func (s *Scanner) peek() rune {
	if s.ch == eof {
		return eof
	}

	r, _, err := s.rd.ReadRune()
	if err != nil {
		return eof
	}

	if unreadErr := s.rd.UnreadRune(); unreadErr != nil {
		return eof
	}

	return r
}

// match checks if any of the given patterns (byte-slices)
// matches the scanner source at the current position.
func (s *Scanner) match(patterns ...[]byte) bool {
	for _, pattern := range patterns {
		if len(pattern) == 0 {
			continue
		}
		if s.ch > 0xFF || s.ch != rune(pattern[0]) {
			continue
		}
		if len(pattern) == 1 {
			return true
		}
		peek, err := s.rd.Peek(len(pattern) - 1)
		if err != nil || len(peek) < len(pattern)-1 {
			continue
		}
		if bytes.Equal(peek[:len(pattern)-1], pattern[1:]) {
			return true
		}
	}
	return false
}

// Scan a single-line comment starting with `//`
func (s *Scanner) scanCppComment() {
	line := s.lineNum
	s.next()
	raw := s.collectUntil(func() bool { return s.ch == '\n' })
	s.emitReminder(line, raw)
}

// Scan a multi-line comment like `/* ... */`
func (s *Scanner) scanCComment() {
	lineNum := s.lineNum
	s.next()
	raw := s.collectUntilPattern(blockClose)

	for i, line := range strings.Split(raw, "\n") {
		line = strings.Trim(line, " \t*")
		s.emitReminder(lineNum+i, line)
	}

}

// Scan a single-line comment starting with `#`
func (s *Scanner) scanHashComment() {
	line := s.lineNum
	s.next()
	raw := s.collectUntil(func() bool { return s.ch == '\n' })
	s.emitReminder(line, raw)
}

// Scan a single-line comment starting with `--`
func (s *Scanner) scanDashComment() {
	line := s.lineNum
	s.next()
	if s.ch == '-' {
		s.next()
	}
	raw := s.collectUntil(func() bool { return s.ch == '\n' })
	s.emitReminder(line, raw)
}

// Scan a multi-line comment like `<!-- ... -->`
func (s *Scanner) scanHtmlComment() {
	lineNum := s.lineNum
	s.skip(3)
	raw := s.collectUntilPattern(htmlClose)

	for i, line := range strings.Split(raw, "\n") {
		s.emitReminder(lineNum+i, line)
	}
}

func (s *Scanner) collectUntil(stop func() bool) string {
	if s.ch == eof {
		return ""
	}

	var b strings.Builder
	for {
		if s.ch == eof || stop() {
			break
		}
		b.WriteRune(s.ch)
		s.next()
		if s.ch == eof {
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
	for s.ch != eof {
		if s.match(pattern) {
			s.skip(len(pattern) - 1)
			break
		}

		if s.ch == eof {
			break
		}

		b.WriteRune(s.ch)
		s.next()
	}

	return b.String()
}

func (s *Scanner) emitReminder(line int, raw string) {
	text, tags := s.parseComment(strings.TrimSpace(raw))
	if len(tags) == 0 {
		return
	}

	rem := reminder.New(s.file, line, text, tags)
	s.reminders <- rem
}

func (s *Scanner) parseComment(raw string) (string, []string) {
	if raw == "" {
		return "", nil
	}

	var (
		tags      []string
		lastSpace = true
		prev      byte
	)

	s.comment.Reset()
	for i := 0; i < len(raw); {
		c := raw[i]

		switch {
		// Normalize whitespaces into space
		case c == '\r' || c == '\n' || c == '\t':
			if !lastSpace && s.comment.Len() > 0 {
				s.comment.WriteByte(' ')
				lastSpace = true
			}
			prev = ' '
			i++
		// Consume tags
		case c == '@' && isTagBoundary(prev) && i+1 < len(raw) && isTagChar(raw[i+1]):
			if !lastSpace && s.comment.Len() > 0 {
				s.comment.WriteByte(' ')
			}
			start := i + 1
			j := start
			for j < len(raw) && isTagChar(raw[j]) {
				j++
			}
			tag := raw[start:j]
			if tag != "" && !slices.Contains(tags, tag) {
				// Normalize tags to lowercase
				lower := strings.ToLower(tag)
				tags = append(tags, lower)
				// Include the tag the text
				s.comment.WriteString(tag)
			}
			i = j
			// Skip trailing colon
			if i < len(raw) && raw[i] == ':' {
				i++
			}
			s.comment.WriteByte(' ')
			lastSpace = true
			prev = ' '
		// Collapse consecutive spaces
		case c == ' ':
			if !lastSpace && s.comment.Len() > 0 {
				s.comment.WriteByte(' ')
			}
			lastSpace = true
			prev = ' '
			i++
		default:
			s.comment.WriteByte(c)
			lastSpace = false
			prev = c
			i++
		}
	}

	text := strings.TrimSpace(s.comment.String())
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
