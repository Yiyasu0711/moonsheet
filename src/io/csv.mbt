// MoonSheet I/O - CSV
// CSV file handling for the spreadsheet engine

/// Export a sheet to CSV format
pub fn sheet_to_csv(sheet : @sheet.Sheet) -> String {
  let mut result = ""
  for r = 0; r <= sheet.max_row; r = r + 1 {
    let mut row_str = ""
    for c = 0; c <= sheet.max_col; c = c + 1 {
      if c > 0 {
        row_str = row_str + ","
      }
      let val = sheet.get_value(r, c)
      let s = val.to_display_string()
      if s.contains(",") || s.contains("\n") || s.contains("\"") {
        let escaped = s.replace("\"", "\"\"")
        row_str = row_str + "\"" + escaped + "\""
      } else {
        row_str = row_str + s
      }
    }
    result = result + row_str + "\n"
  }
  result
}

/// Import CSV data into a sheet
pub fn csv_to_sheet(name : String, csv : String) -> @sheet.Sheet {
  let mut sheet = @sheet.Sheet::new(name)
  let lines = csv.split("\n")
  let mut row = 0
  for line in lines {
    if line.trim() != "" {
      let fields = parse_csv_line(line)
      let mut col = 0
      for field in fields {
        let v = @value.Value::parse(field.trim())
        sheet = sheet.set_value(row, col, v)
        col = col + 1
      }
      row = row + 1
    }
  }
  sheet
}

/// Parse a single CSV line
fn parse_csv_line(line : String) -> Array[String] {
  let mut result = []
  let mut current = ""
  let mut in_quotes = false
  let mut i = 0
  while i < line.length() {
    let ch = line[i]
    if ch == 34 {
      // Double quote
      if in_quotes && i + 1 < line.length() && line[i + 1] == 34 {
        // Escaped quote
        current = current + "\""
        i = i + 1
      } else {
        in_quotes = not(in_quotes)
      }
    } else if ch == 44 && not(in_quotes) {
      // Comma separator
      result.push(current)
      current = ""
    } else {
      current = current + Char::from_int(ch).to_string()
    }
    i = i + 1
  }
  result.push(current)
  result
}

/// Export a sheet to TSV format
pub fn sheet_to_tsv(sheet : @sheet.Sheet) -> String {
  let mut result = ""
  for r = 0; r <= sheet.max_row; r = r + 1 {
    let mut row_str = ""
    for c = 0; c <= sheet.max_col; c = c + 1 {
      if c > 0 {
        row_str = row_str + "\t"
      }
      let val = sheet.get_value(r, c)
      row_str = row_str + val.to_display_string()
    }
    result = result + row_str + "\n"
  }
  result
}

/// Export a specific range as CSV
pub fn range_to_csv(sheet : @sheet.Sheet, row1 : Int, col1 : Int, row2 : Int, col2 : Int) -> String {
  let r1 = if row1 < row2 { row1 } else { row2 }
  let r2 = if row1 < row2 { row2 } else { row1 }
  let c1 = if col1 < col2 { col1 } else { col2 }
  let c2 = if col1 < col2 { col2 } else { col1 }
  let mut result = ""
  for r = r1; r <= r2; r = r + 1 {
    let mut row_str = ""
    for c = c1; c <= c2; c = c + 1 {
      if c > c1 {
        row_str = row_str + ","
      }
      let val = sheet.get_value(r, c)
      let s = val.to_display_string()
      if s.contains(",") || s.contains("\n") || s.contains("\"") {
        let escaped = s.replace("\"", "\"\"")
        row_str = row_str + "\"" + escaped + "\""
      } else {
        row_str = row_str + s
      }
    }
    result = result + row_str + "\n"
  }
  result
}

/// Import CSV from a 2D string array
pub fn data_to_sheet(name : String, data : Array[Array[String]]) -> @sheet.Sheet {
  @sheet.Sheet::from_data(name, data)
}

/// Export workbook to CSV (first sheet only)
pub fn workbook_to_csv(wb : @workbook.Workbook) -> String {
  let sheet = wb.get_first_sheet()
  sheet_to_csv(sheet)
}

/// Count rows in CSV string
pub fn csv_row_count(csv : String) -> Int {
  let lines = csv.split("\n")
  let mut count = 0
  for line in lines {
    if line.trim() != "" {
      count = count + 1
    }
  }
  count
}

/// Count columns in CSV string (first line)
pub fn csv_col_count(csv : String) -> Int {
  let lines = csv.split("\n")
  if lines.length() == 0 { return 0 }
  let first_line = lines[0]
  parse_csv_line(first_line).length()
}
