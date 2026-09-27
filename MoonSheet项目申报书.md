# 2026 MoonBit 国产基础软件生态开源大赛 项目申报书

## 1、项目名称

**MoonSheet —— 基于 MoonBit 的全功能电子表格计算引擎**

GitHub 仓库：`https://github.com/moonsheet-dev/moonsheet`

## 2、项目简介

MoonSheet 是使用 MoonBit 语言从零实现的全功能电子表格计算引擎，提供完整的公式解析、求值、依赖管理、数据格式和 I/O 能力。项目涵盖词法分析器、递归下降解析器、AST 求值器、依赖图拓扑排序、命名区域、条件格式、数据验证，以及 151 个内置函数（数学、文本、逻辑、日期时间、统计、查找、财务、动态数组八大类）。代码规模 8000+ 行，30+ 源文件，配有完整单元测试，采用 Apache-2.0 开源许可证，已配置 GitHub Actions CI 流水线。

## 3、项目方向与通用性说明

**项目方向**：基础软件生态 —— 办公计算 / 数据处理引擎

**通用性说明**：MoonSheet 定位为通用表格计算库，不绑定特定前端或应用场景。核心引擎以纯函数式 API 形式提供（输入公式字符串和数据，返回计算结果），可嵌入任意 MoonBit 应用。数据模型与 Excel/LibreOffice Calc 兼容（A1 引用、错误值体系、函数命名规范），降低迁移成本。输出格式支持 JSON 和 CSV，便于跨语言、跨平台集成。

## 4、预期使用场景

**场景一：在线表格 / 低代码编辑器后端计算引擎**
MoonSheet 作为后端计算服务，接收前端传来的表格数据和公式，批量计算后将结果以 JSON 返回。适用于在线协同表格、低代码平台的表单计算、报表设计器等场景，实现前后端分离的架构，避免前端公式引擎与后端逻辑不一致的问题。

**场景二：报表系统与数据看板**
企业级报表系统中大量使用公式计算（汇总、占比、同比环比、财务指标）。MoonSheet 提供的 150+ 函数覆盖统计、财务、逻辑、日期等常用计算需求，可作为报表引擎的计算核心，通过配置化方式实现复杂报表逻辑，减少硬编码。

**场景三：工作流 / 审批流程中的条件计算**
工作流引擎常需根据表单数据进行条件判断和数值计算（如费用报销金额计算、审批路由条件）。MoonSheet 的 IF/AND/OR/XLOOKUP/CHOOSE 等函数可直接用于表达式配置，业务人员可通过类 Excel 公式定义计算规则，降低开发成本。

## 5、拟实现的核心功能

| 模块 | 功能内容 |
|------|---------|
| 公式引擎 | 词法分析器、递归下降解析器、AST 节点、表达式求值器，支持运算符优先级和结合性 |
| 单元格引用 | A1 表示法、绝对/相对引用（`$A$1`）、范围引用（`A1:B2`）、R1C1 转换 |
| 内置函数 | 151 个函数：数学 34、文本 21、逻辑 20、日期时间 17、统计 21、查找 18、财务 16、数组 22 |
| 数据模型 | 单元格、工作表、工作簿三级结构，支持多工作表 |
| 依赖管理 | 依赖图构建、拓扑排序、循环引用检测、增量重算 |
| 命名区域 | 工作簿级和工作表级命名区域、名称校验、JSON 序列化 |
| 条件格式 | 单元格值规则、公式规则、色阶、前 N 项、高于/低于平均值、重复值、唯一值、空值、错误值 |
| 数据验证 | 整数、小数、列表、日期、时间、文本长度、自定义，支持输入提示和错误警告 |
| 错误处理 | Excel 兼容错误值体系（`#DIV/0!`、`#N/A`、`#NAME?`、`#REF!`、`#VALUE!`、`#CIRC!` 等） |
| 数据格式 | 数字、千分位、百分比、货币、科学计数法、日期、时间格式 |
| I/O | CSV 导入导出、TSV 导出、JSON 序列化/反序列化 |
| 质量保障 | 单元测试全覆盖、GitHub Actions CI 流水线（格式检查 + 构建 + 测试） |

## 6、项目性质

**本项目为原创项目。** MoonSheet 从架构设计到代码实现均独立完成，未移植或参考任何现有开源电子表格引擎的代码。公式语法的 A1 表示法、错误值定义和函数命名规范参照 Excel/LibreOffice Calc 的公开技术文档标准，属于行业通用约定而非特定项目专有设计。所有源码以 MoonBit 原生语法编写，无第三方运行时依赖。

## 7、参考项目说明

不适用。本项目为原创项目。

## 8、GitHub 仓库链接

`https://github.com/moonsheet-dev/moonsheet`

- 提交次数：10+ 次有效提交
- 提交内容：按模块递进提交，每次提交包含完整功能和对应测试
- 提交记录：
  1. `chore: initialize project with .gitignore`
  2. `feat: add project structure and core value types (ErrorValue, Value)`
  3. `feat: add cell, sheet, and workbook data structures with tests`
  4. `feat: add formula engine - lexer, parser, AST, and cell reference parsing`
  5. `feat: add 95 built-in functions, evaluator, dependency graph, I/O, and demo`
  6. `feat: add lookup and reference functions (VLOOKUP, INDEX, MATCH, XLOOKUP, etc.)`
  7. `feat: add financial functions (PV, FV, PMT, NPV, IRR, RATE, etc.)`
  8. `feat: add named ranges support with validation and JSON export`
  9. `feat: add conditional formatting rules (11 rule types)`
  10. `feat: add data validation (7 types with input/error messages)`
  11. `feat: add dynamic array functions (SORT, UNIQUE, TEXTJOIN, FREQUENCY, etc.)`
