# MoonSheet

A lightweight spreadsheet formula calculation engine written in [MoonBit](https://www.moonbitlang.com/), designed for server-side and embedded scenarios.

## Overview

MoonSheet is a pure-MoonBit implementation of a spreadsheet calculation engine. It provides formula parsing, evaluation, dependency management, and a comprehensive set of built-in functions compatible with common spreadsheet conventions. The project includes 151 functions across 8 categories, named ranges, conditional formatting, data validation, and I/O support.

## Relationship with mbtexcel

mbtexcel (a port of Go's excelize library, available on [mooncakes.io](https://mooncakes.io/docs/bobzhang/mbtexcel)) is an XLSX file I/O library focused on reading/writing Excel files with full fidelity (styles, charts, pivot tables, etc.), with formula evaluation as an embedded feature.

MoonSheet takes a different approach — it is a **standalone calculation engine** with no file format dependency. The two libraries are complementary:

| Aspect | mbtexcel | MoonSheet |
|--------|----------|-----------|
| Core focus | XLSX file read/write (excelize port) | Lightweight formula calculation engine (original) |
| Primary use | Excel file manipulation, report generation | Server-side computation, embedded evaluation, data processing |
| File format dependency | Strong XLSX/OOXML dependency | No file format dependency, JSON/CSV native |
| Architecture | File I/O centered, formula built-in | Engine independent, decoupled modules |
| Dynamic array functions | Not explicitly supported | 22 dynamic array functions |
| Best for | Desktop/client, file generation | Microservices, workflows, lightweight apps |
| Size/dependencies | Large (full OOXML + styles + charts) | Lightweight (engine + basic I/O) |

**They can be used together**: use mbtexcel to read/write XLSX files, and MoonSheet for high-performance server-side batch computation.

## Features

- **Formula Engine**: Lexer, recursive descent parser, and AST-based evaluator for spreadsheet formulas
- **Cell References**: A1 notation with absolute/relative references (e.g., `$A$1`, `B2`, `A1:B2`)
- **151 Built-in Functions**: Math, Text, Logical, Date/Time, Statistical, Lookup, Financial, and Array categories
- **Lookup Functions**: VLOOKUP, HLOOKUP, INDEX, MATCH, XLOOKUP, XMATCH, CHOOSE, ADDRESS, INDIRECT, ROW, COLUMN, ROWS, COLUMNS, OFFSET, TRANSPOSE
- **Financial Functions**: PV, FV, PMT, NPER, RATE, NPV, IRR, IPMT, PPMT, EFFECT, NOMINAL, SLN, SYD, DDB, FVSCHEDULE, MIRR
- **Dynamic Array Functions**: SORT, UNIQUE, FILTER, TEXTJOIN, SEQUENCE, RANDARRAY, ARRAYTOTEXT, VALUETOTEXT, TOROW, TOCOL, WRAPROWS, WRAPCOLS, TAKE, DROP, CHOOSEROWS, CHOOSECOLS, EXPAND, HSTACK, VSTACK, SORTBY, FREQUENCY, MMULT
- **Named Ranges**: Workbook and sheet-scoped named ranges with validation
- **Conditional Formatting**: Cell value rules, formula rules, color scales, top/bottom 10, above/below average, duplicates, unique, blanks, errors
- **Data Validation**: Whole number, decimal, list, date, time, text length, and custom validation with input/error messages
- **Dependency Graph**: Topological sorting for correct recalculation order
- **Circular Reference Detection**: Automatic detection and error reporting
- **Error Handling**: Excel-compatible error values (`#DIV/0!`, `#N/A`, `#NAME?`, `#REF!`, `#VALUE!`, `#CIRC!`, etc.)
- **I/O Support**: CSV and JSON import/export
- **Value Formatting**: Number, date, time, percentage, currency, and scientific notation formatting
- **CI/CD**: GitHub Actions with format check, build, and test pipeline

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
  value/              - Core value types (Number, String, Bool, Error, Empty)
  error/              - Spreadsheet error values
  cell/               - Cell representation
  sheet/              - Worksheet management
  workbook/           - Multi-sheet workbook
  token/              - Token definitions for lexer
  lexer/              - Formula tokenizer
  ast/                - Abstract syntax tree nodes
  parser/             - Recursive descent parser
  reference/          - Cell reference parsing and conversion
  functions/          - Built-in function implementations (7 modules)
  evaluator/          - Formula evaluation engine
  dependency/         - Dependency graph and topological sort
  format/             - Value formatting
  io/                 - CSV and JSON import/export
  namedrange/         - Named range support
  conditionalformat/  - Conditional formatting rules
  datavalidation/     - Data validation rules
  top/moonsheet/      - Demo application
```

## Built-in Functions (151 total)

### Math (34)
SUM, PRODUCT, ABS, ROUND, FLOOR, CEILING, MOD, POWER, SQRT, EXP, LN, LOG, LOG10, SIN, COS, TAN, ASIN, ACOS, ATAN, ATAN2, MIN, MAX, PI, SIGN, TRUNC, INT, DEGREES, RADIANS, SUMIF, SUMSQ, FACT, RAND, GCD, LCM

### Text (21)
LEFT, RIGHT, MID, LEN, UPPER, LOWER, TRIM, CONCAT, REPLACE, SUBSTITUTE, FIND, SEARCH, REPT, VALUE, TEXT, PROPER, CLEAN, EXACT, T, CHAR, CODE

### Logical (20)
IF, AND, OR, NOT, XOR, IFERROR, IFNA, TRUE, FALSE, ISNUMBER, ISTEXT, ISLOGICAL, ISERROR, ISEMPTY, ISNONTEXT, ISREF, NA, ERROR.TYPE, IFS, SWITCH

### Date/Time (17)
DATE, TODAY, NOW, TIME, YEAR, MONTH, DAY, HOUR, MINUTE, SECOND, WEEKDAY, EOMONTH, DATEDIF, DAYS360, WEEKNUM, DATEVALUE, TIMEVALUE

### Statistical (21)
AVERAGE, COUNT, COUNTA, COUNTIF, AVERAGEIF, MEDIAN, MODE, STDEV, STDEVP, VAR, VARP, LARGE, SMALL, RANK, PERCENTILE, QUARTILE, SUMPRODUCT, GEOMEAN, HARMEAN, AVEDEV, DEVSQ

### Lookup (18)
VLOOKUP, HLOOKUP, INDEX, MATCH, CHOOSE, ADDRESS, INDIRECT, ROW, COLUMN, ROWS, COLUMNS, TRANSPOSE, OFFSET, XLOOKUP, XMATCH, LOOKUP, AREAS, FORMULATEXT

### Financial (16)
PV, FV, PMT, NPER, RATE, NPV, IRR, IPMT, PPMT, EFFECT, NOMINAL, SLN, SYD, DDB, FVSCHEDULE, MIRR

### Array (22)
SORT, UNIQUE, FILTER, TEXTJOIN, SEQUENCE, RANDARRAY, ARRAYTOTEXT, VALUETOTEXT, TOROW, TOCOL, WRAPROWS, WRAPCOLS, TAKE, DROP, CHOOSEROWS, CHOOSECOLS, EXPAND, HSTACK, VSTACK, SORTBY, FREQUENCY, MMULT

## License

Apache License 2.0
