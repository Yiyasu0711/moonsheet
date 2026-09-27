// MoonSheet Error Types
// Spreadsheet-specific error values compatible with Excel/LibreOffice conventions

/// Spreadsheet error value type
pub enum ErrorValue {
  // #DIV/0! - Division by zero
  DivZero
  // #N/A - Value not available
  NotAvailable
  // #NAME? - Unrecognized name or function
  NameError
  // #NULL! - Intersection of ranges is empty
  NullError
  // #NUM! - Invalid numeric argument or result
  NumError
  // #REF! - Invalid cell reference
  RefError
  // #VALUE! - Wrong type of argument
  ValueError
  // #CIRC! - Circular reference detected
  CircularRef
  // #ERROR! - Generic calculation error with message
  GenericError(String)
} derive(Show, Eq, Compare)

/// Convert error value to its string representation
pub fn ErrorValue::to_error_string(self : ErrorValue) -> String {
  match self {
    DivZero => "#DIV/0!"
    NotAvailable => "#N/A"
    NameError => "#NAME?"
    NullError => "#NULL!"
    NumError => "#NUM!"
    RefError => "#REF!"
    ValueError => "#VALUE!"
    CircularRef => "#CIRC!"
    GenericError(msg) => "#ERROR!: " + msg
  }
}

/// Get a human-readable description of the error
pub fn ErrorValue::description(self : ErrorValue) -> String {
  match self {
    DivZero => "Division by zero"
    NotAvailable => "Value not available"
    NameError => "Unrecognized name or function"
    NullError => "Intersection of ranges is empty"
    NumError => "Invalid numeric argument or result"
    RefError => "Invalid cell reference"
    ValueError => "Wrong type of argument"
    CircularRef => "Circular reference detected"
    GenericError(msg) => "Calculation error: " + msg
  }
}

/// Check if two errors are the same type
pub fn ErrorValue::is_same_type(self : ErrorValue, other : ErrorValue) -> Bool {
  match (self, other) {
    (DivZero, DivZero) => true
    (NotAvailable, NotAvailable) => true
    (NameError, NameError) => true
    (NullError, NullError) => true
    (NumError, NumError) => true
    (RefError, RefError) => true
    (ValueError, ValueError) => true
    (CircularRef, CircularRef) => true
    (GenericError(_), GenericError(_)) => true
    _ => false
  }
}

/// Create a DivZero error
pub fn ErrorValue::div_zero() -> ErrorValue { DivZero }

/// Create a NotAvailable error
pub fn ErrorValue::not_available() -> ErrorValue { NotAvailable }

/// Create a NameError
pub fn ErrorValue::name_error() -> ErrorValue { NameError }

/// Create a NullError
pub fn ErrorValue::null_error() -> ErrorValue { NullError }

/// Create a NumError
pub fn ErrorValue::num_error() -> ErrorValue { NumError }

/// Create a RefError
pub fn ErrorValue::ref_error() -> ErrorValue { RefError }

/// Create a ValueError
pub fn ErrorValue::value_error() -> ErrorValue { ValueError }

/// Create a CircularRef error
pub fn ErrorValue::circular_ref() -> ErrorValue { CircularRef }

/// Create a generic error with a message
pub fn ErrorValue::generic_error(msg : String) -> ErrorValue { GenericError(msg) }

/// Parse an error string back to an ErrorValue
pub fn ErrorValue::from_string(s : String) -> ErrorValue {
  match s {
    "#DIV/0!" => DivZero
    "#N/A" => NotAvailable
    "#NAME?" => NameError
    "#NULL!" => NullError
    "#NUM!" => NumError
    "#REF!" => RefError
    "#VALUE!" => ValueError
    "#CIRC!" => CircularRef
    _ => {
      if s.startsWith("#ERROR!: ") {
        GenericError(s.substring(start=8))
      } else {
        GenericError(s)
      }
    }
  }
}

/// Check if error is DivZero
pub fn ErrorValue::is_div_zero(self : ErrorValue) -> Bool {
  match self { DivZero => true; _ => false }
}

/// Check if error is NotAvailable
pub fn ErrorValue::is_not_available(self : ErrorValue) -> Bool {
  match self { NotAvailable => true; _ => false }
}

/// Check if error is NameError
pub fn ErrorValue::is_name_error(self : ErrorValue) -> Bool {
  match self { NameError => true; _ => false }
}

/// Check if error is NumError
pub fn ErrorValue::is_num_error(self : ErrorValue) -> Bool {
  match self { NumError => true; _ => false }
}

/// Check if error is RefError
pub fn ErrorValue::is_ref_error(self : ErrorValue) -> Bool {
  match self { RefError => true; _ => false }
}

/// Check if error is ValueError
pub fn ErrorValue::is_value_error(self : ErrorValue) -> Bool {
  match self { ValueError => true; _ => false }
}

/// Check if error is CircularRef
pub fn ErrorValue::is_circular_ref(self : ErrorValue) -> Bool {
  match self { CircularRef => true; _ => false }
}

/// Check if error is GenericError
pub fn ErrorValue::is_generic_error(self : ErrorValue) -> Bool {
  match self { GenericError(_) => true; _ => false }
}

/// Get the error code number for ERROR.TYPE function
pub fn ErrorValue::error_type(self : ErrorValue) -> Int {
  match self {
    NullError => 1
    DivZero => 2
    ValueError => 3
    RefError => 4
    NameError => 5
    NumError => 6
    NotAvailable => 7
    CircularRef => 8
    GenericError(_) => 9
  }
}
