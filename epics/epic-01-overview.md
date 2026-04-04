# Epic-01：基础数据管理

> 版本：V1.0
> 日期：2026-04-03
> 优先级：P0
> 预计工时：3天

---

## 一、Epic 概述

基础数据是 WMS 系统的根基，包含仓库、库位、物料等核心档案信息。所有其他业务模块都依赖基础数据进行操作。

## 二、包含 Story

| Story编号 | Story名称 | 优先级 | 工期 | 状态 |
|---------|---------|--------|------|------|
| [01-01](../stories/epic-01/story-01-01.md) | 仓库档案查询 | P0 | 0.5d | Draft |
| [01-02](../stories/epic-01/story-01-02.md) | 仓库档案新增/编辑/删除 | P0 | 1d | Draft |
| [01-03](../stories/epic-01/story-01-03.md) | 库位档案查询与新增 | P0 | 1d | Draft |
| [01-04](../stories/epic-01/story-01-04.md) | 物料档案查询与新增 | P0 | 1d | Draft |
| [01-05](../stories/epic-01/story-01-05.md) | 仓库收货地址管理 | P0 | 0.5d | Draft |

## 三、技术约束

- 所有查询必须支持数据权限过滤
- 新增/编辑必须校验编码唯一性
- 删除必须检查关联数据
- 所有操作必须记录审计日志

## 四、相关文档

| 文档 | 路径 |
|------|------|
| 数据库设计 | [WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md) |
| 权限设计 | [04-permission-design.md](../../05-TECH-STANDARDS/04-permission-design.md) |
| 日志规范 | [05-elk-log-design.md](../../05-TECH-STANDARDS/05-elk-log-design.md) |
