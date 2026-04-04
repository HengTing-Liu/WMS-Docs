# Epic-03：入库管理

> Epic编号：Epic-03
> Epic名称：入库管理
> PRD来源：WMS需求说明书 第3.3节
> 优先级：P0
> 预计工时：5天

---

## 一、Epic 概述

### 1.1 业务背景

入库管理是 WMS 核心业务流程之一，覆盖采购入库、生产入库、调拨入库及各种退货入库场景，确保物料准确、高效入库。

### 1.2 包含模块

| 模块编号 | 模块名称 | Story数 | 开发顺序 |
|---------|---------|---------|---------|
| WMS0090 | 生产入库 | 6 | 1 |
| WMS0100 | 采购入库 | 5 | 2 |
| WMS0110 | 调拨入库 | 4 | 3 |
| WMS0120 | 销售退回入库 | 4 | 4 |
| WMS0130 | 领用退回入库 | 4 | 5 |

---

## 二、模块 Story 拆分

### 2.1 WMS0090 生产入库

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0090-01 | 生产入库列表查询 | 按状态、时间、仓库筛选 | - |
| S-0090-02 | 生产入库新建 | 手动新建/表格上传、关联生产订单 | S-0090-01 |
| S-0090-03 | 生产入库编辑 | 修改表头和明细、保存校验 | S-0090-01 |
| S-0090-04 | 生产入库审批 | 审批流程、审批结论记录 | S-0090-02 |
| S-0090-05 | 生产入库确认 | 扫码入库、库位分配、库存增加 | S-0090-04 |
| S-0090-06 | 生产入库导出 | 导出未完成记录 | S-0090-01 |

**状态流转**：`DRAFT → PENDING → IN_PROGRESS → QC_PENDING/INBOUND → COMPLETED`

**关键字段**：
- 入库单号、生产订单号、申请部门、申请人、申请时间
- 仓库、物料明细（物料编码、批次号、数量、生产日期、失效日期）
- 质检状态、库位分配、实际入库数量

**数据库表**：`io_inventory_account`（io_type='INBOUND', biz_type='PRODUCTION'）

**权限标识**：`wms:inbound:production:query`、`wms:inbound:production:add`、`wms:inbound:production:approve`、`wms:inbound:production:confirm`

---

### 2.2 WMS0100 采购入库

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0100-01 | 采购入库列表查询 | 按状态、时间、仓库筛选 | - |
| S-0100-02 | 采购入库新建 | 手动新建、关联采购订单 | S-0100-01 |
| S-0100-03 | 采购入库确认 | 扫码入库、库位分配、库存增加 | S-0100-02 |
| S-0100-04 | 采购入库ERP同步 | 从ERP同步入库数据 | ERP接口 |
| S-0100-05 | 采购入库导出 | 导出未完成记录 | S-0100-01 |

**状态流转**：`PENDING → IN_PROGRESS → COMPLETED`（ERP上线后自动同步）

**关键字段**：
- 入库单号、采购订单号、供应商、仓库
- 物料明细（物料编码、批次号、到货数量）

**数据库表**：`io_inventory_account`（io_type='INBOUND', biz_type='PURCHASE'）

**权限标识**：`wms:inbound:purchase:query`、`wms:inbound:purchase:add`、`wms:inbound:purchase:confirm`

---

### 2.3 WMS0110 调拨入库

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0110-01 | 调拨入库列表查询 | 按调拨单号、状态筛选 | - |
| S-0110-02 | 调拨入库确认 | 接收调入物料、确认入库 | S-0110-01 |
| S-0110-03 | 调拨入库ERP同步 | 从ERP同步调拨入库 | ERP接口 |
| S-0110-04 | 调拨入库导出 | 导出记录 | S-0110-01 |

**状态流转**：`待接收 → IN_PROGRESS → COMPLETED`

**关键字段**：
- 调拨单号、调出仓库、调入仓库、关联调拨出库单
- 物料明细、实际入库数量

**数据库表**：`io_inventory_account`（io_type='INBOUND', biz_type='TRANSFER'）

**权限标识**：`wms:inbound:transfer:query`、`wms:inbound:transfer:confirm`

---

### 2.4 WMS0120 销售退回入库

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0120-01 | 销售退回列表查询 | 按原销售单号、客户筛选 | - |
| S-0120-02 | 销售退回新建 | 关联原出库单、新建退回申请 | S-0120-01 |
| S-0120-03 | 销售退回确认 | 接收退回物料、确认入库 | S-0120-02 |
| S-0120-04 | 销售退回导出 | 导出记录 | S-0120-01 |

**状态流转**：`PENDING → IN_PROGRESS → COMPLETED`

**关键字段**：
- 退回单号、原销售出库单号、客户、仓库
- 物料明细（物料编码、批次号、退回数量）

**数据库表**：`io_inventory_account`（io_type='INBOUND', biz_type='SALES_RETURN'）

**权限标识**：`wms:inbound:return:query`、`wms:inbound:return:add`、`wms:inbound:return:confirm`

---

### 2.5 WMS0130 领用退回入库

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0130-01 | 领用退回列表查询 | 按领用单号、部门筛选 | - |
| S-0130-02 | 领用退回新建 | 关联原领用单、新建退回申请 | S-0130-01 |
| S-0130-03 | 领用退回确认 | 接收退回物料、确认入库 | S-0130-02 |
| S-0130-04 | 领用退回导出 | 导出记录 | S-0130-01 |

**状态流转**：`PENDING → IN_PROGRESS → COMPLETED`

**数据库表**：`io_inventory_account`（io_type='INBOUND', biz_type='CONSUME_RETURN'）

**权限标识**：`wms:inbound:consumeReturn:query`、`wms:inbound:consumeReturn:add`、`wms:inbound:consumeReturn:confirm`

---

## 三、技术实现要点

### 3.1 核心业务流程

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              入库核心流程                                      │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. 创建入库单 ──▶ 2. 审批（可选）──▶ 3. 分配库位 ──▶ 4. 扫码入库 ──▶ 5. 完成│
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ 入库确认核心逻辑                                                      │  │
│  │                                                                      │  │
│  │ @Transactional                                                        │  │
│  │ public void confirmInbound(InboundConfirmRequest req) {              │  │
│  │     // 1. 校验入库单状态                                              │  │
│  │     validateStatus(inbound, "PENDING");                              │  │
│  │                                                                       │  │
│  │     // 2. 遍历物料明细，逐一入库                                      │  │
│  │     for (InboundItem item : req.getItems()) {                       │  │
│  │         // 3. 查询/创建库存记录                                      │  │
│  │         InvInventory inv = getOrCreateInventory(item);              │  │
│  │                                                                       │  │
│  │         // 4. 乐观锁增加库存                                          │  │
│  │         inventoryService.increaseStock(inv.getId(), item.getQty());│  │
│  │                                                                       │  │
│  │         // 5. 生成库存变更流水                                        │  │
│  │         saveChangeLog(inv, item, "INBOUND");                        │  │
│  │     }                                                                 │  │
│  │                                                                       │  │
│  │     // 6. 更新入库单状态                                            │  │
│  │     updateStatus(inbound, "COMPLETED");                             │  │
│  │ }                                                                     │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 事务配置

```java
// 入库确认：使用 REQUIRED 传播，乐观锁保障一致性
@Transactional(rollbackFor = Exception.class)
public void confirmInbound(InboundConfirmRequest request, String userId) {
    // 业务逻辑
}

// 查询操作：只读事务
@Transactional(readOnly = true)
public InboundOrder queryById(Long id) {
    return inboundMapper.selectById(id);
}
```

### 3.3 幂等设计

| 操作 | 幂等方式 | 幂等键 |
|------|---------|-------|
| 新增入库单 | 业务单号唯一约束 | inbound:{bizType}:{sourceNo} |
| 确认入库 | 幂等表 | idempotent:{inboundId}:{version} |

### 3.4 ERP 同步（见 Epic-09）

| 同步方向 | 触发时机 | 技术方案 |
|---------|---------|---------|
| ERP → WMS | 定时拉取 / Webhook | XXL-Job + MQ |
| WMS → ERP | 入库完成后 | MQ异步推送 |

---

## 四、测试要点

### 4.1 业务测试

| 场景 | 测试要点 |
|------|---------|
| 手动新建入库 | 必填校验、批次号自动生成 |
| 扫码入库 | 扫码匹配、物料一致性校验 |
| 库位分配 | 库位状态检查、容量检查 |
| 入库确认 | 库存增加验证、流水生成 |
| 并发入库 | 多用户同时入库、数据一致性 |

### 4.2 库存一致性测试

| 测试场景 | 预期结果 |
|---------|---------|
| 正常入库 | 库存 = 原库存 + 入库数量 |
| 取消入库 | 库存不变 |
| 部分入库 | 库存 = 原库存 + 部分数量 |
| 并发入库 | 最终库存 = 原库存 + 总入库数量 |

---

## 五、交付物清单

| 交付物 | 状态 |
|-------|------|
| 数据库建表SQL | ✅ 已完成 |
| 实体类 | ✅ 已完成 |
| Mapper接口与XML | ⬜ 待开发 |
| Service接口与实现 | ⬜ 待开发 |
| Controller接口 | ⬜ 待开发 |
| 前端页面 | ⬜ 待开发 |
| 单元测试 | ⬜ 待开发 |
| 接口文档 | ⬜ 待开发 |
| ERP同步接口 | ⬜ 待开发（Epic-09） |

---

## 六、相关文档

| 文档 | 路径 |
|------|------|
| 数据库设计 | [WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md) |
| 事务设计 | [01-transaction-design.md](../../05-TECH-STANDARDS/01-transaction-design.md) |
| 状态机设计 | [02-state-machine-design.md](../../05-TECH-STANDARDS/02-state-machine-design.md) |
| 接口幂等设计 | [06-idempotent-design.md](../../05-TECH-STANDARDS/06-idempotent-design.md) |
| ERP接口文档 | [01-erp-interface.md](../../07-INTERFACE/01-erp-interface.md) |
| Epic索引 | [00-Epic-Index.md](00-Epic-Index.md) |
