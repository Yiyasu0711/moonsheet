// MoonSheet AST
// Abstract syntax tree nodes for parsed formulas

/// Binary operation types
pub enum BinaryOp {
  Add       // +
  Subtract  // -
  Multiply  // *
  Divide    // /
  Power     // ^
  Concat    // &
  Equal     // =
  NotEqual  // <>
  LessThan  // <
  GreaterThan // >
  LessEqual // <=
  GreaterEqual // >=
} derive(Show, Eq)

/// Unary operation types
pub enum UnaryOp {
  Negate    // -x
  Percent   // x%
} derive(Show, Eq)

/// AST node representing a parsed formula expression
pub enum Expr {
  // Numeric literal
  NumLit(Double)
  // String literal
  StrLit(String)
  // Boolean literal
  BoolLit(Bool)
  // Cell reference: (row, col, row_absolute, col_absolute)
  CellRef(Int, Int, Bool, Bool)
  // Range reference: (start_row, start_col, end_row, end_col, start_row_abs, start_col_abs, end_row_abs, end_col_abs)
  RangeRef(Int, Int, Int, Int, Bool, Bool, Bool, Bool)
  // Binary operation: (op, left, right)
  BinaryOp(BinaryOp, Expr, Expr)
  // Unary operation: (op, operand)
  UnaryOp(UnaryOp, Expr)
  // Function call: (name, arguments)
  FuncCall(String, Array[Expr])
} derive(Show)

/// Convert binary op to string
pub fn BinaryOp::to_string(self : BinaryOp) -> String {
  match self {
    Add => "+"
    Subtract => "-"
    Multiply => "*"
    Divide => "/"
    Power => "^"
    Concat => "&"
    Equal => "="
    NotEqual => "<>"
    LessThan => "<"
    GreaterThan => ">"
    LessEqual => "<="
    GreaterEqual => ">="
  }
}

/// Convert unary op to string
pub fn UnaryOp::to_string(self : UnaryOp) -> String {
  match self {
    Negate => "-"
    Percent => "%"
  }
}

/// Get binary op from token type
pub fn token_to_binary_op(kind : @token.TokenType) -> BinaryOp {
  match kind {
    @token.Plus => Add
    @token.Minus => Subtract
    @token.Star => Multiply
    @token.Slash => Divide
    @token.Caret => Power
    @token.Ampersand => Concat
    @token.Equal => Equal
    @token.NotEqual => NotEqual
    @token.LessThan => LessThan
    @token.GreaterThan => GreaterThan
    @token.LessEqual => LessEqual
    @token.GreaterEqual => GreaterEqual
    _ => Add
  }
}

/// Convert expression to string (for debugging)
pub fn Expr::to_string(self : Expr) -> String {
  match self {
    NumLit(n) => n.to_string()
    StrLit(s) => "\"" + s + "\""
    BoolLit(true) => "TRUE"
    BoolLit(false) => "FALSE"
    CellRef(row, col, row_abs, col_abs) => {
      let col_str = if col_abs { "$" } else { "" } + col_to_letter(col)
      let row_str = if row_abs { "$" } else { "" } + (row + 1).to_string()
      col_str + row_str
    }
    RangeRef(r1, c1, r2, c2, r1a, c1a, r2a, c2a) => {
      let s1 = (if c1a { "$" } else { "" }) + col_to_letter(c1) + (if r1a { "$" } else { "" }) + (r1 + 1).to_string()
      let s2 = (if c2a { "$" } else { "" }) + col_to_letter(c2) + (if r2a { "$" } else { "" }) + (r2 + 1).to_string()
      s1 + ":" + s2
    }
    BinaryOp(op, left, right) => {
      "(" + left.to_string() + " " + op.to_string() + " " + right.to_string() + ")"
    }
    UnaryOp(op, operand) => {
      match op {
        Negate => "(-" + operand.to_string() + ")"
        Percent => "(" + operand.to_string() + "%)"
      }
    }
    FuncCall(name, args) => {
      let mut s = name + "("
      for i = 0; i < args.length(); i = i + 1 {
        if i > 0 {
          s = s + ", "
        }
        s = s + args[i].to_string()
      }
      s + ")"
    }
  }
}

/// Get all cell references in an expression
pub fn Expr::get_cell_refs(self : Expr) -> Array[(Int, Int)] {
  match self {
    CellRef(row, col, _, _) => [(row, col)]
    RangeRef(r1, c1, r2, c2, _, _, _, _) => {
      let mut refs = []
      let min_r = if r1 < r2 { r1 } else { r2 }
      let max_r = if r1 < r2 { r2 } else { r1 }
      let min_c = if c1 < c2 { c1 } else { c2 }
      let max_c = if c1 < c2 { c2 } else { c1 }
      for r = min_r; r <= max_r; r = r + 1 {
        for c = min_c; c <= max_c; c = c + 1 {
          refs.push((r, c))
        }
      }
      refs
    }
    BinaryOp(_, left, right) => {
      let mut refs = left.get_cell_refs()
      for r in right.get_cell_refs() {
        refs.push(r)
      }
      refs
    }
    UnaryOp(_, operand) => operand.get_cell_refs()
    FuncCall(_, args) => {
      let mut refs = []
      for arg in args {
        for r in arg.get_cell_refs() {
          refs.push(r)
        }
      }
      refs
    }
    _ => []
  }
}

/// Check if expression is a literal
pub fn Expr::is_literal(self : Expr) -> Bool {
  match self {
    NumLit(_) | StrLit(_) | BoolLit(_) => true
    _ => false
  }
}

/// Check if expression is a cell reference
pub fn Expr::is_cell_ref(self : Expr) -> Bool {
  match self {
    CellRef(_, _, _, _) => true
    _ => false
  }
}

/// Check if expression is a function call
pub fn Expr::is_func_call(self : Expr) -> Bool {
  match self {
    FuncCall(_, _) => true
    _ => false
  }
}

/// Check if expression is a range reference
pub fn Expr::is_range_ref(self : Expr) -> Bool {
  match self {
    RangeRef(_, _, _, _, _, _, _, _) => true
    _ => false
  }
}

/// Get function name if this is a function call
pub fn Expr::get_func_name(self : Expr) -> String? {
  match self {
    FuncCall(name, _) => Some(name)
    _ => None
  }
}

/// Get function arguments if this is a function call
pub fn Expr::get_func_args(self : Expr) -> Array[Expr]? {
  match self {
    FuncCall(_, args) => Some(args)
    _ => None
  }
}

/// Convert column number to letter
fn col_to_letter(col : Int) -> String {
  let mut result = ""
  let mut c = col
  let mut done = false
  while not(done) {
    result = Char::from_int((c % 26) + 65).to_string() + result
    c = c / 26
    if c == 0 {
      done = true
    }
  }
  result
}

/// Count nodes in the expression tree
pub fn Expr::count_nodes(self : Expr) -> Int {
  match self {
    NumLit(_) | StrLit(_) | BoolLit(_) => 1
    CellRef(_, _, _, _) => 1
    RangeRef(_, _, _, _, _, _, _, _) => 1
    BinaryOp(_, left, right) => 1 + left.count_nodes() + right.count_nodes()
    UnaryOp(_, operand) => 1 + operand.count_nodes()
    FuncCall(_, args) => {
      let mut count = 1
      for arg in args {
        count = count + arg.count_nodes()
      }
      count
    }
  }
}

/// Get depth of the expression tree
pub fn Expr::depth(self : Expr) -> Int {
  match self {
    NumLit(_) | StrLit(_) | BoolLit(_) => 0
    CellRef(_, _, _, _) => 0
    RangeRef(_, _, _, _, _, _, _, _) => 0
    BinaryOp(_, left, right) => {
      let ld = left.depth()
      let rd = right.depth()
      1 + (if ld > rd { ld } else { rd })
    }
    UnaryOp(_, operand) => 1 + operand.depth()
    FuncCall(_, args) => {
      let mut max_depth = 0
      for arg in args {
        let d = arg.depth()
        if d > max_depth {
          max_depth = d
        }
      }
      1 + max_depth
    }
  }
}
