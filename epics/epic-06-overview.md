# Epic-06：质量控制

> 版本：V1.0
> 日期：2026-04-03
> 优先级：P1
> 预计工时：2天

---

## 一、Epic 概述

质量控制是医疗器械仓储的核心合规要求，覆盖质检标准管理、请验申请、质检执行，放行决策等全流程。

## 二、包含 Story

| Story编号 | Story名称 | 优先级 | 工期 | 状态 |
|---------|---------|--------|------|------|
| [06-01](../stories/epic-06/story-06-01.md) | 质检标准管理 | P1 | 0.5d | Draft |
| [06-02](../stories/epic-06/story-06-02.md) | 质量放行 | P1 | 1d | Draft |

## 三、技术约束

- 请验期间冻结库存
- LIMS 同步采用 MQ 异步方式
- 让步放行需审批

## 四、相关文档

| 文档 | 路径 |
|------|------|
| 数据库设计 | [WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md) |
| LIMS接口 | [02-lims-interface.md](../../07-INTERFACE/02-lims-interface.md) |
| Epic索引 | [00-Epic-Index.md](../../03-SERVICE-GUIDES/00-Epic-Index.md) |
