test "format_value" {
  assert_eq(format_value(@value.Number(42.0)), "42")
  assert_eq(format_value(@value.Str("hello")), "hello")
  assert_eq(format_value(@value.Bool(true)), "TRUE")
  assert_eq(format_value(@value.Empty), "")
  assert_eq(format_value(@value.Err(@error.DivZero)), "#DIV/0!")
}

test "format_thousands" {
  assert_eq(format_thousands(0), "0")
  assert_eq(format_thousands(1000), "1,000")
  assert_eq(format_thousands(1234567), "1,234,567")
  assert_eq(format_thousands(-1000), "-1,000")
}

test "auto_format" {
  assert_eq(auto_format(@value.Number(42.0)), "42")
  assert_eq(auto_format(@value.Number(3.14)), "3.14")
  assert_eq(auto_format(@value.Str("test")), "test")
  assert_eq(auto_format(@value.Bool(true)), "TRUE")
  assert_eq(auto_format(@value.Empty), "")
}

test "format_number_with_pattern general" {
  assert_eq(format_number_with_pattern(42.0, "general"), "42")
  assert_eq(format_number_with_pattern(3.14, "General"), "3.14")
}

test "format_number_with_pattern 0" {
  assert_eq(format_number_with_pattern(3.7, "0"), "3")
  assert_eq(format_number_with_pattern(42.0, "0"), "42")
}

test "format_number_with_pattern 0.00" {
  let result = format_number_with_pattern(3.14159, "0.00")
  assert_true(result.contains("3.14"))
}

test "format_number_with_pattern percent" {
  assert_eq(format_number_with_pattern(0.5, "0%"), "50%")
}

test "format_number_with_pattern thousands" {
  assert_eq(format_number_with_pattern(1234.0, "#,##0"), "1,234")
}

test "format_currency" {
  let result = format_currency(@value.Number(42.5), "$")
  assert_true(result.contains("$"))
}

test "format_percent" {
  let result = format_percent(@value.Number(0.5), 0)
  assert_eq(result, "50%")
}

test "format_range" {
  let sheet = @sheet.Sheet::with_default()
    .set_value(0, 0, @value.Number(1.0))
    .set_value(0, 1, @value.Number(2.0))
  let result = format_range(sheet, 0, 0, 0, 1)
  assert_true(result.contains("1"))
  assert_true(result.contains("2"))
}
