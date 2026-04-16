# Story 11-04 字典数据管理

## 0. 基本信息

- Epic：低代码配置管理
- Story ID：11-04
- 优先级：P0
- 状态：Done
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 1

---

## 1. 目标

实现字典类型和字典数据的管理功能，支持下拉选项的数据源配置，为低代码表单的下拉、开关等控件提供数据源。

---

## 2. 业务背景

字典数据是低代码表单中下拉选择、开关等控件的数据来源。系统预置常用字典（如状态、类型），也支持业务自定义字典。

---

## 3. 范围

### 3.1 本 Story 包含

- 字典类型管理（CRUD）
- 字典数据管理（CRUD）
- 字典数据批量导入
- 字典数据批量导出
- 字典数据缓存

### 3.2 本 Story 不包含

- 表元数据管理（见 Story 11-01）
- 字段元数据管理（见 Story 11-02）
- 低代码引擎接口（见 Story 11-05）

---

## 4. 参与角色

- 系统管理员：管理字典数据

---

## 5. 前置条件

- 用户已登录系统
- 用户具备系统管理权限

---

## 6. 触发方式

- 页面入口：系统管理 → 字典管理
- 接口入口：GET `/api/system/dict`

---

## 7. 输入 / 输出

### 7.1 字典类型字段

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| dictType | string | 是 | 字典类型编码，唯一 |
| dictName | string | 是 | 字典名称 |
| dictDesc | string | 否 | 字典描述 |
| isSystem | int | 否 | 是否系统内置（0/1） |
| isEnabled | int | 是 | 是否启用（0/1） |

### 7.2 字典数据字段

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| dictType | string | 是 | 字典类型编码 |
| itemText | string | 是 | 字典项文本 |
| itemValue | string | 是 | 字典项值 |
| sortOrder | int | 否 | 排序号 |
| isDefault | int | 否 | 是否默认（0/1） |
| isEnabled | int | 是 | 是否启用（0/1） |
| remark | string | 否 | 备注 |

### 7.3 列表查询输入

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| dictType | string | N | 字典类型 |
| dictName | string | N | 字典名称（模糊搜索） |
| page | int | N | 页码，默认1 |
| pageSize | int | N | 每页条数，默认20 |

### 7.4 列表输出

| 字段 | 类型 | 说明 |
|------|------|------|
| total | int | 总记录数 |
| records | array | 字典列表 |

---

## 8. 业务规则

1. 字典类型编码唯一
2. 字典数据项值唯一
3. 系统内置字典不可删除
4. 导入时覆盖已有数据（按 itemValue 匹配）
5. 字典数据启用本地缓存，有效期 5 分钟

---

## 9. 数据设计

### 9.1 涉及表

- `sys_dict`（字典类型）
- `sys_dict_data`（字典数据）

### 9.2 表结构

```sql
CREATE TABLE sys_dict (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  dict_type VARCHAR(50) NOT NULL COMMENT '字典类型',
  dict_name VARCHAR(100) NOT NULL COMMENT '字典名称',
  dict_desc VARCHAR(200) COMMENT '字典描述',
  is_system TINYINT DEFAULT 0 COMMENT '系统内置',
  is_enabled TINYINT DEFAULT 1 COMMENT '是否启用',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_dict_type (dict_type)
) COMMENT '字典类型';

CREATE TABLE sys_dict_data (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  dict_type VARCHAR(50) NOT NULL COMMENT '字典类型',
  item_text VARCHAR(100) NOT NULL COMMENT '字典项文本',
  item_value VARCHAR(100) NOT NULL COMMENT '字典项值',
  sort_order INT DEFAULT 0 COMMENT '排序',
  is_default TINYINT DEFAULT 0 COMMENT '是否默认',
  is_enabled TINYINT DEFAULT 1 COMMENT '是否启用',
  remark VARCHAR(200) COMMENT '备注',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_dict_value (dict_type, item_value)
) COMMENT '字典数据';
```

---

## 10. API / 接口契约

### 10.1 字典类型接口

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/system/dict/type` | 字典类型列表 |
| GET | `/api/system/dict/type/{dictType}` | 字典类型详情 |
| POST | `/api/system/dict/type` | 创建字典类型 |
| PUT | `/api/system/dict/type/{dictType}` | 更新字典类型 |
| DELETE | `/api/system/dict/type/{dictType}` | 删除字典类型 |

### 10.2 字典数据接口

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/system/dict/data` | 字典数据列表 |
| GET | `/api/system/dict/data/{dictType}` | 获取字典数据（低代码引擎用） |
| POST | `/api/system/dict/data` | 创建字典数据 |
| PUT | `/api/system/dict/data/{id}` | 更新字典数据 |
| DELETE | `/api/system/dict/data/{id}` | 删除字典数据 |
| POST | `/api/system/dict/data/{dictType}/import` | 批量导入 |
| GET | `/api/system/dict/data/{dictType}/export` | 导出字典数据 |

### 10.3 字典数据响应示例

```json
GET /api/system/dict/data/warehouse_status
{
  "code": 200,
  "data": [
    {"value": "ENABLED", "label": "启用", "isDefault": true},
    {"value": "DISABLED", "label": "禁用", "isDefault": false}
  ]
}
```

---

## 11. 权限与审计

### 11.1 权限标识

- `system:dict:query`
- `system:dict:manage`

### 11.2 审计要求

- 新增、修改、删除、导入操作记录日志

---

## 12. 验收标准

### 12.1 功能验收

- [x] 字典类型 CRUD 正常
- [x] 字典数据 CRUD 正常
- [x] 批量导入功能正常
- [x] 导出功能正常
- [x] 字典数据缓存生效

---

## 13. 交付物清单

- [x] 后端代码
- [x] 前端页面
- [x] 接口文档

---

## 14. 关联文档

- Epic Brief：[epic-11-overview.md](../../epics/epic-11-overview.md)
- 低代码设计：[04-DESIGN/03-lowcode-design.md](../../04-DESIGN/03-lowcode-design.md)
