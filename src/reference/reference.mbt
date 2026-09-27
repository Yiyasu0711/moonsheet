// MoonSheet Reference
// Handles cell and range reference parsing, conversion and resolution

/// A cell reference with absolute/relative flags
pub struct CellReference {
  pub row : Int
  pub col : Int
  pub row_absolute : Bool
  pub col_absolute : Bool
} derive(Show)

/// A range reference with two cell references
pub struct RangeReference {
  pub start : CellReference
  pub end : CellReference
} derive(Show)

/// Parse an A1-style reference string into a CellReference
pub fn CellReference::from_a1(ref : String) -> CellReference {
  let s = ref.to_upper().trim()
  let mut i = 0
  let mut col_abs = false
  let mut row_abs = false
  if i < s.length() && s[i] == 36 {
    col_abs = true
    i = i + 1
  }
  let mut col = 0
  while i < s.length() && s[i] >= 65 && s[i] <= 90 {
    col = col * 26 + (s[i] - 65) + 1
    i = i + 1
  }
  col = col - 1
  if i < s.length() && s[i] == 36 {
    row_abs = true
    i = i + 1
  }
  let mut row = 0
  while i < s.length() && s[i] >= 48 && s[i] <= 57 {
    row = row * 10 + (s[i] - 48)
    i = i + 1
  }
  CellReference { row: row - 1, col, row_absolute: row_abs, col_absolute: col_abs }
}

/// Convert CellReference to A1 notation
pub fn CellReference::to_a1(self : CellReference) -> String {
  let col_str = (if self.col_absolute { "$" } else { "" }) + col_to_letter(self.col)
  let row_str = (if self.row_absolute { "$" } else { "" }) + (self.row + 1).to_string()
  col_str + row_str
}

/// Convert CellReference to R1C1 notation
pub fn CellReference::to_r1c1(self : CellReference) -> String {
  let row_str = (if self.row_absolute { "R" } else { "R" }) + (self.row + 1).to_string()
  let col_str = (if self.col_absolute { "C" } else { "C" }) + (self.col + 1).to_string()
  row_str + col_str
}

/// Create a simple cell reference (relative)
pub fn CellReference::new(row : Int, col : Int) -> CellReference {
  CellReference { row, col, row_absolute: false, col_absolute: false }
}

/// Create an absolute cell reference
pub fn CellReference::absolute(row : Int, col : Int) -> CellReference {
  CellReference { row, col, row_absolute: true, col_absolute: true }
}

/// Create with mixed absolute/relative
pub fn CellReference::mixed(row : Int, col : Int, row_abs : Bool, col_abs : Bool) -> CellReference {
  CellReference { row, col, row_absolute: row_abs, col_absolute: col_abs }
}

/// Check if reference is fully absolute
pub fn CellReference::is_absolute(self : CellReference) -> Bool {
  self.row_absolute && self.col_absolute
}

/// Check if reference is fully relative
pub fn CellReference::is_relative(self : CellReference) -> Bool {
  not(self.row_absolute) && not(self.col_absolute)
}

/// Parse a cell reference string and return (row, col, row_abs, col_abs)
pub fn parse_cell_ref(ref : String) -> (Int, Int, Bool, Bool) {
  let cr = CellReference::from_a1(ref)
  (cr.row, cr.col, cr.row_absolute, cr.col_absolute)
}

/// Parse a range reference string like "A1:B2"
pub fn parse_range_ref(ref : String) -> RangeReference {
  let parts = ref.split(":")
  if parts.length() != 2 {
    let cr = CellReference::from_a1(ref)
    RangeReference { start: cr, end: cr }
  } else {
    RangeReference {
      start: CellReference::from_a1(parts[0]),
      end: CellReference::from_a1(parts[1])
    }
  }
}

/// Get all cells in a range
pub fn RangeReference::get_cells(self : RangeReference) -> Array[(Int, Int)] {
  let mut cells = []
  let r1 = if self.start.row < self.end.row { self.start.row } else { self.end.row }
  let r2 = if self.start.row < self.end.row { self.end.row } else { self.start.row }
  let c1 = if self.start.col < self.end.col { self.start.col } else { self.end.col }
  let c2 = if self.start.col < self.end.col { self.end.col } else { self.start.col }
  for r = r1; r <= r2; r = r + 1 {
    for c = c1; c <= c2; c = c + 1 {
      cells.push((r, c))
    }
  }
  cells
}

/// Get the number of rows in a range
pub fn RangeReference::row_count(self : RangeReference) -> Int {
  let r1 = if self.start.row < self.end.row { self.start.row } else { self.end.row }
  let r2 = if self.start.row < self.end.row { self.end.row } else { self.start.row }
  r2 - r1 + 1
}

/// Get the number of columns in a range
pub fn RangeReference::col_count(self : RangeReference) -> Int {
  let c1 = if self.start.col < self.end.col { self.start.col } else { self.end.col }
  let c2 = if self.start.col < self.end.col { self.end.col } else { self.start.col }
  c2 - c1 + 1
}

/// Get total cell count in a range
pub fn RangeReference::cell_count(self : RangeReference) -> Int {
  self.row_count() * self.col_count()
}

/// Convert range to A1 notation
pub fn RangeReference::to_a1(self : RangeReference) -> String {
  self.start.to_a1() + ":" + self.end.to_a1()
}

/// Check if a cell is contained in a range
pub fn RangeReference::contains(self : RangeReference, row : Int, col : Int) -> Bool {
  let r1 = if self.start.row < self.end.row { self.start.row } else { self.end.row }
  let r2 = if self.start.row < self.end.row { self.end.row } else { self.start.row }
  let c1 = if self.start.col < self.end.col { self.start.col } else { self.end.col }
  let c2 = if self.start.col < self.end.col { self.end.col } else { self.start.col }
  row >= r1 && row <= r2 && col >= c1 && col <= c2
}

/// Convert column number to letter
pub fn col_to_letter(col : Int) -> String {
  let mut result = ""
  let mut c = col
  let mut done = false
  while not(done) {
    result = Char::from_int((c % 26) + 65).to_string() + result
    c = c / 26
    if c == 0 {
      done = true
    }
  }
  result
}

/// Convert column letter to number
pub fn letter_to_col(letter : String) -> Int {
  let mut result = 0
  for i = 0; i < letter.length(); i = i + 1 {
    let ch = letter[i]
    if ch >= 65 && ch <= 90 {
      result = result * 26 + (ch - 65 + 1)
    } else if ch >= 97 && ch <= 122 {
      result = result * 26 + (ch - 97 + 1)
    }
  }
  result - 1
}

/// Check if a string is a valid cell reference
pub fn is_valid_cell_ref(s : String) -> Bool {
  let mut i = 0
  if i < s.length() && s[i] == 36 {
    i = i + 1
  }
  let mut has_letter = false
  while i < s.length() && ((s[i] >= 65 && s[i] <= 90) || (s[i] >= 97 && s[i] <= 122)) {
    has_letter = true
    i = i + 1
  }
  if not(has_letter) {
    return false
  }
  if i < s.length() && s[i] == 36 {
    i = i + 1
  }
  let mut has_digit = false
  while i < s.length() && s[i] >= 48 && s[i] <= 57 {
    has_digit = true
    i = i + 1
  }
  has_digit && i == s.length()
}

/// Check if a string is a valid range reference
pub fn is_valid_range_ref(s : String) -> Bool {
  let parts = s.split(":")
  if parts.length() != 2 {
    return false
  }
  is_valid_cell_ref(parts[0]) && is_valid_cell_ref(parts[1])
}

/// Resolve a relative reference against a base cell
pub fn resolve_relative(ref : CellReference, base_row : Int, base_col : Int) -> CellReference {
  let row = if ref.row_absolute { ref.row } else { base_row + ref.row }
  let col = if ref.col_absolute { ref.col } else { base_col + ref.col }
  CellReference { row, col, row_absolute: ref.row_absolute, col_absolute: ref.col_absolute }
}

/// Get the intersection of two ranges (if any)
pub fn range_intersect(r1 : RangeReference, r2 : RangeReference) -> RangeReference? {
  let r1_min_row = if r1.start.row < r1.end.row { r1.start.row } else { r1.end.row }
  let r1_max_row = if r1.start.row < r1.end.row { r1.end.row } else { r1.start.row }
  let r1_min_col = if r1.start.col < r1.end.col { r1.start.col } else { r1.end.col }
  let r1_max_col = if r1.start.col < r1.end.col { r1.end.col } else { r1.start.col }
  let r2_min_row = if r2.start.row < r2.end.row { r2.start.row } else { r2.end.row }
  let r2_max_row = if r2.start.row < r2.end.row { r2.end.row } else { r2.start.row }
  let r2_min_col = if r2.start.col < r2.end.col { r2.start.col } else { r2.end.col }
  let r2_max_col = if r2.start.col < r2.end.col { r2.end.col } else { r2.start.col }
  let min_row = if r1_min_row > r2_min_row { r1_min_row } else { r2_min_row }
  let max_row = if r1_max_row < r2_max_row { r1_max_row } else { r2_max_row }
  let min_col = if r1_min_col > r2_min_col { r1_min_col } else { r2_min_col }
  let max_col = if r1_max_col < r2_max_col { r1_max_col } else { r2_max_col }
  if min_row > max_row || min_col > max_col {
    None
  } else {
    Some(RangeReference {
      start: CellReference::new(min_row, min_col),
      end: CellReference::new(max_row, max_col)
    })
  }
}
