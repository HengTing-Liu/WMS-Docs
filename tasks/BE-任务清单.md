# BE 后端开发任务清单

> BE Agent 后端任务进度 | 2026-04-03
> **BE 后端开发任务清单参考：** [项目总览](../项目状态.md)

---

## Phase 0 开发任务总览

## 任务清单：BE-001 创建 SCM 系统的 Meta 表 DDL

**任务描述：** 创建 sys_table_meta / sys_column_meta / sys_table_operation 等 Meta 表结构

**操作步骤：**
1. 连接到 SCM 数据库，创建 sys_table_meta 表 DDL
   - `sys_table_meta` 表：仓储主表定义
   - `sys_column_meta` 表：字段元数据定义
   - `sys_table_operation` 表：操作按钮定义
   - `sys_dict` 表：字典类型
   - `sys_dict_data` 表：字典数据
2. 编写表结构设计文档
3. **特别注意：** 将所有 DDL 汇总写入 `docs/WMS低代码开发规划.md` 的 Phase 0 数据库设计章节

**验收标准：** DDL 文档参考 `docs/WMS低代码开发规划.md`

---

## 任务清单：BE-002 sys_column_meta 扩展字段 DDL

**任务描述：** 为 sys_column_meta 增加 4 个扩展字段

**扩展字段说明：**
```sql
ADD COLUMN col_span INT DEFAULT 6 COMMENT '表单分组占比权重（1-24）';
ADD COLUMN section_key VARCHAR(50) DEFAULT 'basic' COMMENT '分组 Key，对应表单 Section';
ADD COLUMN i18n_key VARCHAR(100) COMMENT '国际化 Key';
ADD COLUMN visible_condition TEXT COMMENT '字段可见性条件（JSON 格式）如：{"field":"status","value":"1"}';
```

**验收标准：** DDL 参考 `docs/WMS低代码开发规划.md` 执行到数据库

---

## 任务清单：BE-003 ColumnMeta 实体类 + Schema 查询

**任务描述：** 创建 6 个 Meta 表对应的实体类、VO、Mapper 查询 Schema

**详细设计：**
- `GET /api/system/meta/column/schema` — 返回 ColumnMeta 字段的完整 Schema（含 4 个扩展字段）
- 返回结果包含下拉选项的字典数据（dict_type 映射）

**验收标准：** 用 Postman 测试接口返回正确 Schema

---

## 任务清单：BE-004 动态 CRUD 接口开发

**任务描述：** 实现一套通用的动态 CRUD 接口，支持任意表的增删改查

**接口设计：**
```
GET    /api/wms/crud/{tableCode}/list        — 分页列表+高级查询+字段过滤+排序
GET    /api/wms/crud/{tableCode}/{id}        — 详情查询
POST   /api/wms/crud/{tableCode}/save        — 新增保存
PUT    /api/wms/crud/{tableCode}/{id}        — 更新修改
DELETE /api/wms/crud/{tableCode}/{id}        — 删除
POST   /api/wms/crud/{tableCode}/toggle/{id}  — 启禁用切换
```

**验收标准：** 用 Postman 测试 WMS0010 仓库表的完整 CRUD

---

## Phase 0 后端技术架构

| 后端组件 | 职责 | 说明 |
|------|------|------|
| CrudController | `/api/wms/crud/{tableCode}` | GET list/detail/save/put/delete/checkUnique |
| CrudService + Impl | 通用 CRUD 服务 | 通用 SQL + 动态查询 + 字段过滤 |
| MetaService + Impl | 元数据 Schema 查询 | 按 ColumnMeta 字段 + 字典 + Schema |
| DynamicMapper + XML | 动态 SQL | 按 table_code 动态生成 SQL |
| SqlInjectionValidator | SQL 注入校验 | 白名单校验 + 字段名校验 |
| MetaCacheService | 元数据缓存服务 | `MetaCacheEvent` 缓存刷新 |
| CrudPermissionUtil | 数据权限注入 | `injectDataScope()` 数据范围过滤 |

---

## Phase 1 后端接口计划

| # | 开发任务 | 说明 |
|---|------|------|
| 1 | BE-002 字段扩展 DDL | ColumnMeta 增加 4 个字段 |
| 2 | BE-003 Schema 接口 | ColumnMetaVO + Mapper 扩展 |
| 3 | BE-004 LowcodeTreeService | 树形数据查询服务 |
| 4 | BE-004 启禁用接口 | toggleStatus 数据权限过滤 |
| 5 | BE-004 字段占用检查 | occupancy check |
| 6 | BE-004 API 统一前缀 | `/api/wms/crud/*` 统一路由 |

