# Epic-05：库存调整

> Epic编号：Epic-05
> Epic名称：库存调整
> PRD来源：WMS需求说明书 第3.5节
> 优先级：P1
> 预计工时：3天

---

## 一、Epic 概述

### 1.1 业务背景

库存调整包括盘点、报废、库位调整等场景，用于处理库存数据与实际不符、需要调整的情况。

### 1.2 包含模块

| 模块编号 | 模块名称 | Story数 | 开发顺序 |
|---------|---------|---------|---------|
| WMS0190 | 库存盘点 | 8 | 1 |
| WMS0200 | 库存报废 | 4 | 2 |
| WMS0210 | 库位调整 | 4 | 3 |

---

## 二、模块 Story 拆分

### 2.1 WMS0190 库存盘点

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0190-01 | 盘点计划列表 | 按状态、时间范围筛选 | - |
| S-0190-02 | 盘点计划新建 | 选择仓库和库位、设置盘点方式 | S-0190-01 |
| S-0190-03 | 盘点计划审批 | 审批通过/驳回 | S-0190-02 |
| S-0190-04 | 启动盘点 | 锁定库位和库存、生成盘点清单 | S-0190-03 |
| S-0190-05 | 扫码盘点 | 扫码录入实际数量 | S-0190-04 |
| S-0190-06 | 确认更新 | 差异处理、更新库存 | S-0190-05 |
| S-0190-07 | 盘点报表 | 导出盘点结果、差异分析 | S-0190-06 |
| S-0190-08 | 盘点ERP同步 | 盘点结果同步ERP | S-0190-06 |

**状态流转**：`DRAFT → STARTED → IN_PROGRESS → COMPLETED → CONFIRMED`

**关键字段**：
- 盘点单号、盘点方式（全盘/抽盘/循环盘点）
- 仓库、库位列表、盘点人员、计划时间
- 账面数量、实际数量、差异数量、差异原因

**数据库表**：`st_stocktake`、`st_stocktake_location`、`st_stocktake_item`

**权限标识**：`wms:stocktake:query`、`wms:stocktake:add`、`wms:stocktake:start`、`wms:stocktake:confirm`

**核心约束**：
- 盘点期间锁定库位，禁止出入库
- 差异率超过阈值需审批

---

### 2.2 WMS0200 库存报废

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0200-01 | 报废计划列表 | 按状态、仓库筛选 | - |
| S-0200-02 | 报废计划新建 | 选择物料和批次、填写报废数量 | S-0200-01 |
| S-0200-03 | 报废审批 | 审批通过/驳回 | S-0200-02 |
| S-0200-04 | 报废确认 | 扣减隔离仓库存、同步ERP | S-0200-03 |

**状态流转**：`PENDING → APPROVED → COMPLETED`

**关键字段**：
- 报废单号、物料、批次、报废数量、报废原因
- 隔离仓库、隔离库位

**权限标识**：`wms:scrap:query`、`wms:scrap:add`、`wms:scrap:confirm`

---

### 2.3 WMS0210 库位调整

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0210-01 | 调整单列表 | 按状态、仓库筛选 | - |
| S-0210-02 | 调整单新建 | 选择物料、源库位、目标库位、数量 | S-0210-01 |
| S-0210-03 | 调整确认 | 执行调拨、更新库存位置 | S-0210-02 |
| S-0210-04 | 调整导出 | 导出调整记录 | S-0210-01 |

**状态流转**：`PENDING → COMPLETED`

**关键字段**：
- 调整单号、申请部门、申请人
- 物料、批次、调出库位、调入库位、调整数量

**数据库表**：`adj_location`

**权限标识**：`wms:adjust:location:query`、`wms:adjust:location:add`、`wms:adjust:location:confirm`

---

## 三、技术实现要点

### 3.1 盘点锁定机制

```java
// 启动盘点
@Transactional
public void startStocktake(Long stocktakeId, String operator) {
    // 1. 更新盘点单状态
    updateStatus(stocktakeId, "STARTED");

    // 2. 锁定库位（状态=盘点中）
    List<StocktakeLocation> locations = locationMapper.selectByStocktakeId(stocktakeId);
    for (StocktakeLocation loc : locations) {
        locationService.lockLocation(loc.getLocationId(), stocktakeId);
    }

    // 3. 生成盘点明细（读取当前库存）
    List<Inventory> inventories = inventoryService.getByLocationIds(locIds);
    for (Inventory inv : inventories) {
        StocktakeItem item = StocktakeItem.builder()
            .stocktakeId(stocktakeId)
            .materialId(inv.getMaterialId())
            .batchId(inv.getBatchId())
            .systemQuantity(inv.getQuantity())
            .stocktakeQuantity(0)  // 待录入
            .diffQuantity(0)
            .build();
        itemMapper.insert(item);

        // 4. 冻结库存（冻结 = 账面数量）
        inventoryService.freeze(inv.getId(), inv.getQuantity(), "STOCKTAKE", stocktakeId);
    }

    // 5. 生成盘点清单（可导出）
    generateChecklist(stocktakeId);
}
```

### 3.2 差异处理

```java
// 确认盘点
@Transactional
public void confirmStocktake(Long stocktakeId, String operator) {
    // 1. 遍历盘点明细
    List<StocktakeItem> items = itemMapper.selectByStocktakeId(stocktakeId);
    
    for (StocktakeItem item : items) {
        int diff = item.getStocktakeQuantity() - item.getSystemQuantity();
        item.setDiffQuantity(diff);
        
        if (diff != 0) {
            // 2. 检查差异率
            double diffRate = Math.abs(diff) / (double) item.getSystemQuantity();
            if (diffRate > THRESHOLD) {
                // 需要审批
                item.setStatus("PENDING_APPROVAL");
            } else {
                // 3. 自动调整库存
                if (diff > 0) {
                    // 盘盈
                    inventoryService.increase(item.getInventoryId(), diff, operator);
                } else {
                    // 盘亏
                    inventoryService.decrease(item.getInventoryId(), -diff, operator);
                }
                item.setStatus("ADJUSTED");
            }
        } else {
            item.setStatus("CONFIRMED");
        }
        itemMapper.update(item);
    }

    // 4. 解冻库存
    unfreezeByStocktakeId(stocktakeId);

    // 5. 更新状态
    updateStatus(stocktakeId, "CONFIRMED");
}
```

---

## 四、测试要点

### 4.1 盘点测试

| 测试场景 | 预期结果 |
|---------|---------|
| 启动盘点 | 库位锁定、库存冻结、盘点清单生成 |
| 盘点中禁止出入库 | 出入库操作被拒绝 |
| 差异率<阈值 | 自动调整库存 |
| 差异率>阈值 | 需审批后调整 |
| 确认盘点 | 库存更新、库位解锁 |

### 4.2 报废测试

| 测试场景 | 预期结果 |
|---------|---------|
| 报废申请 | 创建报废计划 |
| 报废审批 | 通过/驳回 |
| 报废确认 | 库存扣减、同步ERP |

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

---

## 六、相关文档

| 文档 | 路径 |
|------|------|
| 数据库设计 | [WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md) |
| 事务设计 | [01-transaction-design.md](../../05-TECH-STANDARDS/01-transaction-design.md) |
| 状态机设计 | [02-state-machine-design.md](../../05-TECH-STANDARDS/02-state-machine-design.md) |
| Epic索引 | [00-Epic-Index.md](00-Epic-Index.md) |
