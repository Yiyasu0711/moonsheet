test "Workbook::new" {
  let wb = Workbook::new("Test")
  assert_eq(wb.name, "Test")
  assert_eq(wb.sheet_count(), 0)
}

test "Workbook::with_default" {
  let wb = Workbook::with_default("Test")
  assert_eq(wb.sheet_count(), 1)
  assert_true(wb.has_sheet("Sheet1"))
}

test "Workbook::add_sheet" {
  let wb = Workbook::new("Test").add_sheet("Sheet1").add_sheet("Sheet2")
  assert_eq(wb.sheet_count(), 2)
  assert_true(wb.has_sheet("Sheet1"))
  assert_true(wb.has_sheet("Sheet2"))
}

test "Workbook::add_duplicate_sheet" {
  let wb = Workbook::new("Test").add_sheet("Sheet1")
  let wb2 = wb.add_sheet("Sheet1")
  assert_eq(wb2.sheet_count(), 1)
}

test "Workbook::remove_sheet" {
  let wb = Workbook::new("Test").add_sheet("S1").add_sheet("S2").remove_sheet("S1")
  assert_eq(wb.sheet_count(), 1)
  assert_false(wb.has_sheet("S1"))
  assert_true(wb.has_sheet("S2"))
}

test "Workbook::rename_sheet" {
  let wb = Workbook::new("Test").add_sheet("Old").rename_sheet("Old", "New")
  assert_true(wb.has_sheet("New"))
  assert_false(wb.has_sheet("Old"))
}

test "Workbook::set_value" {
  let wb = Workbook::with_default("Test").set_value("Sheet1", 0, 0, @value.Number(42.0))
  assert_eq(wb.get_value("Sheet1", 0, 0), @value.Number(42.0))
}

test "Workbook::set_formula" {
  let wb = Workbook::with_default("Test").set_formula("Sheet1", 0, 0, "=A1+B1")
  let cell = wb.get_cell("Sheet1", 0, 0)
  assert_true(cell.is_formula())
}

test "Workbook::set_str" {
  let wb = Workbook::with_default("Test").set_str("Sheet1", 0, 0, "42")
  assert_eq(wb.get_value("Sheet1", 0, 0), @value.Number(42.0))
}

test "Workbook::set_num" {
  let wb = Workbook::with_default("Test").set_num("Sheet1", 0, 0, 3.14)
  assert_eq(wb.get_value("Sheet1", 0, 0), @value.Number(3.14))
}

test "Workbook::sheet_names" {
  let wb = Workbook::new("Test").add_sheet("A").add_sheet("B").add_sheet("C")
  let names = wb.sheet_names()
  assert_eq(names.length(), 3)
  assert_eq(names[0], "A")
  assert_eq(names[1], "B")
  assert_eq(names[2], "C")
}

test "Workbook::total_cell_count" {
  let wb = Workbook::with_default("Test")
    .set_value("Sheet1", 0, 0, @value.Number(1.0))
    .set_value("Sheet1", 0, 1, @value.Number(2.0))
    .add_sheet("Sheet2")
    .set_value("Sheet2", 0, 0, @value.Number(3.0))
  assert_eq(wb.total_cell_count(), 3)
}

test "Workbook::get_all_formula_cells" {
  let wb = Workbook::with_default("Test")
    .set_formula("Sheet1", 0, 0, "=A1+B1")
    .set_formula("Sheet1", 1, 0, "=A2*2")
    .add_sheet("Sheet2")
    .set_formula("Sheet2", 0, 0, "=A1")
  let cells = wb.get_all_formula_cells()
  assert_eq(cells.length(), 3)
}

test "Workbook::rename" {
  let wb = Workbook::with_default("Old").rename("New")
  assert_eq(wb.name, "New")
}

test "Workbook::get_value_nonexistent" {
  let wb = Workbook::new("Test")
  assert_eq(wb.get_value("NoSheet", 0, 0), @value.Empty)
}
