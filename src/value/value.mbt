// MoonSheet Value Types
// Core value type representing data stored in spreadsheet cells

/// The primary value type for spreadsheet cell data
pub enum Value {
  // A numeric value (integers and decimals)
  Number(Double)
  // A text string
  Str(String)
  // A boolean value
  Bool(Bool)
  // An error value
  Err(@error.ErrorValue)
  // An empty/unset value
  Empty
} derive(Show, Eq, Compare)

/// Create a Number value from a Double
pub fn Value::number(n : Double) -> Value { Number(n) }

/// Create a Number value from an Int
pub fn Value::from_int(n : Int) -> Value { Number(n.to_double()) }

/// Create a String value
pub fn Value::str(s : String) -> Value { Str(s) }

/// Create a Bool value
pub fn Value::boolean(b : Bool) -> Value { Bool(b) }

/// Create an Empty value
pub fn Value::empty() -> Value { Empty }

/// Create an Error value
pub fn Value::error(e : @error.ErrorValue) -> Value { Err(e) }

/// Check if value is a Number
pub fn Value::is_number(self : Value) -> Bool {
  match self { Number(_) => true; _ => false }
}

/// Check if value is a String
pub fn Value::is_string(self : Value) -> Bool {
  match self { Str(_) => true; _ => false }
}

/// Check if value is a Bool
pub fn Value::is_bool(self : Value) -> Bool {
  match self { Bool(_) => true; _ => false }
}

/// Check if value is an Error
pub fn Value::is_error(self : Value) -> Bool {
  match self { Err(_) => true; _ => false }
}

/// Check if value is Empty
pub fn Value::is_empty(self : Value) -> Bool {
  match self { Empty => true; _ => false }
}

/// Try to extract a Double from a Value
pub fn Value::as_number(self : Value) -> Result[Double, String] {
  match self {
    Number(n) => Ok(n)
    Bool(true) => Ok(1.0)
    Bool(false) => Ok(0.0)
    Str(s) => {
      let s = s.trim()
      if s == "" {
        Ok(0.0)
      } else if s == "true" {
        Ok(1.0)
      } else if s == "false" {
        Ok(0.0)
      } else {
        match Double::from_string(s) {
          Some(n) => Ok(n)
          None => Err("Cannot convert string to number: " + s)
        }
      }
    }
    Empty => Ok(0.0)
    Err(e) => Err("Cannot convert error to number: " + e.to_error_string())
  }
}

/// Try to extract a String from a Value
pub fn Value::as_string(self : Value) -> Result[String, String] {
  match self {
    Str(s) => Ok(s)
    Number(n) => Ok(n.to_string())
    Bool(true) => Ok("TRUE")
    Bool(false) => Ok("FALSE")
    Empty => Ok("")
    Err(e) => Err("Cannot convert error to string: " + e.to_error_string())
  }
}

/// Try to extract a Bool from a Value
pub fn Value::as_bool(self : Value) -> Result[Bool, String] {
  match self {
    Bool(b) => Ok(b)
    Number(n) => Ok(n != 0.0)
    Str(s) => {
      let s = s.trim().to_lower()
      if s == "true" {
        Ok(true)
      } else if s == "false" {
        Ok(false)
      } else {
        Err("Cannot convert string to bool: " + s)
      }
    }
    Empty => Ok(false)
    Err(e) => Err("Cannot convert error to bool: " + e.to_error_string())
  }
}

/// Convert value to display string
pub fn Value::to_display_string(self : Value) -> String {
  match self {
    Str(s) => s
    Number(n) => {
      if n == n.trunc() && n.abs() < 1e15 {
        n.to_int().to_string()
      } else {
        n.to_string()
      }
    }
    Bool(true) => "TRUE"
    Bool(false) => "FALSE"
    Empty => ""
    Err(e) => e.to_error_string()
  }
}

/// Check if value is truthy (for IF conditions)
pub fn Value::truthy(self : Value) -> Bool {
  match self {
    Bool(b) => b
    Number(n) => n != 0.0
    Str(s) => {
      let s = s.trim().to_lower()
      s != "" && s != "false" && s != "0"
    }
    Empty => false
    Err(_) => false
  }
}

/// Compare two values for ordering
pub fn Value::compare_values(a : Value, b : Value) -> Int {
  match (a, b) {
    (Empty, Empty) => 0
    (Empty, _) => -1
    (_, Empty) => 1
    (Number(x), Number(y)) => {
      if x < y { -1 } else if x > y { 1 } else { 0 }
    }
    (Str(x), Str(y)) => {
      if x < y { -1 } else if x > y { 1 } else { 0 }
    }
    (Bool(x), Bool(y)) => {
      if x == y { 0 } else if x { 1 } else { -1 }
    }
    (Number(x), Bool(y)) => {
      let yv = if y { 1.0 } else { 0.0 }
      if x < yv { -1 } else if x > yv { 1 } else { 0 }
    }
    (Bool(x), Number(y)) => {
      let xv = if x { 1.0 } else { 0.0 }
      if xv < y { -1 } else if xv > y { 1 } else { 0 }
    }
    (Number(x), Str(_)) => -1
    (Str(_), Number(_)) => 1
    (Bool(_), Str(_)) => -1
    (Str(_), Bool(_)) => 1
    (Err(x), Err(y)) => x.compare(y)
    (Err(_), _) => 1
    (_, Err(_)) => -1
  }
}

/// Check if two values are equal
pub fn Value::equals(a : Value, b : Value) -> Bool {
  Value::compare_values(a, b) == 0
}

/// Add two values (for arithmetic)
pub fn Value::add(a : Value, b : Value) -> Value {
  match (a, b) {
    (Number(x), Number(y)) => Number(x + y)
    (Number(x), Bool(y)) => Number(x + (if y { 1.0 } else { 0.0 }))
    (Bool(x), Number(y)) => Number((if x { 1.0 } else { 0.0 }) + y)
    (Bool(x), Bool(y)) => Number((if x { 1.0 } else { 0.0 }) + (if y { 1.0 } else { 0.0 }))
    (Str(x), Str(y)) => Str(x + y)
    (Empty, x) => b
    (x, Empty) => a
    (Err(e), _) => Err(e)
    (_, Err(e)) => Err(e)
    _ => Err(@error.ValueError)
  }
}

/// Subtract two values
pub fn Value::subtract(a : Value, b : Value) -> Value {
  match (a, b) {
    (Number(x), Number(y)) => Number(x - y)
    (Number(x), Bool(y)) => Number(x - (if y { 1.0 } else { 0.0 }))
    (Bool(x), Number(y)) => Number((if x { 1.0 } else { 0.0 }) - y)
    (Bool(x), Bool(y)) => Number((if x { 1.0 } else { 0.0 }) - (if y { 1.0 } else { 0.0 }))
    (Empty, Number(y)) => Number(0.0 - y)
    (Number(x), Empty) => Number(x)
    (Empty, Empty) => Number(0.0)
    (Err(e), _) => Err(e)
    (_, Err(e)) => Err(e)
    _ => Err(@error.ValueError)
  }
}

/// Multiply two values
pub fn Value::multiply(a : Value, b : Value) -> Value {
  match (a, b) {
    (Number(x), Number(y)) => Number(x * y)
    (Number(x), Bool(y)) => Number(x * (if y { 1.0 } else { 0.0 }))
    (Bool(x), Number(y)) => Number((if x { 1.0 } else { 0.0 }) * y)
    (Bool(x), Bool(y)) => Number((if x { 1.0 } else { 0.0 }) * (if y { 1.0 } else { 0.0 }))
    (Empty, _) => Number(0.0)
    (_, Empty) => Number(0.0)
    (Err(e), _) => Err(e)
    (_, Err(e)) => Err(e)
    _ => Err(@error.ValueError)
  }
}

/// Divide two values
pub fn Value::divide(a : Value, b : Value) -> Value {
  match (a, b) {
    (Number(x), Number(y)) => {
      if y == 0.0 {
        Err(@error.DivZero)
      } else {
        Number(x / y)
      }
    }
    (Number(x), Bool(y)) => {
      if y {
        Number(x / 1.0)
      } else {
        Err(@error.DivZero)
      }
    }
    (Bool(x), Number(y)) => {
      if y == 0.0 {
        Err(@error.DivZero)
      } else {
        Number((if x { 1.0 } else { 0.0 }) / y)
      }
    }
    (Empty, _) => Err(@error.DivZero)
    (_, Empty) => Err(@error.DivZero)
    (Err(e), _) => Err(e)
    (_, Err(e)) => Err(e)
    _ => Err(@error.ValueError)
  }
}

/// Power operation
pub fn Value::power(a : Value, b : Value) -> Value {
  match (a, b) {
    (Number(x), Number(y)) => {
      if x < 0.0 && y != y.trunc() {
        Err(@error.NumError)
      } else {
        Number(x.pow(y))
      }
    }
    (Empty, _) => Number(0.0)
    (_, Empty) => Number(1.0)
    (Err(e), _) => Err(e)
    (_, Err(e)) => Err(e)
    _ => Err(@error.ValueError)
  }
}

/// Concatenate two values as strings
pub fn Value::concat(a : Value, b : Value) -> Value {
  let sa = a.to_display_string()
  let sb = b.to_display_string()
  Str(sa + sb)
}

/// Negate a value (unary minus)
pub fn Value::negate(self : Value) -> Value {
  match self {
    Number(n) => Number(-n)
    Bool(true) => Number(-1.0)
    Bool(false) => Number(0.0)
    Empty => Number(0.0)
    Err(e) => Err(e)
    _ => Err(@error.ValueError)
  }
}

/// Convert to percentage (multiply by 100)
pub fn Value::to_percent(self : Value) -> Value {
  match self {
    Number(n) => Number(n * 100.0)
    Bool(b) => Number(if b { 100.0 } else { 0.0 })
    Empty => Number(0.0)
    Err(e) => Err(e)
    _ => Err(@error.ValueError)
  }
}

/// Get type name string for TYPE function
pub fn Value::type_name(self : Value) -> String {
  match self {
    Number(_) => "Number"
    Str(_) => "String"
    Bool(_) => "Boolean"
    Err(_) => "Error"
    Empty => "Empty"
  }
}

/// Get type number for TYPE function
pub fn Value::type_number(self : Value) -> Int {
  match self {
    Number(_) => 1
    Str(_) => 2
    Bool(_) => 4
    Err(_) => 16
    Empty => 17
  }
}

/// Try to parse a string into a Value
pub fn Value::parse(s : String) -> Value {
  let s = s.trim()
  if s == "" {
    return Empty
  }
  if s == "TRUE" || s == "true" || s == "True" {
    return Bool(true)
  }
  if s == "FALSE" || s == "false" || s == "False" {
    return Bool(false)
  }
  if s.startsWith("#") {
    return Err(@error.ErrorValue::from_string(s))
  }
  match Double::from_string(s) {
    Some(n) => Number(n)
    None => Str(s)
  }
}
