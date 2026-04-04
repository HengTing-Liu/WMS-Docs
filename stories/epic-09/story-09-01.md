# Story 09-01 中转仓管理

## 0. 基本信息

- Epic：物流发货
- Story ID：09-01
- 优先级：P2
- 状态：Draft
- 预计工期：1.5d
- 依赖 Story：无
- 关联迭代：Sprint 5

---

## 1. 目标

实现中转仓收货、送货管理。

---

## 2. 业务背景

中转仓是物流环节的中间节点，负责收货暂存和送货分发。

---

## 3. 范围

### 3.1 本 Story 包含

- 中转收货列表查询
- 收货确认
- 收货异常处理
- 中转送货列表查询
- 送货分配
- 送货确认

### 3.2 本 Story 不包含

- 中转仓配置

---

## 4. 参与角色

- 中转仓管理员：管理收货和送货

---

## 5. 前置条件

- 中转仓档案已配置
- 用户具备中转仓权限

---

## 6. 触发方式

- 页面入口：物流发货 → 中转仓收货 / 中转仓送货
- 接口入口：GET `/api/logistics/transit/list`

---

## 7. 输入 / 输出

### 7.1 收货确认 - 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| receiveNo | string | Y | 收货单号 |
| items | array | Y | 收货明细 |
| items[].packageNo | string | Y | 包裹号 |
| items[].actualQuantity | int | Y | 实收数量 |

### 7.2 送货分配 - 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| deliveryId | long | Y | 送货单ID |
| driverId | long | Y | 配送员ID |
| routeId | long | N | 路线ID |

### 7.3 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | ID |
| status | string | 状态 |

---

## 8. 状态流转

### 8.1 收货状态

| 状态 | 说明 |
|---|---|
| PENDING | 待收货 |
| RECEIVED | 已收货 |
| ABNORMAL | 异常 |

### 8.2 送货状态

| 状态 | 说明 |
|---|---|
| PENDING | 待送货 |
| ASSIGNED | 已分配 |
| DELIVERING | 配送中 |
| DELIVERED | 已送达 |

---

## 9. 数据设计

### 9.1 涉及表

- `logistics_transit_receive`
- `logistics_transit_delivery`

---

## 10. API / 接口契约

### 10.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0340 |
| CRUD前缀 | `/api/logistics/transit` |

### 10.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/logistics/transit/receive/list` | 中转收货列表 |
| POST | `/api/logistics/transit/receive` | 收货确认 |
| POST | `/api/logistics/transit/receive/{id}/abnormal` | 异常处理 |
| GET | `/api/logistics/transit/delivery/list` | 中转送货列表 |
| POST | `/api/logistics/transit/delivery/{id}/assign` | 送货分配 |
| POST | `/api/logistics/transit/delivery/{id}/confirm` | 送货确认 |

---

## 11. 权限与审计

### 11.1 权限标识

- `logistics:transit:receive:query`
- `logistics:transit:receive:confirm`
- `logistics:transit:delivery:query`
- `logistics:transit:delivery:assign`

---

## 12. 验收标准

### 12.1 功能验收

- [ ] 收货确认正常
- [ ] 异常处理正常
- [ ] 送货分配正常
- [ ] 送货确认正常
- [ ] 状态流转正确

---

## 13. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 14. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0340/WMS0350
- Epic Brief：[epic-09-overview.md](../../epics/epic-09-overview.md)
