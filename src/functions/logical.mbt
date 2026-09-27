// MoonSheet Logical Functions
// Logical and conditional functions

/// IF function: conditional branching
pub fn fn_if(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let condition = args[0].truthy()
  if condition {
    args[1]
  } else {
    if args.length() >= 3 { args[2] } else { @value.Bool(false) }
  }
}

/// AND function: logical AND
pub fn fn_and(args : Array[@value.Value]) -> @value.Value {
  let mut result = true
  for arg in args {
    if not(arg.truthy()) {
      result = false
    }
  }
  if args.length() == 0 { @value.Err(@error.ValueError) } else { @value.Bool(result) }
}

/// OR function: logical OR
pub fn fn_or(args : Array[@value.Value]) -> @value.Value {
  let mut result = false
  for arg in args {
    if arg.truthy() {
      result = true
    }
  }
  if args.length() == 0 { @value.Err(@error.ValueError) } else { @value.Bool(result) }
}

/// NOT function: logical NOT
pub fn fn_not(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  @value.Bool(not(args[0].truthy()))
}

/// XOR function: logical XOR
pub fn fn_xor(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  let mut count = 0
  for arg in args {
    if arg.truthy() {
      count = count + 1
    }
  }
  @value.Bool(count % 2 == 1)
}

/// IFERROR function: return value or error replacement
pub fn fn_iferror(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  match args[0] {
    @value.Err(_) => args[1]
    _ => args[0]
  }
}

/// IFNA function: return value or NA replacement
pub fn fn_ifna(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  match args[0] {
    @value.Err(@error.NotAvailable) => args[1]
    _ => args[0]
  }
}

/// TRUE function
pub fn fn_true(args : Array[@value.Value]) -> @value.Value {
  ignore(args)
  @value.Bool(true)
}

/// FALSE function
pub fn fn_false(args : Array[@value.Value]) -> @value.Value {
  ignore(args)
  @value.Bool(false)
}

/// ISNUMBER function
pub fn fn_isnumber(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Bool(false) }
  @value.Bool(args[0].is_number())
}

/// ISTEXT function
pub fn fn_istext(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Bool(false) }
  @value.Bool(args[0].is_string())
}

/// ISLOGICAL function
pub fn fn_islogical(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Bool(false) }
  @value.Bool(args[0].is_bool())
}

/// ISERROR function
pub fn fn_iserror(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Bool(false) }
  @value.Bool(args[0].is_error())
}

/// ISEMPTY function
pub fn fn_isempty(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Bool(true) }
  @value.Bool(args[0].is_empty())
}

/// ISNONTEXT function
pub fn fn_isnontext(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Bool(true) }
  @value.Bool(not(args[0].is_string()))
}

/// ISREF function (always false since we don't expose refs)
pub fn fn_isref(args : Array[@value.Value]) -> @value.Value {
  ignore(args)
  @value.Bool(false)
}

/// NA function: returns #N/A
pub fn fn_na(args : Array[@value.Value]) -> @value.Value {
  ignore(args)
  @value.Err(@error.NotAvailable)
}

/// ERROR.TYPE function
pub fn fn_error_type(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0] {
    @value.Err(e) => @value.Number(e.error_type().to_double())
    _ => @value.Err(@error.NotAvailable)
  }
}

/// IFS function: multiple IF
pub fn fn_ifs(args : Array[@value.Value]) -> @value.Value {
  if args.length() % 2 != 0 { return @value.Err(@error.ValueError) }
  let mut i = 0
  while i < args.length() {
    if args[i].truthy() {
      return args[i + 1]
    }
    i = i + 2
  }
  @value.Err(@error.NotAvailable)
}

/// SWITCH function
pub fn fn_switch(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 3 { return @value.Err(@error.ValueError) }
  let target = args[0]
  let mut i = 1
  while i < args.length() - 1 {
    if @value.Value::equals(target, args[i]) {
      return args[i + 1]
    }
    i = i + 2
  }
  // Check if last arg is default
  if args.length() % 2 == 0 {
    return args[args.length() - 1]
  }
  @value.Err(@error.NotAvailable)
}

/// AND for values
pub fn fn_and_values(vals : Array[Bool]) -> Bool {
  let mut result = true
  for v in vals {
    if not(v) { result = false }
  }
  result
}

/// OR for values
pub fn fn_or_values(vals : Array[Bool]) -> Bool {
  let mut result = false
  for v in vals {
    if v { result = true }
  }
  result
}

/// NOT for value
pub fn fn_not_value(v : Bool) -> Bool {
  not(v)
}

/// XOR for values
pub fn fn_xor_values(vals : Array[Bool]) -> Bool {
  let mut count = 0
  for v in vals {
    if v { count = count + 1 }
  }
  count % 2 == 1
}
