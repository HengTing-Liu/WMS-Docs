# 低代码完整闭环设计（Table / Column / Operation + 发布）

## 1. 目标
- 让低代码从“仅运行时配置”升级为“可建模、可发布、可回滚”的完整闭环。
- 使用者只维护 3 个配置页面即可完成页面能力配置，并通过“发布”将配置落地到真实数据库与运行时。

## 2. 当前现状
- 已有配置页：
  - `/lowcode/lowcode/table`
  - `/lowcode/lowcode/column`
  - `/lowcode/lowcode/operation`
- 当前能力本质是元数据管理（`sys_table_meta/sys_column_meta/sys_table_operation`）。
- 新建 Table 只写元数据，不会自动 `CREATE TABLE`。

## 3. 闭环定义（目标态）
完整闭环 = 建模 + 校验 + 生成DDL + 执行发布 + 运行生效 + 回滚追踪

### 3.1 建模层（3页）
- Table：定义业务对象级配置（编码、名称、权限前缀、分页、树形、逻辑删除字段等）。
- Column：定义字段级配置（DB类型、长度精度、是否必填、索引、UI组件、是否查询/列表/表单显示）。
- Operation：定义行为级配置（按钮位置、权限、事件类型、事件参数模板、确认提示）。

### 3.2 发布层（新增）
- 发布前校验：
  - 元数据完整性（主键、字段重名、非法类型映射、长度合法性）。
  - 与真实库比对（Diff）。
- 生成变更集：
  - `CREATE TABLE`
  - `ALTER TABLE ADD/MODIFY/DROP COLUMN`
  - `CREATE/DROP INDEX`
- 执行策略：
  - 预览SQL（必须）
  - 手工确认后执行（必须）
  - 执行日志与结果持久化（必须）

### 3.3 运行层
- 低代码页面运行时仅消费已发布版本。
- 发布成功后自动失效/刷新 meta 缓存。

## 4. 是否需要“发布界面”
需要，且是完整闭环的关键。

没有发布界面会出现：
- 配置和物理库状态不一致。
- 无法可视化审阅 DDL 风险。
- 无版本、无审计、无法回滚。

建议新增页面：`/lowcode/lowcode/publish`

## 5. 发布界面功能清单（V1）
## 5.1 页面能力
- 选择目标表（或批量多表）。
- 显示“元数据 vs 数据库”Diff。
- 显示将执行的 SQL 清单（分级：安全/风险/破坏性）。
- 发布前校验结果面板。
- 发布执行按钮（含二次确认）。
- 发布历史与执行日志查询。

## 5.2 操作流
1. 点击“生成变更集”。
2. 系统做校验与 Diff。
3. 用户审阅 SQL 清单。
4. 点击“确认发布”执行事务。
5. 写发布记录、刷新缓存、返回结果。

## 6. 后端设计建议
## 6.1 新增表
- `sys_meta_publish`：发布主记录（表、版本、状态、发布人、发布时间）。
- `sys_meta_publish_detail`：每条SQL执行详情（顺序、SQL、耗时、结果、错误）。
- `sys_meta_snapshot`：发布快照（table/column/operation JSON）。

## 6.2 新增接口
- `POST /api/system/meta/publish/plan`：生成发布计划（校验 + diff + SQL预览）。
- `POST /api/system/meta/publish/execute`：执行发布。
- `GET /api/system/meta/publish/history`：发布历史。
- `GET /api/system/meta/publish/{id}`：发布详情。
- `POST /api/system/meta/publish/rollback/{id}`：按快照回滚（V2）。

## 6.3 事务与安全
- 单表发布默认事务执行。
- 破坏性操作（drop/modify narrowing）默认阻断，需显式强制参数。
- SQL 注入防护：表名/字段名白名单校验，禁止原始拼接输入。

## 7. 前端设计建议
- 复用现有低代码风格，新增 `publish` 配置页。
- 页面模块：
  - 选择区（表/环境）
  - 校验结果区
  - Diff区
  - SQL预览区
  - 执行日志区
- 高风险 SQL（DROP/MODIFY）使用警示色 + 额外确认。

## 8. 实施顺序（推荐）
1. V1：支持 `CREATE TABLE` + `ADD COLUMN` + `CREATE INDEX`（只增不删，最安全）。
2. V1.1：支持 `MODIFY COLUMN`（非破坏变更）。
3. V2：支持 `DROP COLUMN/INDEX` + 回滚。
4. V2.1：支持多表批量发布与依赖排序。

## 9. 验收标准
- 新建表配置后，可在发布页一键生成并执行 `CREATE TABLE`。
- 发布后数据库真实表结构与 `sys_column_meta` 一致。
- 低代码运行页无需重启即可读取最新发布结构。
- 有完整发布历史、SQL日志、失败可追踪。

## 10. 结论
- 仅有 Table/Column/Operation 三页还不构成“完整低代码闭环”。
- 必须补“发布界面 + 发布引擎”，才能把配置可靠落地到实体库并可运维。
