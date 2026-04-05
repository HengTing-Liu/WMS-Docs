# Epic-07：提货单管理

> Epic编号：Epic-07
> Epic名称：提货单管理
> PRD来源：WMS需求说明书 第3.7节
> 优先级：P1
> 预计工时：5天

---

## 一、Epic 概述

### 1.1 业务背景

提货单是销售、调拨、领用、CRO等业务生成的物流单据，包含客户信息、收货地址、发货要求等，用于驱动后续出库和物流发货流程。

### 1.2 包含模块

| 模块编号 | 模块名称 | Story数 | 开发顺序 |
|---------|---------|---------|---------|
| WMS0230 | 销售提货单 | 5 | 1 |
| WMS0240 | 调拨提货单 | 4 | 2 |
| WMS0250 | 领用提货单 | 4 | 3 |
| WMS0260 | CRO提货单 | 4 | 4 |
| WMS0270 | 随货物品 | 3 | 5 |
| WMS0280 | 紧急提货单 | 3 | 6 |

---

## 二、模块 Story 拆分

### 2.1 WMS0230 销售提货单

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0230-01 | 销售提货单列表 | 按状态、客户、时间筛选 | - |
| S-0230-02 | 销售提货单新建 | 手动新建/ERP同步 | S-0230-01 |
| S-0230-03 | 销售提货单合并 | 按规则自动合并生成出库单 | S-0230-01 |
| S-0230-04 | 销售提货单详情 | 查看明细、物流跟踪 | S-0230-01 |
| S-0230-05 | 销售提货单取消 | 取消未发货提货单 | S-0230-01 |

**合并规则**：
- 客户ID + 订单机构 + 发货中转类型 + 订单部门 + 开票公司 + 结算货币 + 发货公司编码 + 发货仓库编码 + 收货人 + 收货电话 + 收货地址 均相同

**状态流转**：`PENDING → PREPARING → READY → PICKED → SHIPPED → COMPLETED`

**数据库表**：`io_pick_order_sale`、`io_pick_order_sale_item`

**权限标识**：`wms:pick:sale:query`、`wms:pick:sale:add`、`wms:pick:sale:merge`

---

### 2.2 WMS0240 调拨提货单

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0240-01 | 调拨提货单列表 | 按状态、时间筛选 | - |
| S-0240-02 | 调拨提货单新建 | 从调拨出库自动生成 | S-0240-01 |
| S-0240-03 | 调拨提货单发货 | 确认发货、更新物流信息 | S-0240-02 |
| S-0240-04 | 调拨提货单取消 | 取消未发货提货单 | S-0240-01 |

**数据库表**：`io_pick_order_transfer`

**权限标识**：`wms:pick:transfer:query`、`wms:pick:transfer:confirm`

---

### 2.3 WMS0250 领用提货单

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0250-01 | 领用提货单列表 | 按状态、部门筛选 | - |
| S-0250-02 | 领用提货单新建 | 从领用出库自动生成 | S-0250-01 |
| S-0250-03 | 领用提货单发货 | 确认发货 | S-0250-02 |
| S-0250-04 | 领用提货单取消 | 取消未发货提货单 | S-0250-01 |

**数据库表**：`io_pick_order_consume`

**权限标识**：`wms:pick:consume:query`、`wms:pick:consume:confirm`

---

### 2.4 WMS0260 CRO提货单

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0260-01 | CRO提货单列表 | 按项目号、客户筛选 | - |
| S-0260-02 | CRO提货单新建 | 填写项目信息、物料明细 | S-0260-01 |
| S-0260-03 | CRO提货单发货 | 确认发货 | S-0260-02 |
| S-0260-04 | CRO提货单取消 | 取消未发货提货单 | S-0260-01 |

**数据库表**：`io_pick_order_cro`

**权限标识**：`wms:pick:cro:query`、`wms:pick:cro:add`、`wms:pick:cro:confirm`

---

### 2.5 WMS0270 随货物品

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0270-01 | 随货物品清单查询 | 按提货单号筛选 | - |
| S-0270-02 | 随货物品关联 | 关联销售提货单 | S-0270-01 |
| S-0270-03 | 随货物品打印 | 打印随货清单 | S-0270-01 |

**数据库表**：`io_goods_with`

**权限标识**：`wms:goods:with:query`、`wms:goods:with:print`

---

### 2.6 WMS0280 紧急提货单

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0280-01 | 紧急提货单列表 | 按状态筛选 | - |
| S-0280-02 | 紧急提货单新建 | 优先处理标记 | S-0280-01 |
| S-0280-03 | 紧急提货单发货 | 快速发货流程 | S-0280-02 |

**数据库表**：`io_pick_order_urgent`（如需独立表）

**权限标识**：`wms:pick:urgent:query`、`wms:pick:urgent:add`

---

## 三、技术实现要点

### 3.1 提货单合并算法

```java
// 提货单合并规则
public List<OutboundOrder> mergePickOrders(List<PickOrder> pickOrders) {
    // 1. 按合并规则分组
    Map<MergeKey, List<PickOrder>> groups = pickOrders.stream()
        .collect(Collectors.groupingBy(p -> MergeKey.builder()
            .customerId(p.getCustomerId())
            .orderOrg(p.getOrderOrgCode())
            .salesDept(p.getSalesDeptCode())
            .invoiceCompany(p.getInvoiceCompany())
            .currency(p.getSettlementCurrency())
            .outCompany(p.getOutCompanyCode())
            .outWarehouse(p.getOutWarehouseCode())
            .consignee(p.getConsignee())
            .phone(p.getPhone())
            .address(p.getAddress())
            .build()));

    // 2. 逐组生成出库单
    List<OutboundOrder> results = new ArrayList<>();
    for (Map.Entry<MergeKey, List<PickOrder>> entry : groups.entrySet()) {
        if (entry.getValue().size() > 1) {
            // 需要合并
            OutboundOrder merged = createMergedOutbound(entry.getValue());
            results.add(merged);
        } else {
            // 单条直接生成
            results.add(createOutbound(entry.getValue().get(0)));
        }
    }
    return results;
}
```

---

## 四、交付物清单

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

## 五、相关文档

| 文档 | 路径 |
|------|------|
| 数据库设计 | [WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md) |
| Epic索引 | [00-Epic-Index.md](00-Epic-Index.md) |
