# Epic-12：报表与统计

> 版本：V1.0
> 日期：2026-04-03
> 优先级：P1
> 预计工时：3.5天

---

## 一、Epic 概述

报表与统计是 WMS 系统的重要组成部分，为仓储管理提供数据支撑。涵盖库存台账、出入库明细、盘点差异等核心报表，以及库存统计看板。

---

## 二、包含 Story

| Story编号 | Story名称 | 优先级 | 工期 | 状态 |
|---------|---------|--------|------|------|
| [12-01](../stories/epic-12/story-12-01.md) | 库存台账报表 | P1 | 1d | Draft |
| [12-02](../stories/epic-12/story-12-02.md) | 出入库明细报表 | P1 | 1d | Draft |
| [12-03](../stories/epic-12/story-12-03.md) | 盘点差异报表 | P1 | 0.5d | Draft |
| [12-04](../stories/epic-12/story-12-04.md) | 库存统计看板 | P1 | 1d | Draft |

---

## 三、技术约束

- 所有查询必须支持数据权限过滤（仓库级）
- 导出使用异步方式，避免超时
- 大数据量查询使用分页
- 报表支持定时推送（可选）

---

## 四、相关文档

| 文档 | 路径 |
|------|------|
| 数据库设计 | [04-DATABASE/WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md) |
| 权限设计 | [05-TECH-STANDARDS/04-permission-design.md](../../05-TECH-STANDARDS/04-permission-design.md) |
| 接口幂等设计 | [05-TECH-STANDARDS/06-idempotent-design.md](../../05-TECH-STANDARDS/06-idempotent-design.md) |

---

## 五、报表清单

| 报表名称 | 说明 | 使用频率 |
|---------|------|----------|
| 库存台账 | 按物料/库位维度的实时库存 | 高 |
| 出入库明细 | 出入库流水明细查询 | 高 |
| 盘点差异 | 盘点结果和差异分析 | 中 |
| 库存统计看板 | Dashboard统计卡片 | 高 |
