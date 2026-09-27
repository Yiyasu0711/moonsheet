test "fn_sum" {
  assert_eq(fn_sum([@value.Number(1.0), @value.Number(2.0), @value.Number(3.0)]), @value.Number(6.0))
  assert_eq(fn_sum([@value.Number(1.0), @value.Bool(true)]), @value.Number(2.0))
  assert_eq(fn_sum([@value.Empty]), @value.Number(0.0))
}

test "fn_product" {
  assert_eq(fn_product([@value.Number(2.0), @value.Number(3.0), @value.Number(4.0)]), @value.Number(24.0))
  assert_eq(fn_product([@value.Number(5.0), @value.Bool(false)]), @value.Number(0.0))
}

test "fn_abs" {
  assert_eq(fn_abs([@value.Number(-5.0)]), @value.Number(5.0))
  assert_eq(fn_abs([@value.Number(5.0)]), @value.Number(5.0))
}

test "fn_round" {
  match fn_round([@value.Number(3.14159), @value.Number(2.0)]) {
    @value.Number(n) => assert_true(n >= 3.14 && n <= 3.15)
    _ => panic("expected Number")
  }
}

test "fn_floor" {
  assert_eq(fn_floor([@value.Number(3.7)]), @value.Number(3.0))
  assert_eq(fn_floor([@value.Number(-3.2)]), @value.Number(-4.0))
}

test "fn_ceiling" {
  assert_eq(fn_ceiling([@value.Number(3.2)]), @value.Number(4.0))
  assert_eq(fn_ceiling([@value.Number(3.0)]), @value.Number(3.0))
}

test "fn_mod" {
  assert_eq(fn_mod([@value.Number(10.0), @value.Number(3.0)]), @value.Number(1.0))
  assert_eq(fn_mod([@value.Number(10.0), @value.Number(0.0)]), @value.Err(@error.DivZero))
}

test "fn_power" {
  assert_eq(fn_power([@value.Number(2.0), @value.Number(3.0)]), @value.Number(8.0))
  assert_eq(fn_power([@value.Number(2.0), @value.Number(0.0)]), @value.Number(1.0))
}

test "fn_sqrt" {
  assert_eq(fn_sqrt([@value.Number(16.0)]), @value.Number(4.0))
  assert_eq(fn_sqrt([@value.Number(-1.0)]), @value.Err(@error.NumError))
}

test "fn_min" {
  assert_eq(fn_min([@value.Number(3.0), @value.Number(1.0), @value.Number(2.0)]), @value.Number(1.0))
}

test "fn_max" {
  assert_eq(fn_max([@value.Number(3.0), @value.Number(1.0), @value.Number(2.0)]), @value.Number(3.0))
}

test "fn_pi" {
  match fn_pi([]) {
    @value.Number(n) => assert_true(n > 3.0 && n < 4.0)
    _ => panic("expected Number")
  }
}

test "fn_sign" {
  assert_eq(fn_sign([@value.Number(5.0)]), @value.Number(1.0))
  assert_eq(fn_sign([@value.Number(-5.0)]), @value.Number(-1.0))
  assert_eq(fn_sign([@value.Number(0.0)]), @value.Number(0.0))
}

test "fn_if true" {
  assert_eq(fn_if([@value.Bool(true), @value.Number(1.0), @value.Number(2.0)]), @value.Number(1.0))
}

test "fn_if false" {
  assert_eq(fn_if([@value.Bool(false), @value.Number(1.0), @value.Number(2.0)]), @value.Number(2.0))
}

test "fn_and" {
  assert_eq(fn_and([@value.Bool(true), @value.Bool(true)]), @value.Bool(true))
  assert_eq(fn_and([@value.Bool(true), @value.Bool(false)]), @value.Bool(false))
}

test "fn_or" {
  assert_eq(fn_or([@value.Bool(false), @value.Bool(true)]), @value.Bool(true))
  assert_eq(fn_or([@value.Bool(false), @value.Bool(false)]), @value.Bool(false))
}

test "fn_not" {
  assert_eq(fn_not([@value.Bool(true)]), @value.Bool(false))
  assert_eq(fn_not([@value.Bool(false)]), @value.Bool(true))
}

test "fn_xor" {
  assert_eq(fn_xor([@value.Bool(true), @value.Bool(false)]), @value.Bool(true))
  assert_eq(fn_xor([@value.Bool(true), @value.Bool(true)]), @value.Bool(false))
}

test "fn_iferror" {
  assert_eq(fn_iferror([@value.Number(1.0), @value.Number(0.0)]), @value.Number(1.0))
  assert_eq(fn_iferror([@value.Err(@error.DivZero), @value.Number(0.0)]), @value.Number(0.0))
}

test "fn_true / fn_false" {
  assert_eq(fn_true([]), @value.Bool(true))
  assert_eq(fn_false([]), @value.Bool(false))
}

test "fn_isnumber" {
  assert_eq(fn_isnumber([@value.Number(1.0)]), @value.Bool(true))
  assert_eq(fn_isnumber([@value.Str("a")]), @value.Bool(false))
}

test "fn_istext" {
  assert_eq(fn_istext([@value.Str("a")]), @value.Bool(true))
  assert_eq(fn_istext([@value.Number(1.0)]), @value.Bool(false))
}

test "fn_iserror" {
  assert_eq(fn_iserror([@value.Err(@error.DivZero)]), @value.Bool(true))
  assert_eq(fn_iserror([@value.Number(1.0)]), @value.Bool(false))
}

test "fn_isempty" {
  assert_eq(fn_isempty([@value.Empty]), @value.Bool(true))
  assert_eq(fn_isempty([@value.Number(1.0)]), @value.Bool(false))
}

test "fn_left" {
  assert_eq(fn_left([@value.Str("hello"), @value.Number(3.0)]), @value.Str("hel"))
  assert_eq(fn_left([@value.Str("hello")]), @value.Str("h"))
}

test "fn_right" {
  assert_eq(fn_right([@value.Str("hello"), @value.Number(2.0)]), @value.Str("lo"))
  assert_eq(fn_right([@value.Str("hello")]), @value.Str("o"))
}

test "fn_mid" {
  assert_eq(fn_mid([@value.Str("hello"), @value.Number(2.0), @value.Number(3.0)]), @value.Str("ell"))
}

test "fn_len" {
  assert_eq(fn_len([@value.Str("hello")]), @value.Number(5.0))
}

test "fn_upper" {
  assert_eq(fn_upper([@value.Str("hello")]), @value.Str("HELLO"))
}

test "fn_lower" {
  assert_eq(fn_lower([@value.Str("HELLO")]), @value.Str("hello"))
}

test "fn_trim" {
  assert_eq(fn_trim([@value.Str("  hello  ")]), @value.Str("hello"))
}

test "fn_concat" {
  assert_eq(fn_concat([@value.Str("a"), @value.Str("b"), @value.Str("c")]), @value.Str("abc"))
}

test "fn_value" {
  assert_eq(fn_value([@value.Str("42")]), @value.Number(42.0))
  assert_eq(fn_value([@value.Str("3.14")]), @value.Number(3.14))
}

test "fn_average" {
  assert_eq(fn_average([@value.Number(2.0), @value.Number(4.0), @value.Number(6.0)]), @value.Number(4.0))
}

test "fn_count" {
  assert_eq(fn_count([@value.Number(1.0), @value.Str("2"), @value.Str("a")]), @value.Number(2.0))
}

test "fn_counta" {
  assert_eq(fn_counta([@value.Number(1.0), @value.Empty, @value.Str("a")]), @value.Number(2.0))
}

test "fn_median odd" {
  assert_eq(fn_median([@value.Number(1.0), @value.Number(3.0), @value.Number(2.0)]), @value.Number(2.0))
}

test "fn_median even" {
  match fn_median([@value.Number(1.0), @value.Number(2.0), @value.Number(3.0), @value.Number(4.0)]) {
    @value.Number(n) => assert_true(n >= 2.0 && n <= 3.0)
    _ => panic("expected Number")
  }
}

test "dispatch SUM" {
  assert_eq(dispatch("SUM", [@value.Number(1.0), @value.Number(2.0)]), @value.Number(3.0))
  assert_eq(dispatch("sum", [@value.Number(1.0), @value.Number(2.0)]), @value.Number(3.0))
}

test "dispatch unknown" {
  assert_eq(dispatch("UNKNOWN", []), @value.Err(@error.NameError))
}

test "has_function" {
  assert_true(has_function("SUM"))
  assert_true(has_function("sum"))
  assert_false(has_function("UNKNOWNFN"))
}

test "function_count" {
  let count = function_count()
  assert_true(count > 80)
}

test "list_functions" {
  let fns = list_functions()
  assert_true(fns.length() > 80)
  assert_true(fns.contains("SUM"))
  assert_true(fns.contains("IF"))
  assert_true(fns.contains("AVERAGE"))
}

test "function_category" {
  assert_eq(function_category("SUM"), "Math")
  assert_eq(function_category("LEFT"), "Text")
  assert_eq(function_category("IF"), "Logical")
  assert_eq(function_category("DATE"), "Date/Time")
  assert_eq(function_category("AVERAGE"), "Statistical")
}

test "fn_exp" {
  match fn_exp([@value.Number(0.0)]) {
    @value.Number(n) => assert_true(n >= 0.9 && n <= 1.1)
    _ => panic("expected Number")
  }
}

test "fn_ln" {
  match fn_ln([@value.Number(1.0)]) {
    @value.Number(n) => assert_true(n >= -0.1 && n <= 0.1)
    _ => panic("expected Number")
  }
}

test "fn_fact" {
  assert_eq(fn_fact([@value.Number(5.0)]), @value.Number(120.0))
  assert_eq(fn_fact([@value.Number(0.0)]), @value.Number(1.0))
}

test "fn_sumsq" {
  assert_eq(fn_sumsq([@value.Number(2.0), @value.Number(3.0)]), @value.Number(13.0))
}

test "fn_gcd" {
  assert_eq(fn_gcd([@value.Number(12.0), @value.Number(8.0)]), @value.Number(4.0))
}

test "fn_lcm" {
  assert_eq(fn_lcm([@value.Number(4.0), @value.Number(6.0)]), @value.Number(12.0))
}

test "fn_rept" {
  assert_eq(fn_rept([@value.Str("ab"), @value.Number(3.0)]), @value.Str("ababab"))
}

test "fn_proper" {
  assert_eq(fn_proper([@value.Str("hello world")]), @value.Str("Hello World"))
}

test "fn_char" {
  assert_eq(fn_char([@value.Number(65.0)]), @value.Str("A"))
}

test "fn_code" {
  assert_eq(fn_code([@value.Str("A")]), @value.Number(65.0))
}

test "fn_exact" {
  assert_eq(fn_exact([@value.Str("hello"), @value.Str("hello")]), @value.Bool(true))
  assert_eq(fn_exact([@value.Str("hello"), @value.Str("Hello")]), @value.Bool(false))
}

test "fn_na" {
  assert_eq(fn_na([]), @value.Err(@error.NotAvailable))
}

test "fn_error_type" {
  assert_eq(fn_error_type([@value.Err(@error.DivZero)]), @value.Number(2.0))
}

test "fn_large" {
  assert_eq(fn_large([@value.Number(1.0), @value.Number(5.0), @value.Number(3.0), @value.Number(2.0)]), @value.Number(5.0))
}

test "fn_small" {
  assert_eq(fn_small([@value.Number(5.0), @value.Number(1.0), @value.Number(3.0), @value.Number(2.0)]), @value.Number(1.0))
}

test "fn_rank" {
  match fn_rank([@value.Number(5.0), @value.Number(1.0), @value.Number(5.0), @value.Number(3.0)]) {
    @value.Number(n) => assert_eq(n, 1.0)
    _ => panic("expected Number")
  }
}

test "fn_stdev" {
  match fn_stdev([@value.Number(2.0), @value.Number(4.0), @value.Number(4.0), @value.Number(4.0), @value.Number(5.0), @value.Number(5.0), @value.Number(7.0), @value.Number(9.0)]) {
    @value.Number(n) => assert_true(n > 2.0 && n < 3.0)
    _ => panic("expected Number")
  }
}

test "fn_var" {
  match fn_var([@value.Number(2.0), @value.Number(4.0), @value.Number(6.0)]) {
    @value.Number(n) => assert_true(n > 0.0)
    _ => panic("expected Number")
  }
}
