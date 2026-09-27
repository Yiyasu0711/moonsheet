// MoonSheet Data Validation
// Data validation rules for cells

/// Validation type
pub enum ValidationType {
  Any
  WholeNumber
  Decimal
  List
  Date
  Time
  TextLength
  Custom
} derive(Show, Eq)

/// Validation operator
pub enum ValidationOperator {
  Between
  NotBetween
  Equal
  NotEqual
  GreaterThan
  LessThan
  GreaterThanOrEqual
  LessThanOrEqual
} derive(Show, Eq)

/// Validation error style
pub enum ValidationErrorStyle {
  Stop
  Warning
  Information
} derive(Show, Eq)

/// A data validation rule
pub struct DataValidation {
  pub val_type : ValidationType
  pub operator : ValidationOperator
  pub formula1 : String
  pub formula2 : String
  pub value1 : @value.Value
  pub value2 : @value.Value
  pub list_values : Array[String]
  pub allow_blank : Bool
  pub in_cell_dropdown : Bool
  pub show_input_message : Bool
  pub show_error_message : Bool
  pub error_style : ValidationErrorStyle
  pub input_title : String
  pub input_message : String
  pub error_title : String
  pub error_message : String
} derive(Show)

/// Create a default data validation
pub fn DataValidation::new(val_type : ValidationType) -> DataValidation {
  DataValidation {
    val_type,
    operator: Between,
    formula1: "",
    formula2: "",
    value1: @value.Empty,
    value2: @value.Empty,
    list_values: [],
    allow_blank: true,
    in_cell_dropdown: true,
    show_input_message: false,
    show_error_message: true,
    error_style: Stop,
    input_title: "",
    input_message: "",
    error_title: "",
    error_message: "",
  }
}

/// Create a whole number validation
pub fn DataValidation::whole_number(operator : ValidationOperator, min : Int, max : Int) -> DataValidation {
  let dv = DataValidation::new(WholeNumber)
  { ..dv, operator, value1: @value.Number(min.to_double()), value2: @value.Number(max.to_double()) }
}

/// Create a decimal validation
pub fn DataValidation::decimal(operator : ValidationOperator, min : Double, max : Double) -> DataValidation {
  let dv = DataValidation::new(Decimal)
  { ..dv, operator, value1: @value.Number(min), value2: @value.Number(max) }
}

/// Create a list validation
pub fn DataValidation::list(values : Array[String]) -> DataValidation {
  let dv = DataValidation::new(List)
  { ..dv, list_values: values, in_cell_dropdown: true }
}

/// Create a date validation
pub fn DataValidation::date(operator : ValidationOperator, start : Int, end : Int) -> DataValidation {
  let dv = DataValidation::new(Date)
  { ..dv, operator, value1: @value.Number(start.to_double()), value2: @value.Number(end.to_double()) }
}

/// Create a text length validation
pub fn DataValidation::text_length(operator : ValidationOperator, min : Int, max : Int) -> DataValidation {
  let dv = DataValidation::new(TextLength)
  { ..dv, operator, value1: @value.Number(min.to_double()), value2: @value.Number(max.to_double()) }
}

/// Create a custom validation
pub fn DataValidation::custom(formula : String) -> DataValidation {
  let dv = DataValidation::new(Custom)
  { ..dv, formula1: formula }
}

/// Validate a value against the rule
pub fn DataValidation::validate(self : DataValidation, value : @value.Value) -> Bool {
  if self.allow_blank && value.is_empty() {
    return true
  }

  match self.val_type {
    Any => true
    WholeNumber => validate_whole_number(self, value)
    Decimal => validate_decimal(self, value)
    List => validate_list(self, value)
    Date => validate_date(self, value)
    Time => validate_time(self, value)
    TextLength => validate_text_length(self, value)
    Custom => true  // Simplified: would need formula evaluation
  }
}

/// Validate whole number
fn validate_whole_number(dv : DataValidation, value : @value.Value) -> Bool {
  match value.as_number() {
    Ok(n) => {
      if n != n.trunc() { return false }
      compare_with_operator(dv.operator, n, dv.value1, dv.value2)
    }
    Err(_) => false
  }
}

/// Validate decimal
fn validate_decimal(dv : DataValidation, value : @value.Value) -> Bool {
  match value.as_number() {
    Ok(n) => compare_with_operator(dv.operator, n, dv.value1, dv.value2)
    Err(_) => false
  }
}

/// Validate list
fn validate_list(dv : DataValidation, value : @value.Value) -> Bool {
  let s = value.to_display_string()
  for item in dv.list_values {
    if item == s {
      return true
    }
  }
  false
}

/// Validate date
fn validate_date(dv : DataValidation, value : @value.Value) -> Bool {
  match value.as_number() {
    Ok(n) => compare_with_operator(dv.operator, n, dv.value1, dv.value2)
    Err(_) => false
  }
}

/// Validate time
fn validate_time(dv : DataValidation, value : @value.Value) -> Bool {
  match value.as_number() {
    Ok(n) => {
      let frac = n - n.trunc()
      compare_with_operator(dv.operator, frac, dv.value1, dv.value2)
    }
    Err(_) => false
  }
}

/// Validate text length
fn validate_text_length(dv : DataValidation, value : @value.Value) -> Bool {
  match value.as_string() {
    Ok(s) => {
      let len = s.length().to_double()
      compare_with_operator(dv.operator, len, dv.value1, dv.value2)
    }
    Err(_) => false
  }
}

/// Compare value with operator
fn compare_with_operator(op : ValidationOperator, value : Double, v1 : @value.Value, v2 : @value.Value) -> Bool {
  let n1 = match v1.as_number() { Ok(v) => v, Err(_) => 0.0 }
  let n2 = match v2.as_number() { Ok(v) => v, Err(_) => 0.0 }
  match op {
    Between => value >= n1 && value <= n2
    NotBetween => value < n1 || value > n2
    Equal => value == n1
    NotEqual => value != n1
    GreaterThan => value > n1
    LessThan => value < n1
    GreaterThanOrEqual => value >= n1
    LessThanOrEqual => value <= n1
  }
}

/// Set input message
pub fn DataValidation::with_input_message(self : DataValidation, title : String, message : String) -> DataValidation {
  { ..self, show_input_message: true, input_title: title, input_message: message }
}

/// Set error message
pub fn DataValidation::with_error_message(self : DataValidation, title : String, message : String, style : ValidationErrorStyle) -> DataValidation {
  { ..self, show_error_message: true, error_title: title, error_message: message, error_style: style }
}

/// Set allow blank
pub fn DataValidation::with_allow_blank(self : DataValidation, allow : Bool) -> DataValidation {
  { ..self, allow_blank: allow }
}

/// Set in-cell dropdown
pub fn DataValidation::with_dropdown(self : DataValidation, show : Bool) -> DataValidation {
  { ..self, in_cell_dropdown: show }
}

/// Check if validation type is list
pub fn DataValidation::is_list(self : DataValidation) -> Bool {
  match self.val_type {
    List => true
    _ => false
  }
}

/// Get list options
pub fn DataValidation::get_list_options(self : DataValidation) -> Array[String] {
  self.list_values
}

/// Get validation type name
pub fn ValidationType::to_string(self : ValidationType) -> String {
  match self {
    Any => "any"
    WholeNumber => "wholeNumber"
    Decimal => "decimal"
    List => "list"
    Date => "date"
    Time => "time"
    TextLength => "textLength"
    Custom => "custom"
  }
}

/// Get operator name
pub fn ValidationOperator::to_string(self : ValidationOperator) -> String {
  match self {
    Between => "between"
    NotBetween => "notBetween"
    Equal => "equal"
    NotEqual => "notEqual"
    GreaterThan => "greaterThan"
    LessThan => "lessThan"
    GreaterThanOrEqual => "greaterThanOrEqual"
    LessThanOrEqual => "lessThanOrEqual"
  }
}

/// Data validation collection for a sheet
pub struct DataValidations {
  pub validations : Map[(Int, Int), DataValidation]
} derive(Show)

/// Create new validations collection
pub fn DataValidations::new() -> DataValidations {
  DataValidations { validations: {} }
}

/// Add validation for a cell
pub fn DataValidations::add(self : DataValidations, row : Int, col : Int, dv : DataValidation) -> DataValidations {
  let mut new_validations = self.validations
  new_validations[(row, col)] = dv
  DataValidations { validations: new_validations }
}

/// Get validation for a cell
pub fn DataValidations::get(self : DataValidations, row : Int, col : Int) -> DataValidation? {
  match self.validations.get((row, col)) {
    Some(dv) => Some(dv)
    None => None
  }
}

/// Check if cell has validation
pub fn DataValidations::has(self : DataValidations, row : Int, col : Int) -> Bool {
  self.validations.contains((row, col))
}

/// Remove validation for a cell
pub fn DataValidations::remove(self : DataValidations, row : Int, col : Int) -> DataValidations {
  let mut new_validations = self.validations
  new_validations.remove((row, col))
  DataValidations { validations: new_validations }
}

/// Count validations
pub fn DataValidations::count(self : DataValidations) -> Int {
  let mut count = 0
  for _ in self.validations {
    count = count + 1
  }
  count
}

/// Validate value at cell position
pub fn DataValidations::validate_cell(self : DataValidations, row : Int, col : Int, value : @value.Value) -> Bool {
  match self.validations.get((row, col)) {
    Some(dv) => dv.validate(value)
    None => true
  }
}
