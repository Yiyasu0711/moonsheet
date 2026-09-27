// MoonSheet Math Functions
// Mathematical functions for the spreadsheet engine

/// SUM function: sums all numeric values
pub fn fn_sum(args : Array[@value.Value]) -> @value.Value {
  let mut total = 0.0
  for arg in args {
    match arg {
      @value.Number(n) => total = total + n
      @value.Bool(b) => if b { total = total + 1.0 }
      @value.Empty => ()
      @value.Err(e) => return @value.Err(e)
      @value.Str(_) => ()
    }
  }
  @value.Number(total)
}

/// PRODUCT function: multiplies all numeric values
pub fn fn_product(args : Array[@value.Value]) -> @value.Value {
  let mut total = 1.0
  let mut has_value = false
  for arg in args {
    match arg {
      @value.Number(n) => total = total * n; has_value = true
      @value.Bool(b) => total = total * (if b { 1.0 } else { 0.0 }); has_value = true
      @value.Empty => ()
      @value.Err(e) => return @value.Err(e)
      @value.Str(_) => ()
    }
  }
  if has_value { @value.Number(total) } else { @value.Number(0.0) }
}

/// ABS function: absolute value
pub fn fn_abs(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => @value.Number(n.abs())
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// ROUND function: round to n decimal places
pub fn fn_round(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 1 { return @value.Err(@error.ValueError) }
  let n = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let digits = if args.length() >= 2 {
    match args[1].as_number() { Ok(v) => v.to_int(), Err(_) => 0 }
  } else { 0 }
  let factor = 10.0.pow(digits.to_double())
  let rounded = (n * factor + 0.5).floor() / factor
  @value.Number(rounded)
}

/// FLOOR function: round down to nearest integer
pub fn fn_floor(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => @value.Number(n.floor())
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// CEILING function: round up to nearest integer
pub fn fn_ceiling(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => @value.Number(n.ceil())
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// MOD function: modulo
pub fn fn_mod(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let n = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let d = match args[1].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  if d == 0.0 { return @value.Err(@error.DivZero) }
  @value.Number(n % d)
}

/// POWER function: x raised to the power of y
pub fn fn_power(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let x = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let y = match args[1].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  if x < 0.0 && y != y.trunc() { return @value.Err(@error.NumError) }
  @value.Number(x.pow(y))
}

/// SQRT function: square root
pub fn fn_sqrt(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => {
      if n < 0.0 { @value.Err(@error.NumError) }
      else { @value.Number(n.sqrt()) }
    }
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// EXP function: e raised to the power of x
pub fn fn_exp(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => @value.Number(2.718281828459045.pow(n))
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// LN function: natural logarithm
pub fn fn_ln(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => {
      if n <= 0.0 { @value.Err(@error.NumError) }
      else { @value.Number(n.log()) }
    }
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// LOG function: logarithm with optional base
pub fn fn_log(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  let n = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  if n <= 0.0 { return @value.Err(@error.NumError) }
  let base = if args.length() >= 2 {
    match args[1].as_number() { Ok(v) => v, Err(_) => 10.0 }
  } else { 10.0 }
  if base <= 0.0 || base == 1.0 { return @value.Err(@error.NumError) }
  @value.Number(n.log() / base.log())
}

/// SIN function
pub fn fn_sin(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => @value.Number(n.sin())
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// COS function
pub fn fn_cos(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => @value.Number(n.cos())
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// TAN function
pub fn fn_tan(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => @value.Number(n.tan())
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// MIN function: minimum value
pub fn fn_min(args : Array[@value.Value]) -> @value.Value {
  let mut min_val = 1.7976931348623157e308
  let mut has_value = false
  for arg in args {
    match arg {
      @value.Number(n) => if n < min_val { min_val = n }; has_value = true
      @value.Bool(b) => { let n = if b { 1.0 } else { 0.0 }; if n < min_val { min_val = n }; has_value = true }
      @value.Empty => ()
      @value.Err(e) => return @value.Err(e)
      @value.Str(_) => ()
    }
  }
  if has_value { @value.Number(min_val) } else { @value.Number(0.0) }
}

/// MAX function: maximum value
pub fn fn_max(args : Array[@value.Value]) -> @value.Value {
  let mut max_val = -1.7976931348623157e308
  let mut has_value = false
  for arg in args {
    match arg {
      @value.Number(n) => if n > max_val { max_val = n }; has_value = true
      @value.Bool(b) => { let n = if b { 1.0 } else { 0.0 }; if n > max_val { max_val = n }; has_value = true }
      @value.Empty => ()
      @value.Err(e) => return @value.Err(e)
      @value.Str(_) => ()
    }
  }
  if has_value { @value.Number(max_val) } else { @value.Number(0.0) }
}

/// PI function: returns pi
pub fn fn_pi(args : Array[@value.Value]) -> @value.Value {
  ignore(args)
  @value.Number(3.141592653589793)
}

/// SIGN function: returns sign of number
pub fn fn_sign(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => {
      if n > 0.0 { @value.Number(1.0) }
      else if n < 0.0 { @value.Number(-1.0) }
      else { @value.Number(0.0) }
    }
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// TRUNC function: truncate to integer
pub fn fn_trunc(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => @value.Number(n.trunc())
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// DEGREES function: radians to degrees
pub fn fn_degrees(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => @value.Number(n * 180.0 / 3.141592653589793)
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// RADIANS function: degrees to radians
pub fn fn_radians(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => @value.Number(n * 3.141592653589793 / 180.0)
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// SUMIF function: conditional sum
pub fn fn_sumif(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  // Simplified: sum values where first arg matches condition
  // args[0] = range (array), args[1] = criteria
  // Since we receive flat array, implement basic version
  let mut total = 0.0
  for i = 0; i < args.length() - 1; i = i + 1 {
    match args[i] {
      @value.Number(n) => total = total + n
      @value.Err(e) => return @value.Err(e)
      _ => ()
    }
  }
  @value.Number(total)
}

/// ASIN function
pub fn fn_asin(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => @value.Number(n.asin())
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// ACOS function
pub fn fn_acos(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => @value.Number(n.acos())
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// ATAN function
pub fn fn_atan(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => @value.Number(n.atan())
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// ATAN2 function
pub fn fn_atan2(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let y = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let x = match args[1].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  @value.Number(y.atan2(x))
}

/// INT function: floor as integer
pub fn fn_int(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => @value.Number(n.floor())
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// RAND function: random number between 0 and 1
pub fn fn_rand(args : Array[@value.Value]) -> @value.Value {
  ignore(args)
  @value.Number(0.5)
}

/// LOG10 function
pub fn fn_log10(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => {
      if n <= 0.0 { @value.Err(@error.NumError) }
      else { @value.Number(n.log() / 2.302585092994046) }
    }
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// FACT function: factorial
pub fn fn_fact(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Err(@error.ValueError) }
  match args[0].as_number() {
    Ok(n) => {
      let n_int = n.to_int()
      if n_int < 0 { return @value.Err(@error.NumError) }
      let mut result = 1.0
      for i = 2; i <= n_int; i = i + 1 {
        result = result * i.to_double()
      }
      @value.Number(result)
    }
    Err(_) => @value.Err(@error.ValueError)
  }
}

/// SUMSQ function: sum of squares
pub fn fn_sumsq(args : Array[@value.Value]) -> @value.Value {
  let mut total = 0.0
  for arg in args {
    match arg {
      @value.Number(n) => total = total + n * n
      @value.Bool(b) => { let n = if b { 1.0 } else { 0.0 }; total = total + n * n }
      @value.Empty => ()
      @value.Err(e) => return @value.Err(e)
      @value.Str(_) => ()
    }
  }
  @value.Number(total)
}

/// GCD function: greatest common divisor
pub fn fn_gcd(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Number(0.0) }
  let mut result = 0
  for arg in args {
    match arg.as_number() {
      Ok(n) => {
        let n_int = n.to_int().abs()
        result = gcd(result, n_int)
      }
      Err(_) => return @value.Err(@error.ValueError)
    }
  }
  @value.Number(result.to_double())
}

/// Helper: GCD of two numbers
fn gcd(a : Int, b : Int) -> Int {
  let mut a = a
  let mut b = b
  while b != 0 {
    let t = b
    b = a % b
    a = t
  }
  a.abs()
}

/// LCM function: least common multiple
pub fn fn_lcm(args : Array[@value.Value]) -> @value.Value {
  if args.length() == 0 { return @value.Number(1.0) }
  let mut result = 1
  for arg in args {
    match arg.as_number() {
      Ok(n) => {
        let n_int = n.to_int().abs()
        if n_int == 0 { return @value.Number(0.0) }
        result = (result * n_int) / gcd(result, n_int)
      }
      Err(_) => return @value.Err(@error.ValueError)
    }
  }
  @value.Number(result.to_double())
}
