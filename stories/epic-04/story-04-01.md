# Story 04-01 销售出库管理

## 0. 基本信息

- Epic：出库管理
- Story ID：04-01
- 优先级：P0
- 状态：Draft
- 预计工期：1.5d
- 依赖 Story：02-01（物料库存查询）
- 关联迭代：Sprint 2

---

## 1. 目标

实现销售出库全流程管理，支持出库单新建、库位分配、标签打印、拣货确认、确认出库。

---

## 2. 业务背景

销售出库是核心出库流程，本 Story 实现销售出库的完整生命周期管理，包括库位分配、拣货、出库确认。

---

## 3. 范围

### 3.1 本 Story 包含

- 销售出库单列表查询
- 销售出库单新建
- 库位分配
- 标签打印
- 拣货确认
- 确认出库
- 销售出库导出

### 3.2 本 Story 不包含

- ERP 同步
- 物流跟踪

---

## 4. 参与角色

- 仓库管理员：新建/确认出库
- 仓库作业员：库位分配、拣货
- 标签打印员：打印标签

---

## 5. 前置条件

- 仓库档案已存在
- 物料档案已存在
- 库存充足
- 用户具备销售出库权限

---

## 6. 触发方式

- 页面入口：出库管理 → 销售出库
- 接口入口：GET `/api/outbound/sale/list`

---

## 7. 输入 / 输出

### 7.1 新增输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| salesOrderNo | string | Y | 销售订单号 |
| customerCode | string | Y | 客户编码 |
| customerName | string | Y | 客户名称 |
| warehouseCode | string | Y | 仓库编码 |
| deliveryAddress | string | Y | 收货地址 |
| contact | string | Y | 联系人 |
| phone | string | Y | 联系电话 |
| items | array | Y | 物料明细 |
| items[].materialCode | string | Y | 物料编码 |
| items[].batchNo | string | N | 批次号 |
| items[].planQuantity | int | Y | 计划数量 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 出库单ID |
| outboundNo | string | 出库单号 |
| status | string | 状态 |

---

## 8. 状态流转

### 8.1 主体对象

- 对象名称：销售出库单

### 8.2 状态定义

| 状态 | 说明 |
|---|---|
| PENDING | 待出库 |
| ALLOCATED | 已分配库位 |
| PRINTED | 已打印 |
| PICKING | 拣货中 |
| PICKED | 已拣货 |
| SHIPPED | 已发货 |
| COMPLETED | 已完成 |
| CANCELLED | 已取消 |

### 8.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| PENDING | 分配库位 | ALLOCATED | - |
| PENDING | 取消 | CANCELLED | - |
| ALLOCATED | 打印标签 | PRINTED | - |
| ALLOCATED | 取消 | CANCELLED | - |
| PRINTED | 开始拣货 | PICKING | - |
| PICKING | 完成拣货 | PICKED | - |
| PICKED | 确认出库 | SHIPPED | - |
| SHIPPED | 确认签收 | COMPLETED | - |

---

## 9. 业务规则

1. **出库单号生成**：`OUT-SALES-{yyyyMMdd}-{6位序号}`
2. **库位分配**：按 FEFO（先进先出）原则分配库位
3. **分配校验**：库存不足时不允许分配
4. **拣货确认**：扫描物料确认拣货数量
5. **库存扣减**：出库确认后扣减库存
6. **流水生成**：出库确认后生成库存变更流水

---

## 10. 数据设计

### 10.1 涉及表

- `io_inventory_account`（io_type='OUTBOUND', biz_type='SALES'）
- `io_inventory_item`
- `io_location_selection`
- `inv_inventory`
- `inv_inventory_change`

---

## 11. API / 接口契约

> 表编码：WMS0140
> CRUD前缀：`/api/outbound/sale`

### 11.1 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/outbound/sale/list` | 销售出库单列表 |
| POST | `/api/outbound/sale` | 新建销售出库单 |
| POST | `/api/outbound/sale/{id}/allocate` | 库位分配 |
| POST | `/api/outbound/sale/{id}/print` | 标签打印 |
| POST | `/api/outbound/sale/{id}/pick` | 拣货确认 |
| POST | `/api/outbound/sale/{id}/confirm` | 确认出库 |
| POST | `/api/outbound/sale/{id}/cancel` | 取消出库单 |
| GET | `/api/outbound/sale/export` | 导出 |

### 11.2 Schema 配置

**表名**：`out_sale_outbound`
**描述**：销售出库单

**主字段**：

| 字段名 | 中文名 | 类型 | 必填 | 说明 |
|---|---|---|---|---|
| sales_order_no | 销售订单号 | varchar(64) | Y | 外部销售订单编号 |
| customer_code | 客户编码 | varchar(64) | Y | - |
| customer_name | 客户名称 | varchar(128) | Y | - |
| warehouse_code | 仓库编码 | varchar(64) | Y | - |
| delivery_address | 收货地址 | varchar(255) | Y | - |
| contact | 联系人 | varchar(64) | Y | - |
| phone | 联系电话 | varchar(32) | Y | - |
| status | 状态 | varchar(32) | N | 枚举：PENDING/ALLOCATED/PRINTED/PICKING/PICKED/SHIPPED/COMPLETED/CANCELLED |
| outbound_no | 出库单号 | varchar(64) | N | 系统生成，格式：OUT-SALES-{yyyyMMdd}-{6位序号} |

---

## 12. 权限与审计

### 12.1 权限标识

- `wms:outbound:sales:query`
- `wms:outbound:sales:add`
- `wms:outbound:sales:allocate`
- `wms:outbound:sales:print`
- `wms:outbound:sales:confirm`

---

## 13. 技术实现约束

- **出库确认必须保证库存一致性**
- 使用分布式锁 + 乐观锁双重保障
- 按仓库+库位+物料+批次维度扣减
- 幂等处理防止重复出库
- 事务内完成库存扣减和流水生成

---

## 14. 验收标准

### 14.1 功能验收

- [ ] 新建出库单成功
- [ ] 库位分配正确（FEFO）
- [ ] 标签打印正常
- [ ] 拣货确认正常
- [ ] 确认出库库存扣减正确
- [ ] 流水生成正确
- [ ] 状态流转正确
- [ ] 库存不足不允许出库

### 14.2 数据验收

- [ ] 库存扣减数量正确
- [ ] 流水记录正确
- [ ] 无超卖

### 14.3 性能验收

- [ ] 并发出库数据一致

---

## 15. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 16. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0140 销售出库
- Epic Brief：[epic-04-overview.md](../../epics/epic-04-overview.md)
- 事务设计：[01-transaction-design.md](../../05-TECH-STANDARDS/01-transaction-design.md)
