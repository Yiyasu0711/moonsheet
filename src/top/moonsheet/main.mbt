fn main {
  println("=== MoonSheet Spreadsheet Engine Demo ===\n")

  // 1. Create a workbook with sales data
  let wb = @workbook.Workbook::with_default("Sales Report")
    .set_value("Sheet1", 0, 0, @value.str("Product"))
    .set_value("Sheet1", 0, 1, @value.str("Q1"))
    .set_value("Sheet1", 0, 2, @value.str("Q2"))
    .set_value("Sheet1", 0, 3, @value.str("Q3"))
    .set_value("Sheet1", 0, 4, @value.str("Total"))
    .set_value("Sheet1", 0, 5, @value.str("Average"))

    .set_value("Sheet1", 1, 0, @value.str("Widget A"))
    .set_value("Sheet1", 1, 1, @value.Number(100.0))
    .set_value("Sheet1", 1, 2, @value.Number(120.0))
    .set_value("Sheet1", 1, 3, @value.Number(150.0))

    .set_value("Sheet1", 2, 0, @value.str("Widget B"))
    .set_value("Sheet1", 2, 1, @value.Number(200.0))
    .set_value("Sheet1", 2, 2, @value.Number(180.0))
    .set_value("Sheet1", 2, 3, @value.Number(220.0))

    .set_value("Sheet1", 3, 0, @value.str("Widget C"))
    .set_value("Sheet1", 3, 1, @value.Number(50.0))
    .set_value("Sheet1", 3, 2, @value.Number(75.0))
    .set_value("Sheet1", 3, 3, @value.Number(90.0))

  // Add formulas for totals and averages
    .set_formula("Sheet1", 1, 4, "=SUM(B2:D2)")
    .set_formula("Sheet1", 2, 4, "=SUM(B3:D3)")
    .set_formula("Sheet1", 3, 4, "=SUM(B4:D4)")
    .set_formula("Sheet1", 1, 5, "=AVERAGE(B2:D2)")
    .set_formula("Sheet1", 2, 5, "=AVERAGE(B3:D3)")
    .set_formula("Sheet1", 3, 5, "=AVERAGE(B4:D4)")

  // 2. Evaluate all formulas
  let evaluated = @evaluator.eval_workbook(wb)
  let sheet = evaluated.get_first_sheet()

  // 3. Display the results
  println("Sales Data with Computed Formulas:")
  println("--------------------------------")
  for r = 0; r <= 3; r = r + 1 {
    let mut row_str = ""
    for c = 0; c <= 5; c = c + 1 {
      let val = sheet.get_value(r, c)
      let s = val.to_display_string()
      let mut padded = s
      while padded.length() < 12 {
        padded = padded + " "
      }
      row_str = row_str + padded + " | "
    }
    println(row_str)
  }
  println("")

  // 4. Demonstrate formula evaluation
  println("Formula Evaluation Examples:")
  println("  SUM(B2:D2) = " + @evaluator.eval_formula("=SUM(B2:D2)", sheet).to_display_string())
  println("  AVERAGE(B3:D3) = " + @evaluator.eval_formula("=AVERAGE(B3:D3)", sheet).to_display_string())
  println("  MAX(B2:D4) = " + @evaluator.eval_formula("=MAX(B2:D4)", sheet).to_display_string())
  println("  MIN(B2:D4) = " + @evaluator.eval_formula("=MIN(B2:D4)", sheet).to_display_string())
  println("  B2+C2 = " + @evaluator.eval_formula("=B2+C2", sheet).to_display_string())
  println("  IF(B2>100,\"High\",\"Low\") = " + @evaluator.eval_formula("=IF(B2>100,\"High\",\"Low\")", sheet).to_display_string())
  println("")

  // 5. CSV Export
  println("CSV Export:")
  println("--------------------------------")
  println(@io.sheet_to_csv(sheet))
  println("")

  // 6. JSON Export
  println("JSON Export (first 200 chars):")
  println("--------------------------------")
  let json = @io.sheet_to_json(sheet)
  let preview_len = if json.length() > 200 { 200 } else { json.length() }
  println(json.substring(start=0, end=preview_len) + "...")
  println("")

  // 7. Cell References
  println("Cell Reference Parsing:")
  println("--------------------------------")
  let cr = @reference.CellReference::from_a1("AB123")
  println("  AB123 -> row=" + cr.row.to_string() + ", col=" + cr.col.to_string())
  let cr2 = @reference.CellReference::from_a1("$A$1")
  println("  $A$1 -> row=" + cr2.row.to_string() + ", col=" + cr2.col.to_string() + ", abs=" + cr2.is_absolute().to_string())
  let rr = @reference.parse_range_ref("A1:C3")
  println("  A1:C3 -> " + rr.cell_count().to_string() + " cells")
  println("")

  // 8. Dependency Graph
  println("Dependency Graph:")
  println("--------------------------------")
  let graph = @dependency.DependencyGraph::from_sheet(sheet)
  println("  Total edges: " + graph.edge_count().to_string())
  println("  Cells in graph: " + graph.get_all_cells().length().to_string())
  println("  Has circular: " + graph.has_circular().to_string())
  println("")

  // 9. Functions count
  println("Built-in Functions:")
  println("--------------------------------")
  println("  Total functions: " + @functions.function_count().to_string())
  let categories = ["Math", "Text", "Logical", "Date/Time", "Statistical"]
  for cat in categories {
    let mut count = 0
    for fn_name in @functions.list_functions() {
      if @functions.function_category(fn_name) == cat {
        count = count + 1
      }
    }
    println("  " + cat + ": " + count.to_string() + " functions")
  }
  println("")

  // 10. Value types
  println("Value Types:")
  println("--------------------------------")
  let vals = [@value.Number(42.0), @value.Str("Hello"), @value.Bool(true), @value.Empty, @value.Err(@error.DivZero)]
  for v in vals {
    println("  " + v.type_name() + " -> " + v.to_display_string())
  }
  println("")

  println("=== Demo Complete ===")
}
