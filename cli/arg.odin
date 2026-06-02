package cli

import "core:encoding/uuid"
import "core:net"
import "core:reflect"
import "core:time"

// Argument is a required positional CLI parameters.
Argument :: struct {
	name:  string,
	usage: string,
	value: Value,
	pos:   int,
}

// Add an `string` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_string :: proc(c: ^Command, p: ^string, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add an `string` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_string :: proc(c: ^Command, name: string, usage: string) -> ^string {
	p := new(string)
	arg_string(c, p, name, usage)
	return p
}

// Add an `int` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_int :: proc(c: ^Command, p: ^int, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add an `int` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_int :: proc(c: ^Command, name: string, usage: string) -> ^int {
	p := new(int)
	arg_int(c, p, name, usage)
	return p
}

// Add an `enum` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_enum :: proc(
	c: ^Command,
	p: ^$E,
	name: string,
	usage: string,
) where intrinsics.type_is_enum(E) {
	pos := len(c.args)
	ti := reflect.type_info_base(type_info_of(E)).variant.(reflect.Type_Info_Enum)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = Enum{ti, p},
		pos   = pos,
	}
}

// --- cstring ---

// Add a `cstring` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_cstring :: proc(c: ^Command, p: ^cstring, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `cstring` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_cstring :: proc(c: ^Command, name: string, usage: string) -> ^cstring {
	p := new(cstring)
	arg_cstring(c, p, name, usage)
	return p
}

// --- bool ---

// Add a `bool` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_bool :: proc(c: ^Command, p: ^bool, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `bool` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_bool :: proc(c: ^Command, name: string, usage: string) -> ^bool {
	p := new(bool)
	arg_bool(c, p, name, usage)
	return p
}

// --- signed integers ---

// Add an `i8` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_i8 :: proc(c: ^Command, p: ^i8, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add an `i8` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_i8 :: proc(c: ^Command, name: string, usage: string) -> ^i8 {
	p := new(i8)
	arg_i8(c, p, name, usage)
	return p
}

// Add an `i16` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_i16 :: proc(c: ^Command, p: ^i16, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add an `i16` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_i16 :: proc(c: ^Command, name: string, usage: string) -> ^i16 {
	p := new(i16)
	arg_i16(c, p, name, usage)
	return p
}

// Add an `i32` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_i32 :: proc(c: ^Command, p: ^i32, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add an `i32` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_i32 :: proc(c: ^Command, name: string, usage: string) -> ^i32 {
	p := new(i32)
	arg_i32(c, p, name, usage)
	return p
}

// Add an `i64` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_i64 :: proc(c: ^Command, p: ^i64, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add an `i64` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_i64 :: proc(c: ^Command, name: string, usage: string) -> ^i64 {
	p := new(i64)
	arg_i64(c, p, name, usage)
	return p
}

// Add an `i128` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_i128 :: proc(c: ^Command, p: ^i128, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add an `i128` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_i128 :: proc(c: ^Command, name: string, usage: string) -> ^i128 {
	p := new(i128)
	arg_i128(c, p, name, usage)
	return p
}

// --- signed integers (little-endian) ---

// Add an `i16le` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_i16le :: proc(c: ^Command, p: ^i16le, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add an `i16le` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_i16le :: proc(c: ^Command, name: string, usage: string) -> ^i16le {
	p := new(i16le)
	arg_i16le(c, p, name, usage)
	return p
}

// Add an `i32le` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_i32le :: proc(c: ^Command, p: ^i32le, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add an `i32le` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_i32le :: proc(c: ^Command, name: string, usage: string) -> ^i32le {
	p := new(i32le)
	arg_i32le(c, p, name, usage)
	return p
}

// Add an `i64le` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_i64le :: proc(c: ^Command, p: ^i64le, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add an `i64le` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_i64le :: proc(c: ^Command, name: string, usage: string) -> ^i64le {
	p := new(i64le)
	arg_i64le(c, p, name, usage)
	return p
}

// Add an `i128le` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_i128le :: proc(c: ^Command, p: ^i128le, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add an `i128le` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_i128le :: proc(c: ^Command, name: string, usage: string) -> ^i128le {
	p := new(i128le)
	arg_i128le(c, p, name, usage)
	return p
}

// --- signed integers (big-endian) ---

// Add an `i16be` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_i16be :: proc(c: ^Command, p: ^i16be, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add an `i16be` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_i16be :: proc(c: ^Command, name: string, usage: string) -> ^i16be {
	p := new(i16be)
	arg_i16be(c, p, name, usage)
	return p
}

// Add an `i32be` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_i32be :: proc(c: ^Command, p: ^i32be, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add an `i32be` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_i32be :: proc(c: ^Command, name: string, usage: string) -> ^i32be {
	p := new(i32be)
	arg_i32be(c, p, name, usage)
	return p
}

// Add an `i64be` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_i64be :: proc(c: ^Command, p: ^i64be, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add an `i64be` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_i64be :: proc(c: ^Command, name: string, usage: string) -> ^i64be {
	p := new(i64be)
	arg_i64be(c, p, name, usage)
	return p
}

// Add an `i128be` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_i128be :: proc(c: ^Command, p: ^i128be, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add an `i128be` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_i128be :: proc(c: ^Command, name: string, usage: string) -> ^i128be {
	p := new(i128be)
	arg_i128be(c, p, name, usage)
	return p
}

// --- unsigned integers ---

// Add a `uint` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_uint :: proc(c: ^Command, p: ^uint, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `uint` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_uint :: proc(c: ^Command, name: string, usage: string) -> ^uint {
	p := new(uint)
	arg_uint(c, p, name, usage)
	return p
}

// Add a `u8` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_u8 :: proc(c: ^Command, p: ^u8, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `u8` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_u8 :: proc(c: ^Command, name: string, usage: string) -> ^u8 {
	p := new(u8)
	arg_u8(c, p, name, usage)
	return p
}

// Add a `u16` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_u16 :: proc(c: ^Command, p: ^u16, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `u16` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_u16 :: proc(c: ^Command, name: string, usage: string) -> ^u16 {
	p := new(u16)
	arg_u16(c, p, name, usage)
	return p
}

// Add a `u32` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_u32 :: proc(c: ^Command, p: ^u32, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `u32` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_u32 :: proc(c: ^Command, name: string, usage: string) -> ^u32 {
	p := new(u32)
	arg_u32(c, p, name, usage)
	return p
}

// Add a `u64` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_u64 :: proc(c: ^Command, p: ^u64, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `u64` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_u64 :: proc(c: ^Command, name: string, usage: string) -> ^u64 {
	p := new(u64)
	arg_u64(c, p, name, usage)
	return p
}

// Add a `u128` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_u128 :: proc(c: ^Command, p: ^u128, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `u128` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_u128 :: proc(c: ^Command, name: string, usage: string) -> ^u128 {
	p := new(u128)
	arg_u128(c, p, name, usage)
	return p
}

// --- unsigned integers (little-endian) ---

// Add a `u16le` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_u16le :: proc(c: ^Command, p: ^u16le, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `u16le` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_u16le :: proc(c: ^Command, name: string, usage: string) -> ^u16le {
	p := new(u16le)
	arg_u16le(c, p, name, usage)
	return p
}

// Add a `u32le` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_u32le :: proc(c: ^Command, p: ^u32le, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `u32le` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_u32le :: proc(c: ^Command, name: string, usage: string) -> ^u32le {
	p := new(u32le)
	arg_u32le(c, p, name, usage)
	return p
}

// Add a `u64le` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_u64le :: proc(c: ^Command, p: ^u64le, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `u64le` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_u64le :: proc(c: ^Command, name: string, usage: string) -> ^u64le {
	p := new(u64le)
	arg_u64le(c, p, name, usage)
	return p
}

// Add a `u128le` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_u128le :: proc(c: ^Command, p: ^u128le, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `u128le` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_u128le :: proc(c: ^Command, name: string, usage: string) -> ^u128le {
	p := new(u128le)
	arg_u128le(c, p, name, usage)
	return p
}

// --- unsigned integers (big-endian) ---

// Add a `u16be` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_u16be :: proc(c: ^Command, p: ^u16be, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `u16be` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_u16be :: proc(c: ^Command, name: string, usage: string) -> ^u16be {
	p := new(u16be)
	arg_u16be(c, p, name, usage)
	return p
}

// Add a `u32be` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_u32be :: proc(c: ^Command, p: ^u32be, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `u32be` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_u32be :: proc(c: ^Command, name: string, usage: string) -> ^u32be {
	p := new(u32be)
	arg_u32be(c, p, name, usage)
	return p
}

// Add a `u64be` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_u64be :: proc(c: ^Command, p: ^u64be, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `u64be` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_u64be :: proc(c: ^Command, name: string, usage: string) -> ^u64be {
	p := new(u64be)
	arg_u64be(c, p, name, usage)
	return p
}

// Add a `u128be` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_u128be :: proc(c: ^Command, p: ^u128be, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `u128be` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_u128be :: proc(c: ^Command, name: string, usage: string) -> ^u128be {
	p := new(u128be)
	arg_u128be(c, p, name, usage)
	return p
}

// --- floats ---

// Add an `f16` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_f16 :: proc(c: ^Command, p: ^f16, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add an `f16` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_f16 :: proc(c: ^Command, name: string, usage: string) -> ^f16 {
	p := new(f16)
	arg_f16(c, p, name, usage)
	return p
}

// Add an `f32` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_f32 :: proc(c: ^Command, p: ^f32, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add an `f32` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_f32 :: proc(c: ^Command, name: string, usage: string) -> ^f32 {
	p := new(f32)
	arg_f32(c, p, name, usage)
	return p
}

// Add an `f64` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_f64 :: proc(c: ^Command, p: ^f64, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add an `f64` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_f64 :: proc(c: ^Command, name: string, usage: string) -> ^f64 {
	p := new(f64)
	arg_f64(c, p, name, usage)
	return p
}

// --- complex ---

// Add a `complex32` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_complex32 :: proc(c: ^Command, p: ^complex32, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `complex32` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_complex32 :: proc(c: ^Command, name: string, usage: string) -> ^complex32 {
	p := new(complex32)
	arg_complex32(c, p, name, usage)
	return p
}

// Add a `complex64` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_complex64 :: proc(c: ^Command, p: ^complex64, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `complex64` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_complex64 :: proc(c: ^Command, name: string, usage: string) -> ^complex64 {
	p := new(complex64)
	arg_complex64(c, p, name, usage)
	return p
}

// Add a `complex128` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_complex128 :: proc(c: ^Command, p: ^complex128, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `complex128` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_complex128 :: proc(c: ^Command, name: string, usage: string) -> ^complex128 {
	p := new(complex128)
	arg_complex128(c, p, name, usage)
	return p
}

// --- quaternion ---

// Add a `quaternion64` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_quaternion64 :: proc(c: ^Command, p: ^quaternion64, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `quaternion64` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_quaternion64 :: proc(c: ^Command, name: string, usage: string) -> ^quaternion64 {
	p := new(quaternion64)
	arg_quaternion64(c, p, name, usage)
	return p
}

// Add a `quaternion128` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_quaternion128 :: proc(c: ^Command, p: ^quaternion128, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `quaternion128` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_quaternion128 :: proc(c: ^Command, name: string, usage: string) -> ^quaternion128 {
	p := new(quaternion128)
	arg_quaternion128(c, p, name, usage)
	return p
}

// Add a `quaternion256` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_quaternion256 :: proc(c: ^Command, p: ^quaternion256, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `quaternion256` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_quaternion256 :: proc(c: ^Command, name: string, usage: string) -> ^quaternion256 {
	p := new(quaternion256)
	arg_quaternion256(c, p, name, usage)
	return p
}

// --- rune ---

// Add a `rune` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_rune :: proc(c: ^Command, p: ^rune, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `rune` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_rune :: proc(c: ^Command, name: string, usage: string) -> ^rune {
	p := new(rune)
	arg_rune(c, p, name, usage)
	return p
}

// --- domain types ---

// Add a `time.Time` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_time_time :: proc(c: ^Command, p: ^time.Time, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `time.Time` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_time_time :: proc(c: ^Command, name: string, usage: string) -> ^time.Time {
	p := new(time.Time)
	arg_time_time(c, p, name, usage)
	return p
}

// Add a `net.Host_Or_Endpoint` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_host_or_endpoint :: proc(c: ^Command, p: ^net.Host_Or_Endpoint, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `net.Host_Or_Endpoint` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_host_or_endpoint :: proc(c: ^Command, name: string, usage: string) -> ^net.Host_Or_Endpoint {
	p := new(net.Host_Or_Endpoint)
	arg_host_or_endpoint(c, p, name, usage)
	return p
}

// Add a `uuid.Identifier` argument to a command.
//
// The provided pointer will be populated upon parsing.
arg_uuid :: proc(c: ^Command, p: ^uuid.Identifier, name: string, usage: string) {
	pos := len(c.args)
	c.args[name] = Argument {
		name  = name,
		usage = usage,
		value = p,
		pos   = pos,
	}
}

// Add a `uuid.Identifier` argument to a command, returning a pointer to the value.
//
// The provided pointer will be populated upon parsing.
argp_uuid :: proc(c: ^Command, name: string, usage: string) -> ^uuid.Identifier {
	p := new(uuid.Identifier)
	arg_uuid(c, p, name, usage)
	return p
}
