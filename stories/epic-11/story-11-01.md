# Story 11-01 表元数据管理

## 0. 基本信息

- Epic：低代码配置管理
- Story ID：11-01
- 优先级：P0
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 1

---

## 1. 目标

实现表元数据（sys_table_meta）的 CRUD 功能，支持前端低代码页面通过表编码获取元数据配置。

---

## 2. 业务背景

表元数据是低代码平台的核心配置表，定义了每个页面的基本信息、表名、模块归属等。所有低代码页面都依赖表元数据进行渲染。

---

## 3. 范围

### 3.1 本 Story 包含

- 表元数据分页列表查询
- 表元数据新增
- 表元数据编辑
- 表元数据删除（含关联检查）
- 表元数据导出

### 3.2 本 Story 不包含

- 字段元数据管理（见 Story 11-02）
- 操作元数据管理（见 Story 11-03）
- 低代码引擎接口（见 Story 11-05）

---

## 4. 参与角色

- 系统管理员：管理表元数据

---

## 5. 前置条件

- 用户已登录系统
- 用户具备系统管理权限

---

## 6. 触发方式

- 页面入口：系统管理 → 低代码配置 → 表元数据
- 接口入口：GET `/api/system/meta/table`

---

## 7. 输入 / 输出

### 7.1 表元数据字段

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| tableCode | string | 是 | 表编码（如 WMS0010），唯一 |
| tableName | string | 是 | 表名称 |
| tableDesc | string | 否 | 表描述 |
| module | string | 是 | 所属模块 |
| crudPrefix | string | 否 | CRUD接口前缀 |
| isEnabled | int | 是 | 是否启用（0/1） |

### 7.2 列表查询输入

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| tableCode | string | N | 表编码（模糊搜索） |
| tableName | string | N | 表名称（模糊搜索） |
| module | string | N | 所属模块 |
| page | int | N | 页码，默认1 |
| pageSize | int | N | 每页条数，默认20 |

### 7.3 列表输出

| 字段 | 类型 | 说明 |
|------|------|------|
| total | int | 总记录数 |
| records | array | 表元数据列表 |
| records[].id | long | 主键 |
| records[].tableCode | string | 表编码 |
| records[].tableName | string | 表名称 |
| records[].tableDesc | string | 表描述 |
| records[].module | string | 所属模块 |
| records[].crudPrefix | string | CRUD接口前缀 |
| records[].isEnabled | int | 是否启用 |
| records[].gmtCreate | datetime | 创建时间 |

---

## 8. 业务规则

1. 表编码唯一，重复时报错
2. 删除表元数据前需检查是否有关联字段或页面引用
3. 启用/禁用不影响已有数据

---

## 9. 数据设计

### 9.1 涉及表

- `sys_table_meta`

### 9.2 表结构

```sql
CREATE TABLE sys_table_meta (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  table_code VARCHAR(50) NOT NULL COMMENT '表编码',
  table_name VARCHAR(100) NOT NULL COMMENT '表名称',
  table_desc VARCHAR(500) COMMENT '表描述',
  module VARCHAR(50) NOT NULL COMMENT '所属模块',
  crud_prefix VARCHAR(100) COMMENT 'CRUD接口前缀',
  is_enabled TINYINT DEFAULT 1 COMMENT '是否启用',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_table_code (table_code)
) COMMENT '表元数据';
```

---

## 10. API / 接口契约

### 10.1 接口清单

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/system/meta/table` | 表元数据列表查询 |
| GET | `/api/system/meta/table/{id}` | 表元数据详情 |
| GET | `/api/system/meta/table/code/{code}` | 通过编码查询 |
| POST | `/api/system/meta/table` | 创建表元数据 |
| PUT | `/api/system/meta/table/{id}` | 更新表元数据 |
| DELETE | `/api/system/meta/table/{id}` | 删除表元数据 |
| PUT | `/api/system/meta/table/{id}/toggle` | 启用/禁用 |

### 10.2 创建请求示例

```json
POST /api/system/meta/table
{
  "tableCode": "WMS0010",
  "tableName": "仓库档案",
  "tableDesc": "管理仓库基本信息",
  "module": "base",
  "crudPrefix": "/api/base/warehouse",
  "isEnabled": 1
}
```

### 10.3 响应示例

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "tableCode": "WMS0010",
    "tableName": "仓库档案"
  }
}
```

### 10.4 错误码

| 错误码 | 场景 | 提示 |
|--------|------|------|
| 400 | 表编码重复 | 表编码已存在 |
| 400 | 有关联数据 | 该表存在关联字段，不允许删除 |

---

## 11. 权限与审计

### 11.1 权限标识

- `system:meta:table:query`
- `system:meta:table:manage`

### 11.2 审计要求

- 新增、修改、删除操作记录日志

---

## 12. 验收标准

### 12.1 功能验收

- [x] 表元数据列表查询正常
- [x] 表编码唯一性校验生效
- [x] 删除前检查关联数据
- [x] 启用/禁用功能正常
- [x] 导出功能正常

---

## 13. 交付物清单

- [x] 后端代码（Controller/Service/Mapper）
- [x] 前端页面（低代码配置页面）
- [x] 接口文档
- [x] 数据库脚本

---

## 14. 关联文档

- Epic Brief：[epic-11-overview.md](../../epics/epic-11-overview.md)
- 低代码设计：[04-DESIGN/03-lowcode-design.md](../../04-DESIGN/03-lowcode-design.md)
