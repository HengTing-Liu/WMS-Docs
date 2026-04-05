# Story 09-02 外贸发货

## 0. 基本信息

- Epic：物流发货
- Story ID：09-02
- 优先级：P2
- 状态：Draft
- 预计工期：3d
- 依赖 Story：无
- 关联迭代：Sprint 5

---

## 1. 目标

实现外贸发货全流程管理，包括报检清单、报关清单、发货清单。

---

## 2. 业务背景

外贸发货涉及报检、报关等合规流程，需要完整的单据管理。

---

## 3. 范围

### 3.1 本 Story 包含

- 待处理列表
- 单据审核
- 报检清单生成/导出
- 报关清单生成/导出
- 发货清单生成/导出
- 待发货列表
- 发货预报

### 3.2 本 Story 不包含

- 报关系统对接
- 报检系统对接

---

## 4. 参与角色

- 外贸专员：管理外贸发货

---

## 5. 前置条件

- 用户具备外贸发货权限

---

## 6. 触发方式

- 页面入口：物流发货 → 外贸发货
- 接口入口：GET `/api/logistics/foreign-trade/list`

---

## 7. 输入 / 输出

### 7.1 发货预报 - 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| shipmentNo | string | Y | 发货单号 |
| estimateTime | datetime | Y | 预计发货时间 |
| destination | string | Y | 目的地 |
| items | array | Y | 预报明细 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | ID |
| status | string | 状态 |

---

## 8. 状态流转

### 8.1 主体对象

- 对象名称：外贸发货单

### 8.2 状态定义

| 状态 | 说明 |
|---|---|
| PENDING | 待处理 |
| PROCESSING | 处理中 |
| READY | 待发货 |
| SHIPPED | 已发货 |
| COMPLETED | 已完成 |

---

## 9. 数据设计

### 9.1 涉及表

- `logistics_foreign_shipment`
- `logistics_inspection_list`
- `logistics_customs_list`
- `logistics_shipping_list`

---

## 10. API / 接口契约

### 10.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0350 |
| CRUD前缀 | `/api/logistics/foreign-trade` |

### 10.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/logistics/foreign-trade/pending/list` | 待处理列表 |
| POST | `/api/logistics/foreign-trade/pending/{id}/approve` | 单据审核 |
| GET | `/api/logistics/foreign-trade/inspection/list` | 报检清单 |
| POST | `/api/logistics/foreign-trade/inspection/generate` | 生成报检清单 |
| GET | `/api/logistics/foreign-trade/inspection/export` | 导出报检清单 |
| GET | `/api/logistics/foreign-trade/customs/list` | 报关清单 |
| POST | `/api/logistics/foreign-trade/customs/generate` | 生成报关清单 |
| GET | `/api/logistics/foreign-trade/customs/export` | 导出报关清单 |
| GET | `/api/logistics/foreign-trade/shipping/list` | 发货清单 |
| POST | `/api/logistics/foreign-trade/shipping/generate` | 生成发货清单 |
| GET | `/api/logistics/foreign-trade/shipping/export` | 导出发货清单 |
| GET | `/api/logistics/foreign-trade/waiting/list` | 待发货列表 |
| POST | `/api/logistics/foreign-trade/waiting/forecast` | 发货预报 |

---

## 11. 权限与审计

### 11.1 权限标识

- `logistics:foreign:query`
- `logistics:foreign:approve`
- `logistics:foreign:export`

---

## 12. 验收标准

### 12.1 功能验收

- [ ] 待处理列表正常
- [ ] 单据审核正常
- [ ] 报检清单生成/导出正常
- [ ] 报关清单生成/导出正常
- [ ] 发货清单生成/导出正常
- [ ] 发货预报正常
- [ ] 状态流转正确

---

## 13. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 14. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0360~WMS0400
- Epic Brief：[epic-09-overview.md](../../epics/epic-09-overview.md)
