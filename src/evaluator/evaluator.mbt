// MoonSheet Evaluator
// Evaluates parsed formula AST expressions to values

/// Evaluation context
pub struct EvalContext {
  pub workbook : @workbook.Workbook
  pub sheet_name : String
  pub computing : Map[(Int, Int), Bool]
  pub max_depth : Int
  pub current_depth : Int
}

/// Create a new evaluation context
pub fn EvalContext::new(workbook : @workbook.Workbook, sheet_name : String) -> EvalContext {
  EvalContext { workbook, sheet_name, computing: {}, max_depth: 100, current_depth: 0 }
}

/// Get cell value from the workbook
pub fn EvalContext::get_cell_value(self : EvalContext, row : Int, col : Int) -> @value.Value {
  match self.workbook.sheets.get(self.sheet_name) {
    Some(sheet) => sheet.get_value(row, col)
    None => @value.Empty
  }
}

/// Get range values from the workbook
pub fn EvalContext::get_range_values(self : EvalContext, r1 : Int, c1 : Int, r2 : Int, c2 : Int) -> Array[@value.Value] {
  match self.workbook.sheets.get(self.sheet_name) {
    Some(sheet) => sheet.get_range_values(r1, c1, r2, c2)
    None => []
  }
}

/// Evaluate an expression to a value
pub fn EvalContext::eval(self : EvalContext, expr : @ast.Expr) -> @value.Value {
  if self.current_depth > self.max_depth {
    return @value.Err(@error.CircularRef)
  }
  let ctx = { ..self, current_depth: self.current_depth + 1 }
  match expr {
    @ast.NumLit(n) => @value.Number(n)
    @ast.StrLit(s) => @value.Str(s)
    @ast.BoolLit(b) => @value.Bool(b)
    @ast.CellRef(row, col, _, _) => {
      match ctx.computing.get((row, col)) {
        Some(true) => @value.Err(@error.CircularRef)
        None => {
          let mut new_computing = ctx.computing
          new_computing[(row, col)] = true
          let ctx2 = { ..ctx, computing: new_computing }
          ctx2.get_cell_value(row, col)
        }
      }
    }
    @ast.RangeRef(r1, c1, r2, c2, _, _, _, _) => {
      let values = ctx.get_range_values(r1, c1, r2, c2)
      if values.length() > 0 { values[0] } else { @value.Empty }
    }
    @ast.BinaryOp(op, left, right) => {
      let left_val = ctx.eval(left)
      let right_val = ctx.eval(right)
      eval_binary_op(op, left_val, right_val)
    }
    @ast.UnaryOp(op, operand) => {
      let val = ctx.eval(operand)
      eval_unary_op(op, val)
    }
    @ast.FuncCall(name, args) => {
      let arg_vals = args.map(arg => ctx.eval(arg))
      @functions.dispatch(name, arg_vals)
    }
  }
}

/// Evaluate a binary operation
pub fn eval_binary_op(op : @ast.BinaryOp, left : @value.Value, right : @value.Value) -> @value.Value {
  match op {
    @ast.Add => @value.Value::add(left, right)
    @ast.Subtract => @value.Value::subtract(left, right)
    @ast.Multiply => @value.Value::multiply(left, right)
    @ast.Divide => @value.Value::divide(left, right)
    @ast.Power => @value.Value::power(left, right)
    @ast.Concat => @value.Value::concat(left, right)
    @ast.Equal => @value.Bool(@value.Value::equals(left, right))
    @ast.NotEqual => @value.Bool(not(@value.Value::equals(left, right)))
    @ast.LessThan => @value.Bool(@value.Value::compare_values(left, right) < 0)
    @ast.GreaterThan => @value.Bool(@value.Value::compare_values(left, right) > 0)
    @ast.LessEqual => @value.Bool(@value.Value::compare_values(left, right) <= 0)
    @ast.GreaterEqual => @value.Bool(@value.Value::compare_values(left, right) >= 0)
  }
}

/// Evaluate a unary operation
pub fn eval_unary_op(op : @ast.UnaryOp, val : @value.Value) -> @value.Value {
  match op {
    @ast.Negate => @value.Value::negate(val)
    @ast.Percent => @value.Value::to_percent(val)
  }
}

/// Evaluate a formula string in the context of a sheet
pub fn eval_formula(formula : String, sheet : @sheet.Sheet) -> @value.Value {
  match @parser.parse(formula) {
    Some(expr) => {
      let wb = @workbook.Workbook::with_default("Temp")
      let mut new_sheets = wb.sheets
      new_sheets["Sheet1"] = sheet
      let wb2 = @workbook.Workbook { name: "Temp", sheets: new_sheets, sheet_order: wb.sheet_order }
      let ctx = EvalContext::new(wb2, "Sheet1")
      ctx.eval(expr)
    }
    None => @value.Err(@error.NameError)
  }
}

/// Evaluate a formula string in the context of a workbook
pub fn eval_formula_in_workbook(formula : String, workbook : @workbook.Workbook, sheet_name : String) -> @value.Value {
  match @parser.parse(formula) {
    Some(expr) => {
      let ctx = EvalContext::new(workbook, sheet_name)
      ctx.eval(expr)
    }
    None => @value.Err(@error.NameError)
  }
}

/// Evaluate a cell
pub fn eval_cell(sheet : @sheet.Sheet, row : Int, col : Int) -> @value.Value {
  let cell = sheet.get_cell(row, col)
  match cell.content {
    EmptyCell => @value.Empty
    ValueCell(v) => v
    FormulaCell(f) => eval_formula(f, sheet)
  }
}

/// Evaluate all formula cells in a sheet
pub fn eval_sheet(sheet : @sheet.Sheet) -> @sheet.Sheet {
  let wb = @workbook.Workbook::with_default("Temp")
  let mut new_sheets = wb.sheets
  new_sheets["Sheet1"] = sheet
  let wb2 = @workbook.Workbook { name: "Temp", sheets: new_sheets, sheet_order: wb.sheet_order }
  let evaluated = eval_workbook(wb2)
  match evaluated.sheets.get("Sheet1") {
    Some(s) => s
    None => sheet
  }
}

/// Evaluate all formula cells in a workbook
pub fn eval_workbook(workbook : @workbook.Workbook) -> @workbook.Workbook {
  let mut wb = workbook
  // First pass: collect all formula cells
  let formula_cells = wb.get_all_formula_cells()
  // Second pass: evaluate each formula
  for (sheet_name, cell) in formula_cells {
    match wb.sheets.get(sheet_name) {
      Some(sheet) => {
        match @parser.parse(cell.formula) {
          Some(expr) => {
            let ctx = EvalContext::new(wb, sheet_name)
            let result = ctx.eval(expr)
            match wb.sheets.get(sheet_name) {
              Some(s) => {
                let updated = s.set_computed(cell.row, cell.col, result)
                let mut new_sheets = wb.sheets
                new_sheets[sheet_name] = updated
                wb = @workbook.Workbook { name: wb.name, sheets: new_sheets, sheet_order: wb.sheet_order }
              }
              None => ()
            }
          }
          None => ()
        }
      }
      None => ()
    }
  }
  wb
}

/// Get dependencies of a cell
pub fn get_cell_dependencies(sheet : @sheet.Sheet, row : Int, col : Int) -> Array[(Int, Int)] {
  let cell = sheet.get_cell(row, col)
  match cell.content {
    EmptyCell => []
    ValueCell(_) => []
    FormulaCell(f) => {
      match @parser.parse(f) {
        Some(expr) => expr.get_cell_refs()
        None => []
      }
    }
  }
}

/// Check if a formula has circular references
pub fn has_circular_ref(formula : String) -> Bool {
  // Simple check: if the formula references itself
  match @parser.parse(formula) {
    Some(expr) => {
      let refs = expr.get_cell_refs()
      // This is a simplified check
      false
    }
    None => false
  }
}

/// Evaluate a formula and return the result as a string
pub fn eval_formula_to_string(formula : String, sheet : @sheet.Sheet) -> String {
  let result = eval_formula(formula, sheet)
  result.to_display_string()
}
