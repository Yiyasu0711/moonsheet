test "Value constructors" {
  assert_eq(Value::number(3.14), Number(3.14))
  assert_eq(Value::from_int(42), Number(42.0))
  assert_eq(Value::str("hello"), Str("hello"))
  assert_eq(Value::boolean(true), Bool(true))
  assert_eq(Value::empty(), Empty)
  assert_eq(Value::error(@error.DivZero), Err(@error.DivZero))
}

test "Value::is_number" {
  assert_true(Number(1.0).is_number())
  assert_false(Str("x").is_number())
  assert_false(Bool(true).is_number())
  assert_false(Empty.is_number())
  assert_false(Err(@error.DivZero).is_number())
}

test "Value::is_string" {
  assert_true(Str("x").is_string())
  assert_false(Number(1.0).is_string())
}

test "Value::is_bool" {
  assert_true(Bool(true).is_bool())
  assert_false(Number(1.0).is_bool())
}

test "Value::is_error" {
  assert_true(Err(@error.DivZero).is_error())
  assert_false(Number(1.0).is_error())
}

test "Value::is_empty" {
  assert_true(Empty.is_empty())
  assert_false(Number(0.0).is_empty())
}

test "Value::as_number" {
  assert_eq(Number(42.0).as_number(), Ok(42.0))
  assert_eq(Bool(true).as_number(), Ok(1.0))
  assert_eq(Bool(false).as_number(), Ok(0.0))
  assert_eq(Str("3.14").as_number(), Ok(3.14))
  assert_eq(Str("").as_number(), Ok(0.0))
  assert_eq(Empty.as_number(), Ok(0.0))
  assert_true(Str("abc").as_number().is_err())
}

test "Value::as_string" {
  assert_eq(Str("hi").as_string(), Ok("hi"))
  assert_eq(Number(42.0).as_string(), Ok("42"))
  assert_eq(Bool(true).as_string(), Ok("TRUE"))
  assert_eq(Bool(false).as_string(), Ok("FALSE"))
  assert_eq(Empty.as_string(), Ok(""))
}

test "Value::as_bool" {
  assert_eq(Bool(true).as_bool(), Ok(true))
  assert_eq(Number(1.0).as_bool(), Ok(true))
  assert_eq(Number(0.0).as_bool(), Ok(false))
  assert_eq(Str("true").as_bool(), Ok(true))
  assert_eq(Str("false").as_bool(), Ok(false))
  assert_eq(Empty.as_bool(), Ok(false))
}

test "Value::to_display_string" {
  assert_eq(Str("hello").to_display_string(), "hello")
  assert_eq(Number(42.0).to_display_string(), "42")
  assert_eq(Bool(true).to_display_string(), "TRUE")
  assert_eq(Bool(false).to_display_string(), "FALSE")
  assert_eq(Empty.to_display_string(), "")
  assert_eq(Err(@error.DivZero).to_display_string(), "#DIV/0!")
}

test "Value::truthy" {
  assert_true(Bool(true).truthy())
  assert_false(Bool(false).truthy())
  assert_true(Number(1.0).truthy())
  assert_false(Number(0.0).truthy())
  assert_true(Str("hello").truthy())
  assert_false(Str("").truthy())
  assert_false(Empty.truthy())
}

test "Value::add" {
  assert_eq(Value::add(Number(1.0), Number(2.0)), Number(3.0))
  assert_eq(Value::add(Number(1.0), Bool(true)), Number(2.0))
  assert_eq(Value::add(Str("a"), Str("b")), Str("ab"))
  assert_eq(Value::add(Number(1.0), Empty), Number(1.0))
  assert_eq(Value::add(Empty, Number(2.0)), Number(2.0))
  assert_eq(Value::add(Err(@error.DivZero), Number(1.0)), Err(@error.DivZero))
}

test "Value::subtract" {
  assert_eq(Value::subtract(Number(5.0), Number(3.0)), Number(2.0))
  assert_eq(Value::subtract(Number(5.0), Empty), Number(5.0))
  assert_eq(Value::subtract(Empty, Number(3.0)), Number(-3.0))
}

test "Value::multiply" {
  assert_eq(Value::multiply(Number(3.0), Number(4.0)), Number(12.0))
  assert_eq(Value::multiply(Number(3.0), Bool(true)), Number(3.0))
  assert_eq(Value::multiply(Number(3.0), Bool(false)), Number(0.0))
  assert_eq(Value::multiply(Number(3.0), Empty), Number(0.0))
}

test "Value::divide" {
  assert_eq(Value::divide(Number(6.0), Number(2.0)), Number(3.0))
  assert_eq(Value::divide(Number(6.0), Number(0.0)), Err(@error.DivZero))
  assert_eq(Value::divide(Number(6.0), Bool(false)), Err(@error.DivZero))
}

test "Value::power" {
  assert_eq(Value::power(Number(2.0), Number(3.0)), Number(8.0))
  assert_eq(Value::power(Number(2.0), Number(0.0)), Number(1.0))
  assert_eq(Value::power(Number(2.0), Empty), Number(1.0))
}

test "Value::concat" {
  assert_eq(Value::concat(Str("Hello"), Str(" ")), Str("Hello "))
  assert_eq(Value::concat(Number(42.0), Str(" items")), Str("42 items"))
}

test "Value::negate" {
  assert_eq(Value::negate(Number(5.0)), Number(-5.0))
  assert_eq(Value::negate(Bool(true)), Number(-1.0))
  assert_eq(Value::negate(Empty), Number(0.0))
}

test "Value::compare_values" {
  assert_eq(Value::compare_values(Number(1.0), Number(2.0)), -1)
  assert_eq(Value::compare_values(Number(2.0), Number(1.0)), 1)
  assert_eq(Value::compare_values(Number(1.0), Number(1.0)), 0)
  assert_eq(Value::compare_values(Str("a"), Str("b")), -1)
  assert_eq(Value::compare_values(Empty, Number(1.0)), -1)
}

test "Value::parse" {
  assert_eq(Value::parse("42"), Number(42.0))
  assert_eq(Value::parse("3.14"), Number(3.14))
  assert_eq(Value::parse("TRUE"), Bool(true))
  assert_eq(Value::parse("FALSE"), Bool(false))
  assert_eq(Value::parse(""), Empty)
  assert_eq(Value::parse("hello"), Str("hello"))
  assert_eq(Value::parse("#DIV/0!"), Err(@error.DivZero))
}

test "Value::type_number" {
  assert_eq(Number(1.0).type_number(), 1)
  assert_eq(Str("x").type_number(), 2)
  assert_eq(Bool(true).type_number(), 4)
  assert_eq(Err(@error.DivZero).type_number(), 16)
  assert_eq(Empty.type_number(), 17)
}
