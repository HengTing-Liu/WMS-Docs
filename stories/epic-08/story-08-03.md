# Story 08-03 包裹单

## 0. 基本信息

- Epic：出库单管理
- Story ID：08-03
- 优先级：P1
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：08-02（出库单）
- 关联迭代：Sprint 4

---

## 1. 目标

实现包裹单管理，支持包裹生成和打印。

---

## 2. 业务背景

包裹单是发货的物流单元，记录包裹内的物料明细和物流信息。

---

## 3. 范围

### 3.1 本 Story 包含

- 包裹单列表查询
- 包裹单生成
- 包裹单打印

### 3.2 本 Story 不包含

- 快递单打印（第三方系统）

---

## 4. 参与角色

- 仓库管理员：管理包裹单

---

## 5. 前置条件

- 出库单已确认发货

---

## 6. 触发方式

- 页面入口：出库管理 → 包裹单
- 接口入口：`GET /api/outbound/package/list`

---

## 7. 输入 / 输出

### 7.1 生成包裹 - 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| outboundOrderId | long | Y | 出库单ID |
| expressCompany | string | N | 快递公司 |
| weight | decimal | N | 重量（kg） |
| volume | decimal | N | 体积（m³） |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 包裹ID |
| packageNo | string | 包裹号 |
| trackingNo | string | 快递单号 |

---

## 8. 数据设计

### 8.1 涉及表

- `io_package`

### 8.2 关键字段

| 表名 | 字段 | 说明 |
|---|---|---|
| io_package | id | 主键 |
| io_package | package_no | 包裹号 |
| io_package | outbound_order_id | 出库单ID |
| io_package | express_company | 快递公司 |
| io_package | tracking_no | 快递单号 |
| io_package | weight | 重量 |
| io_package | volume | 体积 |

---

## 9. API / 接口契约

### 9.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0310 |
| CRUD 前缀 | `/api/outbound/package` |
| 列表字段 | packageNo, outboundNo, expressCompany, trackingNo, weight, status, createdAt |
| 搜索字段 | packageNo, outboundNo, trackingNo, expressCompany |

### 9.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/outbound/package/list` | 包裹单列表 |
| POST | `/api/outbound/package` | 生成包裹单 |
| GET | `/api/outbound/package/{id}` | 包裹单详情 |
| POST | `/api/outbound/package/{id}/print` | 打印包裹单 |

---

## 10. 权限与审计

### 10.1 权限标识

- `wms:package:query`
- `wms:package:create`
- `wms:package:print`

---

## 11. 验收标准

### 11.1 功能验收

- [ ] 包裹单生成正常
- [ ] 打印功能正常

---

## 12. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 13. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0310 包裹单
- Epic Brief：[epic-08-overview.md](../../epics/epic-08-overview.md)
