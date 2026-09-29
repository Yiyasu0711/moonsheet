# 2026 MoonBit 国产基础软件生态开源大赛 项目申报书

## 1、项目名称

**MoonSheet —— 面向服务端与嵌入式场景的 MoonBit 轻量级表格公式引擎**

GitHub 仓库：`https://github.com/Yiyasu0711/moonsheet`（仓库已更名，原链接 moonbit-test 自动重定向）

## 2、项目简介

MoonSheet 是使用 MoonBit 语言从零实现的轻量级表格公式计算引擎，定位为可嵌入的计算内核而非完整的电子表格文件库。项目提供完整的公式解析、求值、依赖图管理、数据格式化与 I/O 能力，涵盖词法分析器、递归下降解析器、AST 求值器、拓扑排序、命名区域、条件格式、数据验证，以及 151 个内置函数（数学、文本、逻辑、日期时间、统计、查找、财务、动态数组八大类）。代码规模 8000+ 行，30+ 源文件，配有完整单元测试，采用 Apache-2.0 开源许可证，已配置 GitHub Actions CI 流水线。

与 mooncakes.io 上的 mbtexcel（excelize 的 MoonBit 移植，侧重 XLSX 文件格式读写）形成互补：mbtexcel 专注文件级操作（读写 XLSX、样式、图表、透视表），MoonSheet 专注计算引擎本身（轻量化、无文件格式依赖、JSON 优先、面向服务端嵌入），二者可组合使用。

## 3、项目方向与通用性说明

**项目方向**：数据处理 —— 表格计算引擎 / 数据处理基础组件

**通用性说明**：MoonSheet 定位为通用计算库，不绑定特定前端或文件格式。核心引擎以纯函数式 API 提供（输入公式字符串和数据，返回计算结果），可嵌入任意 MoonBit 应用。数据模型与 Excel 兼容（A1 引用、错误值体系、函数命名规范），降低迁移成本。输出支持 JSON 和 CSV，便于跨语言、跨平台集成，尤其适合服务端批量计算、微服务、工作流引擎等场景。

## 4、预期使用场景

**场景一：在线表格 / 低代码平台的后端计算服务**
MoonSheet 作为后端计算微服务，接收前端传来的表格数据和公式，批量计算后以 JSON 返回。适用于在线协同表格、低代码平台的表单计算、报表设计器等场景，实现前后端分离架构，避免前端公式引擎与后端逻辑不一致的问题。相比直接使用 mbtexcel 做后端计算，MoonSheet 更轻量，无需加载 XLSX 解析和样式体系。

**场景二：报表系统与数据看板的计算内核**
企业级报表系统大量使用公式计算（汇总、占比、同比环比、财务指标）。MoonSheet 的 150+ 函数覆盖统计、财务、逻辑、日期等常用计算需求，可作为报表引擎的计算核心，通过配置化方式实现复杂报表逻辑，减少硬编码。支持动态数组函数（SORT、UNIQUE、FILTER 等），便于实现灵活的数据筛选和聚合。

**场景三：工作流 / 审批流程中的条件表达式计算**
工作流引擎常需根据表单数据进行条件判断和数值计算（费用报销、审批路由条件）。MoonSheet 的 IF/AND/OR/XLOOKUP/CHOOSE 等函数可直接用于表达式配置，业务人员可通过类 Excel 公式定义计算规则，降低开发成本。轻量级特性使其适合嵌入工作流引擎作为表达式求值器。

## 5、拟实现的核心功能

| 模块 | 功能内容 |
|------|---------|
| 公式引擎 | 词法分析器、递归下降解析器、AST 节点、表达式求值器，支持运算符优先级和结合性 |
| 单元格引用 | A1 表示法、绝对/相对引用（`$A$1`）、范围引用（`A1:B2`）、R1C1 转换 |
| 内置函数 | 151 个函数：数学 34、文本 21、逻辑 20、日期时间 17、统计 21、查找 18、财务 16、动态数组 22 |
| 动态数组 | SORT、UNIQUE、FILTER、TEXTJOIN、SEQUENCE、RANDARRAY、HSTACK、VSTACK、SORTBY 等 22 个函数 |
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

**与 mbtexcel 的关系说明：**

mbtexcel 是 excelize（Go 语言 Excel 文件操作库）的 MoonBit 移植版，由 moonbitlang 官方维护，核心定位是 **XLSX 文件格式的读写库**，侧重于文件操作、样式管理、图表、透视表等完整的 Excel 文件特性，并内置公式计算作为其功能的一部分。

MoonSheet 与 mbtexcel 的定位不同，属于**互补关系**：

| 维度 | mbtexcel | MoonSheet |
|------|----------|-----------|
| 核心定位 | XLSX 文件读写库（excelize 移植） | 轻量级表格公式计算引擎（原创） |
| 主要用途 | 操作 Excel 文件、生成报表文件 | 服务端计算、嵌入式求值、数据处理 |
| 文件格式依赖 | 强依赖 XLSX/OOXML | 无文件格式依赖，JSON/CSV 原生 |
| 架构特点 | 文件 I/O 为核心，公式计算内嵌其中 | 计算引擎独立，模块解耦，可按需引入 |
| 动态数组函数 | 未明确支持 | 支持 22 个动态数组函数 |
| 适用场景 | 桌面/客户端、文件生成场景 | 服务端微服务、工作流、轻量应用 |
| 体积/依赖 | 较大（完整 OOXML 解析 + 样式 + 图表） | 轻量（仅计算引擎 + 基础 I/O） |

**互补价值：**
- 可组合使用：用 mbtexcel 读写 XLSX 文件，用 MoonSheet 做高性能服务端批量计算
- MoonSheet 的动态数组函数可填补现代表格计算特性
- MoonSheet 的 JSON-first 设计更适合 Web API 和微服务架构

## 8、GitHub 仓库链接

`https://github.com/Yiyasu0711/moonsheet`

- 提交次数：13 次有效提交
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
  11. `feat: add dynamic array functions and update documentation`
  12. `docs: add project proposal and setup guide`
  13. `docs: update proposal with mbtexcel differentiation analysis`
