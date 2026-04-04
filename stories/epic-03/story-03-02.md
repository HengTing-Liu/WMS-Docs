# Story 03-02 采购入库管理

## 0. 基本信息

- Epic：入库管理
- Story ID：03-02
- 优先级：P0
- 状态：Draft
- 预计工期：1d
- 依赖 Story：01-01（仓库查询）
- 关联迭代：Sprint 2

---

## 1. 目标

实现采购入库全流程管理，支持入库单新建、ERP同步、扫码入库、确认入库。

---

## 2. 业务背景

采购入库是外购物料进入仓库的核心流程，本 Story 实现采购入库的完整生命周期管理。

---

## 3. 范围

### 3.1 本 Story 包含

- 采购入库单列表查询
- 采购入库单新建
- 采购入库扫码入库
- 采购入库确认
- 采购入库导出

### 3.2 本 Story 不包含

- ERP 同步（后续迭代）
- 质检流程

---

## 4. 参与角色

- 仓库管理员：新建/确认入库
- 仓库作业员：扫码入库

---

## 5. 前置条件

- 仓库档案已存在
- 物料档案已存在
- 用户具备采购入库权限

---

## 6. 触发方式

- 页面入口：入库管理 → 采购入库
- 接口入口：GET `/api/inbound/purchase/list`

---

## 7. 输入 / 输出

### 7.1 新增输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| purchaseOrderNo | string | Y | 采购订单号 |
| supplierCode | string | Y | 供应商编码 |
| supplierName | string | Y | 供应商名称 |
| warehouseCode | string | Y | 仓库编码 |
| expectedDate | date | Y | 预计到货日期 |
| items | array | Y | 物料明细 |
| items[].materialCode | string | Y | 物料编码 |
| items[].batchNo | string | N | 批次号 |
| items[].planQuantity | int | Y | 计划数量 |
| items[].produceDate | date | N | 生产日期 |
| items[].expireDate | date | N | 失效日期 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 入库单ID |
| inboundNo | string | 入库单号 |
| status | string | 状态 |

---

## 8. 状态流转

### 8.1 主体对象

- 对象名称：采购入库单

### 8.2 状态定义

| 状态 | 说明 |
|---|---|
| PENDING | 待入库 |
| IN_PROGRESS | 入库中 |
| COMPLETED | 已完成 |
| CANCELLED | 已取消 |

### 8.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| PENDING | 开始入库 | IN_PROGRESS | - |
| PENDING | 取消 | CANCELLED | - |
| IN_PROGRESS | 完成入库 | COMPLETED | - |

---

## 9. 业务规则

1. **入库单号生成**：`INB-PUR-{yyyyMMdd}-{6位序号}`
2. **扫码入库**：扫描物料条码匹配物料信息
3. **数量校验**：入库数量不超过计划数量
4. **库存增加**：入库确认后增加库存
5. **流水生成**：入库确认后生成库存变更流水

---

## 10. 数据设计

### 10.1 涉及表

- `io_inventory_account`（io_type='INBOUND', biz_type='PURCHASE'）
- `io_inventory_item`
- `inv_inventory`
- `inv_inventory_change`

---

## 11. API / 接口契约

### 11.1 Schema 配置

- 表编码：WMS0100
- CRUD前缀：`/api/inbound/purchase`

### 11.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/inbound/purchase/list` | 采购入库单列表 |
| POST | `/api/inbound/purchase` | 新建采购入库单 |
| POST | `/api/inbound/purchase/{id}/start` | 开始入库 |
| POST | `/api/inbound/purchase/{id}/confirm` | 确认入库 |
| POST | `/api/inbound/purchase/{id}/cancel` | 取消入库单 |
| GET | `/api/inbound/purchase/export` | 导出 |

### 12. 权限与审计

### 12.1 权限标识

- `wms:inbound:purchase:query`
- `wms:inbound:purchase:add`
- `wms:inbound:purchase:confirm`

---

## 13. 技术实现约束

- 入库确认必须保证库存一致性
- 使用乐观锁保障并发安全
- 入库确认在事务内完成
- 幂等处理防止重复入库

---

## 14. 验收标准

### 14.1 功能验收

- [ ] 新建入库单成功
- [ ] 扫码入库匹配正确
- [ ] 确认入库库存增加正确
- [ ] 流水生成正确
- [ ] 状态流转正确

---

## 15. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 16. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0100 采购入库
- Epic Brief：[epic-03-overview.md](../../epics/epic-03-overview.md)
