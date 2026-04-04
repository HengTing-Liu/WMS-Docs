# Story 11-03 操作元数据管理

## 0. 基本信息

- Epic：低代码配置管理
- Story ID：11-03
- 优先级：P0
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：11-01（表元数据管理）
- 关联迭代：Sprint 1

---

## 1. 目标

实现操作元数据（sys_table_operation）的 CRUD 功能，定义页面的操作按钮（新建、编辑、删除、导出等），为低代码页面提供操作按钮配置。

---

## 2. 业务背景

操作元数据定义了页面的操作按钮，包括按钮类型、图标、权限、位置等。前端低代码页面根据操作元数据渲染工具栏按钮和行操作按钮。

---

## 3. 范围

### 3.1 本 Story 包含

- 操作元数据列表查询（按表ID）
- 操作元数据新增
- 操作元数据编辑
- 操作元数据删除
- 操作元数据拖拽排序

### 3.2 本 Story 不包含

- 表元数据管理（见 Story 11-01）
- 字段元数据管理（见 Story 11-02）
- 低代码引擎接口（见 Story 11-05）

---

## 4. 参与角色

- 系统管理员：管理操作元数据

---

## 5. 前置条件

- 表元数据已创建（Story 11-01）
- 用户具备系统管理权限

---

## 6. 触发方式

- 页面入口：系统管理 → 低代码配置 → 操作元数据
- 接口入口：GET `/api/system/meta/operation`

---

## 7. 输入 / 输出

### 7.1 操作元数据字段

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| tableId | long | 是 | 表ID（关联sys_table_meta） |
| operationCode | string | 是 | 操作编码（如 create/edit/delete/export） |
| operationName | string | 是 | 操作名称 |
| buttonType | string | 否 | 按钮类型（primary/default/danger） |
| icon | string | 否 | 图标 |
| permission | string | 否 | 权限标识 |
| position | string | 是 | 位置（toolbar/row） |
| operationType | string | 否 | 操作类型（normal/confirm） |
| confirmMessage | string | 否 | 确认提示语 |
| sortOrder | int | 是 | 排序号 |
| isEnabled | int | 是 | 是否启用（0/1） |

### 7.2 列表查询输入

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| tableId | long | 是 | 表ID |

### 7.3 列表输出

| 字段 | 类型 | 说明 |
|------|------|------|
| total | int | 总记录数 |
| records | array | 操作元数据列表（按sortOrder排序） |

---

## 8. 业务规则

1. 同一表内操作编码唯一
2. position 为 toolbar 表示工具栏按钮，row 表示行操作按钮
3. operationType 为 confirm 时，点击前弹出确认框
4. permission 为空表示不需要权限

---

## 9. 数据设计

### 9.1 涉及表

- `sys_table_operation`

### 9.2 表结构

```sql
CREATE TABLE sys_table_operation (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  table_id BIGINT NOT NULL COMMENT '表ID',
  operation_code VARCHAR(50) NOT NULL COMMENT '操作编码',
  operation_name VARCHAR(50) NOT NULL COMMENT '操作名称',
  button_type VARCHAR(20) DEFAULT 'default' COMMENT '按钮类型',
  icon VARCHAR(50) COMMENT '图标',
  permission VARCHAR(100) COMMENT '权限标识',
  position VARCHAR(20) NOT NULL COMMENT '位置',
  operation_type VARCHAR(20) DEFAULT 'normal' COMMENT '操作类型',
  confirm_message VARCHAR(200) COMMENT '确认提示',
  sort_order INT DEFAULT 0 COMMENT '排序',
  is_enabled TINYINT DEFAULT 1 COMMENT '是否启用',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_table_operation (table_id, operation_code)
) COMMENT '操作元数据';
```

---

## 10. API / 接口契约

### 10.1 接口清单

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/system/meta/operation` | 操作元数据列表 |
| GET | `/api/system/meta/operation/list/{tableCode}` | 按表编码获取操作列表 |
| GET | `/api/system/meta/operation/{id}` | 操作详情 |
| POST | `/api/system/meta/operation` | 创建操作 |
| PUT | `/api/system/meta/operation/{id}` | 更新操作 |
| DELETE | `/api/system/meta/operation/{id}` | 删除操作 |
| PUT | `/api/system/meta/operation/sort` | 批量更新排序 |

### 10.2 操作列表接口响应示例

```json
GET /api/system/meta/operation/list/WMS0010
{
  "code": 200,
  "data": {
    "toolbar": [
      {
        "code": "create",
        "name": "新建",
        "type": "primary",
        "icon": "PlusOutlined",
        "permission": "wms:warehouse:add"
      }
    ],
    "row": [
      {
        "code": "edit",
        "name": "编辑",
        "type": "default",
        "icon": "EditOutlined",
        "permission": "wms:warehouse:edit"
      },
      {
        "code": "delete",
        "name": "删除",
        "type": "danger",
        "icon": "DeleteOutlined",
        "confirmType": "confirm",
        "confirmMessage": "确定要删除吗？",
        "permission": "wms:warehouse:delete"
      }
    ]
  }
}
```

---

## 11. 权限与审计

### 11.1 权限标识

- `system:meta:operation:query`
- `system:meta:operation:manage`

### 11.2 审计要求

- 新增、修改、删除操作记录日志

---

## 12. 验收标准

### 12.1 功能验收

- [ ] 操作列表按位置分组显示
- [ ] 拖拽排序功能正常
- [ ] 操作按钮配置正确
- [ ] 确认提示功能正常

---

## 13. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档

---

## 14. 关联文档

- Epic Brief：[epic-11-overview.md](../../epics/epic-11-overview.md)
- 低代码设计：[04-DESIGN/03-lowcode-design.md](../../04-DESIGN/03-lowcode-design.md)
