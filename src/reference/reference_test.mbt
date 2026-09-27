test "CellReference::from_a1 A1" {
  let cr = CellReference::from_a1("A1")
  assert_eq(cr.row, 0)
  assert_eq(cr.col, 0)
  assert_false(cr.row_absolute)
  assert_false(cr.col_absolute)
}

test "CellReference::from_a1 B3" {
  let cr = CellReference::from_a1("B3")
  assert_eq(cr.row, 2)
  assert_eq(cr.col, 1)
}

test "CellReference::from_a1 Z1" {
  let cr = CellReference::from_a1("Z1")
  assert_eq(cr.row, 0)
  assert_eq(cr.col, 25)
}

test "CellReference::from_a1 AA1" {
  let cr = CellReference::from_a1("AA1")
  assert_eq(cr.row, 0)
  assert_eq(cr.col, 26)
}

test "CellReference::from_a1 absolute" {
  let cr = CellReference::from_a1("$A$1")
  assert_true(cr.row_absolute)
  assert_true(cr.col_absolute)
}

test "CellReference::from_a1 mixed absolute" {
  let cr = CellReference::from_a1("$A1")
  assert_false(cr.row_absolute)
  assert_true(cr.col_absolute)
}

test "CellReference::to_a1" {
  let cr = CellReference::new(0, 0)
  assert_eq(cr.to_a1(), "A1")

  let cr2 = CellReference::absolute(4, 2)
  assert_eq(cr2.to_a1(), "$C$5")
}

test "CellReference::is_absolute" {
  assert_true(CellReference::absolute(0, 0).is_absolute())
  assert_false(CellReference::new(0, 0).is_absolute())
}

test "CellReference::is_relative" {
  assert_true(CellReference::new(0, 0).is_relative())
  assert_false(CellReference::absolute(0, 0).is_relative())
}

test "parse_cell_ref" {
  let (row, col, ra, ca) = parse_cell_ref("B5")
  assert_eq(row, 4)
  assert_eq(col, 1)
  assert_false(ra)
  assert_false(ca)
}

test "parse_range_ref" {
  let rr = parse_range_ref("A1:B2")
  assert_eq(rr.start.row, 0)
  assert_eq(rr.start.col, 0)
  assert_eq(rr.end.row, 1)
  assert_eq(rr.end.col, 1)
}

test "RangeReference::get_cells" {
  let rr = parse_range_ref("A1:B2")
  let cells = rr.get_cells()
  assert_eq(cells.length(), 4)
}

test "RangeReference::row_count" {
  let rr = parse_range_ref("A1:A5")
  assert_eq(rr.row_count(), 5)
}

test "RangeReference::col_count" {
  let rr = parse_range_ref("A1:E1")
  assert_eq(rr.col_count(), 5)
}

test "RangeReference::cell_count" {
  let rr = parse_range_ref("A1:C3")
  assert_eq(rr.cell_count(), 9)
}

test "RangeReference::to_a1" {
  let rr = parse_range_ref("A1:B2")
  assert_eq(rr.to_a1(), "A1:B2")
}

test "RangeReference::contains" {
  let rr = parse_range_ref("A1:C3")
  assert_true(rr.contains(0, 0))
  assert_true(rr.contains(2, 2))
  assert_false(rr.contains(3, 3))
}

test "col_to_letter" {
  assert_eq(col_to_letter(0), "A")
  assert_eq(col_to_letter(25), "Z")
  assert_eq(col_to_letter(26), "AA")
}

test "letter_to_col" {
  assert_eq(letter_to_col("A"), 0)
  assert_eq(letter_to_col("Z"), 25)
  assert_eq(letter_to_col("AA"), 26)
}

test "is_valid_cell_ref" {
  assert_true(is_valid_cell_ref("A1"))
  assert_true(is_valid_cell_ref("$A$1"))
  assert_true(is_valid_cell_ref("B2"))
  assert_false(is_valid_cell_ref("ABC"))
  assert_false(is_valid_cell_ref("123"))
}

test "is_valid_range_ref" {
  assert_true(is_valid_range_ref("A1:B2"))
  assert_false(is_valid_range_ref("A1"))
  assert_false(is_valid_range_ref("A1:"))
}

test "resolve_relative" {
  let cr = CellReference::new(0, 0)
  let resolved = resolve_relative(cr, 5, 3)
  assert_eq(resolved.row, 5)
  assert_eq(resolved.col, 3)
}

test "range_intersect" {
  let r1 = parse_range_ref("A1:C3")
  let r2 = parse_range_ref("B2:D4")
  match range_intersect(r1, r2) {
    Some(rr) => {
      assert_eq(rr.start.row, 1)
      assert_eq(rr.start.col, 1)
      assert_eq(rr.end.row, 2)
      assert_eq(rr.end.col, 2)
    }
    None => panic("expected Some")
  }
}

test "range_intersect no overlap" {
  let r1 = parse_range_ref("A1:A3")
  let r2 = parse_range_ref("B1:B3")
  match range_intersect(r1, r2) {
    None => ()
    Some(_) => panic("expected None")
  }
}
