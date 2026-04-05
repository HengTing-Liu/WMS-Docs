# Story 04-03 领用出库管理

## 0. 基本信息

- Epic：出库管理
- Story ID：04-03
- 优先级：P0
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 2

---

## 1. 目标

实现领用出库管理，支持出库单新建、库位分配、确认出库。

---

## 2. 业务背景

领用出库是企业内部物料领用的出库流程。

---

## 3. 范围

### 3.1 本 Story 包含

- 领用出库单列表查询
- 领用出库单新建
- 库位分配
- 确认出库

### 3.2 本 Story 不包含

- ERP 同步

---

## 4. 参与角色

- 仓库管理员：新建/确认出库

---

## 5. 前置条件

- 仓库档案已存在
- 用户具备领用出库权限

---

## 6. 触发方式

- 页面入口：出库管理 → 领用出库
- 接口入口：GET `/api/outbound/use/list`

---

## 7. 输入 / 输出

### 7.1 新增输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| consumeOrderNo | string | Y | 领用单号 |
| deptCode | string | Y | 部门编码 |
| deptName | string | Y | 部门名称 |
| warehouseCode | string | Y | 仓库编码 |
| items | array | Y | 物料明细 |
| items[].materialCode | string | Y | 物料编码 |
| items[].batchNo | string | Y | 批次号 |
| items[].planQuantity | int | Y | 计划数量 |
| needExpress | boolean | N | 是否需要快递 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 出库单ID |
| outboundNo | string | 出库单号 |
| status | string | 状态 |

---

## 8. 状态流转

### 8.1 主体对象

- 对象名称：领用出库单

### 8.2 状态定义

| 状态 | 说明 |
|---|---|
| PENDING | 待出库 |
| ALLOCATED | 已分配库位 |
| SHIPPED | 已发货 |
| COMPLETED | 已完成 |
| CANCELLED | 已取消 |

---

## 9. 业务规则

1. **出库单号生成**：`OUT-CONSUME-{yyyyMMdd}-{6位序号}`
2. **库位分配**：按 FEFO 原则分配
3. **库存扣减**：出库确认后扣减库存
4. **流水生成**：出库确认后生成库存变更流水

---

## 10. API / 接口契约

> 表编码：WMS0160
> CRUD前缀：`/api/outbound/use`

### 10.1 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/outbound/use/list` | 领用出库单列表 |
| POST | `/api/outbound/use` | 新建领用出库单 |
| POST | `/api/outbound/use/{id}/allocate` | 库位分配 |
| POST | `/api/outbound/use/{id}/confirm` | 确认出库 |

### 10.2 Schema 配置

**表名**：`out_use_outbound`
**描述**：领用出库单

**主字段**：

| 字段名 | 中文名 | 类型 | 必填 | 说明 |
|---|---|---|---|---|
| consume_order_no | 领用单号 | varchar(64) | Y | 外部领用单编号 |
| dept_code | 部门编码 | varchar(64) | Y | - |
| dept_name | 部门名称 | varchar(128) | Y | - |
| warehouse_code | 仓库编码 | varchar(64) | Y | - |
| status | 状态 | varchar(32) | N | 枚举：PENDING/ALLOCATED/SHIPPED/COMPLETED/CANCELLED |
| outbound_no | 出库单号 | varchar(64) | N | 系统生成，格式：OUT-CONSUME-{yyyyMMdd}-{6位序号} |

---

## 11. 权限与审计

### 11.1 权限标识

- `wms:outbound:consume:query`
- `wms:outbound:consume:add`
- `wms:outbound:consume:confirm`

---

## 12. 验收标准

### 12.1 功能验收

- [ ] 新建出库单成功
- [ ] 库位分配正确
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

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0160 领用出库
- Epic Brief：[epic-04-overview.md](../../epics/epic-04-overview.md)
