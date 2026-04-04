# Story 07-05 随货物品

## 0. 基本信息

- Epic：提货单管理
- Story ID：07-05
- 优先级：P1
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：07-01（销售提货单）
- 关联迭代：Sprint 4

---

## 1. 目标

实现随货物品管理，支持随货清单关联和打印。

---

## 2. 业务背景

随货物品是随销售货物一起发货的附件（如说明书、发票等），需要单独管理和打印。

---

## 3. 范围

### 3.1 本 Story 包含

- 随货物品清单查询
- 随货物品关联
- 随货物品打印

### 3.2 本 Story 不包含

- 随货物品配置

---

## 4. 参与角色

- 仓库管理员：管理随货物品

---

## 5. 前置条件

- 销售提货单已创建

---

## 6. 触发方式

- 页面入口：提货单管理 → 随货物品
- 接口入口：`GET /api/pickup/goods/list`

---

## 7. 输入 / 输出

### 7.1 关联输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| pickOrderId | long | Y | 提货单ID |
| items | array | Y | 随货物品 |
| items[].itemName | string | Y | 物品名称 |
| items[].quantity | int | Y | 数量 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | ID |
| pickOrderId | long | 提货单ID |

---

## 8. 数据设计

### 8.1 涉及表

- `io_goods_with`

### 8.2 关键字段

| 表名 | 字段 | 说明 |
|---|---|---|
| io_goods_with | id | 主键 |
| io_goods_with | pick_order_id | 提货单ID |
| io_goods_with | item_name | 物品名称 |
| io_goods_with | quantity | 数量 |

---

## 9. API / 接口契约

### 9.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0270 |
| CRUD 前缀 | `/api/pickup/goods` |
| 列表字段 | id, pickOrderId, itemName, quantity, createdAt |
| 搜索字段 | pickOrderId, itemName |

### 9.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/pickup/goods/list` | 随货物品列表 |
| POST | `/api/pickup/goods` | 关联随货物品 |
| DELETE | `/api/pickup/goods/{id}` | 删除随货物品 |
| GET | `/api/pickup/goods/{pickOrderId}/print` | 打印随货清单 |

---

## 10. 权限与审计

### 10.1 权限标识

- `wms:goods:with:query`
- `wms:goods:with:add`
- `wms:goods:with:print`

---

## 11. 验收标准

### 11.1 功能验收

- [ ] 随货物品关联正常
- [ ] 打印功能正常

---

## 12. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 13. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0270 随货物品
- Epic Brief：[epic-07-overview.md](../../epics/epic-07-overview.md)
