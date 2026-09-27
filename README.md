# MoonSheet

A spreadsheet calculation engine written in [MoonBit](https://www.moonbitlang.com/).

## Overview

MoonSheet is a pure-MoonBit implementation of a spreadsheet calculation engine. It provides formula parsing, evaluation, dependency management, and a comprehensive set of built-in functions compatible with common spreadsheet conventions.

## Features

- **Formula Engine**: Lexer, parser, and AST-based evaluator for spreadsheet formulas
- **Cell References**: A1 notation with absolute/relative references (e.g., `$A$1`, `B2`, `A1:B2`)
- **Built-in Functions**: 70+ functions across math, text, logical, datetime, and statistical categories
- **Dependency Graph**: Topological sorting for correct recalculation order
- **Circular Reference Detection**: Automatic detection and error reporting
- **Error Handling**: Excel-compatible error values (`#DIV/0!`, `#N/A`, `#NAME?`, `#REF!`, `#VALUE!`, etc.)
- **I/O Support**: CSV and JSON import/export
- **Value Formatting**: Number, date, time, percentage, and currency formatting

## Quick Start

```moonbit
let wb = @workbook.Workbook::with_default("Sales Report")
  .set_value("Sheet1", 0, 0, @value.str("Product"))
  .set_value("Sheet1", 0, 1, @value.str("Q1"))
  .set_value("Sheet1", 0, 2, @value.str("Total"))
  .set_value("Sheet1", 1, 0, @value.str("Widget A"))
  .set_value("Sheet1", 1, 1, @value.Number(100.0))
  .set_value("Sheet1", 2, 1, @value.Number(200.0))
  .set_formula("Sheet1", 3, 1, "=SUM(B2:B3)")

let result = @evaluator.eval_workbook(wb)
```

## Module Structure

```
src/
  value/         - Core value types (Number, String, Bool, Error, Empty)
  error/         - Spreadsheet error values
  cell/          - Cell representation
  sheet/         - Worksheet management
  workbook/      - Multi-sheet workbook
  token/         - Token definitions for lexer
  lexer/         - Formula tokenizer
  ast/           - Abstract syntax tree nodes
  parser/       - Recursive descent parser
  reference/     - Cell reference parsing and conversion
  functions/     - Built-in function implementations
  evaluator/     - Formula evaluation engine
  dependency/    - Dependency graph and topological sort
  format/        - Value formatting
  io/            - CSV and JSON import/export
  top/moonsheet/ - Demo application
```

## Built-in Functions

### Math
SUM, PRODUCT, ABS, ROUND, FLOOR, CEILING, MOD, POWER, SQRT, EXP, LN, LOG, SIN, COS, TAN, MIN, MAX, PI, SIGN, TRUNC, DEGREES, RADIANS, SUMIF

### Text
LEFT, RIGHT, MID, LEN, UPPER, LOWER, TRIM, CONCAT, REPLACE, SUBSTITUTE, FIND, SEARCH, REPT, VALUE, TEXT

### Logical
IF, AND, OR, NOT, XOR, IFERROR, IFNA, TRUE, FALSE, ISNUMBER, ISTEXT, ISLOGICAL, ISERROR, ISEMPTY, ISNONTEXT, ISREF, NA, ERROR.TYPE

### Date/Time
DATE, TODAY, NOW, TIME, YEAR, MONTH, DAY, HOUR, MINUTE, SECOND, WEEKDAY, EOMONTH, DATEDIF

### Statistical
AVERAGE, COUNT, COUNTA, COUNTIF, AVERAGEIF, MEDIAN, MODE, STDEV, VAR, LARGE, SMALL, RANK, PERCENTILE, QUARTILE, SUMPRODUCT

## License

Apache License 2.0
