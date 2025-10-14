package main

import (
	"flag"
	"fmt"

	"github.com/MHmorgan/reminders/scanner"
)

func main() {
	flag.Parse()

	fmt.Println("Hello, World! ", flag.Args())
}
