test "sheet_to_csv" {
  let sheet = @sheet.Sheet::with_default()
    .set_value(0, 0, @value.Number(1.0))
    .set_value(0, 1, @value.Number(2.0))
    .set_value(1, 0, @value.Str("hello"))
  let csv = sheet_to_csv(sheet)
  assert_true(csv.contains("1"))
  assert_true(csv.contains("2"))
  assert_true(csv.contains("hello"))
}

test "csv_to_sheet" {
  let csv = "1,2,3\n4,5,6\n"
  let sheet = csv_to_sheet("Test", csv)
  assert_eq(sheet.get_value(0, 0), @value.Number(1.0))
  assert_eq(sheet.get_value(0, 1), @value.Number(2.0))
  assert_eq(sheet.get_value(1, 2), @value.Number(6.0))
}

test "sheet_to_tsv" {
  let sheet = @sheet.Sheet::with_default()
    .set_value(0, 0, @value.Number(1.0))
    .set_value(0, 1, @value.Number(2.0))
  let tsv = sheet_to_tsv(sheet)
  assert_true(tsv.contains("\t"))
}

test "range_to_csv" {
  let sheet = @sheet.Sheet::with_default()
    .set_value(0, 0, @value.Number(1.0))
    .set_value(0, 1, @value.Number(2.0))
    .set_value(1, 0, @value.Number(3.0))
    .set_value(1, 1, @value.Number(4.0))
  let csv = range_to_csv(sheet, 0, 0, 1, 1)
  assert_true(csv.contains("1"))
  assert_true(csv.contains("4"))
}

test "csv with special characters" {
  let sheet = @sheet.Sheet::with_default()
    .set_value(0, 0, @value.Str("hello, world"))
    .set_value(0, 1, @value.Str("say \"hi\""))
  let csv = sheet_to_csv(sheet)
  assert_true(csv.contains("\"hello, world\""))
}

test "value_to_json number" {
  let result = value_to_json(@value.Number(42.0))
  assert_eq(result, "42")
}

test "value_to_json string" {
  let result = value_to_json(@value.Str("hello"))
  assert_eq(result, "\"hello\"")
}

test "value_to_json bool" {
  assert_eq(value_to_json(@value.Bool(true)), "true")
  assert_eq(value_to_json(@value.Bool(false)), "false")
}

test "value_to_json empty" {
  assert_eq(value_to_json(@value.Empty), "null")
}

test "value_to_json error" {
  let result = value_to_json(@value.Err(@error.DivZero))
  assert_true(result.contains("#DIV/0!"))
}

test "escape_json" {
  assert_eq(escape_json("hello"), "hello")
  assert_eq(escape_json("say \"hi\""), "say \\\"hi\\\"")
  assert_eq(escape_json("line\n"), "line\\n")
}

test "sheet_to_json" {
  let sheet = @sheet.Sheet::with_default()
    .set_value(0, 0, @value.Number(1.0))
    .set_value(0, 1, @value.Number(2.0))
  let json = sheet_to_json(sheet)
  assert_true(json.contains("\"name\""))
  assert_true(json.contains("\"cells\""))
}

test "workbook_to_json" {
  let wb = @workbook.Workbook::with_default("Test")
    .set_value("Sheet1", 0, 0, @value.Number(42.0))
  let json = workbook_to_json(wb)
  assert_true(json.contains("\"sheets\""))
}

test "values_to_json" {
  let vals = [@value.Number(1.0), @value.Str("a"), @value.Bool(true)]
  let result = values_to_json(vals)
  assert_eq(result, "[1, \"a\", true]")
}

test "csv_row_count" {
  assert_eq(csv_row_count("1,2\n3,4\n5,6\n"), 3)
  assert_eq(csv_row_count(""), 0)
}

test "csv_col_count" {
  assert_eq(csv_col_count("1,2,3\n4,5,6\n"), 3)
}
