# Story 11-01 表元数据管理

## PM 需求确认

**确认日期**：2026-04-06
**确认状态**：✅ 已确认

---

### 字段规范（已确认）

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| tableCode | string | 是 | 表编码（如 WMS0010），唯一 |
| tableName | string | 是 | 表名称 |
| tableDesc | string | 否 | 表描述 |
| module | string | 是 | 所属模块 |
| crudPrefix | string | 否 | CRUD接口前缀 |
| isEnabled | int | 是 | 是否启用（0/1） |

---

### 接口契约（已确认）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/system/meta/table` | 表元数据列表查询 |
| GET | `/api/system/meta/table/{id}` | 表元数据详情 |
| GET | `/api/system/meta/table/code/{code}` | 通过编码查询 |
| POST | `/api/system/meta/table` | 创建表元数据 |
| PUT | `/api/system/meta/table/{id}` | 更新表元数据 |
| DELETE | `/api/system/meta/table/{id}` | 删除表元数据 |
| PUT | `/api/system/meta/table/{id}/toggle` | 启用/禁用 |

---

### 权限方案（已确认）

| 权限标识 | 说明 |
|----------|------|
| system:meta:table:query | 表元数据查询 |
| system:meta:table:manage | 表元数据管理 |

---

### 业务规则（已确认）

1. 表编码唯一，重复时报错
2. 删除表元数据前需检查是否有关联字段或页面引用
3. 启用/禁用不影响已有数据

---

### 遗留问题

无

---

**PM 确认签字**：OpenClaw wms总控
**确认时间**：2026-04-06
