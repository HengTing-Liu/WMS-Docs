# Story 03-01 生产入库管理

## 0. 基本信息

- Epic：入库管理
- Story ID：03-01
- 优先级：P0
- 状态：Draft
- 预计工期：1d
- 依赖 Story：01-01（仓库查询）、01-03（库位查询）
- 关联迭代：Sprint 2

---

## 1. 目标

实现生产入库全流程管理，支持入库单新建、审批、扫码入库、确认入库。

---

## 2. 业务背景

生产入库是采购物料进入仓库的核心流程，本 Story 实现生产入库的完整生命周期管理。

---

## 3. 范围

### 3.1 本 Story 包含

- 生产入库单列表查询
- 生产入库单新建
- 生产入库单审批
- 生产入库扫码入库
- 生产入库确认
- 生产入库导出

### 3.2 本 Story 不包含

- ERP 同步
- 质检流程

---

## 4. 参与角色

- 仓库管理员：新建/确认入库
- 审批人：审批入库单
- 仓库作业员：扫码入库

---

## 5. 前置条件

- 仓库档案已存在
- 物料档案已存在
- 用户具备生产入库权限

---

## 6. 触发方式

- 页面入口：入库管理 → 生产入库
- 接口入口：GET `/api/inbound/production/list`

---

## 7. 输入 / 输出

### 7.1 新增输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| productionOrderNo | string | Y | 生产订单号 |
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

- 对象名称：生产入库单

### 8.2 状态定义

| 状态 | 说明 |
|---|---|
| DRAFT | 草稿 |
| PENDING | 待入库 |
| IN_PROGRESS | 入库中 |
| QC_PENDING | 待质检 |
| COMPLETED | 已完成 |
| CANCELLED | 已取消 |

### 8.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| DRAFT | 提交 | PENDING | - |
| DRAFT | 取消 | CANCELLED | - |
| PENDING | 开始入库 | IN_PROGRESS | - |
| PENDING | 取消 | CANCELLED | - |
| IN_PROGRESS | 完成入库 | COMPLETED | - |
| IN_PROGRESS | 送检 | QC_PENDING | 必检物料 |
| QC_PENDING | 质检完成 | COMPLETED | - |

---

## 9. 业务规则

1. **入库单号生成**：`INB-PROD-{yyyyMMdd}-{6位序号}`
2. **批次号生成**：无批次号时自动生成
3. **扫码入库**：扫描物料条码匹配物料信息
4. **数量校验**：入库数量不超过计划数量
5. **库存增加**：入库确认后增加库存
6. **流水生成**：入库确认后生成库存变更流水

---

## 10. 数据设计

### 10.1 涉及表

- `io_inventory_account`（io_type='INBOUND', biz_type='PRODUCTION'）
- `io_inventory_item`
- `inv_inventory`
- `inv_inventory_change`

---

## 11. API / 接口契约

### 11.1 Schema 配置

- 表编码：WMS0090
- CRUD前缀：`/api/inbound/production`

### 11.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/inbound/production/list` | 生产入库单列表 |
| POST | `/api/inbound/production` | 新建生产入库单 |
| PUT | `/api/inbound/production/{id}` | 编辑生产入库单 |
| POST | `/api/inbound/production/{id}/submit` | 提交入库单 |
| POST | `/api/inbound/production/{id}/start` | 开始入库 |
| POST | `/api/inbound/production/{id}/confirm` | 确认入库 |
| POST | `/api/inbound/production/{id}/cancel` | 取消入库单 |
| GET | `/api/inbound/production/export` | 导出 |

### 12. 权限与审计

### 12.1 权限标识

- `wms:inbound:production:query`
- `wms:inbound:production:add`
- `wms:inbound:production:approve`
- `wms:inbound:production:confirm`

### 12.2 审计要求

- 记录入库操作人、操作时间
- 记录入库数量
- 记录状态变更

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
- [ ] 审批流程正常
- [ ] 扫码入库匹配正确
- [ ] 确认入库库存增加正确
- [ ] 流水生成正确
- [ ] 状态流转正确

### 14.2 数据验收

- [ ] 库存增加数量正确
- [ ] 流水记录正确

---

## 15. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 16. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0090 生产入库
- 数据库设计：[WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md)
- Epic Brief：[epic-03-overview.md](../../epics/epic-03-overview.md)
- 事务设计：[01-transaction-design.md](../../05-TECH-STANDARDS/01-transaction-design.md)
