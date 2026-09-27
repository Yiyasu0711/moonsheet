# MoonSheet Git 提交与 GitHub 推送指南

## 准备工作

项目路径：`C:\Users\31767\AppData\Roaming\TRAE SOLO CN\ModularData\ai-agent\work-mode-projects\6ab8ecd1e1511a240bca5a9b\moonsheet`

GitHub 仓库：`https://github.com/Yiyasu0711/moonbit-test.git`

## 第一步：初始化 Git 仓库并配置用户

打开 **PowerShell** 或 **Git Bash**，执行以下命令：

```powershell
cd "C:\Users\31767\AppData\Roaming\TRAE SOLO CN\ModularData\ai-agent\work-mode-projects\6ab8ecd1e1511a240bca5a9b\moonsheet"
git init
git config user.name "Yiyasu0711"
git config user.email "yiyasu0711@example.com"
```

> 注意：邮箱请替换为您注册 GitHub 时使用的邮箱。

## 第二步：按模块分 11 次提交（确保每次提交有实际内容）

### 提交 1：项目初始化

```powershell
git add .gitignore LICENSE moon.mod.json
git commit -m "chore: initialize project with license and module config"
```

### 提交 2：核心值类型与错误处理

```powershell
git add src/value/value.mbt src/error/error.mbt
git commit -m "feat: add core value types and error handling"
```

### 提交 3：单元格、工作表与工作簿数据结构

```powershell
git add src/cell/cell.mbt src/sheet/sheet.mbt src/workbook/workbook.mbt
git commit -m "feat: add cell, sheet, and workbook data structures"
```

### 提交 4：公式引擎 —— 词法分析器与 Token

```powershell
git add src/token/token.mbt src/lexer/lexer.mbt
git commit -m "feat: add formula lexer and token definitions"
```

### 提交 5：公式引擎 —— AST 与解析器

```powershell
git add src/ast/ast.mbt src/parser/parser.mbt src/reference/reference.mbt
git commit -m "feat: add AST, parser, and cell reference parsing"
```

### 提交 6：求值器与依赖图

```powershell
git add src/evaluator/evaluator.mbt src/dependency/graph.mbt
git commit -m "feat: add formula evaluator and dependency graph"
```

### 提交 7：内置函数（数学/文本/逻辑/日期/统计）

```powershell
git add src/functions/math.mbt src/functions/text.mbt src/functions/logical.mbt src/functions/datetime.mbt src/functions/statistical.mbt src/functions/dispatch.mbt
git commit -m "feat: add 95 built-in functions across 5 categories"
```

### 提交 8：查找引用函数 + 财务函数

```powershell
git add src/functions/lookup.mbt src/functions/financial.mbt
git commit -m "feat: add lookup and financial functions (34 more)"
```

### 提交 9：命名区域 + 条件格式 + 数据验证

```powershell
git add src/namedrange/namedrange.mbt src/conditionalformat/conditionalformat.mbt src/datavalidation/datavalidation.mbt
git commit -m "feat: add named ranges, conditional formatting, and data validation"
```

### 提交 10：数组函数 + 格式化 + I/O

```powershell
git add src/functions/array.mbt src/format/format.mbt src/io/csv.mbt src/io/json.mbt
git commit -m "feat: add array functions, formatting, and CSV/JSON IO"
```

### 提交 11：测试文件 + Demo + CI + 文档

```powershell
git add src/cell/cell_test.mbt src/sheet/sheet_test.mbt src/workbook/workbook_test.mbt
git add src/value/value_test.mbt src/error/error_test.mbt
git add src/lexer/lexer_test.mbt src/parser/parser_test.mbt
git add src/reference/reference_test.mbt src/evaluator/evaluator_test.mbt
git add src/functions/functions_test.mbt src/dependency/graph_test.mbt
git add src/format/format_test.mbt src/io/io_test.mbt
git add src/top/moonsheet/main.mbt
git add README.md CHANGELOG.md MoonSheet项目申报书.md
git add .github/workflows/ci.yml
git commit -m "feat: add tests, demo, CI pipeline, and documentation"
```

## 第三步：添加远程仓库并推送

```powershell
git branch -M main
git remote add origin https://github.com/Yiyasu0711/moonbit-test.git
git push -u origin main
```

> 如果推送失败，可能需要先在 GitHub 上创建空仓库（不要勾选 README 和 .gitignore）。

## 验证

```powershell
git log --oneline
```

应该能看到 11 条提交记录。

## 如果遇到 PowerShell 执行策略错误

请先执行以下命令修改执行策略：

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
```

然后重新打开 PowerShell 窗口。
