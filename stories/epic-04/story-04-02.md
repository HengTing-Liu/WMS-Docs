# Story 04-02 调拨出库管理

## 0. 基本信息

- Epic：出库管理
- Story ID：04-02
- 优先级：P0
- 状态：Draft
- 预计工期：1d
- 依赖 Story：无
- 关联迭代：Sprint 2

---

## 1. 目标

实现调拨出库管理，支持出库单新建、库位分配、确认出库。

---

## 2. 业务背景

调拨出库是仓库间物料调拨的出库环节，将物料从调出仓库发出。

---

## 3. 范围

### 3.1 本 Story 包含

- 调拨出库单列表查询
- 调拨出库单新建
- 库位分配
- 确认出库

### 3.2 本 Story 不包含

- ERP 同步
- 调拨提货单生成

---

## 4. 参与角色

- 仓库管理员：新建/确认出库

---

## 5. 前置条件

- 仓库档案已存在
- 用户具备调拨出库权限

---

## 6. 触发方式

- 页面入口：出库管理 → 调拨出库
- 接口入口：GET `/api/outbound/transfer/list`

---

## 7. 输入 / 输出

### 7.1 新增输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| transferOrderNo | string | Y | 调拨单号 |
| outWarehouseCode | string | Y | 调出仓库编码 |
| inWarehouseCode | string | Y | 调入仓库编码 |
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

- 对象名称：调拨出库单

### 8.2 状态定义

| 状态 | 说明 |
|---|---|
| PENDING | 待出库 |
| ALLOCATED | 已分配库位 |
| SHIPPED | 已发货 |
| COMPLETED | 已完成 |
| CANCELLED | 已取消 |

### 8.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| PENDING | 分配库位 | ALLOCATED | - |
| PENDING | 取消 | CANCELLED | - |
| ALLOCATED | 确认出库 | SHIPPED | - |
| SHIPPED | 确认收货 | COMPLETED | 调入仓库确认 |

---

## 9. 业务规则

1. **出库单号生成**：`OUT-TRANS-{yyyyMMdd}-{6位序号}`
2. **库位分配**：按 FEFO 原则分配
3. **分配校验**：库存不足时不允许分配
4. **库存扣减**：出库确认后扣减调出仓库库存
5. **流水生成**：出库确认后生成库存变更流水
6. **物流同步**：需要快递时同步 ERP 生成提货单

---

## 10. 数据设计

### 10.1 涉及表

- `io_inventory_account`（io_type='OUTBOUND', biz_type='TRANSFER'）
- `io_inventory_item`
- `io_location_selection`
- `inv_inventory`
- `inv_inventory_change`

---

## 11. API / 接口契约

> 表编码：WMS0150
> CRUD前缀：`/api/outbound/transfer`

### 11.1 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/outbound/transfer/list` | 调拨出库单列表 |
| POST | `/api/outbound/transfer` | 新建调拨出库单 |
| POST | `/api/outbound/transfer/{id}/allocate` | 库位分配 |
| POST | `/api/outbound/transfer/{id}/confirm` | 确认出库 |

### 11.2 Schema 配置

**表名**：`out_transfer_outbound`
**描述**：调拨出库单

**主字段**：

| 字段名 | 中文名 | 类型 | 必填 | 说明 |
|---|---|---|---|---|
| transfer_order_no | 调拨单号 | varchar(64) | Y | 外部调拨单编号 |
| out_warehouse_code | 调出仓库编码 | varchar(64) | Y | - |
| in_warehouse_code | 调入仓库编码 | varchar(64) | Y | - |
| need_express | 是否需要快递 | boolean | N | - |
| status | 状态 | varchar(32) | N | 枚举：PENDING/ALLOCATED/SHIPPED/COMPLETED/CANCELLED |
| outbound_no | 出库单号 | varchar(64) | N | 系统生成，格式：OUT-TRANS-{yyyyMMdd}-{6位序号} |

---

## 12. 权限与审计

### 12.1 权限标识

- `wms:outbound:transfer:query`
- `wms:outbound:transfer:add`
- `wms:outbound:transfer:allocate`
- `wms:outbound:transfer:confirm`

---

## 13. 技术实现约束

- 出库确认必须保证库存一致性
- 使用分布式锁 + 乐观锁双重保障
- 按仓库+库位+物料+批次维度扣减

---

## 14. 验收标准

### 14.1 功能验收

- [ ] 新建出库单成功
- [ ] 库位分配正确
- [ ] 确认出库库存扣减正确
- [ ] 流水生成正确

---

## 15. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 16. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0150 调拨出库
- Epic Brief：[epic-04-overview.md](../../epics/epic-04-overview.md)
