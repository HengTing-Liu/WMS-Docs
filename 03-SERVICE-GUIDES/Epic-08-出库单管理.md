# Epic-08：出库单管理

> Epic编号：Epic-08
> Epic名称：出库单管理
> PRD来源：WMS需求说明书 第3.8节
> 优先级：P1
> 预计工时：4天

---

## 一、Epic 概述

### 1.1 业务背景

出库单是提货单的下一环节，将提货单按一定规则拆分为具体的出库任务，驱动拣货、打包、发货等物流操作。

### 1.2 包含模块

| 模块编号 | 模块名称 | Story数 | 开发顺序 |
|---------|---------|---------|---------|
| WMS0290 | 出库准备 | 5 | 1 |
| WMS0300 | 出库单 | 5 | 2 |
| WMS0310 | 包裹单 | 3 | 3 |
| WMS0330 | 发货列表 | 3 | 4 |

---

## 二、模块 Story 拆分

### 2.1 WMS0290 出库准备

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0290-01 | 出库准备列表 | 按状态、仓库筛选 | - |
| S-0290-02 | 出库明细查看 | 查看待出库物料明细 | S-0290-01 |
| S-0290-03 | 库位分配 | 按规则自动分配/手动分配 | S-0290-01 |
| S-0290-04 | 标签打印 | 打印物料标签、说明书 | S-0290-03 |
| S-0290-05 | 确认出库 | 扣减库存、生成出库单 | S-0290-04 |

**核心约束**：
- 按仓库+库位+物料+批次维度分配
- 先进先出（FEFO）

**数据库表**：`io_outbound_prepare`

**权限标识**：`wms:outbound:prepare:query`、`wms:outbound:prepare:allocate`、`wms:outbound:prepare:confirm`

---

### 2.2 WMS0300 出库单

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0300-01 | 出库单列表 | 按状态、时间、仓库筛选 | - |
| S-0300-02 | 出库单详情 | 查看出库明细、物流信息 | S-0300-01 |
| S-0300-03 | 出库单拆分 | 按库位/批次拆分出库任务 | S-0300-01 |
| S-0300-04 | 出库单取消 | 取消未发货出库单 | S-0300-01 |
| S-0300-05 | 出库单导出 | 导出出库记录 | S-0300-01 |

**状态流转**：`PENDING → ALLOCATED → PRINTED → PICKING → PICKED → PACKED → SHIPPED`

**数据库表**：`io_outbound`

**权限标识**：`wms:outbound:order:query`、`wms:outbound:order:split`、`wms:outbound:order:cancel`

---

### 2.3 WMS0310 包裹单

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0310-01 | 包裹单列表 | 按出库单筛选 | - |
| S-0310-02 | 包裹单生成 | 按出库明细生成包裹 | S-0310-01 |
| S-0310-03 | 包裹单打印 | 打印快递单、发货清单 | S-0310-02 |

**关键字段**：
- 包裹号、出库单号、快递公司、快递单号
- 包裹内物料明细、重量、体积

**数据库表**：`io_package`

**权限标识**：`wms:package:query`、`wms:package:create`、`wms:package:print`

---

### 2.4 WMS0330 发货列表

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0330-01 | 发货列表查询 | 按时间、仓库、物流状态筛选 | - |
| S-0330-02 | 发货确认 | 确认发货、更新物流信息 | S-0330-01 |
| S-0330-03 | 发货导出 | 导出发货记录 | S-0330-01 |

**数据库表**：`io_shipment`

**权限标识**：`wms:shipment:query`、`wms:shipment:confirm`

---

## 三、技术实现要点

### 3.1 出库单生成

```java
// 出库单生成（从提货单）
public List<OutboundOrder> generateFromPickOrder(Long pickOrderId) {
    // 1. 查询提货单明细
    List<PickOrderItem> items = pickOrderItemMapper.selectByPickId(pickOrderId);

    // 2. 按仓库分组
    Map<String, List<PickOrderItem>> byWarehouse = items.stream()
        .collect(Collectors.groupingBy(PickOrderItem::getWarehouseCode));

    // 3. 逐仓库生成出库单
    List<OutboundOrder> results = new ArrayList<>();
    for (Map.Entry<String, List<PickOrderItem>> entry : byWarehouse.entrySet()) {
        OutboundOrder order = createOutboundOrder(entry.getKey(), entry.getValue());
        results.add(order);
    }
    return results;
}
```

---

## 四、交付物清单

| 交付物 | 状态 |
|-------|------|
| 数据库建表SQL | ⬜ 待设计 |
| 实体类 | ⬜ 待开发 |
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
