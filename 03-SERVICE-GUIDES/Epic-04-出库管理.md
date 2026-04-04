# Epic-04：出库管理

> Epic编号：Epic-04
> Epic名称：出库管理
> PRD来源：WMS需求说明书 第3.4节
> 优先级：P0
> 预计工时：5天

---

## 一、Epic 概述

### 1.1 业务背景

出库管理覆盖销售出库、调拨出库、领用出库及各种退货出库场景，是库存扣减的核心环节，需要严格的库存一致性保障。

### 1.2 包含模块

| 模块编号 | 模块名称 | Story数 | 开发顺序 |
|---------|---------|---------|---------|
| WMS0140 | 销售出库 | 7 | 1 |
| WMS0150 | 调拨出库 | 5 | 2 |
| WMS0160 | 领用出库 | 4 | 3 |
| WMS0170 | 生产退回出库 | 4 | 4 |
| WMS0180 | 采购退回出库 | 4 | 5 |

---

## 二、模块 Story 拆分

### 2.1 WMS0140 销售出库

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0140-01 | 销售出库列表查询 | 按状态、时间、客户筛选 | - |
| S-0140-02 | 销售出库新建 | 手动新建/表格上传、关联销售订单 | S-0140-01 |
| S-0140-03 | 库位分配 | 系统自动分配/手动分配、更新出库单 | S-0140-02 |
| S-0140-04 | 标签打印 | 打印物料标签、说明书 | S-0140-03 |
| S-0140-05 | 拣货确认 | 扫码拣货、确认拣货数量 | S-0140-04 |
| S-0140-06 | 确认出库 | 扣减库存、生成出库流水、更新状态 | S-0140-05 |
| S-0140-07 | 销售出库导出 | 导出未完成记录 | S-0140-01 |

**状态流转**：`PENDING → ALLOCATED → PRINTED → PICKING → PICKED → SHIPPED → COMPLETED`

**关键字段**：
- 出库单号、销售订单号、客户、仓库、收货信息
- 物料明细（物料编码、批次号、出库数量、库位）
- 物流单号、快递公司、发货时间

**数据库表**：`io_inventory_account`（io_type='OUTBOUND', biz_type='SALES'）

**权限标识**：`wms:outbound:sales:query`、`wms:outbound:sales:add`、`wms:outbound:sales:allocate`、`wms:outbound:sales:print`、`wms:outbound:sales:confirm`

**核心约束**：
- **库存一致性**：按仓库+库位+物料+批次维度扣减，使用乐观锁
- **先进先出**：按生产日期/失效日期排序（FEFO）

---

### 2.2 WMS0150 调拨出库

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0150-01 | 调拨出库列表查询 | 按调拨单号、仓库筛选 | - |
| S-0150-02 | 调拨出库新建 | 关联调拨申请、选择调出仓库 | S-0150-01 |
| S-0150-03 | 调拨出库确认 | 扣减调出仓库库存、生成出库流水 | S-0150-02 |
| S-0150-04 | 调拨出库ERP同步 | 同步结果至ERP、生成调拨提货单 | S-0150-03 |
| S-0150-05 | 调拨出库导出 | 导出记录 | S-0150-01 |

**状态流转**：`PENDING → ALLOCATED → SHIPPED → COMPLETED`

**关键字段**：
- 调拨单号、调出仓库、调入仓库、关联调拨入库单
- 物料明细、实际出库数量、是否需要快递

**数据库表**：`io_inventory_account`（io_type='OUTBOUND', biz_type='TRANSFER'）

**权限标识**：`wms:outbound:transfer:query`、`wms:outbound:transfer:add`、`wms:outbound:transfer:confirm`

---

### 2.3 WMS0160 领用出库

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0160-01 | 领用出库列表查询 | 按领用单号、部门筛选 | - |
| S-0160-02 | 领用出库新建 | 填写领用信息、选择物料 | S-0160-01 |
| S-0160-03 | 领用出库确认 | 扣减库存、生成出库流水 | S-0160-02 |
| S-0160-04 | 领用出库导出 | 导出记录 | S-0160-01 |

**状态流转**：`PENDING → ALLOCATED → SHIPPED → COMPLETED`

**数据库表**：`io_inventory_account`（io_type='OUTBOUND', biz_type='CONSUME'）

**权限标识**：`wms:outbound:consume:query`、`wms:outbound:consume:add`、`wms:outbound:consume:confirm`

---

### 2.4 WMS0170 生产退回出库

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0170-01 | 生产退回列表查询 | 按退回单号、仓库筛选 | - |
| S-0170-02 | 生产退回新建 | 关联生产订单、新建退回申请 | S-0170-01 |
| S-0170-03 | 生产退回确认 | 扣减库存、生成出库流水 | S-0170-02 |
| S-0170-04 | 生产退回导出 | 导出记录 | S-0170-01 |

**状态流转**：`PENDING → ALLOCATED → SHIPPED → COMPLETED`

**数据库表**：`io_inventory_account`（io_type='OUTBOUND', biz_type='PRODUCTION_RETURN'）

---

### 2.5 WMS0180 采购退回出库

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0180-01 | 采购退回列表查询 | 按退回单号、供应商筛选 | - |
| S-0180-02 | 采购退回新建 | 关联采购订单、新建退回申请 | S-0180-01 |
| S-0180-03 | 采购退回确认 | 扣减库存、生成出库流水 | S-0180-02 |
| S-0180-04 | 采购退回导出 | 导出记录 | S-0180-01 |

**状态流转**：`PENDING → ALLOCATED → SHIPPED → COMPLETED`

**数据库表**：`io_inventory_account`（io_type='OUTBOUND', biz_type='PURCHASE_RETURN'）

---

## 三、技术实现要点

### 3.1 出库核心流程

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              出库核心流程                                      │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  创建出库单 ──▶ 库位分配 ──▶ 标签打印 ──▶ 拣货确认 ──▶ 确认出库 ──▶ 完成   │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ 出库确认（核心）                                                       │  │
│  │                                                                       │  │
│  │ @Transactional(rollbackFor = Exception.class)                          │  │
│  │ public void confirmOutbound(OutboundConfirmRequest req, String userId)│  │
│  │ {                                                                     │  │
│  │     // 1. 查询出库单明细                                               │  │
│  │     List<OutboundItem> items = outboundMapper.selectItems(req.getId());│  │
│  │                                                                       │  │
│  │     // 2. 获取分布式锁（仓库:库位:物料:批次）                          │  │
│  │     List<String> lockKeys = buildLockKeys(items);                      │  │
│  │     List<RLock> locks = lockService.acquireMultipleLocks(lockKeys);   │  │
│  │     try {                                                             │  │
│  │         for (OutboundItem item : items) {                              │  │
│  │             // 3. 校验库存                                             │  │
│  │             InvInventory inv = inventoryService.getById(item.getInvId());│  │
│  │             if (inv.getAvailableQty() < item.getQty()) {               │  │
│  │                 throw new BusinessException("INV001", "库存不足");    │  │
│  │             }                                                          │  │
│  │             // 4. 乐观锁扣减                                          │  │
│  │             inventoryService.deductWithRetry(inv.getId(), item.getQty(),userId);│  │
│  │             // 5. 生成库存变更流水                                     │  │
│  │             saveChangeLog(inv, item, "OUTBOUND");                     │  │
│  │         }                                                              │  │
│  │         // 6. 更新出库单状态                                          │  │
│  │         updateStatus(req.getId(), "SHIPPED");                          │  │
│  │     } finally {                                                        │  │
│  │         lockService.releaseMultipleLocks(locks);                        │  │
│  │     }                                                                  │  │
│  │ }                                                                     │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 库位分配算法

```java
// 库位分配策略：FEFO（先进先出）
public List<LocationAllocation> allocateLocation(List<OutboundItem> items) {
    for (OutboundItem item : items) {
        // 1. 查询可用库存（按效期升序，确保FEFO）
        List<InvInventory> candidates = inventoryMapper.selectAvailableByMaterial(
            item.getMaterialId(),
            item.getWarehouseCode(),
            item.getRequiredQty()
        ).stream()
         .sorted(Comparator.comparing(InvInventory::getExpireDate)) // FEFO
         .collect(Collectors.toList());

        // 2. 贪心分配
        int remainQty = item.getRequiredQty();
        for (InvInventory inv : candidates) {
            if (remainQty <= 0) break;
            
            int allocateQty = Math.min(remainQty, inv.getAvailableQty());
            saveAllocation(item, inv, allocateQty);
            remainQty -= allocateQty;
        }

        // 3. 校验分配结果
        if (remainQty > 0) {
            throw new BusinessException("INV001", 
                String.format("物料[%s]库存不足", item.getMaterialCode()));
        }
    }
}
```

### 3.3 标签打印

| 标签类型 | 内容 | 打印机 |
|---------|------|-------|
| 物料标签 | 物料编码、批次号、UDI、生产日期、失效日期 | ZPL标签打印机 |
| 说明书 | 物料名称、使用说明 | 激光打印机 |
| 清单 | 出库单明细、客户信息 | 激光打印机 |

---

## 四、测试要点

### 4.1 库存一致性测试

| 测试场景 | 预期结果 |
|---------|---------|
| 正常出库 | 库存 = 原库存 - 出库数量 |
| 部分出库 | 库存 = 原库存 - 部分数量 |
| 取消出库 | 库存不变 |
| 并发出库 | 最终库存 = 原库存 - 总出库数量 |
| 超额出库 | 抛出库存不足异常 |

### 4.2 状态机测试

| 当前状态 | 目标状态 | 触发操作 | 测试要点 |
|---------|---------|---------|---------|
| PENDING | ALLOCATED | 分配库位 | 库位锁定成功 |
| PENDING | CANCELLED | 取消 | 状态校验 |
| ALLOCATED | SHIPPED | 确认出库 | 库存扣减验证 |
| SHIPPED | COMPLETED | 确认签收 | 状态更新 |

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
| Epic索引 | [00-Epic-Index.md](00-Epic-Index.md) |
