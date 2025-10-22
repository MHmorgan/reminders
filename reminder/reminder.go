package reminder

type Reminder struct {
	file string
	line int
	tags []string
	text string
}

type Span struct {
	start int
	end   int
}

func New(file string, line int, text string, tags []string) Reminder {
	return Reminder{
		file: file,
		line: line,
		text: text,
		tags: tags,
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
	return r.tags
}

func (r *Reminder) SetTags(tags []string) {
	r.tags = tags
}
