// MoonSheet Parser
// Recursive descent parser for spreadsheet formulas

/// Parser state
pub struct Parser {
  pub tokens : Array[@token.Token]
  pub pos : Int
  pub errors : Array[String]
}

/// Create a new parser
pub fn Parser::new(tokens : Array[@token.Token]) -> Parser {
  Parser { tokens, pos: 0, errors: [] }
}

/// Create a parser from a formula string
pub fn Parser::from_string(formula : String) -> Parser {
  Parser::new(@lexer.tokenize(formula))
}

/// Peek at current token
pub fn Parser::peek(self : Parser) -> @token.Token {
  if self.pos < self.tokens.length() {
    self.tokens[self.pos]
  } else {
    @token.Token::eof(0, 0, 0)
  }
}

/// Peek at next token
pub fn Parser::peek_next(self : Parser) -> @token.Token {
  if self.pos + 1 < self.tokens.length() {
    self.tokens[self.pos + 1]
  } else {
    @token.Token::eof(0, 0, 0)
  }
}

/// Advance to next token
pub fn Parser::advance(self : Parser) -> (Parser, @token.Token) {
  let tok = self.peek()
  let new_pos = if self.pos < self.tokens.length() { self.pos + 1 } else { self.pos }
  (Parser { tokens: self.tokens, pos: new_pos, errors: self.errors }, tok)
}

/// Check if current token is at EOF
pub fn Parser::is_at_end(self : Parser) -> Bool {
  self.peek().is_eof()
}

/// Expect a specific token type
pub fn Parser::expect(self : Parser, kind : @token.TokenType) -> (Parser, Bool) {
  let tok = self.peek()
  if tok.kind == kind {
    let (p, _) = self.advance()
    (p, true)
  } else {
    let err = "Expected " + kind.to_string() + " but got " + tok.kind.to_string()
    let mut errs = self.errors
    errs.push(err)
    (Parser { tokens: self.tokens, pos: self.pos, errors: errs }, false)
  }
}

/// Parse an expression (entry point)
pub fn Parser::parse_expr(self : Parser) -> Option[@ast.Expr] {
  self.parse_comparison()
}

/// Parse comparison level expressions (=, <>, <, >, <=, >=)
fn Parser::parse_comparison(self : Parser) -> Option[@ast.Expr] {
  let (p, left_opt) = self.parse_concat()
  match left_opt {
    None => None
    Some(left) => {
      let mut parser = p
      let mut expr = left
      let mut done = false
      while not(done) {
        let tok = parser.peek()
        if tok.is_comparison() {
          let (p2, _) = parser.advance()
          parser = p2
          let (p3, right_opt) = parser.parse_concat()
          match right_opt {
            None => done = true
            Some(right) => {
              parser = p3
              let op = @ast.token_to_binary_op(tok.kind)
              expr = @ast.BinaryOp(op, expr, right)
            }
          }
        } else {
          done = true
        }
      }
      Some(expr)
    }
  }
}

/// Parse concatenation level (&)
fn Parser::parse_concat(self : Parser) -> Option[@ast.Expr] {
  let (p, left_opt) = self.parse_additive()
  match left_opt {
    None => None
    Some(left) => {
      let mut parser = p
      let mut expr = left
      let mut done = false
      while not(done) {
        let tok = parser.peek()
        if tok.kind == @token.Ampersand {
          let (p2, _) = parser.advance()
          parser = p2
          let (p3, right_opt) = parser.parse_additive()
          match right_opt {
            None => done = true
            Some(right) => {
              parser = p3
              expr = @ast.BinaryOp(@ast.Concat, expr, right)
            }
          }
        } else {
          done = true
        }
      }
      Some(expr)
    }
  }
}

/// Parse additive level (+, -)
fn Parser::parse_additive(self : Parser) -> Option[@ast.Expr] {
  let (p, left_opt) = self.parse_multiplicative()
  match left_opt {
    None => None
    Some(left) => {
      let mut parser = p
      let mut expr = left
      let mut done = false
      while not(done) {
        let tok = parser.peek()
        if tok.is_additive() {
          let (p2, _) = parser.advance()
          parser = p2
          let (p3, right_opt) = parser.parse_multiplicative()
          match right_opt {
            None => done = true
            Some(right) => {
              parser = p3
              let op = @ast.token_to_binary_op(tok.kind)
              expr = @ast.BinaryOp(op, expr, right)
            }
          }
        } else {
          done = true
        }
      }
      Some(expr)
    }
  }
}

/// Parse multiplicative level (*, /, %)
fn Parser::parse_multiplicative(self : Parser) -> Option[@ast.Expr] {
  let (p, left_opt) = self.parse_power()
  match left_opt {
    None => None
    Some(left) => {
      let mut parser = p
      let mut expr = left
      let mut done = false
      while not(done) {
        let tok = parser.peek()
        if tok.is_multiplicative() {
          let (p2, _) = parser.advance()
          parser = p2
          let (p3, right_opt) = parser.parse_power()
          match right_opt {
            None => done = true
            Some(right) => {
              parser = p3
              if tok.kind == @token.Percent {
                expr = @ast.UnaryOp(@ast.Percent, expr)
              } else {
                let op = @ast.token_to_binary_op(tok.kind)
                expr = @ast.BinaryOp(op, expr, right)
              }
            }
          }
        } else {
          done = true
        }
      }
      Some(expr)
    }
  }
}

/// Parse power level (^)
fn Parser::parse_power(self : Parser) -> Option[@ast.Expr] {
  let (p, left_opt) = self.parse_unary()
  match left_opt {
    None => None
    Some(left) => {
      let mut parser = p
      let mut expr = left
      let mut done = false
      while not(done) {
        let tok = parser.peek()
        if tok.is_power() {
          let (p2, _) = parser.advance()
          parser = p2
          let (p3, right_opt) = parser.parse_unary()
          match right_opt {
            None => done = true
            Some(right) => {
              parser = p3
              expr = @ast.BinaryOp(@ast.Power, expr, right)
            }
          }
        } else {
          done = true
        }
      }
      Some(expr)
    }
  }
}

/// Parse unary operations (-, +)
fn Parser::parse_unary(self : Parser) -> Option[@ast.Expr] {
  let tok = self.peek()
  if tok.kind == @token.Minus {
    let (p, _) = self.advance()
    let (_, inner_opt) = p.parse_unary()
    match inner_opt {
      Some(inner) => Some(@ast.UnaryOp(@ast.Negate, inner))
      None => None
    }
  } else if tok.kind == @token.Plus {
    let (p, _) = self.advance()
    p.parse_unary()
  } else {
    self.parse_postfix()
  }
}

/// Parse postfix operations (like %)
fn Parser::parse_postfix(self : Parser) -> Option[@ast.Expr] {
  let (p, expr_opt) = self.parse_primary()
  match expr_opt {
    None => None
    Some(expr) => {
      let tok = p.peek()
      if tok.kind == @token.Percent {
        let (p2, _) = p.advance()
        let inner = @ast.UnaryOp(@ast.Percent, expr)
        Some(inner)
      } else {
        Some(expr)
      }
    }
  }
}

/// Parse primary expressions (literals, cell refs, function calls, parentheses)
fn Parser::parse_primary(self : Parser) -> Option[@ast.Expr] {
  let tok = self.peek()
  match tok.kind {
    @token.Number => {
      let (p, _) = self.advance()
      match Double::from_string(tok.value) {
        Some(n) => Some(@ast.NumLit(n))
        None => None
      }
    }
    @token.StringLit => {
      let (p, _) = self.advance()
      Some(@ast.StrLit(tok.value))
    }
    @token.BoolLit => {
      let (p, _) = self.advance()
      let b = tok.value.to_upper() == "TRUE"
      Some(@ast.BoolLit(b))
    }
    @token.CellRef => {
      let (p, _) = self.advance()
      // Check if next token is Colon (range)
      let next = p.peek()
      if next.kind == @token.Colon {
        let (p2, _) = p.advance()
        let next_tok = p2.peek()
        if next_tok.kind == @token.CellRef {
          let (p3, _) = p2.advance()
          let (r1, c1, r1a, c1a) = @reference.parse_cell_ref(tok.value)
          let (r2, c2, r2a, c2a) = @reference.parse_cell_ref(next_tok.value)
          Some(@ast.RangeRef(r1, c1, r2, c2, r1a, c1a, r2a, c2a))
        } else {
          // Just a cell ref
          let (r, c, ra, ca) = @reference.parse_cell_ref(tok.value)
          Some(@ast.CellRef(r, c, ra, ca))
        }
      } else {
        let (r, c, ra, ca) = @reference.parse_cell_ref(tok.value)
        Some(@ast.CellRef(r, c, ra, ca))
      }
    }
    @token.LParen => {
      let (p, _) = self.advance()
      let (p2, inner_opt) = p.parse_expr()
      match inner_opt {
        Some(inner) => {
          let (p3, ok) = p2.expect(@token.RParen)
          if ok {
            Some(inner)
          } else {
            None
          }
        }
        None => None
      }
    }
    @token.Identifier => {
      // Could be function call
      let (p, _) = self.advance()
      let next = p.peek()
      if next.kind == @token.LParen {
        // Function call
        let (p2, _) = p.advance()
        let (p3, args) = parse_arguments(p2)
        let (p4, _) = p3.expect(@token.RParen)
        Some(@ast.FuncCall(tok.value, args))
      } else {
        // Named range or error - not supported, return NameError
        None
      }
    }
    _ => None
  }
}

/// Parse function arguments
fn parse_arguments(parser : Parser) -> (Parser, Array[@ast.Expr]) {
  let mut p = parser
  let mut args = []
  let tok = p.peek()
  if tok.kind == @token.RParen {
    return (p, [])
  }
  let (p2, first_opt) = p.parse_expr()
  match first_opt {
    Some(first) => {
      args.push(first)
      p = p2
    }
    None => return (p2, args)
  }
  let mut done = false
  while not(done) {
    let tok = p.peek()
    if tok.kind == @token.Comma {
      let (p2, _) = p.advance()
      let (p3, arg_opt) = p2.parse_expr()
      match arg_opt {
        Some(arg) => {
          args.push(arg)
          p = p3
        }
        None => done = true
      }
    } else {
      done = true
    }
  }
  (p, args)
}

/// Parse a formula string into an AST
pub fn parse(formula : String) -> Option[@ast.Expr] {
  let parser = Parser::from_string(formula)
  parser.parse_expr()
}

/// Parse and return errors if any
pub fn parse_with_errors(formula : String) -> (Option[@ast.Expr], Array[String]) {
  let parser = Parser::from_string(formula)
  let result = parser.parse_expr()
  (result, parser.errors)
}
