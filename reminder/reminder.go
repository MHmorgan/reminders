package reminder

type Reminder struct {
	file string
	line int
	tags []string
	text string
}

func New(file string, line int, text string, tags []string) Reminder {
	return Reminder{
		file: file,
		line: line,
		text: text,
		tags: cloneStrings(tags),
	}
}

func (r Reminder) File() string {
	return r.file
}

func (r Reminder) Line() int {
	return r.line
}

func (r Reminder) Text() string {
	return r.text
}

func (r Reminder) Tags() []string {
	return cloneStrings(r.tags)
}

func (r *Reminder) SetTags(tags []string) {
	r.tags = cloneStrings(tags)
}

func cloneStrings(in []string) []string {
	if len(in) == 0 {
		return nil
	}
	out := make([]string, len(in))
	copy(out, in)
	return out
}
