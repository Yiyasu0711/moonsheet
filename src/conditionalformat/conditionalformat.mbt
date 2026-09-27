// MoonSheet Conditional Formatting
// Conditional formatting rules for cells

/// Rule type for conditional formatting
pub enum ConditionalFormatRuleType {
  CellIsRule
  FormulaRule
  ColorScaleRule
  DataBarRule
  IconSetRule
  Top10Rule
  AboveAverageRule
  DuplicateRule
  UniqueRule
  BlanksRule
  NoBlanksRule
  ErrorsRule
  NoErrorsRule
} derive(Show, Eq)

/// Operator for cell value rules
pub enum ConditionalFormatOperator {
  Equal
  NotEqual
  GreaterThan
  LessThan
  GreaterThanOrEqual
  LessThanOrEqual
  Between
  NotBetween
  ContainsText
  NotContainsText
  BeginsWith
  EndsWith
} derive(Show, Eq)

/// Format to apply when condition is met
pub struct ConditionalFormatStyle {
  pub bold : Bool
  pub italic : Bool
  pub underline : Bool
  pub font_color : String
  pub fill_color : String
  pub border_color : String
  pub font_size : Double
} derive(Show)

/// A conditional formatting rule
pub struct ConditionalFormatRule {
  pub rule_type : ConditionalFormatRuleType
  pub operator : ConditionalFormatOperator
  pub formula : String
  pub values : Array[@value.Value]
  pub style : ConditionalFormatStyle
  pub priority : Int
  pub stop_if_true : Bool
} derive(Show)

/// Conditional formatting for a range
pub struct ConditionalFormat {
  pub start_row : Int
  pub start_col : Int
  pub end_row : Int
  pub end_col : Int
  pub rules : Array[ConditionalFormatRule]
} derive(Show)

/// Create a default style
pub fn ConditionalFormatStyle::default() -> ConditionalFormatStyle {
  ConditionalFormatStyle {
    bold: false,
    italic: false,
    underline: false,
    font_color: "",
    fill_color: "",
    border_color: "",
    font_size: 0.0,
  }
}

/// Create a cell value rule
pub fn ConditionalFormatRule::cell_is(operator : ConditionalFormatOperator, values : Array[@value.Value], style : ConditionalFormatStyle) -> ConditionalFormatRule {
  ConditionalFormatRule {
    rule_type: CellIsRule,
    operator,
    formula: "",
    values,
    style,
    priority: 1,
    stop_if_true: false,
  }
}

/// Create a formula rule
pub fn ConditionalFormatRule::formula_rule(formula : String, style : ConditionalFormatStyle) -> ConditionalFormatRule {
  ConditionalFormatRule {
    rule_type: FormulaRule,
    operator: Equal,
    formula,
    values: [],
    style,
    priority: 1,
    stop_if_true: false,
  }
}

/// Create a color scale rule
pub fn ConditionalFormatRule::color_scale(min_color : String, max_color : String) -> ConditionalFormatRule {
  ConditionalFormatRule {
    rule_type: ColorScaleRule,
    operator: Equal,
    formula: "",
    values: [@value.Str(min_color), @value.Str(max_color)],
    style: ConditionalFormatStyle::default(),
    priority: 1,
    stop_if_true: false,
  }
}

/// Create a top 10 rule
pub fn ConditionalFormatRule::top10(percent : Bool, top : Bool, rank : Int, style : ConditionalFormatStyle) -> ConditionalFormatRule {
  ConditionalFormatRule {
    rule_type: Top10Rule,
    operator: if top { GreaterThan } else { LessThan },
    formula: "",
    values: [@value.Number(rank.to_double()), @value.Bool(percent), @value.Bool(top)],
    style,
    priority: 1,
    stop_if_true: false,
  }
}

/// Create an above/below average rule
pub fn ConditionalFormatRule::above_average(above : Bool, style : ConditionalFormatStyle) -> ConditionalFormatRule {
  ConditionalFormatRule {
    rule_type: AboveAverageRule,
    operator: if above { GreaterThan } else { LessThan },
    formula: "",
    values: [@value.Bool(above)],
    style,
    priority: 1,
    stop_if_true: false,
  }
}

/// Create a duplicate values rule
pub fn ConditionalFormatRule::duplicates(style : ConditionalFormatStyle) -> ConditionalFormatRule {
  ConditionalFormatRule {
    rule_type: DuplicateRule,
    operator: Equal,
    formula: "",
    values: [],
    style,
    priority: 1,
    stop_if_true: false,
  }
}

/// Create a unique values rule
pub fn ConditionalFormatRule::unique(style : ConditionalFormatStyle) -> ConditionalFormatRule {
  ConditionalFormatRule {
    rule_type: UniqueRule,
    operator: Equal,
    formula: "",
    values: [],
    style,
    priority: 1,
    stop_if_true: false,
  }
}

/// Create a blanks rule
pub fn ConditionalFormatRule::blanks(style : ConditionalFormatStyle) -> ConditionalFormatRule {
  ConditionalFormatRule {
    rule_type: BlanksRule,
    operator: Equal,
    formula: "",
    values: [],
    style,
    priority: 1,
    stop_if_true: false,
  }
}

/// Check if a cell value satisfies a conditional format rule
pub fn rule_matches(rule : ConditionalFormatRule, value : @value.Value, all_values : Array[@value.Value]) -> Bool {
  match rule.rule_type {
    CellIsRule => check_cell_is_rule(rule, value)
    FormulaRule => true  // Simplified: formula rules need evaluation context
    ColorScaleRule => true
    DataBarRule => true
    IconSetRule => true
    Top10Rule => check_top10_rule(rule, value, all_values)
    AboveAverageRule => check_above_average_rule(rule, value, all_values)
    DuplicateRule => check_duplicate_rule(value, all_values)
    UniqueRule => not(check_duplicate_rule(value, all_values))
    BlanksRule => value.is_empty()
    NoBlanksRule => not(value.is_empty())
    ErrorsRule => value.is_error()
    NoErrorsRule => not(value.is_error())
  }
}

/// Check cell value rule
fn check_cell_is_rule(rule : ConditionalFormatRule, value : @value.Value) -> Bool {
  if rule.values.length() == 0 { return false }
  let cmp = @value.Value::compare_values(value, rule.values[0])
  match rule.operator {
    Equal => cmp == 0
    NotEqual => cmp != 0
    GreaterThan => cmp > 0
    LessThan => cmp < 0
    GreaterThanOrEqual => cmp >= 0
    LessThanOrEqual => cmp <= 0
    Between => {
      if rule.values.length() < 2 { false }
      else {
        let cmp1 = @value.Value::compare_values(value, rule.values[0])
        let cmp2 = @value.Value::compare_values(value, rule.values[1])
        cmp1 >= 0 && cmp2 <= 0
      }
    }
    NotBetween => {
      if rule.values.length() < 2 { false }
      else {
        let cmp1 = @value.Value::compare_values(value, rule.values[0])
        let cmp2 = @value.Value::compare_values(value, rule.values[1])
        cmp1 < 0 || cmp2 > 0
      }
    }
    ContainsText => {
      match (value.as_string(), rule.values[0].as_string()) {
        (Ok(v), Ok(t)) => v.contains(t)
        _ => false
      }
    }
    NotContainsText => {
      match (value.as_string(), rule.values[0].as_string()) {
        (Ok(v), Ok(t)) => not(v.contains(t))
        _ => true
      }
    }
    BeginsWith => {
      match (value.as_string(), rule.values[0].as_string()) {
        (Ok(v), Ok(t)) => v.starts_with(t)
        _ => false
      }
    }
    EndsWith => {
      match (value.as_string(), rule.values[0].as_string()) {
        (Ok(v), Ok(t)) => v.ends_with(t)
        _ => false
      }
    }
  }
}

/// Check top 10 rule
fn check_top10_rule(rule : ConditionalFormatRule, value : @value.Value, all_values : Array[@value.Value]) -> Bool {
  if rule.values.length() < 1 { return false }
  let rank = match rule.values[0].as_number() { Ok(v) => v.to_int(), Err(_) => 10 }
  let top = if rule.values.length() >= 3 {
    match rule.values[2].as_bool() { Ok(v) => v, Err(_) => true }
  } else { true }

  let mut nums = []
  for v in all_values {
    match v {
      @value.Number(n) => nums.push(n)
      _ => ()
    }
  }
  nums.sort()
  if top {
    nums.reverse()
  }
  let threshold = if rank > nums.length() { nums.length() } else { rank }
  if threshold == 0 { return false }
  let threshold_val = nums[threshold - 1]
  match value.as_number() {
    Ok(n) => {
      if top { n >= threshold_val } else { n <= threshold_val }
    }
    Err(_) => false
  }
}

/// Check above/below average rule
fn check_above_average_rule(rule : ConditionalFormatRule, value : @value.Value, all_values : Array[@value.Value]) -> Bool {
  if rule.values.length() == 0 { return false }
  let above = match rule.values[0].as_bool() { Ok(v) => v, Err(_) => true }
  let mut total = 0.0
  let mut count = 0
  for v in all_values {
    match v {
      @value.Number(n) => total = total + n; count = count + 1
      _ => ()
    }
  }
  if count == 0 { return false }
  let avg = total / count.to_double()
  match value.as_number() {
    Ok(n) => if above { n > avg } else { n < avg }
    Err(_) => false
  }
}

/// Check duplicate values rule
fn check_duplicate_rule(value : @value.Value, all_values : Array[@value.Value]) -> Bool {
  let mut count = 0
  for v in all_values {
    if @value.Value::equals(v, value) {
      count = count + 1
    }
  }
  count > 1
}

/// Get all rules that match a cell value
pub fn get_matching_rules(rules : Array[ConditionalFormatRule], value : @value.Value, all_values : Array[@value.Value]) -> Array[ConditionalFormatRule] {
  let mut matching = []
  for rule in rules {
    if rule_matches(rule, value, all_values) {
      matching.push(rule)
    }
  }
  matching
}

/// Create a new conditional format for a range
pub fn ConditionalFormat::new(start_row : Int, start_col : Int, end_row : Int, end_col : Int) -> ConditionalFormat {
  ConditionalFormat { start_row, start_col, end_row, end_col, rules: [] }
}

/// Add a rule to conditional format
pub fn ConditionalFormat::add_rule(self : ConditionalFormat, rule : ConditionalFormatRule) -> ConditionalFormat {
  let mut new_rules = self.rules
  new_rules.push(rule)
  // Sort by priority
  { ..self, rules: new_rules }
}

/// Check if a cell is in the range
pub fn ConditionalFormat::contains(self : ConditionalFormat, row : Int, col : Int) -> Bool {
  row >= self.start_row && row <= self.end_row && col >= self.start_col && col <= self.end_col
}

/// Get rule count
pub fn ConditionalFormat::rule_count(self : ConditionalFormat) -> Int {
  self.rules.length()
}
