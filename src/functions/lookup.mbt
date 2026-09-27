// MoonSheet Lookup & Reference Functions
// Lookup and reference functions for the spreadsheet engine

/// VLOOKUP function: vertical lookup
pub fn fn_vlookup(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 3 { return @value.Err(@error.ValueError) }
  let lookup_value = args[0]
  // args[1] should be the table array (we receive as flat array of values)
  // args[2] = column index
  // args[3] = range lookup (optional, default true)
  let col_index = match args[2].as_number() {
    Ok(v) => v.to_int()
    Err(_) => return @value.Err(@error.ValueError)
  }
  if col_index < 1 { return @value.Err(@error.ValueError) }
  let range_lookup = if args.length() >= 4 { args[3].truthy() } else { true }

  // Simplified implementation: search through the flat array
  // In a real spreadsheet, the table array would be a 2D range
  // Here we approximate: first N values are column 1, next N are column 2, etc.
  // Since we receive flat args, we use a simplified approach
  let mut best_match = @value.Err(@error.NotAvailable)
  let table_values = []
  // Collect table values from args[1] onwards (excluding last args)
  let table_start = 1
  let table_end = if args.length() >= 4 { args.length() - 2 } else { args.length() - 1 }
  let mut table = []
  for i = table_start; i < table_end; i = i + 1 {
    table.push(args[i])
  }

  // If col_index is 1, just look for the value
  if col_index == 1 {
    for i = 0; i < table.length(); i = i + 1 {
      let cmp = @value.Value::compare_values(lookup_value, table[i])
      if cmp == 0 {
        return table[i]
      }
      if range_lookup && cmp > 0 {
        best_match = table[i]
      }
    }
    if range_lookup {
      best_match
    } else {
      @value.Err(@error.NotAvailable)
    }
  } else {
    // For multi-column: approximate by returning the Nth value after match
    // This is a simplified version
    for i = 0; i < table.length(); i = i + 1 {
      let cmp = @value.Value::compare_values(lookup_value, table[i])
      if cmp == 0 {
        let result_idx = i + col_index - 1
        if result_idx < table.length() {
          return table[result_idx]
        }
      }
    }
    @value.Err(@error.NotAvailable)
  }
}

/// HLOOKUP function: horizontal lookup
pub fn fn_hlookup(args : Array[@value.Value]) -> @value.Value {
  // Simplified: same as VLOOKUP for flat arrays
  fn_vlookup(args)
}

/// INDEX function: return value at given row/column
pub fn fn_index(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  // args[0] = array (flat)
  // args[1] = row number
  // args[2] = column number (optional)
  let row_num = match args[1].as_number() {
    Ok(v) => v.to_int()
    Err(_) => return @value.Err(@error.ValueError)
  }
  let col_num = if args.length() >= 3 {
    match args[2].as_number() { Ok(v) => v.to_int(), Err(_) => 1 }
  } else { 1 }

  if row_num < 1 || col_num < 1 {
    return @value.Err(@error.ValueError)
  }

  // For flat array, treat as 1D
  let idx = row_num - 1
  if idx < 0 || idx >= args.length() - 1 {
    return @value.Err(@error.RefError)
  }
  args[idx + 1]
}

/// MATCH function: find position of value in array
pub fn fn_match(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let lookup_value = args[0]
  // args[1..] = lookup array
  // args[last] = match type (optional, 1=approx, 0=exact, -1=approx desc)
  let match_type = if args.length() >= 3 {
    match args[args.length() - 1].as_number() { Ok(v) => v.to_int(), Err(_) => 1 }
  } else { 1 }

  let array_start = 1
  let array_end = if args.length() >= 3 { args.length() - 1 } else { args.length() }

  let mut result_idx = -1
  for i = array_start; i < array_end; i = i + 1 {
    let cmp = @value.Value::compare_values(lookup_value, args[i])
    if match_type == 0 {
      if cmp == 0 {
        return @value.Number((i - array_start + 1).to_double())
      }
    } else if match_type == 1 {
      // Find largest value <= lookup_value (assumes sorted ascending)
      if cmp >= 0 {
        result_idx = i - array_start + 1
      }
    } else {
      // match_type == -1: find smallest value >= lookup_value (assumes sorted descending)
      if cmp <= 0 {
        result_idx = i - array_start + 1
      }
    }
  }

  if result_idx > 0 {
    @value.Number(result_idx.to_double())
  } else {
    @value.Err(@error.NotAvailable)
  }
}

/// CHOOSE function: choose value from list by index
pub fn fn_choose(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let idx = match args[0].as_number() {
    Ok(v) => v.to_int()
    Err(_) => return @value.Err(@error.ValueError)
  }
  if idx < 1 || idx > args.length() - 1 {
    return @value.Err(@error.ValueError)
  }
  args[idx]
}

/// ADDRESS function: return cell reference as text
pub fn fn_address(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let row = match args[0].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  let col = match args[1].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  if row < 1 || col < 1 { return @value.Err(@error.ValueError) }
  let abs_type = if args.length() >= 3 {
    match args[2].as_number() { Ok(v) => v.to_int(), Err(_) => 1 }
  } else { 1 }

  let col_letter = @reference.col_to_letter(col - 1)
  let row_str = row.to_string()

  match abs_type {
    1 => @value.Str("$" + col_letter + "$" + row_str)
    2 => @value.Str(col_letter + "$" + row_str)
    3 => @value.Str("$" + col_letter + row_str)
    4 => @value.Str(col_letter + row_str)
    _ => @value.Str("$" + col_letter + "$" + row_str)
  }
}

/// INDIRECT function: return value from text reference
pub fn fn_indirect(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  // Simplified: returns #REF! since we can't resolve references in this context
  // In a full implementation, this would parse the text as a reference and get the value
  @value.Err(@error.RefError)
}

/// ROW function: return row number
pub fn fn_row(args : Array[@value.Value]) -> @value.Value {
  // Simplified: returns 1 as default
  // In context of a cell, would return the cell's row
  @value.Number(1.0)
}

/// COLUMN function: return column number
pub fn fn_column(args : Array[@value.Value]) -> @value.Value {
  @value.Number(1.0)
}

/// ROWS function: return number of rows in range
pub fn fn_rows(args : Array[@value.Value]) -> @value.Value {
  @value.Number(args.length().to_double())
}

/// COLUMNS function: return number of columns in range
pub fn fn_columns(args : Array[@value.Value]) -> @value.Value {
  @value.Number(1.0)
}

/// TRANSPOSE function: transpose array
pub fn fn_transpose(args : Array[@value.Value]) -> @value.Value {
  // For single values, just return the value
  if args.length() == 1 { args[0] }
  else { args[0] }
}

/// OFFSET function: return offset range
pub fn fn_offset(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 3 { return @value.Err(@error.ValueError) }
  // Simplified: returns first value as a placeholder
  args[0]
}

/// XLOOKUP function: enhanced lookup
pub fn fn_xlookup(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 3 { return @value.Err(@error.ValueError) }
  let lookup_value = args[0]
  // args[1] = lookup array
  // args[2] = return array
  // args[3] = if_not_found (optional)
  // args[4] = match_mode (optional, 0=exact)
  // args[5] = search_mode (optional, 1=first to last)

  let lookup_end = 2
  let return_start = 2
  let return_end = if args.length() >= 4 { 3 } else { args.length() }

  // Simple exact match search
  for i = 1; i < lookup_end && i < args.length(); i = i + 1 {
    if @value.Value::equals(lookup_value, args[i]) {
      let return_idx = return_start + (i - 1)
      if return_idx < args.length() {
        return args[return_idx]
      }
    }
  }

  // Return if_not_found or #N/A
  if args.length() >= 4 {
    args[3]
  } else {
    @value.Err(@error.NotAvailable)
  }
}

/// XMATCH function: enhanced match
pub fn fn_xmatch(args : Array[@value.Value]) -> @value.Value {
  // Use same logic as MATCH
  fn_match(args)
}

/// LOOKUP function: simple lookup
pub fn fn_lookup(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  // If 2 args: lookup value in array, return from same array
  // If 3 args: lookup in first array, return from second
  fn_vlookup(args)
}

/// AREAS function: number of areas in reference
pub fn fn_areas(args : Array[@value.Value]) -> @value.Value {
  @value.Number(1.0)
}

/// FORMULATEXT function: return formula as text
pub fn fn_formulatext(args : Array[@value.Value]) -> @value.Value {
  @value.Err(@error.NotAvailable)
}

/// Get cell count for lookup operations
fn fn_lookup_count(args : Array[@value.Value], start : Int, end : Int) -> Int {
  let mut count = 0
  for i = start; i < end; i = i + 1 {
    match args[i] {
      @value.Empty => ()
      _ => count = count + 1
    }
  }
  count
}
