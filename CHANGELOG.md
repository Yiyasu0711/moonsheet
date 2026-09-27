# Changelog

## [0.1.0] - 2024-12-01

### Added
- Core value types: Number, String, Bool, Error, Empty
- Spreadsheet error values with Excel-compatible representations
- Cell and worksheet management
- Multi-sheet workbook support
- Formula lexer with full token support
- Recursive descent parser for spreadsheet formulas
- AST-based formula evaluator
- A1 notation cell reference parsing and conversion
- 70+ built-in functions across 5 categories:
  - Math (SUM, PRODUCT, ABS, ROUND, etc.)
  - Text (LEFT, RIGHT, MID, CONCAT, etc.)
  - Logical (IF, AND, OR, NOT, etc.)
  - Date/Time (DATE, TODAY, NOW, YEAR, etc.)
  - Statistical (AVERAGE, COUNT, MEDIAN, STDEV, etc.)
- Dependency graph with topological sorting
- Circular reference detection
- CSV and JSON import/export
- Value formatting (number, date, percentage, etc.)
- Comprehensive unit test suite
- GitHub Actions CI configuration
