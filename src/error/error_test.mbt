test "ErrorValue::to_error_string" {
  assert_eq(DivZero.to_error_string(), "#DIV/0!")
  assert_eq(NotAvailable.to_error_string(), "#N/A")
  assert_eq(NameError.to_error_string(), "#NAME?")
  assert_eq(NullError.to_error_string(), "#NULL!")
  assert_eq(NumError.to_error_string(), "#NUM!")
  assert_eq(RefError.to_error_string(), "#REF!")
  assert_eq(ValueError.to_error_string(), "#VALUE!")
  assert_eq(CircularRef.to_error_string(), "#CIRC!")
  assert_eq(GenericError("test").to_error_string(), "#ERROR!: test")
}

test "ErrorValue::from_string" {
  assert_eq(ErrorValue::from_string("#DIV/0!"), DivZero)
  assert_eq(ErrorValue::from_string("#N/A"), NotAvailable)
  assert_eq(ErrorValue::from_string("#NAME?"), NameError)
  assert_eq(ErrorValue::from_string("#VALUE!"), ValueError)
  assert_eq(ErrorValue::from_string("#REF!"), RefError)
  assert_eq(ErrorValue::from_string("#NUM!"), NumError)
  assert_eq(ErrorValue::from_string("#NULL!"), NullError)
  assert_eq(ErrorValue::from_string("#CIRC!"), CircularRef)
}

test "ErrorValue::error_type" {
  assert_eq(NullError.error_type(), 1)
  assert_eq(DivZero.error_type(), 2)
  assert_eq(ValueError.error_type(), 3)
  assert_eq(RefError.error_type(), 4)
  assert_eq(NameError.error_type(), 5)
  assert_eq(NumError.error_type(), 6)
  assert_eq(NotAvailable.error_type(), 7)
}

test "ErrorValue::is_same_type" {
  assert_true(DivZero.is_same_type(DivZero))
  assert_false(DivZero.is_same_type(NumError))
  assert_true(GenericError("a").is_same_type(GenericError("b")))
}

test "ErrorValue::description" {
  assert_eq(DivZero.description(), "Division by zero")
  assert_eq(NameError.description(), "Unrecognized name or function")
  assert_eq(CircularRef.description(), "Circular reference detected")
}

test "ErrorValue predicates" {
  assert_true(DivZero.is_div_zero())
  assert_true(NotAvailable.is_not_available())
  assert_true(NameError.is_name_error())
  assert_true(NumError.is_num_error())
  assert_true(RefError.is_ref_error())
  assert_true(ValueError.is_value_error())
  assert_true(CircularRef.is_circular_ref())
  assert_true(GenericError("x").is_generic_error())
  assert_false(DivZero.is_name_error())
}
