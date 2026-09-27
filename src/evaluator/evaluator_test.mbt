test "eval: number literal" {
  match parse("42") {
    Some(expr) => {
      let sheet = @sheet.Sheet::with_default()
      let result = eval_formula("42", sheet)
      assert_eq(result, @value.Number(42.0))
    }
    None => panic("parse failed")
  }
}

test "eval: addition" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("1+2", sheet)
  assert_eq(result, @value.Number(3.0))
}

test "eval: subtraction" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("10-3", sheet)
  assert_eq(result, @value.Number(7.0))
}

test "eval: multiplication" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("3*4", sheet)
  assert_eq(result, @value.Number(12.0))
}

test "eval: division" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("10/2", sheet)
  assert_eq(result, @value.Number(5.0))
}

test "eval: division by zero" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("10/0", sheet)
  assert_eq(result, @value.Err(@error.DivZero))
}

test "eval: power" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("2^3", sheet)
  assert_eq(result, @value.Number(8.0))
}

test "eval: concatenation" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("\"Hello\"&\" \"&\"World\"", sheet)
  assert_eq(result, @value.Str("Hello World"))
}

test "eval: parentheses" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("(1+2)*3", sheet)
  assert_eq(result, @value.Number(9.0))
}

test "eval: operator precedence" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("1+2*3", sheet)
  assert_eq(result, @value.Number(7.0))
}

test "eval: unary minus" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("-5", sheet)
  assert_eq(result, @value.Number(-5.0))
}

test "eval: comparison equal" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("1=1", sheet)
  assert_eq(result, @value.Bool(true))
}

test "eval: comparison not equal" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("1<>2", sheet)
  assert_eq(result, @value.Bool(true))
}

test "eval: comparison less than" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("1<2", sheet)
  assert_eq(result, @value.Bool(true))
}

test "eval: SUM function" {
  let sheet = @sheet.Sheet::with_default()
    .set_value(0, 0, @value.Number(1.0))
    .set_value(0, 1, @value.Number(2.0))
    .set_value(0, 2, @value.Number(3.0))
  let result = eval_formula("SUM(A1:C1)", sheet)
  assert_eq(result, @value.Number(6.0))
}

test "eval: AVERAGE function" {
  let sheet = @sheet.Sheet::with_default()
    .set_value(0, 0, @value.Number(2.0))
    .set_value(0, 1, @value.Number(4.0))
    .set_value(0, 2, @value.Number(6.0))
  let result = eval_formula("AVERAGE(A1:C1)", sheet)
  assert_eq(result, @value.Number(4.0))
}

test "eval: MAX function" {
  let sheet = @sheet.Sheet::with_default()
    .set_value(0, 0, @value.Number(1.0))
    .set_value(0, 1, @value.Number(5.0))
    .set_value(0, 2, @value.Number(3.0))
  let result = eval_formula("MAX(A1:C1)", sheet)
  assert_eq(result, @value.Number(5.0))
}

test "eval: MIN function" {
  let sheet = @sheet.Sheet::with_default()
    .set_value(0, 0, @value.Number(1.0))
    .set_value(0, 1, @value.Number(5.0))
    .set_value(0, 2, @value.Number(3.0))
  let result = eval_formula("MIN(A1:C1)", sheet)
  assert_eq(result, @value.Number(1.0))
}

test "eval: IF function true" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("IF(1>0,100,200)", sheet)
  assert_eq(result, @value.Number(100.0))
}

test "eval: IF function false" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("IF(1<0,100,200)", sheet)
  assert_eq(result, @value.Number(200.0))
}

test "eval: IFERROR function" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("IFERROR(1/0,\"error\")", sheet)
  assert_eq(result, @value.Str("error"))
}

test "eval: cell reference" {
  let sheet = @sheet.Sheet::with_default()
    .set_value(0, 0, @value.Number(42.0))
  let result = eval_formula("A1", sheet)
  assert_eq(result, @value.Number(42.0))
}

test "eval: cell reference in formula" {
  let sheet = @sheet.Sheet::with_default()
    .set_value(0, 0, @value.Number(10.0))
    .set_value(0, 1, @value.Number(20.0))
  let result = eval_formula("A1+B1", sheet)
  assert_eq(result, @value.Number(30.0))
}

test "eval: nested function call" {
  let sheet = @sheet.Sheet::with_default()
    .set_value(0, 0, @value.Number(1.0))
    .set_value(0, 1, @value.Number(2.0))
    .set_value(0, 2, @value.Number(3.0))
  let result = eval_formula("SUM(A1:C1)*2", sheet)
  assert_eq(result, @value.Number(12.0))
}

test "eval: ABS function" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("ABS(-5)", sheet)
  assert_eq(result, @value.Number(5.0))
}

test "eval: SQRT function" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("SQRT(16)", sheet)
  assert_eq(result, @value.Number(4.0))
}

test "eval: ROUND function" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("ROUND(3.14159,2)", sheet)
  match result {
    @value.Number(n) => assert_true(n >= 3.14 && n <= 3.15)
    _ => panic("expected Number")
  }
}

test "eval: POWER function" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("POWER(2,3)", sheet)
  assert_eq(result, @value.Number(8.0))
}

test "eval: UPPER function" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("UPPER(\"hello\")", sheet)
  assert_eq(result, @value.Str("HELLO"))
}

test "eval: LOWER function" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("LOWER(\"HELLO\")", sheet)
  assert_eq(result, @value.Str("hello"))
}

test "eval: LEN function" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("LEN(\"hello\")", sheet)
  assert_eq(result, @value.Number(5.0))
}

test "eval: CONCAT function" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("CONCAT(\"a\",\"b\",\"c\")", sheet)
  assert_eq(result, @value.Str("abc"))
}

test "eval: AND function" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("AND(TRUE,TRUE)", sheet)
  assert_eq(result, @value.Bool(true))
}

test "eval: OR function" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("OR(TRUE,FALSE)", sheet)
  assert_eq(result, @value.Bool(true))
}

test "eval: NOT function" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("NOT(FALSE)", sheet)
  assert_eq(result, @value.Bool(true))
}

test "eval: PI function" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("PI()", sheet)
  match result {
    @value.Number(n) => assert_true(n > 3.0 && n < 4.0)
    _ => panic("expected Number")
  }
}

test "eval: unknown function" {
  let sheet = @sheet.Sheet::with_default()
  let result = eval_formula("UNKNOWNFN(1)", sheet)
  assert_eq(result, @value.Err(@error.NameError))
}

test "eval_sheet" {
  let sheet = @sheet.Sheet::with_default()
    .set_value(0, 0, @value.Number(1.0))
    .set_value(0, 1, @value.Number(2.0))
    .set_formula(0, 2, "=SUM(A1:B1)")
  let evaluated = eval_sheet(sheet)
  assert_eq(evaluated.get_value(0, 2), @value.Number(3.0))
}

test "eval_workbook" {
  let wb = @workbook.Workbook::with_default("Test")
    .set_value("Sheet1", 0, 0, @value.Number(10.0))
    .set_value("Sheet1", 0, 1, @value.Number(20.0))
    .set_formula("Sheet1", 0, 2, "=A1+B1")
  let evaluated = eval_workbook(wb)
  assert_eq(evaluated.get_value("Sheet1", 0, 2), @value.Number(30.0))
}

test "get_cell_dependencies" {
  let sheet = @sheet.Sheet::with_default()
    .set_value(0, 0, @value.Number(1.0))
    .set_value(0, 1, @value.Number(2.0))
    .set_formula(0, 2, "=A1+B1")
  let deps = get_cell_dependencies(sheet, 0, 2)
  assert_eq(deps.length(), 2)
}
