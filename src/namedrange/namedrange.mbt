// MoonSheet Named Ranges
// Named range support for the spreadsheet engine

/// A named range definition
pub struct NamedRange {
  pub name : String
  pub sheet_name : String
  pub start_row : Int
  pub start_col : Int
  pub end_row : Int
  pub end_col : Int
  pub scope : NamedRangeScope
  pub comment : String
} derive(Show)

/// Scope of a named range
pub enum NamedRangeScope {
  Workbook
  Sheet(String)
} derive(Show, Eq)

/// Named range collection
pub struct NamedRanges {
  pub ranges : Map[String, NamedRange]
} derive(Show)

/// Create a new empty named ranges collection
pub fn NamedRanges::new() -> NamedRanges {
  NamedRanges { ranges: {} }
}

/// Add a named range
pub fn NamedRanges::add(self : NamedRanges, name : String, sheet_name : String, start_row : Int, start_col : Int, end_row : Int, end_col : Int) -> NamedRanges {
  let nr = NamedRange { name, sheet_name, start_row, start_col, end_row, end_col, scope: Workbook, comment: "" }
  let mut new_ranges = self.ranges
  new_ranges[name.to_upper()] = nr
  NamedRanges { ranges: new_ranges }
}

/// Add a named range with scope
pub fn NamedRanges::add_with_scope(self : NamedRanges, name : String, sheet_name : String, start_row : Int, start_col : Int, end_row : Int, end_col : Int, scope : NamedRangeScope) -> NamedRanges {
  let nr = NamedRange { name, sheet_name, start_row, start_col, end_row, end_col, scope, comment: "" }
  let mut new_ranges = self.ranges
  new_ranges[name.to_upper()] = nr
  NamedRanges { ranges: new_ranges }
}

/// Remove a named range
pub fn NamedRanges::remove(self : NamedRanges, name : String) -> NamedRanges {
  let mut new_ranges = self.ranges
  new_ranges.remove(name.to_upper())
  NamedRanges { ranges: new_ranges }
}

/// Get a named range by name
pub fn NamedRanges::get(self : NamedRanges, name : String) -> NamedRange? {
  match self.ranges.get(name.to_upper()) {
    Some(nr) => Some(nr)
    None => None
  }
}

/// Check if a named range exists
pub fn NamedRanges::has(self : NamedRanges, name : String) -> Bool {
  self.ranges.contains(name.to_upper())
}

/// Get all named range names
pub fn NamedRanges::names(self : NamedRanges) -> Array[String] {
  let mut result = []
  for item in self.ranges {
    let (name, _) = item
    result.push(name)
  }
  result.sort()
  result
}

/// Count named ranges
pub fn NamedRanges::count(self : NamedRanges) -> Int {
  let mut count = 0
  for _ in self.ranges {
    count = count + 1
  }
  count
}

/// Rename a named range
pub fn NamedRanges::rename(self : NamedRanges, old_name : String, new_name : String) -> NamedRanges {
  match self.ranges.get(old_name.to_upper()) {
    Some(nr) => {
      let new_nr = { ..nr, name: new_name }
      let mut new_ranges = self.ranges
      new_ranges.remove(old_name.to_upper())
      new_ranges[new_name.to_upper()] = new_nr
      NamedRanges { ranges: new_ranges }
    }
    None => self
  }
}

/// Get named ranges for a specific sheet
pub fn NamedRanges::for_sheet(self : NamedRanges, sheet_name : String) -> Array[NamedRange] {
  let mut result = []
  for item in self.ranges {
    let (_, nr) = item
    if nr.sheet_name == sheet_name {
      result.push(nr)
    }
  }
  result
}

/// Check if name is valid (follows spreadsheet naming conventions)
pub fn is_valid_name(name : String) -> Bool {
  if name.length() == 0 { return false }
  // Must start with letter or underscore
  let first = name[0]
  if not((first >= 65 && first <= 90) || (first >= 97 && first <= 122) || first == 95) {
    return false
  }
  // Can contain letters, numbers, underscores, periods
  for i = 0; i < name.length(); i = i + 1 {
    let ch = name[i]
    if not((ch >= 65 && ch <= 90) || (ch >= 97 && ch <= 122) || (ch >= 48 && ch <= 57) || ch == 95 || ch == 46) {
      return false
    }
  }
  // Must not be a valid cell reference
  if @reference.is_valid_cell_ref(name) {
    return false
  }
  true
}

/// Resolve a name to a range reference string
pub fn NamedRanges::resolve(self : NamedRanges, name : String) -> String? {
  match self.ranges.get(name.to_upper()) {
    Some(nr) => {
      let start_ref = @reference.CellReference::new(nr.start_row, nr.start_col).to_a1()
      let end_ref = @reference.CellReference::new(nr.end_row, nr.end_col).to_a1()
      if start_ref == end_ref {
        Some(start_ref)
      } else {
        Some(start_ref + ":" + end_ref)
      }
    }
    None => None
  }
}

/// Get the range as A1 notation
pub fn NamedRange::to_a1(self : NamedRange) -> String {
  let start_ref = @reference.CellReference::new(self.start_row, self.start_col).to_a1()
  let end_ref = @reference.CellReference::new(self.end_row, self.end_col).to_a1()
  if start_ref == end_ref {
    start_ref
  } else {
    start_ref + ":" + end_ref
  }
}

/// Get cell count in named range
pub fn NamedRange::cell_count(self : NamedRange) -> Int {
  let rows = self.end_row - self.start_row + 1
  let cols = self.end_col - self.start_col + 1
  rows * cols
}

/// Check if range is a single cell
pub fn NamedRange::is_single_cell(self : NamedRange) -> Bool {
  self.start_row == self.end_row && self.start_col == self.end_col
}

/// Check if scope is workbook-level
pub fn NamedRange::is_workbook_scope(self : NamedRange) -> Bool {
  match self.scope {
    Workbook => true
    _ => false
  }
}

/// Check if scope is sheet-level
pub fn NamedRange::is_sheet_scope(self : NamedRange) -> Bool {
  match self.scope {
    Sheet(_) => true
    _ => false
  }
}

/// Get scope sheet name
pub fn NamedRange::scope_sheet(self : NamedRange) -> String? {
  match self.scope {
    Sheet(s) => Some(s)
    _ => None
  }
}

/// Set comment on named range
pub fn NamedRange::with_comment(self : NamedRange, comment : String) -> NamedRange {
  { ..self, comment }
}

/// Clone named ranges
pub fn NamedRanges::clone(self : NamedRanges) -> NamedRanges {
  let mut new_ranges = {}
  for item in self.ranges {
    let (name, nr) = item
    new_ranges[name] = nr
  }
  NamedRanges { ranges: new_ranges }
}

/// Export named ranges to JSON
pub fn NamedRanges::to_json(self : NamedRanges) -> String {
  let mut result = "["
  let mut first = true
  for item in self.ranges {
    let (_, nr) = item
    if not(first) {
      result = result + ","
    }
    first = false
    result = result + "{\"name\":\"" + nr.name + "\",\"sheet\":\"" + nr.sheet_name + "\",\"start_row\":" + nr.start_row.to_string() + ",\"start_col\":" + nr.start_col.to_string() + ",\"end_row\":" + nr.end_row.to_string() + ",\"end_col\":" + nr.end_col.to_string() + "}"
  }
  result + "]"
}
