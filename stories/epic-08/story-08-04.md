# Story 08-04 发货列表

## 0. 基本信息

- Epic：出库单管理
- Story ID：08-04
- 优先级：P1
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：08-03（包裹单）
- 关联迭代：Sprint 4

---

## 1. 目标

实现发货列表管理，支持发货确认和导出。

---

## 2. 业务背景

发货列表汇总所有待发货订单，支持批量发货确认。

---

## 3. 范围

### 3.1 本 Story 包含

- 发货列表查询
- 发货确认
- 发货导出

### 3.2 本 Story 不包含

- 发货计划制定

---

## 4. 参与角色

- 仓库管理员：管理发货列表

---

## 5. 前置条件

- 包裹单已生成

---

## 6. 触发方式

- 页面入口：出库管理 → 发货列表
- 接口入口：`GET /api/outbound/delivery/list`

---

## 7. 输入 / 输出

### 7.1 发货确认 - 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| packageIds | array | Y | 包裹ID列表 |
| shippingTime | datetime | Y | 发货时间 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| success | boolean | 是否成功 |
| count | int | 发货数量 |

---

## 8. 数据设计

### 8.1 涉及表

- `io_shipment`

---

## 9. API / 接口契约

### 9.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0330 |
| CRUD 前缀 | `/api/outbound/delivery` |
| 列表字段 | shipmentNo, packageCount, expressCompany, shippingTime, status, createdAt |
| 搜索字段 | shipmentNo, expressCompany, status, shippingTime |

### 9.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/outbound/delivery/list` | 发货列表 |
| POST | `/api/outbound/delivery/confirm` | 发货确认 |
| GET | `/api/outbound/delivery/export` | 发货导出 |

---

## 10. 权限与审计

### 10.1 权限标识

- `wms:shipment:query`
- `wms:shipment:confirm`

---

## 11. 验收标准

### 11.1 功能验收

- [ ] 发货列表查询正常
- [ ] 发货确认正常
- [ ] 导出功能正常

---

## 12. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 13. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0330 发货列表
- Epic Brief：[epic-08-overview.md](../../epics/epic-08-overview.md)
