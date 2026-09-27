// MoonSheet Workbook
// A workbook contains multiple worksheets

/// A spreadsheet workbook containing multiple sheets
pub struct Workbook {
  pub name : String
  pub sheets : Map[String, @sheet.Sheet]
  pub sheet_order : Array[String]
} derive(Show)

/// Create a new workbook
pub fn Workbook::new(name : String) -> Workbook {
  Workbook { name, sheets: {}, sheet_order: [] }
}

/// Create a workbook with a default sheet
pub fn Workbook::with_default(name : String) -> Workbook {
  let sheet = @sheet.Sheet::with_default()
  let mut sheets = {}
  sheets["Sheet1"] = sheet
  Workbook { name, sheets, sheet_order: ["Sheet1"] }
}

/// Add a sheet to the workbook
pub fn Workbook::add_sheet(self : Workbook, sheet_name : String) -> Workbook {
  if self.sheets.contains(sheet_name) {
    self
  } else {
    let mut new_sheets = self.sheets
    new_sheets[sheet_name] = @sheet.Sheet::new(sheet_name)
    let mut new_order = self.sheet_order
    new_order.push(sheet_name)
    Workbook { name: self.name, sheets: new_sheets, sheet_order: new_order }
  }
}

/// Remove a sheet from the workbook
pub fn Workbook::remove_sheet(self : Workbook, sheet_name : String) -> Workbook {
  if not(self.sheets.contains(sheet_name)) {
    return self
  }
  let mut new_sheets = self.sheets
  new_sheets.remove(sheet_name)
  let mut new_order = []
  for name in self.sheet_order {
    if name != sheet_name {
      new_order.push(name)
    }
  }
  Workbook { name: self.name, sheets: new_sheets, sheet_order: new_order }
}

/// Rename a sheet
pub fn Workbook::rename_sheet(self : Workbook, old_name : String, new_name : String) -> Workbook {
  if not(self.sheets.contains(old_name)) || self.sheets.contains(new_name) {
    return self
  }
  let sheet = self.sheets[old_name].rename(new_name)
  let mut new_sheets = self.sheets
  new_sheets.remove(old_name)
  new_sheets[new_name] = sheet
  let mut new_order = []
  for name in self.sheet_order {
    if name == old_name {
      new_order.push(new_name)
    } else {
      new_order.push(name)
    }
  }
  Workbook { name: self.name, sheets: new_sheets, sheet_order: new_order }
}

/// Get a sheet by name
pub fn Workbook::get_sheet(self : Workbook, sheet_name : String) -> @sheet.Sheet? {
  match self.sheets.get(sheet_name) {
    Some(s) => Some(s)
    None => None
  }
}

/// Get or create a sheet
pub fn Workbook::get_or_create_sheet(self : Workbook, sheet_name : String) -> (Workbook, @sheet.Sheet) {
  match self.sheets.get(sheet_name) {
    Some(s) => (self, s)
    None => {
      let wb = self.add_sheet(sheet_name)
      (wb, wb.sheets[sheet_name])
    }
  }
}

/// Get the first sheet
pub fn Workbook::get_first_sheet(self : Workbook) -> @sheet.Sheet {
  if self.sheet_order.length() > 0 {
    let name = self.sheet_order[0]
    self.sheets[name]
  } else {
    @sheet.Sheet::with_default()
  }
}

/// Set a value in a specific sheet
pub fn Workbook::set_value(self : Workbook, sheet_name : String, row : Int, col : Int, v : @value.Value) -> Workbook {
  match self.get_or_create_sheet(sheet_name) {
    (wb, sheet) => {
      let updated = sheet.set_value(row, col, v)
      let mut new_sheets = wb.sheets
      new_sheets[sheet_name] = updated
      Workbook { name: wb.name, sheets: new_sheets, sheet_order: wb.sheet_order }
    }
  }
}

/// Set a formula in a specific sheet
pub fn Workbook::set_formula(self : Workbook, sheet_name : String, row : Int, col : Int, formula : String) -> Workbook {
  match self.get_or_create_sheet(sheet_name) {
    (wb, sheet) => {
      let updated = sheet.set_formula(row, col, formula)
      let mut new_sheets = wb.sheets
      new_sheets[sheet_name] = updated
      Workbook { name: wb.name, sheets: new_sheets, sheet_order: wb.sheet_order }
    }
  }
}

/// Set a string in a specific sheet
pub fn Workbook::set_str(self : Workbook, sheet_name : String, row : Int, col : Int, s : String) -> Workbook {
  match self.get_or_create_sheet(sheet_name) {
    (wb, sheet) => {
      let updated = sheet.set_str(row, col, s)
      let mut new_sheets = wb.sheets
      new_sheets[sheet_name] = updated
      Workbook { name: wb.name, sheets: new_sheets, sheet_order: wb.sheet_order }
    }
  }
}

/// Set a number in a specific sheet
pub fn Workbook::set_num(self : Workbook, sheet_name : String, row : Int, col : Int, n : Double) -> Workbook {
  self.set_value(sheet_name, row, col, @value.Number(n))
}

/// Get a value from a specific sheet
pub fn Workbook::get_value(self : Workbook, sheet_name : String, row : Int, col : Int) -> @value.Value {
  match self.sheets.get(sheet_name) {
    Some(sheet) => sheet.get_value(row, col)
    None => @value.Empty
  }
}

/// Get a cell from a specific sheet
pub fn Workbook::get_cell(self : Workbook, sheet_name : String, row : Int, col : Int) -> @cell.Cell {
  match self.sheets.get(sheet_name) {
    Some(sheet) => sheet.get_cell(row, col)
    None => @cell.Cell::empty(row, col)
  }
}

/// Get sheet count
pub fn Workbook::sheet_count(self : Workbook) -> Int {
  self.sheet_order.length()
}

/// Get all sheet names
pub fn Workbook::sheet_names(self : Workbook) -> Array[String] {
  self.sheet_order
}

/// Check if sheet exists
pub fn Workbook::has_sheet(self : Workbook, sheet_name : String) -> Bool {
  self.sheets.contains(sheet_name)
}

/// Set computed value
pub fn Workbook::set_computed(self : Workbook, sheet_name : String, row : Int, col : Int, v : @value.Value) -> Workbook {
  match self.sheets.get(sheet_name) {
    Some(sheet) => {
      let updated = sheet.set_computed(row, col, v)
      let mut new_sheets = self.sheets
      new_sheets[sheet_name] = updated
      Workbook { name: self.name, sheets: new_sheets, sheet_order: self.sheet_order }
    }
    None => self
  }
}

/// Get all formula cells across all sheets
pub fn Workbook::get_all_formula_cells(self : Workbook) -> Array[(String, @cell.Cell)] {
  let mut result = []
  for name in self.sheet_order {
    let sheet = self.sheets[name]
    let cells = sheet.get_formula_cells()
    for cell in cells {
      result.push((name, cell))
    }
  }
  result
}

/// Rename workbook
pub fn Workbook::rename(self : Workbook, name : String) -> Workbook {
  Workbook { name, sheets: self.sheets, sheet_order: self.sheet_order }
}

/// Get total cell count across all sheets
pub fn Workbook::total_cell_count(self : Workbook) -> Int {
  let mut count = 0
  for name in self.sheet_order {
    let sheet = self.sheets[name]
    count = count + sheet.count_cells()
  }
  count
}

/// Get total formula count across all sheets
pub fn Workbook::total_formula_count(self : Workbook) -> Int {
  self.get_all_formula_cells().length()
}
