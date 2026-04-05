# Epic-09：物流发货

> 版本：V1.0
> 日期：2026-04-03
> 优先级：P2
> 预计工时：8天

---

## 一、Epic 概述

物流发货覆盖中转仓管理、外贸发货流程、快递配送跟踪，是出库后的全链路物流管理。

## 二、包含 Story

| Story编号 | Story名称 | 优先级 | 工期 | 状态 |
|---------|---------|--------|------|------|
| [09-01](../stories/epic-09/story-09-01.md) | 中转仓管理 | P2 | 1.5d | Draft |
| [09-02](../stories/epic-09/story-09-02.md) | 外贸发货 | P2 | 3d | Draft |
| [09-03](../stories/epic-09/story-09-03.md) | 快递配送 | P2 | 2.5d | Draft |

## 三、技术约束

- 快递轨迹同步采用主动推送或定时拉取
- 报检/报关清单支持导出

## 四、相关文档

| 文档 | 路径 |
|------|------|
| 数据库设计 | [WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md) |
| Epic索引 | [00-Epic-Index.md](../../03-SERVICE-GUIDES/00-Epic-Index.md) |
