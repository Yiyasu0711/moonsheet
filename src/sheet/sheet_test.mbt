test "Sheet::new" {
  let s = Sheet::new("Test")
  assert_eq(s.name, "Test")
  assert_eq(s.max_row, 0)
  assert_eq(s.max_col, 0)
}

test "Sheet::set_value" {
  let s = Sheet::new("Test").set_value(0, 0, @value.Number(42.0))
  assert_eq(s.get_value(0, 0), @value.Number(42.0))
  assert_eq(s.max_row, 0)
  assert_eq(s.max_col, 0)
}

test "Sheet::set_formula" {
  let s = Sheet::new("Test").set_formula(0, 0, "=A1+B1")
  let cell = s.get_cell(0, 0)
  assert_true(cell.is_formula())
  assert_eq(cell.get_formula(), "=A1+B1")
}

test "Sheet::set_str" {
  let s = Sheet::new("Test").set_str(0, 0, "42")
  assert_eq(s.get_value(0, 0), @value.Number(42.0))

  let s2 = Sheet::new("Test").set_str(0, 0, "=A1+B1")
  assert_true(s2.get_cell(0, 0).is_formula())
}

test "Sheet::set_num" {
  let s = Sheet::new("Test").set_num(0, 0, 3.14)
  assert_eq(s.get_value(0, 0), @value.Number(3.14))
}

test "Sheet::clear_cell" {
  let s = Sheet::new("Test").set_value(0, 0, @value.Number(42.0)).clear_cell(0, 0)
  assert_true(s.get_cell(0, 0).is_empty())
}

test "Sheet::get_all_cells" {
  let s = Sheet::new("Test")
    .set_value(0, 0, @value.Number(1.0))
    .set_value(0, 1, @value.Number(2.0))
    .set_formula(1, 0, "=A1+B1")
  let cells = s.get_all_cells()
  assert_eq(cells.length(), 3)
}

test "Sheet::get_formula_cells" {
  let s = Sheet::new("Test")
    .set_value(0, 0, @value.Number(1.0))
    .set_formula(0, 1, "=A1*2")
    .set_formula(1, 0, "=B1+1")
  let fcells = s.get_formula_cells()
  assert_eq(fcells.length(), 2)
}

test "Sheet::has_cell" {
  let s = Sheet::new("Test").set_value(0, 0, @value.Number(1.0))
  assert_true(s.has_cell(0, 0))
  assert_false(s.has_cell(1, 1))
}

test "Sheet::get_range_values" {
  let s = Sheet::new("Test")
    .set_value(0, 0, @value.Number(1.0))
    .set_value(0, 1, @value.Number(2.0))
    .set_value(1, 0, @value.Number(3.0))
    .set_value(1, 1, @value.Number(4.0))
  let vals = s.get_range_values(0, 0, 1, 1)
  assert_eq(vals.length(), 4)
}

test "Sheet::count_cells" {
  let s = Sheet::new("Test")
    .set_value(0, 0, @value.Number(1.0))
    .set_value(0, 1, @value.Number(2.0))
  assert_eq(s.count_cells(), 2)
}

test "Sheet::rename" {
  let s = Sheet::new("Old")
  let s2 = s.rename("New")
  assert_eq(s2.name, "New")
}

test "Sheet::row_count / col_count" {
  let s = Sheet::new("Test")
    .set_value(3, 4, @value.Number(1.0))
  assert_eq(s.row_count(), 4)
  assert_eq(s.col_count(), 5)
}

test "Sheet::get_row" {
  let s = Sheet::new("Test")
    .set_value(0, 0, @value.Number(1.0))
    .set_value(0, 1, @value.Number(2.0))
    .set_value(0, 2, @value.Number(3.0))
  let row = s.get_row(0)
  assert_eq(row.length(), 3)
  assert_eq(row[0], @value.Number(1.0))
}

test "Sheet::from_data" {
  let s = Sheet::from_data("Test", [["1", "2", "3"], ["4", "5", "6"]])
  assert_eq(s.name, "Test")
  assert_eq(s.get_value(0, 0), @value.Number(1.0))
  assert_eq(s.get_value(1, 2), @value.Number(6.0))
}

test "Sheet::range_cell_count" {
  assert_eq(Sheet::range_cell_count(0, 0, 2, 2), 9)
  assert_eq(Sheet::range_cell_count(0, 0, 0, 0), 1)
  assert_eq(Sheet::range_cell_count(0, 0, 3, 4), 20)
}
