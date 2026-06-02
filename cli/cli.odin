package cli

import "core:reflect"

// Command is the center of the CLI - all applications has one or more commands.
Command :: struct {
	name:  string,
	usage: string,
	args:  map[string]Argument,
	flags: map[string]Flag,
	run:   proc(),
}

new_command :: proc(name, usage: string, run: proc()) -> ^Command {
	c := new(Command)
	c.name = name
	c.usage = usage
	c.args = make(map[string]Argument)
	c.flags = make(map[string]Flag)
	c.run = run
	return c
}

Application :: struct {
	using command: Command,
	commands:      map[string]^Command,
}

@(private)
Enum :: struct {
	type_info: reflect.Type_Info_Enum,
	ptr:       rawptr,
}

parse :: proc(args: []string) {

}
