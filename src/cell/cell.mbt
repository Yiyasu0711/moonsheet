// MoonSheet Cell Types
// Represents individual cells in a worksheet

/// Cell content type
pub enum CellContent {
  EmptyCell
  ValueCell(@value.Value)
  FormulaCell(String)
} derive(Show, Eq)

/// A single cell in a spreadsheet
pub struct Cell {
  pub row : Int
  pub col : Int
  pub content : CellContent
  pub computed : @value.Value
  pub formula : String
  pub dirty : Bool
} derive(Show)

/// Create an empty cell
pub fn Cell::empty(row : Int, col : Int) -> Cell {
  Cell { row, col, content: EmptyCell, computed: @value.Empty, formula: "", dirty: false }
}

/// Create a cell with a value
pub fn Cell::with_value(row : Int, col : Int, v : @value.Value) -> Cell {
  Cell { row, col, content: ValueCell(v), computed: v, formula: "", dirty: false }
}

/// Create a cell with a formula
pub fn Cell::with_formula(row : Int, col : Int, formula_str : String) -> Cell {
  Cell { row, col, content: FormulaCell(formula_str), computed: @value.Empty, formula: formula_str, dirty: true }
}

/// Check if cell is empty
pub fn Cell::is_empty(self : Cell) -> Bool {
  match self.content {
    EmptyCell => true
    _ => false
  }
}

/// Check if cell contains a value
pub fn Cell::has_value(self : Cell) -> Bool {
  match self.content {
    ValueCell(_) => true
    _ => false
  }
}

/// Check if cell contains a formula
pub fn Cell::is_formula(self : Cell) -> Bool {
  match self.content {
    FormulaCell(_) => true
    _ => false
  }
}

/// Get the computed value of the cell
pub fn Cell::get_value(self : Cell) -> @value.Value {
  self.computed
}

/// Get the formula string
pub fn Cell::get_formula(self : Cell) -> String {
  self.formula
}

/// Set the computed value
pub fn Cell::set_computed(self : Cell, v : @value.Value) -> Cell {
  { ..self, computed: v, dirty: false }
}

/// Mark cell as dirty (needs recalculation)
pub fn Cell::mark_dirty(self : Cell) -> Cell {
  { ..self, dirty: true }
}

/// Set cell value
pub fn Cell::set_value(self : Cell, v : @value.Value) -> Cell {
  Cell { row: self.row, col: self.col, content: ValueCell(v), computed: v, formula: "", dirty: false }
}

/// Set cell formula
pub fn Cell::set_formula(self : Cell, formula_str : String) -> Cell {
  Cell { row: self.row, col: self.col, content: FormulaCell(formula_str), computed: @value.Empty, formula: formula_str, dirty: true }
}

/// Clear cell content
pub fn Cell::clear(self : Cell) -> Cell {
  Cell { row: self.row, col: self.col, content: EmptyCell, computed: @value.Empty, formula: "", dirty: false }
}

/// Get cell type as string
pub fn Cell::cell_type(self : Cell) -> String {
  match self.content {
    EmptyCell => "empty"
    ValueCell(v) => {
      match v {
        @value.Number(_) => "number"
        @value.Str(_) => "string"
        @value.Bool(_) => "boolean"
        @value.Err(_) => "error"
        @value.Empty => "empty"
      }
    }
    FormulaCell(_) => "formula"
  }
}

/// Get cell reference string (A1 notation)
pub fn Cell::ref_string(self : Cell) -> String {
  col_to_letter(self.col) + (self.row + 1).to_string()
}

/// Convert column number to letter (0 -> A, 1 -> B, ..., 25 -> Z, 26 -> AA, etc.)
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

/// Convert column letter to number (A -> 0, B -> 1, ..., Z -> 25, AA -> 26, etc.)
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

/// Get a single character as string
pub fn char_str(code : Int) -> String {
  Char::from_int(code).to_string()
}

/// Create a cell from a string value
pub fn Cell::from_string(row : Int, col : Int, s : String) -> Cell {
  if s.startsWith("=") {
    Cell::with_formula(row, col, s)
  } else {
    let v = @value.Value::parse(s)
    Cell::with_value(row, col, v)
  }
}

/// Check if cell equals another
pub fn Cell::equals(self : Cell, other : Cell) -> Bool {
  self.row == other.row && self.col == other.col && self.content == other.content
}

/// Clone cell
pub fn Cell::clone(self : Cell) -> Cell {
  Cell { row: self.row, col: self.col, content: self.content, computed: self.computed, formula: self.formula, dirty: self.dirty }
}
