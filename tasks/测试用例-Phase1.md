# Phase 1 测试用例

> **版本：** v1.0
> **创建日期：** 2026-04-03
> **负责人：** QA
> **关联需求：** WMS 低代码平台 MVP + WMS0010 仓库管理

---

## 测试用例总览

| 模块 | 用例数 | 优先级 |
|------|--------|--------|
| DDL 字段扩展 | 6 | P0 |
| CRUD 接口 | 22 | P0 |
| FieldRenderer | 14 | P0 |
| LowcodeForm | 18 | P0 |
| LowcodeLayout | 8 | P1 |
| WmsSearchBar | 6 | P1 |
| 数据权限 | 10 | P0 |
| **总计** | **99** | |

---

## 1. DDL 字段扩展测试用例

### 1.1 字段结构验证

| 用例ID | 用例描述 | 前提条件 | 测试步骤 | 预期结果 | 优先级 |
|--------|---------|---------|---------|---------|--------|
| DDL-001 | sys_column_meta 表结构 | — | 执行 DDL 并验证表结构 | 4 个扩展字段存在 | P0 |
| DDL-002 | col_span 字段验证 | 字段存在 | 验证字段类型和默认值 | 默认值为 6 | P0 |
| DDL-003 | section_key 字段验证 | 字段存在 | 验证字段类型和默认值 | 默认值为 'basic' | P0 |
| DDL-004 | i18n_key 字段验证 | 字段存在 | 验证字段类型和长度 | 最大长度 100 | P0 |
| DDL-005 | visible_condition 字段验证 | 字段存在 | 验证 JSON 格式存储 | 可存储 JSON 条件 | P0 |
| DDL-006 | 字段与实体类映射 | 字段存在 | 验证字段与实体类映射 | 实体类包含所有字段 | P0 |

---

## 2. Meta Schema 接口测试用例

### 2.1 Schema 接口验证

| 用例ID | 用例描述 | 前提条件 | 测试步骤 | 预期结果 | 优先级 |
|--------|---------|---------|---------|---------|--------|
| META-001 | column/schema 接口 | DDL 已执行 | 调用 GET /api/system/meta/column/schema | 返回完整 Schema | P0 |
| META-002 | 扩展字段返回 | WMS0010 已配置 | 验证返回包含 4 个扩展字段 | col_span 等字段存在 | P0 |

---

## 3. CRUD 接口测试用例

### 3.1 基础 CRUD 操作

| 用例ID | 用例描述 | 前提条件 | 测试步骤 | 预期结果 | 优先级 |
|--------|---------|---------|---------|---------|--------|
| CRUD-001 | 列表查询 | WMS0010 已配置 | GET /api/wms/crud/{tableCode}/list | 返回分页数据 | P0 |
| CRUD-002 | 详情查询 | 记录存在 | GET /api/wms/crud/{tableCode}/{id} | 返回完整数据 | P0 |
| CRUD-003 | 新增保存 | 数据有效 | POST /api/wms/crud/{tableCode}/save | 新增成功 | P0 |
| CRUD-004 | 更新修改 | 记录存在 | PUT /api/wms/crud/{tableCode}/{id} | 更新成功 | P0 |
| CRUD-005 | 删除 | 记录存在 | DELETE /api/wms/crud/{tableCode}/{id} | 删除成功 | P0 |
| CRUD-006 | 启禁用切换 | 记录存在 | POST /api/wms/crud/{tableCode}/toggle/{id} | 状态切换成功 | P0 |

