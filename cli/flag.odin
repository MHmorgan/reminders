package cli

import "core:encoding/uuid"
import "core:net"
import "core:reflect"
import "core:time"

// Flag is an optional CLI argument like `key=value`.
Flag :: struct {
	name:  string,
	usage: string,
	value: Value,
}

// Add an `int` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_int :: proc(c: ^Command, p: ^int, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add an `int` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_int :: proc(c: ^Command, name: string, usage: string) -> ^int {
	p := new(int)
	flag_int(c, p, name, usage)
	return p
}

// Add a `string` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_string :: proc(c: ^Command, p: ^string, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `string` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_string :: proc(c: ^Command, name: string, usage: string) -> ^string {
	p := new(string)
	flag_string(c, p, name, usage)
	return p
}

// Add an `enum` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_enum :: proc(
	c: ^Command,
	p: ^$E,
	name: string,
	usage: string,
) where intrinsics.type_is_enum(E) {
	ti := reflect.type_info_base(type_info_of(E)).variant.(reflect.Type_Info_Enum)
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = Enum{ti, p},
	}
}

// Add a `cstring` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_cstring :: proc(c: ^Command, p: ^cstring, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `cstring` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_cstring :: proc(c: ^Command, name: string, usage: string) -> ^cstring {
	p := new(cstring)
	flag_cstring(c, p, name, usage)
	return p
}

// Add a `bool` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_bool :: proc(c: ^Command, p: ^bool, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `bool` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_bool :: proc(c: ^Command, name: string, usage: string) -> ^bool {
	p := new(bool)
	flag_bool(c, p, name, usage)
	return p
}

// Add a `i8` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_i8 :: proc(c: ^Command, p: ^i8, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `i8` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_i8 :: proc(c: ^Command, name: string, usage: string) -> ^i8 {
	p := new(i8)
	flag_i8(c, p, name, usage)
	return p
}

// Add a `i16` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_i16 :: proc(c: ^Command, p: ^i16, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `i16` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_i16 :: proc(c: ^Command, name: string, usage: string) -> ^i16 {
	p := new(i16)
	flag_i16(c, p, name, usage)
	return p
}

// Add a `i32` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_i32 :: proc(c: ^Command, p: ^i32, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `i32` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_i32 :: proc(c: ^Command, name: string, usage: string) -> ^i32 {
	p := new(i32)
	flag_i32(c, p, name, usage)
	return p
}

// Add a `i64` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_i64 :: proc(c: ^Command, p: ^i64, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `i64` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_i64 :: proc(c: ^Command, name: string, usage: string) -> ^i64 {
	p := new(i64)
	flag_i64(c, p, name, usage)
	return p
}

// Add a `i128` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_i128 :: proc(c: ^Command, p: ^i128, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `i128` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_i128 :: proc(c: ^Command, name: string, usage: string) -> ^i128 {
	p := new(i128)
	flag_i128(c, p, name, usage)
	return p
}

// Add a `i16le` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_i16le :: proc(c: ^Command, p: ^i16le, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `i16le` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_i16le :: proc(c: ^Command, name: string, usage: string) -> ^i16le {
	p := new(i16le)
	flag_i16le(c, p, name, usage)
	return p
}

// Add a `i32le` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_i32le :: proc(c: ^Command, p: ^i32le, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `i32le` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_i32le :: proc(c: ^Command, name: string, usage: string) -> ^i32le {
	p := new(i32le)
	flag_i32le(c, p, name, usage)
	return p
}

// Add a `i64le` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_i64le :: proc(c: ^Command, p: ^i64le, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `i64le` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_i64le :: proc(c: ^Command, name: string, usage: string) -> ^i64le {
	p := new(i64le)
	flag_i64le(c, p, name, usage)
	return p
}

// Add a `i128le` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_i128le :: proc(c: ^Command, p: ^i128le, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `i128le` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_i128le :: proc(c: ^Command, name: string, usage: string) -> ^i128le {
	p := new(i128le)
	flag_i128le(c, p, name, usage)
	return p
}

// Add a `i16be` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_i16be :: proc(c: ^Command, p: ^i16be, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `i16be` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_i16be :: proc(c: ^Command, name: string, usage: string) -> ^i16be {
	p := new(i16be)
	flag_i16be(c, p, name, usage)
	return p
}

// Add a `i32be` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_i32be :: proc(c: ^Command, p: ^i32be, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `i32be` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_i32be :: proc(c: ^Command, name: string, usage: string) -> ^i32be {
	p := new(i32be)
	flag_i32be(c, p, name, usage)
	return p
}

// Add a `i64be` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_i64be :: proc(c: ^Command, p: ^i64be, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `i64be` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_i64be :: proc(c: ^Command, name: string, usage: string) -> ^i64be {
	p := new(i64be)
	flag_i64be(c, p, name, usage)
	return p
}

// Add a `i128be` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_i128be :: proc(c: ^Command, p: ^i128be, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `i128be` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_i128be :: proc(c: ^Command, name: string, usage: string) -> ^i128be {
	p := new(i128be)
	flag_i128be(c, p, name, usage)
	return p
}

// Add a `uint` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_uint :: proc(c: ^Command, p: ^uint, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `uint` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_uint :: proc(c: ^Command, name: string, usage: string) -> ^uint {
	p := new(uint)
	flag_uint(c, p, name, usage)
	return p
}

// Add a `u8` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_u8 :: proc(c: ^Command, p: ^u8, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `u8` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_u8 :: proc(c: ^Command, name: string, usage: string) -> ^u8 {
	p := new(u8)
	flag_u8(c, p, name, usage)
	return p
}

// Add a `u16` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_u16 :: proc(c: ^Command, p: ^u16, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `u16` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_u16 :: proc(c: ^Command, name: string, usage: string) -> ^u16 {
	p := new(u16)
	flag_u16(c, p, name, usage)
	return p
}

// Add a `u32` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_u32 :: proc(c: ^Command, p: ^u32, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `u32` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_u32 :: proc(c: ^Command, name: string, usage: string) -> ^u32 {
	p := new(u32)
	flag_u32(c, p, name, usage)
	return p
}

// Add a `u64` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_u64 :: proc(c: ^Command, p: ^u64, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `u64` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_u64 :: proc(c: ^Command, name: string, usage: string) -> ^u64 {
	p := new(u64)
	flag_u64(c, p, name, usage)
	return p
}

// Add a `u128` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_u128 :: proc(c: ^Command, p: ^u128, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `u128` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_u128 :: proc(c: ^Command, name: string, usage: string) -> ^u128 {
	p := new(u128)
	flag_u128(c, p, name, usage)
	return p
}

// Add a `u16le` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_u16le :: proc(c: ^Command, p: ^u16le, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `u16le` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_u16le :: proc(c: ^Command, name: string, usage: string) -> ^u16le {
	p := new(u16le)
	flag_u16le(c, p, name, usage)
	return p
}

// Add a `u32le` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_u32le :: proc(c: ^Command, p: ^u32le, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `u32le` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_u32le :: proc(c: ^Command, name: string, usage: string) -> ^u32le {
	p := new(u32le)
	flag_u32le(c, p, name, usage)
	return p
}

// Add a `u64le` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_u64le :: proc(c: ^Command, p: ^u64le, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `u64le` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_u64le :: proc(c: ^Command, name: string, usage: string) -> ^u64le {
	p := new(u64le)
	flag_u64le(c, p, name, usage)
	return p
}

// Add a `u128le` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_u128le :: proc(c: ^Command, p: ^u128le, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `u128le` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_u128le :: proc(c: ^Command, name: string, usage: string) -> ^u128le {
	p := new(u128le)
	flag_u128le(c, p, name, usage)
	return p
}

// Add a `u16be` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_u16be :: proc(c: ^Command, p: ^u16be, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `u16be` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_u16be :: proc(c: ^Command, name: string, usage: string) -> ^u16be {
	p := new(u16be)
	flag_u16be(c, p, name, usage)
	return p
}

// Add a `u32be` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_u32be :: proc(c: ^Command, p: ^u32be, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `u32be` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_u32be :: proc(c: ^Command, name: string, usage: string) -> ^u32be {
	p := new(u32be)
	flag_u32be(c, p, name, usage)
	return p
}

// Add a `u64be` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_u64be :: proc(c: ^Command, p: ^u64be, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `u64be` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_u64be :: proc(c: ^Command, name: string, usage: string) -> ^u64be {
	p := new(u64be)
	flag_u64be(c, p, name, usage)
	return p
}

// Add a `u128be` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_u128be :: proc(c: ^Command, p: ^u128be, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `u128be` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_u128be :: proc(c: ^Command, name: string, usage: string) -> ^u128be {
	p := new(u128be)
	flag_u128be(c, p, name, usage)
	return p
}

// Add a `f16` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_f16 :: proc(c: ^Command, p: ^f16, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `f16` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_f16 :: proc(c: ^Command, name: string, usage: string) -> ^f16 {
	p := new(f16)
	flag_f16(c, p, name, usage)
	return p
}

// Add a `f32` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_f32 :: proc(c: ^Command, p: ^f32, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `f32` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_f32 :: proc(c: ^Command, name: string, usage: string) -> ^f32 {
	p := new(f32)
	flag_f32(c, p, name, usage)
	return p
}

// Add a `f64` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_f64 :: proc(c: ^Command, p: ^f64, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `f64` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_f64 :: proc(c: ^Command, name: string, usage: string) -> ^f64 {
	p := new(f64)
	flag_f64(c, p, name, usage)
	return p
}

// Add a `complex32` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_complex32 :: proc(c: ^Command, p: ^complex32, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `complex32` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_complex32 :: proc(c: ^Command, name: string, usage: string) -> ^complex32 {
	p := new(complex32)
	flag_complex32(c, p, name, usage)
	return p
}

// Add a `complex64` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_complex64 :: proc(c: ^Command, p: ^complex64, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `complex64` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_complex64 :: proc(c: ^Command, name: string, usage: string) -> ^complex64 {
	p := new(complex64)
	flag_complex64(c, p, name, usage)
	return p
}

// Add a `complex128` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_complex128 :: proc(c: ^Command, p: ^complex128, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `complex128` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_complex128 :: proc(c: ^Command, name: string, usage: string) -> ^complex128 {
	p := new(complex128)
	flag_complex128(c, p, name, usage)
	return p
}

// Add a `quaternion64` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_quaternion64 :: proc(c: ^Command, p: ^quaternion64, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `quaternion64` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_quaternion64 :: proc(c: ^Command, name: string, usage: string) -> ^quaternion64 {
	p := new(quaternion64)
	flag_quaternion64(c, p, name, usage)
	return p
}

// Add a `quaternion128` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_quaternion128 :: proc(c: ^Command, p: ^quaternion128, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `quaternion128` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_quaternion128 :: proc(c: ^Command, name: string, usage: string) -> ^quaternion128 {
	p := new(quaternion128)
	flag_quaternion128(c, p, name, usage)
	return p
}

// Add a `quaternion256` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_quaternion256 :: proc(c: ^Command, p: ^quaternion256, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `quaternion256` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_quaternion256 :: proc(c: ^Command, name: string, usage: string) -> ^quaternion256 {
	p := new(quaternion256)
	flag_quaternion256(c, p, name, usage)
	return p
}

// Add a `rune` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_rune :: proc(c: ^Command, p: ^rune, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `rune` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_rune :: proc(c: ^Command, name: string, usage: string) -> ^rune {
	p := new(rune)
	flag_rune(c, p, name, usage)
	return p
}

// Add a `time.Time` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_time_time :: proc(c: ^Command, p: ^time.Time, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `time.Time` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_time_time :: proc(c: ^Command, name: string, usage: string) -> ^time.Time {
	p := new(time.Time)
	flag_time_time(c, p, name, usage)
	return p
}

// Add a `net.Host_Or_Endpoint` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_host_or_endpoint :: proc(c: ^Command, p: ^net.Host_Or_Endpoint, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `net.Host_Or_Endpoint` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_host_or_endpoint :: proc(c: ^Command, name: string, usage: string) -> ^net.Host_Or_Endpoint {
	p := new(net.Host_Or_Endpoint)
	flag_host_or_endpoint(c, p, name, usage)
	return p
}

// Add a `uuid.Identifier` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flag_uuid :: proc(c: ^Command, p: ^uuid.Identifier, name: string, usage: string) {
	c.flags[name] = Flag {
		name  = name,
		usage = usage,
		value = p,
	}
}

// Add a `uuid.Identifier` flag to a command.
//
// The provided pointer will be populated upon parsing, if present.
// If the flag isn't present, the pointer will not be written to.
flagp_uuid :: proc(c: ^Command, name: string, usage: string) -> ^uuid.Identifier {
	p := new(uuid.Identifier)
	flag_uuid(c, p, name, usage)
	return p
}
