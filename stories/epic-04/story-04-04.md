# Story 04-04 生产退回出库

## 0. 基本信息

- Epic：出库管理
- Story ID：04-04
- 优先级：P0
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 2

---

## 1. 目标

实现生产退回出库管理，支持退回申请创建、确认出库。

---

## 2. 业务背景

生产退回是生产过程中物料退还仓库的出库流程。

---

## 3. 范围

### 3.1 本 Story 包含

- 生产退回列表查询
- 生产退回新建
- 库位分配
- 确认出库

---

## 4. 参与角色

- 仓库管理员：确认退回出库

---

## 5. 前置条件

- 仓库档案已存在
- 用户具备生产退回出库权限

---

## 6. 触发方式

- 页面入口：出库管理 → 生产退回出库
- 接口入口：GET `/api/outbound/return-production/list`

---

## 7. 输入 / 输出

### 7.1 新增输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| productionOrderNo | string | Y | 生产订单号 |
| warehouseCode | string | Y | 仓库编码 |
| items | array | Y | 物料明细 |
| items[].materialCode | string | Y | 物料编码 |
| items[].batchNo | string | Y | 批次号 |
| items[].returnQuantity | int | Y | 退回数量 |
| items[].returnReason | string | N | 退回原因 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 出库单ID |
| outboundNo | string | 出库单号 |
| status | string | 状态 |

---

## 8. 状态流转

### 8.1 主体对象

- 对象名称：生产退回出库单

### 8.2 状态定义

| 状态 | 说明 |
|---|---|
| PENDING | 待出库 |
| ALLOCATED | 已分配库位 |
| SHIPPED | 已发货 |
| COMPLETED | 已完成 |

---

## 9. 业务规则

1. **出库单号生成**：`OUT-RET-PROD-{yyyyMMdd}-{6位序号}`
2. **库存扣减**：出库确认后扣减库存
3. **流水生成**：出库确认后生成库存变更流水

---

## 10. API / 接口契约

> 表编码：WMS0170
> CRUD前缀：`/api/outbound/return-production`

### 10.1 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/outbound/return-production/list` | 生产退回列表 |
| POST | `/api/outbound/return-production` | 新建生产退回 |
| POST | `/api/outbound/return-production/{id}/allocate` | 库位分配 |
| POST | `/api/outbound/return-production/{id}/confirm` | 确认出库 |

### 10.2 Schema 配置

**表名**：`out_return_production_outbound`
**描述**：生产退回出库单

**主字段**：

| 字段名 | 中文名 | 类型 | 必填 | 说明 |
|---|---|---|---|---|
| production_order_no | 生产订单号 | varchar(64) | Y | 外部生产订单编号 |
| warehouse_code | 仓库编码 | varchar(64) | Y | - |
| status | 状态 | varchar(32) | N | 枚举：PENDING/ALLOCATED/SHIPPED/COMPLETED |
| outbound_no | 出库单号 | varchar(64) | N | 系统生成，格式：OUT-RET-PROD-{yyyyMMdd}-{6位序号} |

---

## 11. 权限与审计

### 11.1 权限标识

- `wms:outbound:productionReturn:query`
- `wms:outbound:productionReturn:add`
- `wms:outbound:productionReturn:confirm`

---

## 12. 验收标准

### 12.1 功能验收

- [ ] 新建出库单成功
- [ ] 确认出库库存扣减正确
- [ ] 流水生成正确

---

## 13. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 14. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0170 生产入库退回
- Epic Brief：[epic-04-overview.md](../../epics/epic-04-overview.md)
