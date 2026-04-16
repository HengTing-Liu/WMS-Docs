# Epic-11：低代码配置管理

> 版本：V1.0
> 日期：2026-04-03
> 优先级：P0
> 预计工时：4天

---

## 一、Epic 概述

低代码配置是 WMS 系统的前端页面开发基础设施。通过元数据驱动的方式，实现档案页面和简单单据页面的零代码/低代码开发，大幅提升开发效率。

**核心价值**：
- 新增档案页面从3天缩短至30分钟
- 所有档案页面风格一致
- 减少前端开发工作量，聚焦复杂业务

---

## 二、包含 Story

| Story编号 | Story名称 | 优先级 | 工期 | 状态 |
|---------|---------|--------|------|------|
| [11-01](../stories/epic-11/story-11-01.md) | 表元数据管理 | P0 | 0.5d | Draft |
| [11-02](../stories/epic-11/story-11-02.md) | 字段元数据管理 | P0 | 0.5d | Done |
| [11-03](../stories/epic-11/story-11-03.md) | 操作元数据管理 | P0 | 0.5d | Done |
| [11-04](../stories/epic-11/story-11-04.md) | 字典数据管理 | P0 | 0.5d | Done |
| [11-05](../stories/epic-11/story-11-05.md) | 低代码引擎接口 | P0 | 1.5d | Done |
| [11-06](../stories/epic-11/story-11-06.md) | 前端低代码组件 | P0 | 1d | Done |

---

## 三、技术约束

- 元数据变更需记录操作日志
- 表元数据删除前必须检查是否被页面引用
- 字段元数据支持拖拽排序
- 字典数据支持批量导入导出

---

## 四、相关文档

| 文档 | 路径 |
|------|------|
| 低代码设计 | [04-DESIGN/03-lowcode-design.md](../../04-DESIGN/03-lowcode-design.md) |
| 数据库设计 | [04-DATABASE/WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md) |
| 前端开发指南 | [05-DEV-GUIDE/02-frontend-dev-guide.md](../../05-DEV-GUIDE/02-frontend-dev-guide.md) |
| 页面开发指南 | [05-DEV-GUIDE/03-page-impl-guide.md](../../05-DEV-GUIDE/03-page-impl-guide.md) |

---

## 五、适用页面范围

| 类别 | 数量 | 页面示例 |
|------|------|----------|
| A类（纯档案） | ~12个 | 仓库档案、库位档案、物料档案、供应商、客户等 |
| B类（简单单据） | ~7个 | 采购入库、销售出库、调拨单等 |
