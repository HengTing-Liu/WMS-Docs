# Epic-05：库存调整

> 版本：V1.0
> 日期：2026-04-03
> 优先级：P1
> 预计工时：3天

---

## 一、Epic 概述

库存调整包括盘点、报废、库位调整等场景，用于处理库存数据与实际不符、需要调整的情况。

## 二、包含 Story

| Story编号 | Story名称 | 优先级 | 工期 | 状态 |
|---------|---------|--------|------|------|
| [05-01](../stories/epic-05/story-05-01.md) | 库存盘点 | P1 | 1.5d | Draft |
| [05-02](../stories/epic-05/story-05-02.md) | 库位调整 | P1 | 0.5d | Draft |
| [05-03](../stories/epic-05/story-05-03.md) | 库存报废 | P1 | 0.5d | Draft |

## 三、技术约束

- 盘点期间锁定库位，禁止出入库
- 盘点使用冻结机制隔离库存
- 差异率超阈值需审批

## 四、相关文档

| 文档 | 路径 |
|------|------|
| 数据库设计 | [WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md) |
| 事务设计 | [01-transaction-design.md](../../05-TECH-STANDARDS/01-transaction-design.md) |
| Epic索引 | [00-Epic-Index.md](../../03-SERVICE-GUIDES/00-Epic-Index.md) |
