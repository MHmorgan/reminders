#+feature dynamic-literals
package main

import "core:fmt"
import "core:os"

Foo :: struct {
	name: string,
}

new_foo :: proc(name: string) -> Foo {
	return Foo{name}
}

hey :: proc() {
	fmt.printf("Hello, task!")
}

main :: proc() {
	commands := map[string]proc() {
		"task" = hey,
	}


	foo := new_foo("Smith")
	fmt.printf("Hello, %v! From Odin", os.args[0:])
}
