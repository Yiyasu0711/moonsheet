test "parse number" {
  match parse("42") {
    Some(@ast.NumLit(n)) => assert_eq(n, 42.0)
    _ => panic("expected NumLit")
  }
}

test "parse decimal" {
  match parse("3.14") {
    Some(@ast.NumLit(n)) => assert_eq(n, 3.14)
    _ => panic("expected NumLit")
  }
}

test "parse string literal" {
  match parse("\"hello\"") {
    Some(@ast.StrLit(s)) => assert_eq(s, "hello")
    _ => panic("expected StrLit")
  }
}

test "parse boolean" {
  match parse("TRUE") {
    Some(@ast.BoolLit(true)) => ()
    _ => panic("expected BoolLit true")
  }
  match parse("FALSE") {
    Some(@ast.BoolLit(false)) => ()
    _ => panic("expected BoolLit false")
  }
}

test "parse cell reference" {
  match parse("A1") {
    Some(@ast.CellRef(row, col, _, _)) => {
      assert_eq(row, 0)
      assert_eq(col, 0)
    }
    _ => panic("expected CellRef")
  }
}

test "parse absolute cell reference" {
  match parse("$A$1") {
    Some(@ast.CellRef(row, col, ra, ca)) => {
      assert_eq(row, 0)
      assert_eq(col, 0)
      assert_true(ra)
      assert_true(ca)
    }
    _ => panic("expected CellRef")
  }
}

test "parse range reference" {
  match parse("A1:B2") {
    Some(@ast.RangeRef(r1, c1, r2, c2, _, _, _, _)) => {
      assert_eq(r1, 0)
      assert_eq(c1, 0)
      assert_eq(r2, 1)
      assert_eq(c2, 1)
    }
    _ => panic("expected RangeRef")
  }
}

test "parse simple addition" {
  match parse("1+2") {
    Some(@ast.BinaryOp(@ast.Add, @ast.NumLit(_), @ast.NumLit(_))) => ()
    _ => panic("expected BinaryOp Add")
  }
}

test "parse subtraction" {
  match parse("10-3") {
    Some(@ast.BinaryOp(@ast.Subtract, _, _)) => ()
    _ => panic("expected BinaryOp Subtract")
  }
}

test "parse multiplication" {
  match parse("3*4") {
    Some(@ast.BinaryOp(@ast.Multiply, _, _)) => ()
    _ => panic("expected BinaryOp Multiply")
  }
}

test "parse division" {
  match parse("10/2") {
    Some(@ast.BinaryOp(@ast.Divide, _, _)) => ()
    _ => panic("expected BinaryOp Divide")
  }
}

test "parse power" {
  match parse("2^3") {
    Some(@ast.BinaryOp(@ast.Power, _, _)) => ()
    _ => panic("expected BinaryOp Power")
  }
}

test "parse concatenation" {
  match parse("\"a\"&\"b\"") {
    Some(@ast.BinaryOp(@ast.Concat, _, _)) => ()
    _ => panic("expected BinaryOp Concat")
  }
}

test "parse comparison equal" {
  match parse("A1=B1") {
    Some(@ast.BinaryOp(@ast.Equal, _, _)) => ()
    _ => panic("expected BinaryOp Equal")
  }
}

test "parse comparison not equal" {
  match parse("A1<>B1") {
    Some(@ast.BinaryOp(@ast.NotEqual, _, _)) => ()
    _ => panic("expected BinaryOp NotEqual")
  }
}

test "parse comparison less than" {
  match parse("A1<B1") {
    Some(@ast.BinaryOp(@ast.LessThan, _, _)) => ()
    _ => panic("expected BinaryOp LessThan")
  }
}

test "parse comparison greater than" {
  match parse("A1>B1") {
    Some(@ast.BinaryOp(@ast.GreaterThan, _, _)) => ()
    _ => panic("expected BinaryOp GreaterThan")
  }
}

test "parse unary minus" {
  match parse("-5") {
    Some(@ast.UnaryOp(@ast.Negate, @ast.NumLit(_))) => ()
    _ => panic("expected UnaryOp Negate")
  }
}

test "parse parenthesized expression" {
  match parse("(1+2)") {
    Some(@ast.BinaryOp(@ast.Add, _, _)) => ()
    _ => panic("expected BinaryOp Add")
  }
}

test "parse function call no args" {
  match parse("PI()") {
    Some(@ast.FuncCall(name, args)) => {
      assert_eq(name, "PI")
      assert_eq(args.length(), 0)
    }
    _ => panic("expected FuncCall")
  }
}

test "parse function call with args" {
  match parse("SUM(1,2,3)") {
    Some(@ast.FuncCall(name, args)) => {
      assert_eq(name, "SUM")
      assert_eq(args.length(), 3)
    }
    _ => panic("expected FuncCall")
  }
}

test "parse nested function call" {
  match parse("SUM(A1:A3,MAX(B1:B3))") {
    Some(@ast.FuncCall(name, args)) => {
      assert_eq(name, "SUM")
      assert_eq(args.length(), 2)
    }
    _ => panic("expected FuncCall")
  }
}

test "parse operator precedence" {
  match parse("1+2*3") {
    Some(@ast.BinaryOp(@ast.Add, _, @ast.BinaryOp(@ast.Multiply, _, _))) => ()
    _ => panic("expected Add with Multiply as right operand")
  }
}

test "parse power right associative" {
  match parse("2^3^2") {
    Some(@ast.BinaryOp(@ast.Power, _, @ast.BinaryOp(@ast.Power, _, _))) => ()
    _ => panic("expected right-associative Power")
  }
}

test "parse complex expression" {
  let result = parse("IF(A1>0,SUM(B1:B10),0)")
  assert_true(result.is_some())
}

test "parse expression with cell refs" {
  match parse("A1+B1*C1-D1") {
    Some(_) => ()
    None => panic("expected Some")
  }
}

test "parse with leading equals" {
  match parse("=A1+B1") {
    Some(@ast.BinaryOp(@ast.Add, _, _)) => ()
    _ => panic("expected BinaryOp Add")
  }
}

test "Expr::get_cell_refs" {
  match parse("A1+B2") {
    Some(expr) => {
      let refs = expr.get_cell_refs()
      assert_eq(refs.length(), 2)
    }
    None => panic("expected Some")
  }
}

test "Expr::get_cell_refs range" {
  match parse("A1:B3") {
    Some(expr) => {
      let refs = expr.get_cell_refs()
      assert_eq(refs.length(), 6)
    }
    None => panic("expected Some")
  }
}

test "Expr::count_nodes" {
  match parse("1+2*3") {
    Some(expr) => assert_eq(expr.count_nodes(), 5)
    None => panic("expected Some")
  }
}

test "Expr::to_string" {
  match parse("1+2") {
    Some(expr) => {
      let s = expr.to_string()
      assert_true(s.contains("+"))
    }
    None => panic("expected Some")
  }
}
