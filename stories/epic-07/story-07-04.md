# Story 07-04 CRO提货单

## 0. 基本信息

- Epic：提货单管理
- Story ID：07-04
- 优先级：P1
- 状态：Draft
- 预计工期：1d
- 依赖 Story：无
- 关联迭代：Sprint 4

---

## 1. 目标

实现 CRO 提货单管理，支持新建、发货、取消。

---

## 2. 业务背景

CRO 提货单是临床试验用物料的物流单据，有特殊的项目管理要求。

---

## 3. 范围

### 3.1 本 Story 包含

- CRO 提货单列表查询
- CRO 提货单新建
- CRO 提货单发货确认
- CRO 提货单取消

### 3.2 本 Story 不包含

- CRO 项目管理

---

## 4. 参与角色

- 仓库管理员：管理 CRO 提货单

---

## 5. 前置条件

- 仓库档案已存在
- 用户具备 CRO 提货单权限

---

## 6. 触发方式

- 页面入口：提货单管理 → CRO提货单
- 接口入口：`GET /api/pickup/cro/list`

---

## 7. 输入 / 输出

### 7.1 新增输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| projectNo | string | Y | 项目编号 |
| projectName | string | Y | 项目名称 |
| customerId | long | Y | 客户ID |
| customerName | string | Y | 客户名称 |
| outWarehouseCode | string | Y | 发货仓库编码 |
| consignee | string | Y | 收货人 |
| phone | string | Y | 联系电话 |
| address | string | Y | 收货地址 |
| items | array | Y | 物料明细 |
| items[].materialCode | string | Y | 物料编码 |
| items[].batchNo | string | Y | 批次号 |
| items[].planQuantity | int | Y | 计划数量 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 提货单ID |
| pickNo | string | 提货单号 |
| status | string | 状态 |

---

## 8. 状态流转

### 8.1 主体对象

- 对象名称：CRO 提货单

### 8.2 状态定义

| 状态 | 说明 |
|---|---|
| PENDING | 待发货 |
| SHIPPED | 已发货 |
| COMPLETED | 已完成 |
| CANCELLED | 已取消 |

---

## 9. 数据设计

### 9.1 涉及表

- `io_pick_order_cro`
- `io_pick_order_cro_item`

### 9.2 关键字段

| 表名 | 字段 | 说明 |
|---|---|---|
| io_pick_order_cro | id | 主键 |
| io_pick_order_cro | pick_no | 提货单号 |
| io_pick_order_cro | project_no | 项目编号 |
| io_pick_order_cro | status | 状态 |

---

## 10. API / 接口契约

### 10.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0260 |
| CRUD 前缀 | `/api/pickup/cro` |
| 列表字段 | pickNo, projectNo, projectName, customerName, status, createdAt |
| 搜索字段 | pickNo, projectNo, customerId, status |

### 10.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/pickup/cro/list` | CRO提货单列表 |
| POST | `/api/pickup/cro` | 新建CRO提货单 |
| POST | `/api/pickup/cro/{id}/ship` | 发货确认 |
| POST | `/api/pickup/cro/{id}/cancel` | 取消提货单 |

---

## 11. 权限与审计

### 11.1 权限标识

- `wms:pick:cro:query`
- `wms:pick:cro:add`
- `wms:pick:cro:ship`
- `wms:pick:cro:cancel`

---

## 12. 验收标准

### 12.1 功能验收

- [ ] 提货单新建成功
- [ ] 发货确认正常
- [ ] 取消功能正常
- [ ] 状态流转正确

---

## 13. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 14. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0260 CRO提货单
- Epic Brief：[epic-07-overview.md](../../epics/epic-07-overview.md)
