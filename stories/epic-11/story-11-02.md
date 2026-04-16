# Story 11-02 字段元数据管理

## 0. 基本信息

- Epic：低代码配置管理
- Story ID：11-02
- 优先级：P0
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：11-01（表元数据管理）
- 关联迭代：Sprint 1

---

## 1. 目标

实现字段元数据（sys_column_meta）的 CRUD 功能，支持拖拽排序和批量操作，为低代码表单渲染提供字段配置。

---

## 2. 业务背景

字段元数据定义了表单字段的类型、必填、显示、校验等属性。前端低代码引擎根据字段元数据动态渲染表单控件。

---

## 3. 范围

### 3.1 本 Story 包含

- 字段元数据列表查询（按表ID）
- 字段元数据新增
- 字段元数据编辑
- 字段元数据删除
- 字段元数据批量新增
- 字段元数据拖拽排序
- 字段元数据复制（从其他表复制）

### 3.2 本 Story 不包含

- 表元数据管理（见 Story 11-01）
- 操作元数据管理（见 Story 11-03）
- 低代码引擎接口（见 Story 11-05）

---

## 4. 参与角色

- 系统管理员：管理字段元数据

---

## 5. 前置条件

- 表元数据已创建（Story 11-01）
- 用户具备系统管理权限

---

## 6. 触发方式

- 页面入口：系统管理 → 低代码配置 → 字段元数据
- 接口入口：GET `/api/system/meta/column`

---

## 7. 输入 / 输出

### 7.1 字段元数据字段

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| tableId | long | 是 | 表ID（关联sys_table_meta） |
| columnCode | string | 是 | 字段编码 |
| columnName | string | 是 | 字段名称 |
| fieldType | string | 是 | 字段类型（text/textarea/number/select/switch/date/datetime） |
| dataType | string | 是 | 数据类型（string/int/decimal/datetime） |
| dictType | string | 否 | 字典类型编码（select类型时） |
| isRequired | int | 是 | 是否必填（0/1） |
| isUnique | int | 否 | 是否唯一（0/1） |
| isShowInList | int | 是 | 是否在列表显示（0/1） |
| isShowInForm | int | 是 | 是否在表单显示（0/1） |
| isSortable | int | 否 | 是否可排序（0/1） |
| listWidth | int | 否 | 列表列宽 |
| formColSpan | int | 否 | 表单列宽占比（24栅格） |
| defaultValue | string | 否 | 默认值 |
| placeholder | string | 否 | 占位符 |
| validRules | string | 否 | 校验规则（JSON格式） |
| sortOrder | int | 是 | 排序号 |
| isEnabled | int | 是 | 是否启用（0/1） |

### 7.2 列表查询输入

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| tableId | long | 是 | 表ID |
| page | int | N | 页码，默认1 |
| pageSize | int | N | 每页条数，默认100 |

### 7.3 列表输出

| 字段 | 类型 | 说明 |
|------|------|------|
| total | int | 总记录数 |
| records | array | 字段元数据列表（按sortOrder排序） |

---

## 8. 业务规则

1. 同一表内字段编码唯一
2. 拖拽排序自动更新sortOrder
3. 删除字段时提示是否级联删除数据
4. validRules 支持格式：`{"pattern":"","min":0,"max":100}`

---

## 9. 数据设计

### 9.1 涉及表

- `sys_column_meta`

### 9.2 表结构

```sql
CREATE TABLE sys_column_meta (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  table_id BIGINT NOT NULL COMMENT '表ID',
  column_code VARCHAR(50) NOT NULL COMMENT '字段编码',
  column_name VARCHAR(100) NOT NULL COMMENT '字段名称',
  field_type VARCHAR(20) NOT NULL COMMENT '字段类型',
  data_type VARCHAR(20) NOT NULL COMMENT '数据类型',
  dict_type VARCHAR(50) COMMENT '字典类型',
  is_required TINYINT DEFAULT 0 COMMENT '是否必填',
  is_unique TINYINT DEFAULT 0 COMMENT '是否唯一',
  is_show_in_list TINYINT DEFAULT 1 COMMENT '列表显示',
  is_show_in_form TINYINT DEFAULT 1 COMMENT '表单显示',
  is_sortable TINYINT DEFAULT 0 COMMENT '可排序',
  list_width INT DEFAULT 120 COMMENT '列宽',
  form_col_span INT DEFAULT 24 COMMENT '表单栅格',
  default_value VARCHAR(100) COMMENT '默认值',
  placeholder VARCHAR(100) COMMENT '占位符',
  valid_rules VARCHAR(500) COMMENT '校验规则JSON',
  sort_order INT DEFAULT 0 COMMENT '排序',
  is_enabled TINYINT DEFAULT 1 COMMENT '是否启用',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_table_column (table_id, column_code)
) COMMENT '字段元数据';
```

---

## 10. API / 接口契约

### 10.1 接口清单

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/system/meta/column` | 字段元数据列表 |
| GET | `/api/system/meta/column/schema` | 获取Schema（低代码引擎用） |
| GET | `/api/system/meta/column/{id}` | 字段详情 |
| POST | `/api/system/meta/column` | 创建字段 |
| PUT | `/api/system/meta/column/{id}` | 更新字段 |
| DELETE | `/api/system/meta/column/{id}` | 删除字段 |
| POST | `/api/system/meta/column/batch` | 批量创建字段 |
| PUT | `/api/system/meta/column/sort` | 批量更新排序 |

### 10.2 Schema 接口响应示例

```json
GET /api/system/meta/column/schema?tableCode=WMS0010
{
  "code": 200,
  "data": {
    "tableCode": "WMS0010",
    "tableName": "仓库档案",
    "columns": [
      {
        "field": "warehouseCode",
        "label": "仓库编码",
        "fieldType": "text",
        "required": true,
        "placeholder": "请输入仓库编码",
        "colSpan": 24
      },
      {
        "field": "warehouseName",
        "label": "仓库名称",
        "fieldType": "text",
        "required": true,
        "colSpan": 24
      },
      {
        "field": "status",
        "label": "状态",
        "fieldType": "switch",
        "colSpan": 24
      }
    ]
  }
}
```

### 10.3 批量排序请求示例

```json
PUT /api/system/meta/column/sort
{
  "orders": [
    {"id": 1, "sortOrder": 1},
    {"id": 2, "sortOrder": 2},
    {"id": 3, "sortOrder": 3}
  ]
}
```

---

## 11. 权限与审计

### 11.1 权限标识

- `system:meta:column:query`
- `system:meta:column:manage`

### 11.2 审计要求

- 新增、修改、删除操作记录日志

---

## 12. 验收标准

### 12.1 功能验收

- [x] 字段列表按sortOrder排序显示
- [x] 拖拽排序功能正常
- [x] 批量新增功能正常
- [x] Schema接口返回格式正确
- [x] 校验规则保存和解析正常

---

## 13. 交付物清单

- [x] 后端代码
- [x] 前端页面
- [x] 接口文档

---

## 14. 关联文档

- Epic Brief：[epic-11-overview.md](../../epics/epic-11-overview.md)
- 低代码设计：[04-DESIGN/03-lowcode-design.md](../../04-DESIGN/03-lowcode-design.md)
