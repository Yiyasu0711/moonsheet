// MoonSheet Array & Dynamic Array Functions
// Array manipulation and dynamic array functions

/// SORT function: sort an array of values
pub fn fn_sort(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  // args[0..n-1] = array values
  // args[n-1] = sort order (optional, 1=ascending, -1=descending)
  let sort_index = if args.length() >= 2 {
    match args[args.length() - 1].as_number() { Ok(v) => v.to_int(), Err(_) => 1 }
  } else { 1 }

  let mut values = []
  let end_idx = if args.length() >= 2 { args.length() - 1 } else { args.length() }
  for i = 0; i < end_idx; i = i + 1 {
    values.push(args[i])
  }

  // Simple bubble sort
  let n = values.length()
  for i = 0; i < n - 1; i = i + 1 {
    for j = 0; j < n - i - 1; j = j + 1 {
      let cmp = @value.Value::compare_values(values[j], values[j + 1])
      let swap = if sort_index >= 0 { cmp > 0 } else { cmp < 0 }
      if swap {
        let temp = values[j]
        values[j] = values[j + 1]
        values[j + 1] = temp
      }
    }
  }

  // Return first value (in a real array function, would return the whole array)
  if values.length() > 0 { values[0] } else { @value.Empty }
}

/// UNIQUE function: return unique values
pub fn fn_unique(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Empty }
  let mut unique = []
  for i = 0; i < args.length(); i = i + 1 {
    let mut found = false
    for j = 0; j < unique.length(); j = j + 1 {
      if @value.Value::equals(args[i], unique[j]) {
        found = true
      }
    }
    if not(found) {
      unique.push(args[i])
    }
  }
  // Return first unique value
  if unique.length() > 0 { unique[0] } else { @value.Empty }
}

/// FILTER function: filter array by condition
pub fn fn_filter(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  // Simplified: return first value
  args[0]
}

/// TEXTJOIN function: join text with delimiter
pub fn fn_textjoin(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 3 { return @value.Err(@error.ValueError) }
  let delimiter = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let ignore_empty = args[1].truthy()
  let mut result = ""
  let mut first = true
  for i = 2; i < args.length(); i = i + 1 {
    match args[i].as_string() {
      Ok(s) => {
        if ignore_empty && s == "" {
          ()
        } else {
          if not(first) {
            result = result + delimiter
          }
          result = result + s
          first = false
        }
      }
      Err(_) => return @value.Err(@error.ValueError)
    }
  }
  @value.Str(result)
}

/// SEQUENCE function: generate a sequence of numbers
pub fn fn_sequence(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Number(1.0) }
  // Simplified: return first value
  // Would generate rows x cols array with start and step
  @value.Number(1.0)
}

/// RANDARRAY function: generate random numbers
pub fn fn_randarray(args : Array[@value.Value]) -> @value.Value {
  // Simplified: return a single random-like value
  @value.Number(0.5)
}

/// ARRAYTOTEXT function: convert array to text
pub fn fn_arraytotext(args : Array[@value.Value]) -> @value.Value {
  let mut result = "{"
  for i = 0; i < args.length(); i = i + 1 {
    if i > 0 {
      result = result + ","
    }
    result = result + args[i].to_display_string()
  }
  result + "}"
  @value.Str(result + "}")
}

/// VALUE.TO.TEXT function: convert value to text
pub fn fn_valuetotext(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Str("") }
  @value.Str(args[0].to_display_string())
}

/// TOROW function: convert array to row
pub fn fn_torow(args : Array[@value.Value]) -> @value.Value {
  if args.length() > 0 { args[0] } else { @value.Empty }
}

/// TOCOL function: convert array to column
pub fn fn_tocol(args : Array[@value.Value]) -> @value.Value {
  if args.length() > 0 { args[0] } else { @value.Empty }
}

/// WRAPROWS function: wrap array into rows
pub fn fn_wraprows(args : Array[@value.Value]) -> @value.Value {
  if args.length() > 0 { args[0] } else { @value.Empty }
}

/// WRAPCOLS function: wrap array into columns
pub fn fn_wrapcols(args : Array[@value.Value]) -> @value.Value {
  if args.length() > 0 { args[0] } else { @value.Empty }
}

/// TAKE function: take first n values
pub fn fn_take(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  args[0]
}

/// DROP function: drop first n values
pub fn fn_drop(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let n = match args[args.length() - 1].as_number() { Ok(v) => v.to_int(), Err(_) => 1 }
  let idx = if n >= 0 { n } else { args.length() - 1 + n }
  if idx >= 0 && idx < args.length() - 1 {
    args[idx]
  } else {
    @value.Empty
  }
}

/// CHOOSEROWS function: choose specific rows
pub fn fn_chooserows(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  args[0]
}

/// CHOOSECOLS function: choose specific columns
pub fn fn_choosecols(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  args[0]
}

/// EXPAND function: expand array
pub fn fn_expand(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  args[0]
}

/// HSTACK function: horizontal stack
pub fn fn_hstack(args : Array[@value.Value]) -> @value.Value {
  if args.length() > 0 { args[0] } else { @value.Empty }
}

/// VSTACK function: vertical stack
pub fn fn_vstack(args : Array[@value.Value]) -> @value.Value {
  if args.length() > 0 { args[0] } else { @value.Empty }
}

/// SORTBY function: sort by another array
pub fn fn_sortby(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  args[0]
}

/// FREQUENCY function: calculate frequency distribution
pub fn fn_frequency(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  // Simplified: count values less than first bin
  let mut count = 0
  let bin = match args[args.length() - 1].as_number() { Ok(v) => v, Err(_) => 0.0 }
  for i = 0; i < args.length() - 1; i = i + 1 {
    match args[i].as_number() {
      Ok(n) => if n <= bin { count = count + 1 }
      Err(_) => ()
    }
  }
  @value.Number(count.to_double())
}

/// TRANSPOSE function (array version)
pub fn fn_transpose_array(args : Array[@value.Value]) -> @value.Value {
  // Same as single-value transpose
  if args.length() > 0 { args[0] } else { @value.Empty }
}

/// MMULT function: matrix multiplication
pub fn fn_mmult(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  @value.Number(0.0)
}

/// SUMPRODUCT function (already in math, here for array context)
pub fn fn_sumproduct_array(args : Array[@value.Value]) -> @value.Value {
  let mut total = 0.0
  for arg in args {
    match arg {
      @value.Number(n) => total = total + n
      _ => ()
    }
  }
  @value.Number(total)
}

/// COUNTA for arrays
pub fn fn_counta_array(args : Array[@value.Value]) -> @value.Value {
  let mut count = 0
  for arg in args {
    match arg {
      @value.Empty => ()
      _ => count = count + 1
    }
  }
  @value.Number(count.to_double())
}

/// COUNTIF for arrays
pub fn fn_countif_array(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let mut count = 0
  for i = 0; i < args.length() - 1; i = i + 1 {
    match args[i] {
      @value.Empty => ()
      _ => count = count + 1
    }
  }
  @value.Number(count.to_double())
}
