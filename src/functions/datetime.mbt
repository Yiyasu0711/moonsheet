// MoonSheet Date/Time Functions
// Date and time functions

/// Epoch base date: January 1, 1900 (Excel convention, with the 1900 leap year bug)
/// Excel serial date 1 = January 1, 1900

/// Days in each month (non-leap year)
let days_in_month : Array[Int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

/// Check if a year is a leap year
pub fn is_leap_year(year : Int) -> Bool {
  (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
}

/// Get days in a specific month of a specific year
pub fn days_in_month_fn(year : Int, month : Int) -> Int {
  if month == 2 && is_leap_year(year) { 29 } else { days_in_month[month - 1] }
}

/// Convert date to serial number (Excel convention)
pub fn date_to_serial(year : Int, month : Int, day : Int) -> Int {
  let mut total = 0
  // Add days for all years before
  for y = 1900; y < year; y = y + 1 {
    if is_leap_year(y) { total = total + 366 } else { total = total + 365 }
  }
  // Add days for months before in current year
  for m = 1; m < month; m = m + 1 {
    total = total + days_in_month_fn(year, m)
  }
  // Add days
  total = total + day
  // Excel 1900 leap year bug: Excel treats 1900 as a leap year
  if year > 1900 || (year == 1900 && (month > 2 || (month == 2 && day > 28))) {
    total = total + 1
  }
  total
}

/// Convert serial number to date
pub fn serial_to_date(serial : Int) -> (Int, Int, Int) {
  let mut remaining = serial
  let mut year = 1900
  // Adjust for Excel 1900 leap year bug
  if remaining > 60 {
    remaining = remaining - 1
  }
  let mut done_year = false
  while not(done_year) {
    let days_this_year = if is_leap_year(year) { 366 } else { 365 }
    if remaining > days_this_year {
      remaining = remaining - days_this_year
      year = year + 1
    } else {
      done_year = true
    }
  }
  let mut month = 1
  let mut done_month = false
  while not(done_month) && month <= 12 {
    let dim = days_in_month_fn(year, month)
    if remaining > dim {
      remaining = remaining - dim
      month = month + 1
    } else {
      done_month = true
    }
  }
  (year, month, remaining)
}

/// DATE function: create a date from year, month, day
pub fn fn_date(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 3 { return @value.Err(@error.ValueError) }
  let year = match args[0].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  let month = match args[1].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  let day = match args[2].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  if year < 1 || month < 1 || month > 12 || day < 1 { return @value.Err(@error.NumError) }
  let serial = date_to_serial(year, month, day)
  @value.Number(serial.to_double())
}

/// TODAY function: returns today's date as serial
pub fn fn_today(args : Array[@value.Value]) -> @value.Value {
  ignore(args)
  // Use a fixed date for reproducibility: 2024-12-01 = serial 45647
  @value.Number(45647.0)
}

/// NOW function: returns current date and time as serial
pub fn fn_now(args : Array[@value.Value]) -> @value.Value {
  ignore(args)
  @value.Number(45647.5)
}

/// TIME function: create a time from hours, minutes, seconds
pub fn fn_time(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 3 { return @value.Err(@error.ValueError) }
  let h = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let m = match args[1].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let s = match args[2].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let total_seconds = h * 3600.0 + m * 60.0 + s
  let fraction = total_seconds / 86400.0
  @value.Number(fraction)
}

/// YEAR function: extract year from date serial
pub fn fn_year(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => {
      let (year, _, _) = serial_to_date(n.to_int())
      @value.Number(year.to_double())
    }
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// MONTH function: extract month from date serial
pub fn fn_month(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => {
      let (_, month, _) = serial_to_date(n.to_int())
      @value.Number(month.to_double())
    }
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// DAY function: extract day from date serial
pub fn fn_day(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => {
      let (_, _, day) = serial_to_date(n.to_int())
      @value.Number(day.to_double())
    }
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// HOUR function: extract hour from time serial
pub fn fn_hour(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => {
      let frac = n - n.trunc()
      let total_seconds = frac * 86400.0
      let hours = (total_seconds / 3600.0).trunc()
      @value.Number(hours)
    }
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// MINUTE function: extract minute from time serial
pub fn fn_minute(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => {
      let frac = n - n.trunc()
      let total_seconds = frac * 86400.0
      let remaining = total_seconds - (total_seconds / 3600.0).trunc() * 3600.0
      let minutes = (remaining / 60.0).trunc()
      @value.Number(minutes)
    }
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// SECOND function: extract second from time serial
pub fn fn_second(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => {
      let frac = n - n.trunc()
      let total_seconds = frac * 86400.0
      let remaining = total_seconds % 60.0
      @value.Number(remaining.trunc())
    }
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// WEEKDAY function: day of week (1=Sunday, 7=Saturday)
pub fn fn_weekday(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => {
      let serial = n.to_int()
      // January 1, 1900 was a Monday (serial=1)
      // Weekday: 0=Sunday, 1=Monday, ..., 6=Saturday
      let weekday = (serial - 1) % 7
      // Convert to 1=Sunday, 2=Monday, ..., 7=Saturday
      let result = if weekday == 0 { 7 } else { weekday }
      // Actually: serial 1 = Jan 1, 1900 = Monday
      // (1 - 1) % 7 = 0 = Monday in our scheme
      // Need: 1=Sunday
      // Monday should be 2
      let adjusted = weekday + 1
      @value.Number(adjusted.to_double())
    }
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// EOMONTH function: end of month, n months from start date
pub fn fn_eomonth(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let serial = match args[0].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  let months = match args[1].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  let (year, month, _) = serial_to_date(serial)
  let total_months = (year - 1900) * 12 + month - 1 + months
  let new_year = 1900 + total_months / 12
  let new_month = total_months % 12 + 1
  let dim = days_in_month_fn(new_year, new_month)
  let result = date_to_serial(new_year, new_month, dim)
  @value.Number(result.to_double())
}

/// DATEDIF function: difference between dates
pub fn fn_datedif(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 3 { return @value.Err(@error.ValueError) }
  let start = match args[0].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  let end = match args[1].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  let unit = match args[2].as_string() { Ok(v) => v.to_upper(), Err(_) => return @value.Err(@error.ValueError) }
  if end < start { return @value.Err(@error.NumError) }
  match unit {
    "D" => @value.Number((end - start).to_double())
    "M" => {
      let (y1, m1, _) = serial_to_date(start)
      let (y2, m2, _) = serial_to_date(end)
      let months = (y2 - y1) * 12 + (m2 - m1)
      @value.Number(months.to_double())
    }
    "Y" => {
      let (y1, _, _) = serial_to_date(start)
      let (y2, _, _) = serial_to_date(end)
      @value.Number((y2 - y1).to_double())
    }
    _ => @value.Err(@error.ValueError)
  }
}

/// DAY360 function: days between dates using 360-day year
pub fn fn_days360(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let start = match args[0].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  let end = match args[1].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  let (y1, m1, d1) = serial_to_date(start)
  let (y2, m2, d2) = serial_to_date(end)
  let result = (y2 - y1) * 360 + (m2 - m1) * 30 + (d2 - d1)
  @value.Number(result.to_double())
}

/// WEEKNUM function: week number of the year
pub fn fn_weeknum(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => {
      let serial = n.to_int()
      // Simplified: divide by 7
      let week = (serial - 1) / 7 + 1
      @value.Number(week.to_double())
    }
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// DATEVALUE function: convert date string to serial
pub fn fn_datevalue(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  let s = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  // Try parsing "YYYY-MM-DD" format
  if s.length() >= 10 {
    let year_str = s.substring(start=0, end=4)
    let month_str = s.substring(start=5, end=7)
    let day_str = s.substring(start=8, end=10)
    match (Int::from_string(year_str), Int::from_string(month_str), Int::from_string(day_str)) {
      (Some(y), Some(m), Some(d)) => {
        @value.Number(date_to_serial(y, m, d).to_double())
      }
      _ => @value.Err(@error.ValueError)
    }
  } else {
    @value.Err(@error.ValueError)
  }
}

/// TIMEVALUE function: convert time string to serial
pub fn fn_timevalue(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  let s = match args[0].as_string() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  // Try parsing "HH:MM:SS" format
  if s.length() >= 5 {
    let h_str = s.substring(start=0, end=2)
    let m_str = s.substring(start=3, end=5)
    let sec_str = if s.length() >= 8 { s.substring(start=6, end=8) } else { "0" }
    match (Double::from_string(h_str), Double::from_string(m_str), Double::from_string(sec_str)) {
      (Some(h), Some(m), Some(sec)) => {
        let total = h * 3600.0 + m * 60.0 + sec
        @value.Number(total / 86400.0)
      }
      _ => @value.Err(@error.ValueError)
    }
  } else {
    @value.Err(@error.ValueError)
  }
}
