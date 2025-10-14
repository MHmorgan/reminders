package scanner

type Scanner struct {
	delimiters []Delimiters
}

type Delimiters struct {
	start string
	end   string
}

func hashDelimiters() []Delimiters {
	lst := make([]Delimiters, 1)
	lst[0] = Delimiters{"#", "\n"}
	return lst
}

type SlashScanner struct{}

type HashScanner struct{}

type DashScanner struct{}

type HtmlScanner struct{}
