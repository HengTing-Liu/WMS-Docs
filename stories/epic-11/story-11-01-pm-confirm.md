# Story 11-01 表元数据管理

## PM 需求确认

**确认日期**：2026-04-06
**确认状态**：✅ 已确认
**数据来源**：实际数据库表结构

---

### 实际数据库表结构

```sql
DESC sys_table_meta;
```

| 字段 | 类型 | Null | Key | Default | 说明 |
|------|------|------|-----|---------|------|
| id | bigint | NO | PRI | NULL | 主键 |
| table_code | varchar(100) | NO | UNI | NULL | 表编码 |
| table_name | varchar(200) | NO | | NULL | 表名称 |
| module | varchar(50) | YES | MUL | NULL | 所属模块 |
| entity_class | varchar(200) | YES | | NULL | 实体类名 |
| service_class | varchar(200) | YES | | NULL | 服务类名 |
| permission_code | varchar(100) | YES | | NULL | 权限标识 |
| page_size | int | YES | | 20 | 默认页大小 |
| is_tree | tinyint | YES | | 0 | 是否树形 |
| status | tinyint | YES | | 1 | 状态（1启用） |
| remark | varchar(500) | YES | | NULL | 备注 |
| create_by | varchar(64) | YES | | NULL | 创建人 |
| create_time | datetime | YES | | CURRENT_TIMESTAMP | 创建时间 |
| update_by | varchar(64) | YES | | NULL | 更新人 |
| update_time | datetime | YES | | CURRENT_TIMESTAMP | 更新时间 |
| is_deleted | tinyint | YES | | 0 | 逻辑删除：0-否 1-是 |
| has_data_permission | tinyint | NO | | 0 | 是否有数据权限 |
| permission_field | varchar(64) | YES | | dept_id | 权限字段 |
| permission_scope | varchar(32) | YES | | DEPT | 权限范围 |

---

### 字段规范（已确认，按实际表结构）

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| tableCode | string | 是 | 表编码，唯一 |
| tableName | string | 是 | 表名称 |
| module | string | 是 | 所属模块 |
| entityClass | string | 否 | 实体类名 |
| serviceClass | string | 否 | 服务类名 |
| permissionCode | string | 否 | 权限标识 |
| pageSize | int | 否 | 默认页大小，默认20 |
| isTree | int | 否 | 是否树形，默认0 |
| status | int | 否 | 状态，默认1（启用） |
| remark | string | 否 | 备注 |

---

### 接口契约（已确认）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/system/meta/table` | 表元数据列表查询（分页+模糊搜索） |
| GET | `/api/system/meta/table/{id}` | 表元数据详情 |
| GET | `/api/system/meta/table/code/{code}` | 通过编码查询 |
| POST | `/api/system/meta/table` | 创建表元数据 |
| PUT | `/api/system/meta/table/{id}` | 更新表元数据 |
| DELETE | `/api/system/meta/table/{id}` | 删除表元数据 |
| PUT | `/api/system/meta/table/{id}/toggle` | 启用/禁用切换 |

---

### 权限方案（已确认）

| 权限标识 | 说明 |
|----------|------|
| system:meta:table:query | 表元数据查询 |
| system:meta:table:manage | 表元数据管理 |

---

### 业务规则（已确认）

1. 表编码唯一，重复时报错
2. 删除前检查是否有关联字段
3. 启用/禁用不影响已有数据
4. 逻辑删除：使用 is_deleted 字段（int 类型，0-否 1-是）

---

### 遗留问题

无

---

**PM 确认签字**：OpenClaw wms总控
**确认时间**：2026-04-06
**数据来源**：实际数据库表结构 + Nacos 配置
