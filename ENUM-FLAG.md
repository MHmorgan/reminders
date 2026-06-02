# Enum Flag Support — Design Options

All examples assume the existing `cli/` package with `Value :: union { ^string, ^int }`, `Flag`, `Command`, and `parse_value`.

---

## Approach A — Inline struct as a new Value variant

The enum definition and output pointer are bundled into a struct stored directly inside the `Value` union. No changes to `Flag`. `parse_value` gains one new case.

**`cli/value.odin` changes:**

```odin
Enum_Flag :: struct {
    variants: []string,
    value:    ^string,
}

Value :: union {
    ^string,
    ^int,
    Enum_Flag,
}

parse_value :: proc(value: Value, s: string) {
    switch v in value {
    case ^int:
        if res, ok := strconv.parse_int(s); ok {
            v^ = res
        }
    case ^string:
        v^ = s
    case Enum_Flag:
        for variant in v.variants {
            if s == variant {
                v.value^ = s
                return
            }
        }
        // invalid — s is not in v.variants
        // currently silently ignored; see error-handling note below
    }
}
```

**`cli/flag.odin` additions:**

```odin
flag_enum :: proc(c: ^Command, p: ^string, variants: []string, name, usage: string) {
    c.flags[name] = Flag{
        name  = name,
        usage = usage,
        value = Enum_Flag{variants = variants, value = p},
    }
}

flagp_enum :: proc(c: ^Command, variants: []string, name, usage: string) -> ^string {
    p := new(string)
    flag_enum(c, p, variants, name, usage)
    return p
}
```

**Caller (`main.odin`):**

```odin
priority: string
flag_enum(&cmd, &priority, []string{"low", "medium", "high"}, "priority", "task priority")

// After parsing "--priority high":  priority == "high"
// After parsing "--priority BOOM":  priority unchanged (or error, depending on impl)
```

**Key properties:**
- Zero changes to `Flag` struct
- Enum metadata travels with the value — impossible to register a flag and forget the variants
- Allowed values are inspectable at runtime (for generated help text)
- Slice header copied by value into the union — fine, it's just a pointer + length

---

## Approach B — `allowed` field on Flag struct

The flag stores `^string` as usual; an additional `allowed []string` field on `Flag` constrains it. Validation is a separate step decoupled from `parse_value`.

**`cli/flag.odin` changes:**

```odin
Flag :: struct {
    name:    string,
    usage:   string,
    value:   Value,
    allowed: []string,   // nil = no constraint
}

validate_flag :: proc(f: Flag, s: string) -> bool {
    if len(f.allowed) == 0 do return true
    for v in f.allowed do if s == v do return true
    return false
}

flag_enum :: proc(c: ^Command, p: ^string, variants: []string, name, usage: string) {
    c.flags[name] = Flag{
        name    = name,
        usage   = usage,
        value   = p,
        allowed = variants,
    }
}
```

**Caller (`main.odin`):**

```odin
priority: string
flag_enum(&cmd, &priority, []string{"low", "medium", "high"}, "priority", "task priority")

// Consumer code must call validate_flag before trusting the value:
if !validate_flag(cmd.flags["priority"], raw_input) {
    fmt.eprintln("invalid priority")
    os.exit(1)
}
```

**Key properties:**
- `Value` union and `parse_value` untouched
- Every `Flag` carries an extra `[]string` header even if not an enum flag
- Validation is opt-in — the caller can forget to call `validate_flag`
- Decoupled from parsing: useful if you want to validate after all flags are collected

---

## Approach C — Validation callback on Flag

A `validate` proc field on `Flag` holds an optional predicate. For enums the caller provides a closure; `nil` means unconstrained.

**`cli/flag.odin` changes:**

```odin
Flag :: struct {
    name:     string,
    usage:    string,
    value:    Value,
    validate: proc(s: string) -> bool,
}

// Helper to build the enum closure
make_enum_validator :: proc(variants: []string) -> proc(s: string) -> bool {
    return proc(s: string) -> bool {
        // Note: variants captured by pointer — variants slice must outlive the flag
        for v in variants do if s == v do return true
        return false
    }
}

flag_enum :: proc(c: ^Command, p: ^string, variants: []string, name, usage: string) {
    c.flags[name] = Flag{
        name     = name,
        usage    = usage,
        value    = p,
        validate = make_enum_validator(variants),
    }
}
```

**Caller (`main.odin`):**

```odin
priority: string
flag_enum(&cmd, &priority, []string{"low", "medium", "high"}, "priority", "task priority")

// Or with a fully custom predicate:
c.flags["count"] = Flag{
    name     = "count",
    usage    = "number of items (1-10)",
    value    = &count,
    validate = proc(s: string) -> bool {
        n, ok := strconv.parse_int(s)
        return ok && n >= 1 && n <= 10
    },
}
```

**Key properties:**
- Most flexible — any predicate fits (ranges, regex, cross-field checks)
- Enum allowed-values are hidden inside the closure: no introspection, no auto help text
- Proc pointer in a struct means `Flag` is no longer plain data (harder to copy/compare)
- Closures capturing slices require careful lifetime management in Odin

---

## Approach D — Odin native `enum` type via reflect

The caller defines a real Odin `enum` type. The library erases the pointer to `rawptr`, stores type metadata, and uses `reflect` at parse time to map the incoming string to the correct variant ordinal.

**User's application code:**

```odin
// In the user's package — real Odin enum:
Priority :: enum { Low, Medium, High }

priority: Priority

flag_native_enum(&cmd, &priority, "priority", "task priority")

// After parsing "--priority High":
if priority == .High {
    fmt.println("high priority task")
}
// .High is a real compiler symbol — typos caught at compile time in application code
```

**`cli/value.odin` additions:**

```odin
import "core:reflect"

// Type-erased container for any Odin enum value
Enum_Native :: struct {
    ti:  ^reflect.Type_Info,   // carries field names + ordinal values
    ptr: rawptr,               // points to the caller's enum variable
}

Value :: union {
    ^string,
    ^int,
    Enum_Native,
}

parse_value :: proc(value: Value, s: string) {
    switch v in value {
    case ^int:
        if res, ok := strconv.parse_int(s); ok { v^ = res }
    case ^string:
        v^ = s
    case Enum_Native:
        // Walk enum field names via reflect
        enum_info := v.ti.variant.(reflect.Type_Info_Enum)
        for name, i in enum_info.names {
            if name == s {
                // Write the ordinal value into the type-erased pointer.
                // The enum's backing type is enum_info.base; default is int.
                // For simplicity, assume int-backed enums here:
                (cast(^int)v.ptr)^ = int(enum_info.values[i])
                return
            }
        }
        // s not found in enum names — error path needed
    }
}
```

**`cli/flag.odin` addition:**

```odin
// $E is constrained to enum types at the call site
flag_native_enum :: proc(c: ^Command, p: ^$E, name, usage: string)
    where intrinsics.type_is_enum(E) {
    c.flags[name] = Flag{
        name  = name,
        usage = usage,
        value = Enum_Native{
            ti  = type_info_of(E),
            ptr = p,
        },
    }
}
```

**Help text is free — reflect gives you the names without a separate string slice:**

```odin
// In a hypothetical print_usage proc:
case Enum_Native:
    enum_info := f.value.(Enum_Native).ti.variant.(reflect.Type_Info_Enum)
    fmt.printf("  --%s  <%s>  %s\n", f.name, strings.join(enum_info.names, "|"), f.usage)
    // prints:  --priority  <Low|Medium|High>  task priority
```

**Key properties:**
- Caller uses `.Low`, `.Medium`, `.High` — compiler catches invalid variants in application code
- Allowed values are never written twice (no redundant `[]string{"Low", "Medium", "High"}`)
- Library internals must erase type and write through `rawptr` — complexity lives in the library, not the caller
- Backing-type size assumptions must be handled correctly (Odin enums default to `int` but can be explicitly typed as `u8`, etc.)
- Invalid CLI input (e.g. `"BOOM"`) is still a runtime error — there's no way to make CLI string input a compile-time error

---

## Comparison

| | A — Inline struct | B — `allowed` on Flag | C — Callback | D — Native enum |
|---|---|---|---|---|
| `Value` union change | Yes (1 variant) | No | No | Yes (1 variant) |
| `Flag` struct change | No | Yes | Yes | No |
| Caller writes string variants | Yes | Yes | Yes | No |
| Auto help text | Yes | Yes | No | Yes |
| Compiler checks variants | No | No | No | Yes (in app code) |
| Custom predicates | No | No | Yes | No |
| Internal complexity | Low | Low | Medium | High |

---

## Error Handling Note

`parse_value` currently swallows errors silently. All four approaches expose a new failure mode (input rejected by constraint). Before implementing any of these, decide on the error surface:

- Return `bool` or `(ok: bool)` from `parse_value`
- Add an `error: string` out-parameter
- Store a global/thread-local parse error on the `Command`
- Panic with a formatted message (acceptable for CLI tools)
