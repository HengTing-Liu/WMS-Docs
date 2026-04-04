# Epic-02：库存查询

> 版本：V1.0
> 日期：2026-04-03
> 优先级：P0
> 预计工时：2天

---

## 一、Epic 概述

库存查询是仓储业务的核心视图，提供物料、库位、流水等关键信息的实时查询能力，支持库存预警和追溯。

## 二、包含 Story

| Story编号 | Story名称 | 优先级 | 工期 | 状态 |
|---------|---------|--------|------|------|
| [02-01](../stories/epic-02/story-02-01.md) | 物料库存查询 | P0 | 0.5d | Draft |
| [02-02](../stories/epic-02/story-02-02.md) | 库位库存查询 | P0 | 0.5d | Draft |
| [02-03](../stories/epic-02/story-02-03.md) | 库存流水查询 | P0 | 0.5d | Draft |
| [02-04](../stories/epic-02/story-02-04.md) | 二维码扫描查询 | P1 | 0.5d | Draft |

## 三、技术约束

- 所有查询必须支持数据权限过滤（仓库级）
- 查询性能要求：单表查询 < 200ms
- 大数据量（>10000条）分页查询 < 1s
- 导出使用异步方式

## 四、相关文档

| 文档 | 路径 |
|------|------|
| 数据库设计 | [WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md) |
| 事务设计 | [01-transaction-design.md](../../05-TECH-STANDARDS/01-transaction-design.md) |
| 数据权限设计 | [04-permission-design.md](../../05-TECH-STANDARDS/04-permission-design.md) |
