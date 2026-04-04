# Epic-03：入库管理

> 版本：V1.0
> 日期：2026-04-03
> 优先级：P0
> 预计工时：5天

---

## 一、Epic 概述

入库管理是 WMS 核心业务流程之一，覆盖采购入库、生产入库、调拨入库及各种退货入库场景，确保物料准确、高效入库。

## 二、包含 Story

| Story编号 | Story名称 | 优先级 | 工期 | 状态 |
|---------|---------|--------|------|------|
| [03-01](../stories/epic-03/story-03-01.md) | 生产入库管理 | P0 | 1d | Draft |
| [03-02](../stories/epic-03/story-03-02.md) | 采购入库管理 | P0 | 1d | Draft |
| [03-03](../stories/epic-03/story-03-03.md) | 调拨入库管理 | P0 | 0.5d | Draft |
| [03-04](../stories/epic-03/story-03-04.md) | 销售退回入库 | P0 | 0.5d | Draft |
| [03-05](../stories/epic-03/story-03-05.md) | 领用退回入库 | P0 | 0.5d | Draft |

## 三、技术约束

- 入库确认使用乐观锁保障库存一致性
- 质检物料入库需先冻结库存
- 入库完成后需生成库存变更流水
- ERP 同步采用 MQ 异步方式

## 四、相关文档

| 文档 | 路径 |
|------|------|
| 数据库设计 | [WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md) |
| 事务设计 | [01-transaction-design.md](../../05-TECH-STANDARDS/01-transaction-design.md) |
| 状态机设计 | [02-state-machine-design.md](../../05-TECH-STANDARDS/02-state-machine-design.md) |
| 接口幂等设计 | [06-idempotent-design.md](../../05-TECH-STANDARDS/06-idempotent-design.md) |
