test "Lexer: number" {
  let tokens = tokenize("42")
  assert_eq(tokens[0].kind, @token.Number)
  assert_eq(tokens[0].value, "42")
}

test "Lexer: decimal number" {
  let tokens = tokenize("3.14")
  assert_eq(tokens[0].kind, @token.Number)
  assert_eq(tokens[0].value, "3.14")
}

test "Lexer: scientific notation" {
  let tokens = tokenize("1e10")
  assert_eq(tokens[0].kind, @token.Number)
  assert_eq(tokens[0].value, "1e10")
}

test "Lexer: string literal" {
  let tokens = tokenize("\"hello\"")
  assert_eq(tokens[0].kind, @token.StringLit)
  assert_eq(tokens[0].value, "hello")
}

test "Lexer: string with escapes" {
  let tokens = tokenize("\"hello\\nworld\"")
  assert_eq(tokens[0].value, "hello\nworld")
}

test "Lexer: boolean TRUE" {
  let tokens = tokenize("TRUE")
  assert_eq(tokens[0].kind, @token.BoolLit)
  assert_eq(tokens[0].value, "TRUE")
}

test "Lexer: boolean FALSE" {
  let tokens = tokenize("FALSE")
  assert_eq(tokens[0].kind, @token.BoolLit)
}

test "Lexer: cell reference A1" {
  let tokens = tokenize("A1")
  assert_eq(tokens[0].kind, @token.CellRef)
  assert_eq(tokens[0].value, "A1")
}

test "Lexer: absolute cell reference" {
  let tokens = tokenize("$A$1")
  assert_eq(tokens[0].kind, @token.CellRef)
  assert_eq(tokens[0].value, "$A$1")
}

test "Lexer: function name" {
  let tokens = tokenize("SUM")
  assert_eq(tokens[0].kind, @token.Identifier)
  assert_eq(tokens[0].value, "SUM")
}

test "Lexer: simple expression" {
  let tokens = tokenize("1+2")
  assert_eq(tokens[0].kind, @token.Number)
  assert_eq(tokens[1].kind, @token.Plus)
  assert_eq(tokens[2].kind, @token.Number)
  assert_eq(tokens[3].kind, @token.EOF)
}

test "Lexer: comparison operators" {
  let tokens = tokenize("A1<>B2")
  assert_eq(tokens[0].kind, @token.CellRef)
  assert_eq(tokens[1].kind, @token.NotEqual)
  assert_eq(tokens[2].kind, @token.CellRef)
}

test "Lexer: less than or equal" {
  let tokens = tokenize("A1<=B2")
  assert_eq(tokens[1].kind, @token.LessEqual)
}

test "Lexer: greater than or equal" {
  let tokens = tokenize("A1>=B2")
  assert_eq(tokens[1].kind, @token.GreaterEqual)
}

test "Lexer: parentheses and comma" {
  let tokens = tokenize("SUM(A1,B2)")
  assert_eq(tokens[0].kind, @token.Identifier)
  assert_eq(tokens[1].kind, @token.LParen)
  assert_eq(tokens[2].kind, @token.CellRef)
  assert_eq(tokens[3].kind, @token.Comma)
  assert_eq(tokens[4].kind, @token.CellRef)
  assert_eq(tokens[5].kind, @token.RParen)
}

test "Lexer: power and percent" {
  let tokens = tokenize("A1^2%")
  assert_eq(tokens[1].kind, @token.Caret)
  assert_eq(tokens[3].kind, @token.Percent)
}

test "Lexer: ampersand concatenation" {
  let tokens = tokenize("\"a\"&\"b\"")
  assert_eq(tokens[1].kind, @token.Ampersand)
}

test "Lexer: strip leading equals" {
  let tokens = tokenize("=1+2")
  assert_eq(tokens[0].kind, @token.Number)
  assert_eq(tokens[0].value, "1")
}

test "Lexer: complex formula" {
  let tokens = tokenize("=IF(A1>0,SUM(B1:B10),0)")
  assert_eq(tokens[0].kind, @token.Identifier)
  assert_eq(tokens[0].value, "IF")
  assert_eq(tokens[1].kind, @token.LParen)
  assert_eq(tokens[2].kind, @token.CellRef)
  assert_eq(tokens[3].kind, @token.GreaterThan)
  assert_eq(tokens[4].kind, @token.Number)
}

test "Lexer: whitespace handling" {
  let tokens = tokenize("  1  +  2  ")
  assert_eq(tokens[0].kind, @token.Number)
  assert_eq(tokens[1].kind, @token.Plus)
  assert_eq(tokens[2].kind, @token.Number)
}

test "Lexer: EOF at end" {
  let tokens = tokenize("42")
  assert_eq(tokens[tokens.length() - 1].kind, @token.EOF)
}
