# Epic-14：辅助功能与外部接口

> 版本：V1.0
> 日期：2026-04-03
> 优先级：P1
> 预计工时：5天

---

## 一、Epic 概述

Epic-14 包含系统中不可或缺但不属于核心业务流程的辅助功能模块，包括系统登录、物料分类、供应商/客户管理、外部系统接口集成等。

---

## 二、包含 Story

| Story编号 | Story名称 | 优先级 | 工期 | 状态 |
|---------|---------|--------|------|------|
| [14-01](../stories/epic-14/story-14-01.md) | 系统登录认证 | P0 | 1d | Draft |
| [14-02](../stories/epic-14/story-14-02.md) | 物料分类管理 | P1 | 0.5d | Draft |
| [14-03](../stories/epic-14/story-14-03.md) | 供应商档案 | P1 | 0.5d | Draft |
| [14-04](../stories/epic-14/story-14-04.md) | 客户档案 | P1 | 0.5d | Draft |
| [14-05](../stories/epic-14/story-14-05.md) | 序列号规则 | P1 | 0.5d | Draft |
| [14-06](../stories/epic-14/story-14-06.md) | ERP接口集成 | P1 | 1.5d | Draft |
| [14-07](../stories/epic-14/story-14-07.md) | 打印模板配置 | P2 | 1d | Draft |

---

## 三、技术约束

- 系统登录必须支持 JWT Token 认证
- ERP接口使用 XXL-Job 定时同步
- 打印模板支持 HTML 模板

---

## 四、相关文档

| 文档 | 路径 |
|------|------|
| 数据库设计 | [04-DATABASE/WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md) |
| 接口规范 | [07-INTERFACE/01-erp-interface.md](../../07-INTERFACE/01-erp-interface.md) |
| ERP接口 | [07-INTERFACE/02-lims-interface.md](../../07-INTERFACE/02-lims-interface.md) |

---

## 四、PRD 对照表

| PRD模块 | WMS编号 | 对应Story |
|---------|---------|----------|
| 系统登录 | 3.12.6 | 14-01 |
| 物料分类 | 3.1.3 | 14-02 |
| 基础数据-序列号规则 | 3.1.4 | 14-05 |
| 供应商档案 | - | 14-03 |
| 客户档案 | - | 14-04 |
| ERP接口 | V1.0目标 | 14-06 |
| 打印模板 | - | 14-07 |
