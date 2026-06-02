package cli

import "core:encoding/uuid"
import "core:fmt"
import "core:net"
import "core:reflect"
import "core:strconv"
import "core:strings"
import "core:testing"
import "core:time"
import "core:unicode/utf8"

Parse_Error :: union {
	Invalid_Format,
	Out_Of_Range,
	Unknown_Enum_Variant,
}

// `input` holds the raw CLI argument as-is and appears verbatim in any rendered
// error message — be mindful when logging.
Invalid_Format :: struct {
	input:     string,
	type_name: string,
}

// `input` holds the raw CLI argument as-is and appears verbatim in any rendered
// error message — be mindful when logging.
Out_Of_Range :: struct {
	input:     string,
	type_name: string,
	min:       string,
	max:       string,
}

// `input` holds the raw CLI argument as-is and appears verbatim in any rendered
// error message — be mindful when logging.
// `allowed` aliases the program's static type-info table — safe to retain
// indefinitely without cloning.
Unknown_Enum_Variant :: struct {
	input:   string,
	allowed: []string,
}

Value :: union {
	^string,
	^cstring,
	^bool,
	^int,
	^i8,
	^i16,
	^i32,
	^i64,
	^i128,
	^i16le,
	^i32le,
	^i64le,
	^i128le,
	^i16be,
	^i32be,
	^i64be,
	^i128be,
	^uint,
	^u8,
	^u16,
	^u32,
	^u64,
	^u128,
	^u16le,
	^u32le,
	^u64le,
	^u128le,
	^u16be,
	^u32be,
	^u64be,
	^u128be,
	^f16,
	^f32,
	^f64,
	^complex32,
	^complex64,
	^complex128,
	^quaternion64,
	^quaternion128,
	^quaternion256,
	^rune,
	Enum,
	^time.Time,
	^net.Host_Or_Endpoint,
	^uuid.Identifier,
}

@(private)
parse_signed_bounded :: proc(s, type_name: string, lo, hi: i64) -> (i64, Parse_Error) {
	res, ok := strconv.parse_i64_maybe_prefixed(s)
	if !ok do return 0, Invalid_Format{s, type_name}
	if res < lo || res > hi {
		return 0, Out_Of_Range {
			input = s,
			type_name = type_name,
			min = fmt.tprintf("%d", lo),
			max = fmt.tprintf("%d", hi),
		}
	}
	return res, nil
}

@(private)
parse_unsigned_bounded :: proc(s, type_name: string, hi: u64) -> (u64, Parse_Error) {
	res, ok := strconv.parse_u64_maybe_prefixed(s)
	if !ok do return 0, Invalid_Format{s, type_name}
	if res > hi {
		return 0, Out_Of_Range {
			input = s,
			type_name = type_name,
			min = "0",
			max = fmt.tprintf("%d", hi),
		}
	}
	return res, nil
}

parse_value :: proc(value: Value, s: string) -> Parse_Error {
	switch v in value {
	case ^string:
		v^ = s

	case ^int:
		res, ok := strconv.parse_int(s)
		if !ok do return Invalid_Format{s, "int"}
		v^ = res

	case ^uint:
		res, ok := strconv.parse_uint(s)
		if !ok do return Invalid_Format{s, "uint"}
		v^ = res

	case ^i8:
		res, err := parse_signed_bounded(s, "i8", i64(min(i8)), i64(max(i8)))
		if err != nil do return err
		v^ = i8(res)

	case ^i16:
		res, err := parse_signed_bounded(s, "i16", i64(min(i16)), i64(max(i16)))
		if err != nil do return err
		v^ = i16(res)

	case ^i32:
		res, err := parse_signed_bounded(s, "i32", i64(min(i32)), i64(max(i32)))
		if err != nil do return err
		v^ = i32(res)

	case ^i64:
		res, ok := strconv.parse_i64_maybe_prefixed(s)
		if !ok do return Invalid_Format{s, "i64"}
		v^ = res

	case ^i128:
		res, ok := strconv.parse_i128_maybe_prefixed(s)
		if !ok do return Invalid_Format{s, "i128"}
		v^ = res

	case ^i16le:
		res, err := parse_signed_bounded(s, "i16le", i64(min(i16)), i64(max(i16)))
		if err != nil do return err
		v^ = cast(i16le)i16(res)

	case ^i32le:
		res, err := parse_signed_bounded(s, "i32le", i64(min(i32)), i64(max(i32)))
		if err != nil do return err
		v^ = cast(i32le)i32(res)

	case ^i64le:
		res, ok := strconv.parse_i64_maybe_prefixed(s)
		if !ok do return Invalid_Format{s, "i64le"}
		v^ = cast(i64le)res

	case ^i128le:
		res, ok := strconv.parse_i128_maybe_prefixed(s)
		if !ok do return Invalid_Format{s, "i128le"}
		v^ = cast(i128le)res

	case ^i16be:
		res, err := parse_signed_bounded(s, "i16be", i64(min(i16)), i64(max(i16)))
		if err != nil do return err
		v^ = cast(i16be)i16(res)

	case ^i32be:
		res, err := parse_signed_bounded(s, "i32be", i64(min(i32)), i64(max(i32)))
		if err != nil do return err
		v^ = cast(i32be)i32(res)

	case ^i64be:
		res, ok := strconv.parse_i64_maybe_prefixed(s)
		if !ok do return Invalid_Format{s, "i64be"}
		v^ = cast(i64be)res

	case ^i128be:
		res, ok := strconv.parse_i128_maybe_prefixed(s)
		if !ok do return Invalid_Format{s, "i128be"}
		v^ = cast(i128be)res

	case ^u8:
		res, err := parse_unsigned_bounded(s, "u8", u64(max(u8)))
		if err != nil do return err
		v^ = u8(res)

	case ^u16:
		res, err := parse_unsigned_bounded(s, "u16", u64(max(u16)))
		if err != nil do return err
		v^ = u16(res)

	case ^u32:
		res, err := parse_unsigned_bounded(s, "u32", u64(max(u32)))
		if err != nil do return err
		v^ = u32(res)

	case ^u64:
		res, ok := strconv.parse_u64_maybe_prefixed(s)
		if !ok do return Invalid_Format{s, "u64"}
		v^ = res

	case ^u128:
		res, ok := strconv.parse_u128_maybe_prefixed(s)
		if !ok do return Invalid_Format{s, "u128"}
		v^ = res

	case ^u16le:
		res, err := parse_unsigned_bounded(s, "u16le", u64(max(u16)))
		if err != nil do return err
		v^ = cast(u16le)u16(res)

	case ^u32le:
		res, err := parse_unsigned_bounded(s, "u32le", u64(max(u32)))
		if err != nil do return err
		v^ = cast(u32le)u32(res)

	case ^u64le:
		res, ok := strconv.parse_u64_maybe_prefixed(s)
		if !ok do return Invalid_Format{s, "u64le"}
		v^ = cast(u64le)res

	case ^u128le:
		res, ok := strconv.parse_u128_maybe_prefixed(s)
		if !ok do return Invalid_Format{s, "u128le"}
		v^ = cast(u128le)res

	case ^u16be:
		res, err := parse_unsigned_bounded(s, "u16be", u64(max(u16)))
		if err != nil do return err
		v^ = cast(u16be)u16(res)

	case ^u32be:
		res, err := parse_unsigned_bounded(s, "u32be", u64(max(u32)))
		if err != nil do return err
		v^ = cast(u32be)u32(res)

	case ^u64be:
		res, ok := strconv.parse_u64_maybe_prefixed(s)
		if !ok do return Invalid_Format{s, "u64be"}
		v^ = cast(u64be)res

	case ^u128be:
		res, ok := strconv.parse_u128_maybe_prefixed(s)
		if !ok do return Invalid_Format{s, "u128be"}
		v^ = cast(u128be)res

	case ^cstring:
		// strings.clone_to_cstring allocates from the context allocator; caller owns.
		// On allocator failure, v^ is set to nil (the cstring zero value); parse_value
		// returns nil (success). Callers must not assume a successful return implies
		// a non-nil cstring.
		v^, _ = strings.clone_to_cstring(s)

	case ^bool:
		res, ok := strconv.parse_bool(s)
		if !ok do return Invalid_Format{s, "bool"}
		v^ = res

	case ^f16:
		res, ok := strconv.parse_f64(s)
		if !ok do return Invalid_Format{s, "f16"}
		v^ = f16(res)

	case ^f32:
		res, ok := strconv.parse_f32(s)
		if !ok do return Invalid_Format{s, "f32"}
		v^ = res

	case ^f64:
		res, ok := strconv.parse_f64(s)
		if !ok do return Invalid_Format{s, "f64"}
		v^ = res

	case ^complex32:
		res, ok := strconv.parse_complex32(s)
		if !ok do return Invalid_Format{s, "complex32"}
		v^ = res

	case ^complex64:
		res, ok := strconv.parse_complex64(s)
		if !ok do return Invalid_Format{s, "complex64"}
		v^ = res

	case ^complex128:
		res, ok := strconv.parse_complex128(s)
		if !ok do return Invalid_Format{s, "complex128"}
		v^ = res

	case ^quaternion64:
		res, ok := strconv.parse_quaternion64(s)
		if !ok do return Invalid_Format{s, "quaternion64"}
		v^ = res

	case ^quaternion128:
		res, ok := strconv.parse_quaternion128(s)
		if !ok do return Invalid_Format{s, "quaternion128"}
		v^ = res

	case ^quaternion256:
		res, ok := strconv.parse_quaternion256(s)
		if !ok do return Invalid_Format{s, "quaternion256"}
		v^ = res

	case ^rune:
		if utf8.rune_count_in_string(s) != 1 do return Invalid_Format{s, "rune"}
		r, _ := utf8.decode_rune_in_string(s)
		v^ = r

	case ^time.Time:
		res, consumed := time.rfc3339_to_time_utc(s)
		if consumed == 0 do return Invalid_Format{s, "time.Time"}
		v^ = res

	case ^net.Host_Or_Endpoint:
		res, err := net.parse_hostname_or_endpoint(s)
		if err != .None do return Invalid_Format{s, "net.Host_Or_Endpoint"}
		v^ = res

	case ^uuid.Identifier:
		res, err := uuid.read(s)
		if err != .None do return Invalid_Format{s, "uuid.Identifier"}
		v^ = res

	case Enum:
		// The `allowed` slice aliases the program's static type-info table —
		// safe to retain indefinitely without cloning.
		for name, i in v.type_info.names {
			if name == s {
				(cast(^int)v.ptr)^ = int(v.type_info.values[i])
				return nil
			}
		}
		return Unknown_Enum_Variant{input = s, allowed = v.type_info.names}
	}
	return nil
}

// -----------------------------------------------------------------------------
//
// Tests
//
// -----------------------------------------------------------------------------

@(test)
test_parse_int :: proc(t: ^testing.T) {
	v: int = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "Expected nil error")
	testing.expect(t, v == 42, "Failed to parse int")
}


@(test)
test_parse_enum :: proc(t: ^testing.T) {
	Dir :: enum {
		Up,
		Down,
	}

	dir: Dir = ---
	tib := reflect.type_info_base(type_info_of(Dir))
	val := Enum {
		type_info = tib.variant.(reflect.Type_Info_Enum),
		ptr       = &dir,
	}

	err := parse_value(val, "Up")
	testing.expect(t, err == nil, "Expected nil error - Up")
	testing.expect(t, dir == .Up, "Failed to parse enum - Up")

	err = parse_value(val, "Down")
	testing.expect(t, err == nil, "Expected nil error - Down")
	testing.expect(t, dir == .Down, "Failed to parse enum - Down")
}

@(test)
test_parse_string :: proc(t: ^testing.T) {
	v: string = ---
	err := parse_value(&v, "hello")
	testing.expect(t, err == nil, "expected nil error for string")
	testing.expect(t, v == "hello", "value mismatch for string")
}

@(test)
test_parse_cstring :: proc(t: ^testing.T) {
	v: cstring = ---
	err := parse_value(&v, "hello")
	testing.expect(t, err == nil, "expected nil error for cstring")
	testing.expect(t, v != nil, "expected non-nil cstring")
	testing.expect(t, string(v) == "hello", "value mismatch for cstring")
}

@(test)
test_parse_bool :: proc(t: ^testing.T) {
	v: bool = ---
	err := parse_value(&v, "true")
	testing.expect(t, err == nil, "expected nil error for bool")
	testing.expect(t, v == true, "value mismatch for bool")
}

@(test)
test_parse_i8 :: proc(t: ^testing.T) {
	v: i8 = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for i8")
	testing.expect(t, v == i8(42), "value mismatch for i8")
}

@(test)
test_parse_i16 :: proc(t: ^testing.T) {
	v: i16 = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for i16")
	testing.expect(t, v == i16(42), "value mismatch for i16")
}

@(test)
test_parse_i32 :: proc(t: ^testing.T) {
	v: i32 = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for i32")
	testing.expect(t, v == i32(42), "value mismatch for i32")
}

@(test)
test_parse_i64 :: proc(t: ^testing.T) {
	v: i64 = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for i64")
	testing.expect(t, v == i64(42), "value mismatch for i64")
}

@(test)
test_parse_i128 :: proc(t: ^testing.T) {
	v: i128 = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for i128")
	testing.expect(t, v == i128(42), "value mismatch for i128")
}

@(test)
test_parse_i16le :: proc(t: ^testing.T) {
	v: i16le = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for i16le")
	testing.expect(t, v == i16le(42), "value mismatch for i16le")
}

@(test)
test_parse_i32le :: proc(t: ^testing.T) {
	v: i32le = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for i32le")
	testing.expect(t, v == i32le(42), "value mismatch for i32le")
}

@(test)
test_parse_i64le :: proc(t: ^testing.T) {
	v: i64le = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for i64le")
	testing.expect(t, v == i64le(42), "value mismatch for i64le")
}

@(test)
test_parse_i128le :: proc(t: ^testing.T) {
	v: i128le = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for i128le")
	testing.expect(t, v == i128le(42), "value mismatch for i128le")
}

@(test)
test_parse_i16be :: proc(t: ^testing.T) {
	v: i16be = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for i16be")
	testing.expect(t, v == i16be(42), "value mismatch for i16be")
}

@(test)
test_parse_i32be :: proc(t: ^testing.T) {
	v: i32be = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for i32be")
	testing.expect(t, v == i32be(42), "value mismatch for i32be")
}

@(test)
test_parse_i64be :: proc(t: ^testing.T) {
	v: i64be = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for i64be")
	testing.expect(t, v == i64be(42), "value mismatch for i64be")
}

@(test)
test_parse_i128be :: proc(t: ^testing.T) {
	v: i128be = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for i128be")
	testing.expect(t, v == i128be(42), "value mismatch for i128be")
}

@(test)
test_parse_uint :: proc(t: ^testing.T) {
	v: uint = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for uint")
	testing.expect(t, v == uint(42), "value mismatch for uint")
}

@(test)
test_parse_u8 :: proc(t: ^testing.T) {
	v: u8 = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for u8")
	testing.expect(t, v == u8(42), "value mismatch for u8")
}

@(test)
test_parse_u16 :: proc(t: ^testing.T) {
	v: u16 = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for u16")
	testing.expect(t, v == u16(42), "value mismatch for u16")
}

@(test)
test_parse_u32 :: proc(t: ^testing.T) {
	v: u32 = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for u32")
	testing.expect(t, v == u32(42), "value mismatch for u32")
}

@(test)
test_parse_u64 :: proc(t: ^testing.T) {
	v: u64 = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for u64")
	testing.expect(t, v == u64(42), "value mismatch for u64")
}

@(test)
test_parse_u128 :: proc(t: ^testing.T) {
	v: u128 = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for u128")
	testing.expect(t, v == u128(42), "value mismatch for u128")
}

@(test)
test_parse_u16le :: proc(t: ^testing.T) {
	v: u16le = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for u16le")
	testing.expect(t, v == u16le(42), "value mismatch for u16le")
}

@(test)
test_parse_u32le :: proc(t: ^testing.T) {
	v: u32le = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for u32le")
	testing.expect(t, v == u32le(42), "value mismatch for u32le")
}

@(test)
test_parse_u64le :: proc(t: ^testing.T) {
	v: u64le = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for u64le")
	testing.expect(t, v == u64le(42), "value mismatch for u64le")
}

@(test)
test_parse_u128le :: proc(t: ^testing.T) {
	v: u128le = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for u128le")
	testing.expect(t, v == u128le(42), "value mismatch for u128le")
}

@(test)
test_parse_u16be :: proc(t: ^testing.T) {
	v: u16be = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for u16be")
	testing.expect(t, v == u16be(42), "value mismatch for u16be")
}

@(test)
test_parse_u32be :: proc(t: ^testing.T) {
	v: u32be = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for u32be")
	testing.expect(t, v == u32be(42), "value mismatch for u32be")
}

@(test)
test_parse_u64be :: proc(t: ^testing.T) {
	v: u64be = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for u64be")
	testing.expect(t, v == u64be(42), "value mismatch for u64be")
}

@(test)
test_parse_u128be :: proc(t: ^testing.T) {
	v: u128be = ---
	err := parse_value(&v, "42")
	testing.expect(t, err == nil, "expected nil error for u128be")
	testing.expect(t, v == u128be(42), "value mismatch for u128be")
}

@(test)
test_parse_f16 :: proc(t: ^testing.T) {
	v: f16 = ---
	err := parse_value(&v, "3.5")
	testing.expect(t, err == nil, "expected nil error for f16")
	testing.expect(t, v == f16(3.5), "value mismatch for f16")
}

@(test)
test_parse_f32 :: proc(t: ^testing.T) {
	v: f32 = ---
	err := parse_value(&v, "3.5")
	testing.expect(t, err == nil, "expected nil error for f32")
	testing.expect(t, v == f32(3.5), "value mismatch for f32")
}

@(test)
test_parse_f64 :: proc(t: ^testing.T) {
	v: f64 = ---
	err := parse_value(&v, "3.5")
	testing.expect(t, err == nil, "expected nil error for f64")
	testing.expect(t, v == f64(3.5), "value mismatch for f64")
}

@(test)
test_parse_complex32 :: proc(t: ^testing.T) {
	v: complex32 = ---
	err := parse_value(&v, "1+2i")
	testing.expect(t, err == nil, "expected nil error for complex32")
	testing.expect(t, real(v) == f16(1) && imag(v) == f16(2), "value mismatch for complex32")
}

@(test)
test_parse_complex64 :: proc(t: ^testing.T) {
	v: complex64 = ---
	err := parse_value(&v, "1+2i")
	testing.expect(t, err == nil, "expected nil error for complex64")
	testing.expect(t, real(v) == f32(1) && imag(v) == f32(2), "value mismatch for complex64")
}

@(test)
test_parse_complex128 :: proc(t: ^testing.T) {
	v: complex128 = ---
	err := parse_value(&v, "1+2i")
	testing.expect(t, err == nil, "expected nil error for complex128")
	testing.expect(t, real(v) == f64(1) && imag(v) == f64(2), "value mismatch for complex128")
}

@(test)
test_parse_quaternion64 :: proc(t: ^testing.T) {
	v: quaternion64 = ---
	err := parse_value(&v, "1+2i+3j+4k")
	testing.expect(t, err == nil, "expected nil error for quaternion64")
	testing.expect(
		t,
		real(v) == f16(1) && imag(v) == f16(2) && jmag(v) == f16(3) && kmag(v) == f16(4),
		"value mismatch for quaternion64",
	)
}

@(test)
test_parse_quaternion128 :: proc(t: ^testing.T) {
	v: quaternion128 = ---
	err := parse_value(&v, "1+2i+3j+4k")
	testing.expect(t, err == nil, "expected nil error for quaternion128")
	testing.expect(
		t,
		real(v) == f32(1) && imag(v) == f32(2) && jmag(v) == f32(3) && kmag(v) == f32(4),
		"value mismatch for quaternion128",
	)
}

@(test)
test_parse_quaternion256 :: proc(t: ^testing.T) {
	v: quaternion256 = ---
	err := parse_value(&v, "1+2i+3j+4k")
	testing.expect(t, err == nil, "expected nil error for quaternion256")
	testing.expect(
		t,
		real(v) == f64(1) && imag(v) == f64(2) && jmag(v) == f64(3) && kmag(v) == f64(4),
		"value mismatch for quaternion256",
	)
}

@(test)
test_parse_rune :: proc(t: ^testing.T) {
	v: rune = ---
	err := parse_value(&v, "ø")
	testing.expect(t, err == nil, "expected nil error for rune")
	testing.expect(t, v == 'ø', "value mismatch for rune")
}

@(test)
test_parse_time :: proc(t: ^testing.T) {
	v: time.Time = ---
	err := parse_value(&v, "2026-06-01T12:34:56Z")
	testing.expect(t, err == nil, "expected nil error for time.Time")
}

@(test)
test_parse_host_or_endpoint :: proc(t: ^testing.T) {
	v: net.Host_Or_Endpoint = ---
	err := parse_value(&v, "example.com:8080")
	testing.expect(t, err == nil, "expected nil error for net.Host_Or_Endpoint")
}

@(test)
test_parse_uuid :: proc(t: ^testing.T) {
	v: uuid.Identifier = ---
	err := parse_value(&v, "550e8400-e29b-41d4-a716-446655440000")
	testing.expect(t, err == nil, "expected nil error for uuid.Identifier")
}

@(test)
test_parse_invalid_format :: proc(t: ^testing.T) {
	v: bool
	err := parse_value(&v, "not-a-bool")
	inv, ok := err.(Invalid_Format)
	testing.expect(t, ok, "expected Invalid_Format")
	testing.expect(t, inv.type_name == "bool", "wrong type_name")
	testing.expect(t, inv.input == "not-a-bool", "wrong input")
}

@(test)
test_parse_out_of_range :: proc(t: ^testing.T) {
	v: i8
	err := parse_value(&v, "500")
	oor, ok := err.(Out_Of_Range)
	testing.expect(t, ok, "expected Out_Of_Range")
	testing.expect(t, oor.type_name == "i8", "wrong type_name")
	testing.expect(t, oor.input == "500", "wrong input")
	testing.expect(t, oor.min == "-128", "wrong min")
	testing.expect(t, oor.max == "127", "wrong max")
}

@(test)
test_parse_unknown_enum_variant :: proc(t: ^testing.T) {
	Dir :: enum {
		Up,
		Down,
	}
	dir: Dir
	tib := reflect.type_info_base(type_info_of(Dir))
	val := Enum{tib.variant.(reflect.Type_Info_Enum), &dir}
	err := parse_value(val, "Left")
	uev, ok := err.(Unknown_Enum_Variant)
	testing.expect(t, ok, "expected Unknown_Enum_Variant")
	testing.expect(t, uev.input == "Left", "wrong input")
	testing.expect(t, len(uev.allowed) == 2, "expected 2 allowed names")
	testing.expect(t, uev.allowed[0] == "Up", "wrong first allowed")
	testing.expect(t, uev.allowed[1] == "Down", "wrong second allowed")
}

@(test)
test_parse_rune_multi :: proc(t: ^testing.T) {
	v: rune
	err := parse_value(&v, "ab")
	inv, ok := err.(Invalid_Format)
	testing.expect(t, ok, "expected Invalid_Format for multi-rune input")
	testing.expect(t, inv.type_name == "rune", "wrong type_name")
}
