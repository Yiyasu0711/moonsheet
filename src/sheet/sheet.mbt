// MoonSheet Worksheet
// Represents a worksheet containing cells organized in rows and columns

/// A worksheet containing cells organized in rows and columns
pub struct Sheet {
  pub name : String
  pub cells : Map[(Int, Int), @cell.Cell]
  pub max_row : Int
  pub max_col : Int
} derive(Show)

/// Create a new empty sheet
pub fn Sheet::new(name : String) -> Sheet {
  Sheet { name, cells: {}, max_row: 0, max_col: 0 }
}

/// Create a sheet with default name
pub fn Sheet::with_default() -> Sheet {
  Sheet::new("Sheet1")
}

/// Get a cell at the given position
pub fn Sheet::get_cell(self : Sheet, row : Int, col : Int) -> @cell.Cell {
  match self.cells.get((row, col)) {
    Some(c) => c
    None => @cell.Cell::empty(row, col)
  }
}

/// Get the value at the given position
pub fn Sheet::get_value(self : Sheet, row : Int, col : Int) -> @value.Value {
  self.get_cell(row, col).get_value()
}

/// Set a cell
pub fn Sheet::set_cell(self : Sheet, cell : @cell.Cell) -> Sheet {
  let mut new_cells = self.cells
  new_cells[(cell.row, cell.col)] = cell
  let new_max_row = if cell.row > self.max_row { cell.row } else { self.max_row }
  let new_max_col = if cell.col > self.max_col { cell.col } else { self.max_col }
  Sheet { name: self.name, cells: new_cells, max_row: new_max_row, max_col: new_max_col }
}

/// Set a value at the given position
pub fn Sheet::set_value(self : Sheet, row : Int, col : Int, v : @value.Value) -> Sheet {
  let cell = @cell.Cell::with_value(row, col, v)
  self.set_cell(cell)
}

/// Set a formula at the given position
pub fn Sheet::set_formula(self : Sheet, row : Int, col : Int, formula : String) -> Sheet {
  let cell = @cell.Cell::with_formula(row, col, formula)
  self.set_cell(cell)
}

/// Set a string value at the given position
pub fn Sheet::set_str(self : Sheet, row : Int, col : Int, s : String) -> Sheet {
  let cell = @cell.Cell::from_string(row, col, s)
  self.set_cell(cell)
}

/// Set a number value at the given position
pub fn Sheet::set_num(self : Sheet, row : Int, col : Int, n : Double) -> Sheet {
  self.set_value(row, col, @value.Number(n))
}

/// Clear a cell at the given position
pub fn Sheet::clear_cell(self : Sheet, row : Int, col : Int) -> Sheet {
  let mut new_cells = self.cells
  new_cells.remove((row, col))
  Sheet { name: self.name, cells: new_cells, max_row: self.max_row, max_col: self.max_col }
}

/// Get all cells
pub fn Sheet::get_all_cells(self : Sheet) -> Array[@cell.Cell] {
  let mut result = []
  for item in self.cells {
    let (_, cell) = item
    result.push(cell)
  }
  result
}

/// Get all formula cells
pub fn Sheet::get_formula_cells(self : Sheet) -> Array[@cell.Cell] {
  let mut result = []
  for item in self.cells {
    let (_, cell) = item
    if cell.is_formula() {
      result.push(cell)
    }
  }
  result
}

/// Get all value cells
pub fn Sheet::get_value_cells(self : Sheet) -> Array[@cell.Cell] {
  let mut result = []
  for item in self.cells {
    let (_, cell) = item
    if cell.has_value() {
      result.push(cell)
    }
  }
  result
}

/// Check if cell exists at position
pub fn Sheet::has_cell(self : Sheet, row : Int, col : Int) -> Bool {
  self.cells.contains((row, col))
}

/// Get cells in a range
pub fn Sheet::get_range_cells(self : Sheet, row1 : Int, col1 : Int, row2 : Int, col2 : Int) -> Array[@cell.Cell] {
  let mut result = []
  let r1 = if row1 < row2 { row1 } else { row2 }
  let r2 = if row1 < row2 { row2 } else { row1 }
  let c1 = if col1 < col2 { col1 } else { col2 }
  let c2 = if col1 < col2 { col2 } else { col1 }
  for r = r1; r <= r2; r = r + 1 {
    for c = c1; c <= c2; c = c + 1 {
      result.push(self.get_cell(r, c))
    }
  }
  result
}

/// Get values in a range
pub fn Sheet::get_range_values(self : Sheet, row1 : Int, col1 : Int, row2 : Int, col2 : Int) -> Array[@value.Value] {
  let cells = self.get_range_cells(row1, col1, row2, col2)
  cells.map(c => c.get_value())
}

/// Count cells
pub fn Sheet::count_cells(self : Sheet) -> Int {
  let mut count = 0
  for _ in self.cells {
    count = count + 1
  }
  count
}

/// Count non-empty cells
pub fn Sheet::count_non_empty(self : Sheet) -> Int {
  let mut count = 0
  for item in self.cells {
    let (_, cell) = item
    if not(cell.is_empty()) {
      count = count + 1
    }
  }
  count
}

/// Rename the sheet
pub fn Sheet::rename(self : Sheet, name : String) -> Sheet {
  Sheet { name, cells: self.cells, max_row: self.max_row, max_col: self.max_col }
}

/// Get row count (max_row + 1)
pub fn Sheet::row_count(self : Sheet) -> Int {
  self.max_row + 1
}

/// Get column count (max_col + 1)
pub fn Sheet::col_count(self : Sheet) -> Int {
  self.max_col + 1
}

/// Get a row of values
pub fn Sheet::get_row(self : Sheet, row : Int) -> Array[@value.Value] {
  let mut result = []
  for c = 0; c <= self.max_col; c = c + 1 {
    result.push(self.get_value(row, c))
  }
  result
}

/// Get a column of values
pub fn Sheet::get_col(self : Sheet, col : Int) -> Array[@value.Value] {
  let mut result = []
  for r = 0; r <= self.max_row; r = r + 1 {
    result.push(self.get_value(r, col))
  }
  result
}

/// Set computed value for a cell
pub fn Sheet::set_computed(self : Sheet, row : Int, col : Int, v : @value.Value) -> Sheet {
  match self.cells.get((row, col)) {
    Some(cell) => {
      let updated = cell.set_computed(v)
      self.set_cell(updated)
    }
    None => self
  }
}

/// Mark cell as dirty
pub fn Sheet::mark_dirty(self : Sheet, row : Int, col : Int) -> Sheet {
  match self.cells.get((row, col)) {
    Some(cell) => {
      let updated = cell.mark_dirty()
      self.set_cell(updated)
    }
    None => self
  }
}

/// Check if any cells need recalculation
pub fn Sheet::has_dirty(self : Sheet) -> Bool {
  for item in self.cells {
    let (_, cell) = item
    if cell.dirty {
      return true
    }
  }
  false
}

/// Get all dirty cells
pub fn Sheet::get_dirty_cells(self : Sheet) -> Array[@cell.Cell] {
  let mut result = []
  for item in self.cells {
    let (_, cell) = item
    if cell.dirty {
      result.push(cell)
    }
  }
  result
}

/// Create a sheet from string data (2D array)
pub fn Sheet::from_data(name : String, data : Array[Array[String]]) -> Sheet {
  let mut sheet = Sheet::new(name)
  for r = 0; r < data.length(); r = r + 1 {
    let row = data[r]
    for c = 0; c < row.length(); c = c + 1 {
      sheet = sheet.set_str(r, c, row[c])
    }
  }
  sheet
}

/// Get cell count in range
pub fn Sheet::range_cell_count(row1 : Int, col1 : Int, row2 : Int, col2 : Int) -> Int {
  let r1 = if row1 < row2 { row1 } else { row2 }
  let r2 = if row1 < row2 { row2 } else { row1 }
  let c1 = if col1 < col2 { col1 } else { col2 }
  let c2 = if col1 < col2 { col2 } else { col1 }
  (r2 - r1 + 1) * (c2 - c1 + 1)
}
