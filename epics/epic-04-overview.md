# Epic-04：出库管理

> 版本：V1.0
> 日期：2026-04-03
> 优先级：P0
> 预计工时：5天

---

## 一、Epic 概述

出库管理覆盖销售出库、调拨出库、领用出库及各种退货出库场景，是库存扣减的核心环节，需要严格的库存一致性保障。

## 二、包含 Story

| Story编号 | Story名称 | 优先级 | 工期 | 状态 |
|---------|---------|--------|------|------|
| [04-01](../stories/epic-04/story-04-01.md) | 销售出库管理 | P0 | 1.5d | Draft |
| [04-02](../stories/epic-04/story-04-02.md) | 调拨出库管理 | P0 | 1d | Draft |
| [04-03](../stories/epic-04/story-04-03.md) | 领用出库管理 | P0 | 0.5d | Draft |
| [04-04](../stories/epic-04/story-04-04.md) | 生产退回出库 | P0 | 0.5d | Draft |
| [04-05](../stories/epic-04/story-04-05.md) | 采购退回出库 | P0 | 0.5d | Draft |

## 三、技术约束

- 出库确认使用分布式锁 + 乐观锁双重保障
- 按仓库+库位+物料+批次维度扣减
- 支持 FEFO（先进先出）
- 库位分配支持自动分配和手动分配

## 四、相关文档

| 文档 | 路径 |
|------|------|
| 数据库设计 | [WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md) |
| 事务设计 | [01-transaction-design.md](../../05-TECH-STANDARDS/01-transaction-design.md) |
| 状态机设计 | [02-state-machine-design.md](../../05-TECH-STANDARDS/02-state-machine-design.md) |
| 接口幂等设计 | [06-idempotent-design.md](../../05-TECH-STANDARDS/06-idempotent-design.md) |
