// MoonSheet I/O - JSON
// JSON serialization for the spreadsheet engine

/// Export a sheet to JSON format
pub fn sheet_to_json(sheet : @sheet.Sheet) -> String {
  let mut result = "{\n"
  result = result + "  \"name\": \"" + escape_json(sheet.name) + "\",\n"
  result = result + "  \"max_row\": " + sheet.max_row.to_string() + ",\n"
  result = result + "  \"max_col\": " + sheet.max_col.to_string() + ",\n"
  result = result + "  \"cells\": [\n"
  let cells = sheet.get_all_cells()
  for i = 0; i < cells.length(); i = i + 1 {
    let cell = cells[i]
    result = result + "    {\n"
    result = result + "      \"ref\": \"" + cell.ref_string() + "\",\n"
    result = result + "      \"row\": " + cell.row.to_string() + ",\n"
    result = result + "      \"col\": " + cell.col.to_string() + ",\n"
    result = result + "      \"type\": \"" + cell.cell_type() + "\",\n"
    result = result + "      \"value\": " + value_to_json(cell.get_value())
    if cell.is_formula() {
      result = result + ",\n"
      result = result + "      \"formula\": \"" + escape_json(cell.get_formula()) + "\""
    }
    result = result + "\n"
    result = result + "    }"
    if i < cells.length() - 1 {
      result = result + ","
    }
    result = result + "\n"
  }
  result = result + "  ]\n"
  result = result + "}"
  result
}

/// Export a workbook to JSON format
pub fn workbook_to_json(wb : @workbook.Workbook) -> String {
  let mut result = "{\n"
  result = result + "  \"name\": \"" + escape_json(wb.name) + "\",\n"
  result = result + "  \"sheets\": [\n"
  for i = 0; i < wb.sheet_order.length(); i = i + 1 {
    let name = wb.sheet_order[i]
    let sheet = wb.sheets[name]
    let sheet_json = sheet_to_json(sheet)
    // Indent the sheet JSON
    let indented = sheet_json.replace("\n", "\n  ")
    result = result + "  " + indented
    if i < wb.sheet_order.length() - 1 {
      result = result + ","
    }
    result = result + "\n"
  }
  result = result + "  ]\n"
  result = result + "}"
  result
}

/// Convert a value to JSON representation
pub fn value_to_json(v : @value.Value) -> String {
  match v {
    @value.Number(n) => {
      if n == n.trunc() && n.abs() < 1e15 {
        n.to_int().to_string()
      } else {
        n.to_string()
      }
    }
    @value.Str(s) => "\"" + escape_json(s) + "\""
    @value.Bool(true) => "true"
    @value.Bool(false) => "false"
    @value.Empty => "null"
    @value.Err(e) => "{\"error\": \"" + escape_json(e.to_error_string()) + "\"}"
  }
}

/// Escape a string for JSON
pub fn escape_json(s : String) -> String {
  let mut result = ""
  for i = 0; i < s.length(); i = i + 1 {
    let ch = s[i]
    match ch {
      34 => result = result + "\\\""       // "
      92 => result = result + "\\\\"       // \
      10 => result = result + "\\n"        // \n
      13 => result = result + "\\r"        // \r
      9 => result = result + "\\t"         // \t
      _ => result = result + Char::from_int(ch).to_string()
    }
  }
  result
}

/// Import JSON data into a sheet (simplified)
pub fn json_to_sheet(name : String, json : String) -> @sheet.Sheet {
  // Simplified: just create an empty sheet
  // A full implementation would parse the JSON
  @sheet.Sheet::new(name)
}

/// Export cell to JSON
pub fn cell_to_json(cell : @cell.Cell) -> String {
  let mut result = "{\n"
  result = result + "  \"ref\": \"" + cell.ref_string() + "\",\n"
  result = result + "  \"row\": " + cell.row.to_string() + ",\n"
  result = result + "  \"col\": " + cell.col.to_string() + ",\n"
  result = result + "  \"type\": \"" + cell.cell_type() + "\",\n"
  result = result + "  \"value\": " + value_to_json(cell.get_value())
  if cell.is_formula() {
    result = result + ",\n  \"formula\": \"" + escape_json(cell.get_formula()) + "\""
  }
  result = result + "\n}"
  result
}

/// Export values as JSON array
pub fn values_to_json(values : Array[@value.Value]) -> String {
  let mut result = "["
  for i = 0; i < values.length(); i = i + 1 {
    if i > 0 {
      result = result + ", "
    }
    result = result + value_to_json(values[i])
  }
  result + "]"
}

/// Export sheet metadata as JSON
pub fn sheet_metadata_json(sheet : @sheet.Sheet) -> String {
  let mut result = "{\n"
  result = result + "  \"name\": \"" + escape_json(sheet.name) + "\",\n"
  result = result + "  \"max_row\": " + sheet.max_row.to_string() + ",\n"
  result = result + "  \"max_col\": " + sheet.max_col.to_string() + ",\n"
  result = result + "  \"cell_count\": " + sheet.count_cells().to_string() + ",\n"
  result = result + "  \"formula_count\": " + sheet.get_formula_cells().length().to_string() + "\n"
  result + "}"
}

/// Export workbook metadata as JSON
pub fn workbook_metadata_json(wb : @workbook.Workbook) -> String {
  let mut result = "{\n"
  result = result + "  \"name\": \"" + escape_json(wb.name) + "\",\n"
  result = result + "  \"sheet_count\": " + wb.sheet_count().to_string() + ",\n"
  result = result + "  \"total_cells\": " + wb.total_cell_count().to_string() + ",\n"
  result = result + "  \"total_formulas\": " + wb.total_formula_count().to_string() + ",\n"
  result = result + "  \"sheets\": ["
  for i = 0; i < wb.sheet_order.length(); i = i + 1 {
    if i > 0 { result = result + ", " }
    result = result + "\"" + escape_json(wb.sheet_order[i]) + "\""
  }
  result = result + "]\n"
  result + "}"
}
