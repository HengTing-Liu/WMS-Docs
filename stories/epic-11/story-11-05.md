# Story 11-05 低代码引擎接口

## 0. 基本信息

- Epic：低代码配置管理
- Story ID：11-05
- 优先级：P0
- 状态：Draft
- 预计工期：1.5d
- 依赖 Story：11-01、11-02、11-03、11-04
- 关联迭代：Sprint 1

---

## 1. 目标

实现低代码引擎的核心接口，为前端 LowcodePage 和 LowcodeDrawer 组件提供数据支撑，包括 Schema 获取、CRUD 操作等接口。

---

## 2. 业务背景

低代码引擎接口是连接后端元数据和前端低代码组件的桥梁。前端组件通过这些接口获取页面配置（Schema），然后动态渲染页面。

---

## 3. 范围

### 3.1 本 Story 包含

- 获取页面 Schema 接口（字段 + 操作按钮）
- 通用 CRUD 接口封装
- 启用/禁用接口
- 导出接口
- 字典数据获取接口（带缓存）

### 3.2 本 Story 不包含

- 元数据管理页面（见 Story 11-01~11-04）
- 前端低代码组件（见 Story 11-06）

---

## 4. 参与角色

- 前端低代码组件：调用低代码接口

---

## 5. 前置条件

- Story 11-01~11-04 已完成
- 表元数据、字段元数据、操作元数据、字典数据已配置

---

## 6. 触发方式

- 前端组件调用

---

## 7. 接口设计

### 7.1 获取页面 Schema

**接口**：GET `/api/system/lowcode/schema`

**请求参数**：

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| tableCode | string | 是 | 表编码 |

**响应**：

```json
{
  "code": 200,
  "data": {
    "tableCode": "WMS0010",
    "tableName": "仓库档案",
    "crudPrefix": "/api/base/warehouse",
    "columns": [
      {
        "field": "warehouseCode",
        "label": "仓库编码",
        "fieldType": "text",
        "dataType": "string",
        "required": true,
        "unique": false,
        "showInList": true,
        "showInForm": true,
        "sortable": true,
        "listWidth": 120,
        "colSpan": 24,
        "defaultValue": "",
        "placeholder": "请输入仓库编码",
        "validRules": {}
      }
    ],
    "operations": {
      "toolbar": [
        {"code": "create", "name": "新建", "type": "primary", "icon": "PlusOutlined", "permission": "wms:warehouse:add"}
      ],
      "row": [
        {"code": "edit", "name": "编辑", "type": "default", "icon": "EditOutlined", "permission": "wms:warehouse:edit"},
        {"code": "delete", "name": "删除", "type": "danger", "icon": "DeleteOutlined", "confirmType": "confirm", "confirmMessage": "确定要删除吗？", "permission": "wms:warehouse:delete"},
        {"code": "toggle", "name": "启用/禁用", "type": "default", "permission": "wms:warehouse:toggle"}
      ]
    }
  }
}
```

### 7.2 列表查询

**接口**：GET `{crudPrefix}/list`

**请求参数**：

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| page | int | N | 页码，默认1 |
| pageSize | int | N | 每页条数，默认20 |
| sortField | string | N | 排序字段 |
| sortDirection | string | N | 排序方向（ASC/DESC） |
| 其他 | string | N | 根据字段元数据动态支持 |

**响应**：

```json
{
  "code": 200,
  "data": {
    "total": 100,
    "records": []
  }
}
```

### 7.3 详情查询

**接口**：GET `{crudPrefix}/{id}`

**响应**：

```json
{
  "code": 200,
  "data": {}
}
```

### 7.4 新增

**接口**：POST `{crudPrefix}`

**请求体**：根据字段元数据动态生成

**响应**：

```json
{
  "code": 200,
  "data": { "id": 1 }
}
```

### 7.5 修改

**接口**：PUT `{crudPrefix}/{id}`

**请求体**：根据字段元数据动态生成

**响应**：

```json
{
  "code": 200,
  "data": null
}
```

### 7.6 删除

**接口**：DELETE `{crudPrefix}/{id}`

**响应**：

```json
{
  "code": 200,
  "data": null
}
```

### 7.7 启用/禁用

**接口**：PUT `{crudPrefix}/{id}/toggle`

**响应**：

```json
{
  "code": 200,
  "data": { "isEnabled": true }
}
```

### 7.8 导出

**接口**：GET `{crudPrefix}/export`

**请求参数**：同列表查询

**响应**：Excel 文件流

---

## 8. 技术实现

### 8.1 低代码查询处理器

```java
@Component
public class LowcodeQueryHandler {

    public PageResult<?> query(LowcodeSchema schema, PageRequest request) {
        // 1. 构建动态SQL
        // 2. 执行查询
        // 3. 转换结果
    }
}
```

### 8.2 字典数据缓存

```java
@Cacheable(value = "dict", key = "#dictType")
public List<DictItemVO> getDictData(String dictType) {
    // 查询字典数据
}
```

---

## 9. 验收标准

### 9.1 功能验收

- [ ] Schema 接口返回完整的字段和操作配置
- [ ] CRUD 接口正常工作
- [ ] 启用/禁用功能正常
- [ ] 导出功能正常
- [ ] 字典缓存生效

### 9.2 性能验收

- [ ] Schema 接口响应 < 100ms
- [ ] 字典数据缓存命中后响应 < 10ms

---

## 10. 交付物清单

- [ ] 后端代码（Controller/Service/Handler）
- [ ] 接口文档
- [ ] 单元测试

---

## 11. 关联文档

- Epic Brief：[epic-11-overview.md](../../epics/epic-11-overview.md)
- 低代码设计：[04-DESIGN/03-lowcode-design.md](../../04-DESIGN/03-lowcode-design.md)
- 前端开发指南：[05-DEV-GUIDE/02-frontend-dev-guide.md](../../05-DEV-GUIDE/02-frontend-dev-guide.md)
