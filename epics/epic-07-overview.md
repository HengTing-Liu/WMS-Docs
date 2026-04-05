# Epic-07：提货单管理

> 版本：V1.0
> 日期：2026-04-03
> 优先级：P1
> 预计工时：5天

---

## 一、Epic 概述

提货单是销售、调拨、领用、CRO等业务生成的物流单据，包含客户信息、收货地址、发货要求等，用于驱动后续出库和物流发货流程。

## 二、包含 Story

| Story编号 | Story名称 | 优先级 | 工期 | 状态 |
|---------|---------|--------|------|------|
| [07-01](../stories/epic-07/story-07-01.md) | 销售提货单 | P1 | 1d | Draft |
| [07-02](../stories/epic-07/story-07-02.md) | 调拨提货单 | P1 | 0.5d | Draft |
| [07-03](../stories/epic-07/story-07-03.md) | 领用提货单 | P1 | 0.5d | Draft |
| [07-04](../stories/epic-07/story-07-04.md) | CRO提货单 | P1 | 1d | Draft |
| [07-05](../stories/epic-07/story-07-05.md) | 随货物品 | P1 | 0.5d | Draft |
| [07-06](../stories/epic-07/story-07-06.md) | 紧急提货单 | P1 | 0.5d | Draft |

## 三、技术约束

- 提货单可按规则合并生成出库单
- 紧急提货单优先处理

## 四、相关文档

| 文档 | 路径 |
|------|------|
| 数据库设计 | [WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md) |
| Epic索引 | [00-Epic-Index.md](../../03-SERVICE-GUIDES/00-Epic-Index.md) |
