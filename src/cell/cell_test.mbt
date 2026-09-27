test "Cell::empty" {
  let c = Cell::empty(0, 0)
  assert_true(c.is_empty())
  assert_false(c.has_value())
  assert_false(c.is_formula())
  assert_eq(c.get_value(), @value.Empty)
}

test "Cell::with_value" {
  let c = Cell::with_value(1, 2, @value.Number(42.0))
  assert_true(c.has_value())
  assert_false(c.is_empty())
  assert_false(c.is_formula())
  assert_eq(c.get_value(), @value.Number(42.0))
}

test "Cell::with_formula" {
  let c = Cell::with_formula(0, 0, "=SUM(A1:A3)")
  assert_true(c.is_formula())
  assert_false(c.is_empty())
  assert_false(c.has_value())
  assert_eq(c.get_formula(), "=SUM(A1:A3)")
  assert_true(c.dirty)
}

test "Cell::set_value" {
  let c = Cell::empty(0, 0)
  let c2 = c.set_value(@value.Number(10.0))
  assert_eq(c2.get_value(), @value.Number(10.0))
  assert_true(c2.has_value())
}

test "Cell::set_formula" {
  let c = Cell::empty(0, 0)
  let c2 = c.set_formula("=A1+B1")
  assert_true(c2.is_formula())
  assert_eq(c2.get_formula(), "=A1+B1")
  assert_true(c2.dirty)
}

test "Cell::set_computed" {
  let c = Cell::with_formula(0, 0, "=1+2")
  let c2 = c.set_computed(@value.Number(3.0))
  assert_eq(c2.get_value(), @value.Number(3.0))
  assert_false(c2.dirty)
}

test "Cell::clear" {
  let c = Cell::with_value(0, 0, @value.Number(42.0))
  let c2 = c.clear()
  assert_true(c2.is_empty())
}

test "Cell::cell_type" {
  assert_eq(Cell::empty(0, 0).cell_type(), "empty")
  assert_eq(Cell::with_value(0, 0, @value.Number(1.0)).cell_type(), "number")
  assert_eq(Cell::with_value(0, 0, @value.str("x")).cell_type(), "string")
  assert_eq(Cell::with_value(0, 0, @value.boolean(true)).cell_type(), "boolean")
  assert_eq(Cell::with_formula(0, 0, "=1").cell_type(), "formula")
}

test "col_to_letter" {
  assert_eq(col_to_letter(0), "A")
  assert_eq(col_to_letter(1), "B")
  assert_eq(col_to_letter(25), "Z")
  assert_eq(col_to_letter(26), "AA")
  assert_eq(col_to_letter(27), "AB")
}

test "letter_to_col" {
  assert_eq(letter_to_col("A"), 0)
  assert_eq(letter_to_col("B"), 1)
  assert_eq(letter_to_col("Z"), 25)
  assert_eq(letter_to_col("AA"), 26)
  assert_eq(letter_to_col("AB"), 27)
}

test "Cell::ref_string" {
  assert_eq(Cell::empty(0, 0).ref_string(), "A1")
  assert_eq(Cell::empty(0, 1).ref_string(), "B1")
  assert_eq(Cell::empty(9, 0).ref_string(), "A10")
  assert_eq(Cell::empty(99, 25).ref_string(), "Z100")
}

test "Cell::from_string" {
  let c1 = Cell::from_string(0, 0, "42")
  assert_true(c1.has_value())
  assert_eq(c1.get_value(), @value.Number(42.0))

  let c2 = Cell::from_string(0, 0, "=A1+B1")
  assert_true(c2.is_formula())

  let c3 = Cell::from_string(0, 0, "hello")
  assert_eq(c3.get_value(), @value.Str("hello"))
}

test "Cell::mark_dirty" {
  let c = Cell::with_value(0, 0, @value.Number(1.0))
  let c2 = c.mark_dirty()
  assert_true(c2.dirty)
}

test "Cell::clone" {
  let c = Cell::with_formula(2, 3, "=SUM(A1:A3)")
  let c2 = c.clone()
  assert_eq(c2.row, 2)
  assert_eq(c2.col, 3)
  assert_eq(c2.get_formula(), "=SUM(A1:A3)")
}
