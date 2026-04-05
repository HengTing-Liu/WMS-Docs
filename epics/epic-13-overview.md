# Epic-13：预警通知管理

> 版本：V1.0
> 日期：2026-04-03
> 优先级：P1
> 预计工时：4天

---

## 一、Epic 概述

预警通知是 WMS 系统的重要组成部分，覆盖库存预警、效期预警、盘点超时等业务预警，以及系统异常告警。通过钉钉/邮件/短信等渠道及时通知相关人员，确保问题及时处理。

---

## 二、包含 Story

| Story编号 | Story名称 | 优先级 | 工期 | 状态 |
|---------|---------|--------|------|------|
| [13-01](../stories/epic-13/story-13-01.md) | 预警规则配置 | P1 | 0.5d | Draft |
| [13-02](../stories/epic-13/story-13-02.md) | 预警消息管理 | P1 | 1d | Draft |
| [13-03](../stories/epic-13/story-13-03.md) | 效期预警通知 | P1 | 0.5d | Draft |
| [13-04](../stories/epic-13/story-13-04.md) | 库存预警通知 | P1 | 0.5d | Draft |
| [13-05](../stories/epic-13/story-13-05.md) | 盘点超时预警 | P1 | 0.5d | Draft |
| [13-06](../stories/epic-13/story-13-06.md) | 钉钉通知集成 | P1 | 1d | Draft |

---

## 三、预警类型

| 预警类型 | 触发条件 | 通知方式 | 负责人 |
|---------|---------|---------|--------|
| 效期预警 | 物料效期 <= 30天 | 钉钉+邮件 | 仓库管理员 |
| 库存预警 | 可用库存 < 最低库存 | 钉钉+短信 | 仓库管理员 |
| 盘点超时 | 盘点单超过72小时未完成 | 钉钉 | 盘点负责人 |
| 呆滞预警 | 物料超过6个月无异动 | 钉钉+邮件 | 物料管理员 |
| 异常告警 | 系统异常/接口失败 | 钉钉 | 运维人员 |

---

## 四、技术约束

- 预警消息需记录发送状态
- 支持重复预警（可配置间隔）
- 钉钉通知使用官方 Webhook
- 支持按用户/角色配置通知渠道

---

## 五、相关文档

| 文档 | 路径 |
|------|------|
| 任务调度设计 | [05-TECH-STANDARDS/03-job-scheduler-design.md](../../05-TECH-STANDARDS/03-job-scheduler-design.md) |
| 数据库设计 | [04-DATABASE/WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md) |
| 告警规范 | [03-NON-FUNCTIONAL/06-interface-req.md](../../03-NON-FUNCTIONAL/06-interface-req.md) |

---

## 六、数据库表

| 表名 | 说明 |
|------|------|
| `wms_warning_rule` | 预警规则配置表 |
| `wms_warning_message` | 预警消息表 |
| `wms_warning_channel` | 通知渠道配置表 |
| `sys_dingtalk_config` | 钉钉配置表 |
