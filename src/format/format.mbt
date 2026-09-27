// MoonSheet Format
// Value formatting for display and export

/// Format a value for display
pub fn format_value(v : @value.Value) -> String {
  v.to_display_string()
}

/// Format a number with a pattern
pub fn format_number_with_pattern(n : Double, pattern : String) -> String {
  match pattern {
    "general" | "General" | "" => n.to_string()
    "0" => n.trunc().to_int().to_string()
    "0.00" => {
      let scaled = (n * 100.0 + 0.5).floor() / 100.0
      scaled.to_string()
    }
    "#,##0" => format_thousands(n.trunc().to_int())
    "#,##0.00" => {
      let int_part = format_thousands(n.trunc().to_int())
      let frac = n - n.trunc()
      let frac_str = ((frac * 100.0 + 0.5).floor()).to_string()
      int_part + "." + frac_str
    }
    "0%" => (n * 100.0).trunc().to_int().to_string() + "%"
    "0.00%" => (n * 100.0).to_string() + "%"
    "$#,##0" => "$" + format_thousands(n.trunc().to_int())
    "$#,##0.00" => {
      let int_part = format_thousands(n.trunc().to_int())
      let frac = n - n.trunc()
      let frac_str = ((frac * 100.0 + 0.5).floor()).to_string()
      "$" + int_part + "." + frac_str
    }
    "0.00E+00" => {
      if n == 0.0 { return "0.00E+00" }
      let exp = n.abs().log().floor().to_int()
      let mantissa = n / 10.0.pow(exp.to_double())
      mantissa.to_string() + "E+" + (if exp >= 0 { "+" } else { "-" }) + exp.abs().to_string()
    }
    "yyyy-mm-dd" | "YYYY-MM-DD" => {
      let serial = n.to_int()
      let (year, month, day) = @functions.serial_to_date(serial)
      let month_str = if month < 10 { "0" + month.to_string() } else { month.to_string() }
      let day_str = if day < 10 { "0" + day.to_string() } else { day.to_string() }
      year.to_string() + "-" + month_str + "-" + day_str
    }
    "yyyy/mm/dd" | "YYYY/MM/DD" => {
      let serial = n.to_int()
      let (year, month, day) = @functions.serial_to_date(serial)
      year.to_string() + "/" + month.to_string() + "/" + day.to_string()
    }
    "hh:mm:ss" | "HH:MM:SS" => {
      let frac = n - n.trunc()
      let total_seconds = (frac * 86400.0).to_int()
      let h = total_seconds / 3600
      let m = (total_seconds % 3600) / 60
      let s = total_seconds % 60
      let h_str = if h < 10 { "0" + h.to_string() } else { h.to_string() }
      let m_str = if m < 10 { "0" + m.to_string() } else { m.to_string() }
      let s_str = if s < 10 { "0" + s.to_string() } else { s.to_string() }
      h_str + ":" + m_str + ":" + s_str
    }
    "hh:mm" | "HH:MM" => {
      let frac = n - n.trunc()
      let total_seconds = (frac * 86400.0).to_int()
      let h = total_seconds / 3600
      let m = (total_seconds % 3600) / 60
      let h_str = if h < 10 { "0" + h.to_string() } else { h.to_string() }
      let m_str = if m < 10 { "0" + m.to_string() } else { m.to_string() }
      h_str + ":" + m_str
    }
    _ => n.to_string()
  }
}

/// Format thousands with comma separator
pub fn format_thousands(n : Int) -> String {
  let mut s = n.abs().to_string()
  let mut result = ""
  while s.length() > 3 {
    result = "," + s.substring(start=s.length() - 3) + result
    s = s.substring(start=0, end=s.length() - 3)
  }
  result = s + result
  if n < 0 { "-" + result } else { result }
}

/// Auto-format a value based on its type
pub fn auto_format(v : @value.Value) -> String {
  match v {
    @value.Number(n) => {
      if n == n.trunc() && n.abs() < 1e15 {
        n.to_int().to_string()
      } else {
        n.to_string()
      }
    }
    @value.Str(s) => s
    @value.Bool(true) => "TRUE"
    @value.Bool(false) => "FALSE"
    @value.Empty => ""
    @value.Err(e) => e.to_error_string()
  }
}

/// Format value as currency
pub fn format_currency(v : @value.Value, symbol : String) -> String {
  match v.as_number() {
    Ok(n) => symbol + format_thousands(n.trunc().to_int()) + "." + ((n - n.trunc()) * 100.0 + 0.5).floor().to_int().to_string()
    Err(_) => v.to_display_string()
  }
}

/// Format value as percentage
pub fn format_percent(v : @value.Value, decimals : Int) -> String {
  match v.as_number() {
    Ok(n) => {
      let scaled = n * 100.0
      if decimals == 0 {
        scaled.trunc().to_int().to_string() + "%"
      } else {
        let factor = 10.0.pow(decimals.to_double())
        let rounded = (scaled * factor + 0.5).floor() / factor
        rounded.to_string() + "%"
      }
    }
    Err(_) => v.to_display_string()
  }
}

/// Format value as scientific notation
pub fn format_scientific(v : @value.Value, digits : Int) -> String {
  match v.as_number() {
    Ok(n) => {
      if n == 0.0 { return "0E+0" }
      let exp = n.abs().log().floor().to_int()
      let mantissa = n / 10.0.pow(exp.to_double())
      let factor = 10.0.pow(digits.to_double())
      let rounded = (mantissa * factor + 0.5).floor() / factor
      rounded.to_string() + "E+" + exp.to_string()
    }
    Err(_) => v.to_display_string()
  }
}

/// Format value as date
pub fn format_date(v : @value.Value, fmt : String) -> String {
  match v.as_number() {
    Ok(n) => format_number_with_pattern(n, fmt)
    Err(_) => v.to_display_string()
  }
}

/// Format value as fraction
pub fn format_fraction(v : @value.Value) -> String {
  match v.as_number() {
    Ok(n) => {
      let int_part = n.trunc().to_int()
      let frac = n - int_part.to_double()
      if frac == 0.0 {
        return int_part.to_string()
      }
      // Simple fraction approximation
      let mut numerator = 1
      let mut denominator = 1
      let mut best_err = frac.abs()
      for d = 1; d <= 100; d = d + 1 {
        let n_opt = (frac * d.to_double()).round().to_int()
        let err = (frac - n_opt.to_double() / d.to_double()).abs()
        if err < best_err {
          best_err = err
          numerator = n_opt
          denominator = d
        }
      }
      if int_part == 0 {
        numerator.to_string() + "/" + denominator.to_string()
      } else {
        int_part.to_string() + " " + numerator.to_string() + "/" + denominator.to_string()
      }
    }
    Err(_) => v.to_display_string()
  }
}

/// Format a cell for display
pub fn format_cell(cell : @cell.Cell, fmt : String) -> String {
  if fmt == "" || fmt == "General" {
    auto_format(cell.get_value())
  } else {
    match cell.get_value() {
      @value.Number(n) => format_number_with_pattern(n, fmt)
      v => v.to_display_string()
    }
  }
}

/// Format a range of cells as a table
pub fn format_range(sheet : @sheet.Sheet, row1 : Int, col1 : Int, row2 : Int, col2 : Int) -> String {
  let mut result = ""
  for r = row1; r <= row2; r = r + 1 {
    let mut row_str = ""
    for c = col1; c <= col2; c = c + 1 {
      if c > col1 {
        row_str = row_str + " | "
      }
      let val = sheet.get_value(r, c)
      let s = auto_format(val)
      let mut padded = s
      while padded.length() < 12 {
        padded = padded + " "
      }
      row_str = row_str + padded
    }
    result = result + row_str + "\n"
  }
  result
}
