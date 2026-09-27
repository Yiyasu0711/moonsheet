// MoonSheet Text Functions
// String manipulation functions

/// LEFT function: returns leftmost n characters
pub fn fn_left(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  let s = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let n = if args.length() >= 2 {
    match args[1].as_number() { Ok(v) => v.to_int(), Err(_) => 1 }
  } else { 1 }
  if n <= 0 { return @value.Str("") }
  if n >= s.length() { return @value.Str(s) }
  @value.Str(s.substring(start=0, end=n))
}

/// RIGHT function: returns rightmost n characters
pub fn fn_right(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  let s = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let n = if args.length() >= 2 {
    match args[1].as_number() { Ok(v) => v.to_int(), Err(_) => 1 }
  } else { 1 }
  if n <= 0 { return @value.Str("") }
  if n >= s.length() { return @value.Str(s) }
  @value.Str(s.substring(start=s.length() - n))
}

/// MID function: returns substring
pub fn fn_mid(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 3 { return @value.Err(@error.ValueError) }
  let s = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let start = match args[1].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  let len = match args[2].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  if start < 1 || len < 0 { return @value.Err(@error.ValueError) }
  let start_idx = start - 1
  if start_idx >= s.length() || len == 0 { return @value.Str("") }
  let end_idx = if start_idx + len > s.length() { s.length() } else { start_idx + len }
  @value.Str(s.substring(start=start_idx, end=end_idx))
}

/// LEN function: length of string
pub fn fn_len(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  let s = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  @value.Number(s.length().to_double())
}

/// UPPER function: convert to uppercase
pub fn fn_upper(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  let s = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  @value.Str(s.to_upper())
}

/// LOWER function: convert to lowercase
pub fn fn_lower(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  let s = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  @value.Str(s.to_lower())
}

/// TRIM function: remove leading/trailing whitespace
pub fn fn_trim(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  let s = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  @value.Str(s.trim())
}

/// CONCAT function: concatenate multiple values
pub fn fn_concat(args : Array[@value.Value]) -> @value.Value {
  let mut result = ""
  for arg in args {
    match arg.as_string() {
      Ok(s) => result = result + s
      Err(_) => return @value.Err(@error.ValueError)
    }
  }
  @value.Str(result)
}

/// REPLACE function: replace text
pub fn fn_replace(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 4 { return @value.Err(@error.ValueError) }
  let s = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let start = match args[1].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  let len = match args[2].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  let new_text = match args[3].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  if start < 1 { return @value.Err(@error.ValueError) }
  let start_idx = start - 1
  let prefix = if start_idx <= s.length() { s.substring(start=0, end=start_idx) } else { s }
  let suffix_idx = if start_idx + len <= s.length() { start_idx + len } else { s.length() }
  let suffix = s.substring(start=suffix_idx)
  @value.Str(prefix + new_text + suffix)
}

/// SUBSTITUTE function: substitute text
pub fn fn_substitute(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 3 { return @value.Err(@error.ValueError) }
  let s = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let old_text = match args[1].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let new_text = match args[2].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  if old_text == "" { return @value.Str(s) }
  @value.Str(s.replace(old_text, new_text))
}

/// FIND function: find substring (case-sensitive)
pub fn fn_find(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let find_text = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let within_text = match args[1].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let start = if args.length() >= 3 {
    match args[2].as_number() { Ok(v) => v.to_int(), Err(_) => 1 }
  } else { 1 }
  if start < 1 { return @value.Err(@error.ValueError) }
  let start_idx = start - 1
  if start_idx >= within_text.length() { return @value.Err(@error.ValueError) }
  let search_str = within_text.substring(start=start_idx)
  match search_str.find(find_text) {
    Some(idx) => @value.Number((idx + start_idx + 1).to_double())
    None => @value.Err(@error.ValueError)
  }
}

/// SEARCH function: find substring (case-insensitive)
pub fn fn_search(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let find_text = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let within_text = match args[1].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let start = if args.length() >= 3 {
    match args[2].as_number() { Ok(v) => v.to_int(), Err(_) => 1 }
  } else { 1 }
  if start < 1 { return @value.Err(@error.ValueError) }
  let start_idx = start - 1
  let search_str = within_text.substring(start=start_idx).to_lower()
  let find_lower = find_text.to_lower()
  match search_str.find(find_lower) {
    Some(idx) => @value.Number((idx + start_idx + 1).to_double())
    None => @value.Err(@error.ValueError)
  }
}

/// REPT function: repeat text n times
pub fn fn_rept(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let s = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let n = match args[1].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  if n < 0 { return @value.Err(@error.ValueError) }
  let mut result = ""
  for i = 0; i < n; i = i + 1 {
    result = result + s
  }
  @value.Str(result)
}

/// VALUE function: convert text to number
pub fn fn_value(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_string() {
    Ok(s) => {
      match Double::from_string(s.trim()) {
        Some(n) => @value.Number(n)
        None => @value.Err(@error.ValueError)
      }
    }
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// TEXT function: format number as text
pub fn fn_text(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let n = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let fmt = match args[1].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  @value.Str(@format.format_number_with_pattern(n, fmt))
}

/// PROPER function: capitalize first letter of each word
pub fn fn_proper(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  let s = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  @value.Str(s.to_title())
}

/// CLEAN function: remove non-printable characters
pub fn fn_clean(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  let s = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let mut result = ""
  for i = 0; i < s.length(); i = i + 1 {
    let ch = s[i]
    if ch >= 32 || ch == 10 || ch == 13 || ch == 9 {
      result = result + Char::from_int(ch).to_string()
    }
  }
  @value.Str(result)
}

/// EXACT function: compare two strings
pub fn fn_exact(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let s1 = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let s2 = match args[1].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  @value.Bool(s1 == s2)
}

/// T function: returns text if value is text, empty otherwise
pub fn fn_t(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Str("") }
  match args[0] {
    @value.Str(s) => @value.Str(s)
    _ => @value.Str("")
  }
}

/// CHAR function: returns character from code
pub fn fn_char(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => @value.Str(Char::from_int(n.to_int()).to_string())
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// CODE function: returns code of first character
pub fn fn_code(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  let s = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  if s.length() == 0 { return @value.Number(0.0) }
  @value.Number(s[0].to_double())
}
