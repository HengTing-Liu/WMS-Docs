# Story 13-02 预警消息管理

## 0. 基本信息

- Epic：预警通知管理
- Story ID：13-02
- 优先级：P1
- 状态：Draft
- 预计工期：1d
- 依赖 Story：13-01（预警规则配置）
- 关联迭代：Sprint 6

---

## 1. 目标

实现预警消息的查询和管理，支持按类型、状态、时间范围筛选，支持消息确认和处理。

---

## 2. 业务背景

预警消息是预警触发的结果，记录所有预警事件和通知状态，便于追溯和统计。

---

## 3. 范围

### 3.1 本 Story 包含

- 预警消息列表查询
- 预警消息详情查看
- 预警消息确认/处理
- 预警消息导出

### 3.2 本 Story 不包含

- 预警规则配置（见 Story 13-01）
- 钉钉通知发送（见 Story 13-06）

---

## 4. API / 接口契约

### 4.1 接口清单

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/warning/message/list` | 预警消息列表 |
| GET | `/api/warning/message/{id}` | 预警消息详情 |
| PUT | `/api/warning/message/{id}/confirm` | 确认预警 |
| PUT | `/api/warning/message/{id}/handle` | 处理预警 |
| DELETE | `/api/warning/message/{id}` | 删除预警消息 |
| GET | `/api/warning/message/export` | 导出预警消息 |

### 4.2 Schema 配置

- **表编码**：WMS0502
- **CRUD前缀**：`/api/warning/message`

### 4.3 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| ruleType | string | N | 规则类型 |
| warningLevel | string | N | 预警级别：INFO/WARNING/ERROR |
| status | string | N | 状态：PENDING/SENT/CONFIRMED/HANDLED |
| startTime | datetime | N | 开始时间 |
| endTime | datetime | N | 结束时间 |
| page | int | N | 页码 |
| pageSize | int | N | 每页条数 |

### 4.4 响应字段

| 字段 | 类型 | 说明 |
|------|------|------|
| total | int | 总记录数 |
| records | array | 消息列表 |
| records[].id | long | 消息ID |
| records[].ruleCode | string | 规则编码 |
| records[].ruleName | string | 规则名称 |
| records[].warningLevel | string | 预警级别 |
| records[].title | string | 预警标题 |
| records[].content | string | 预警内容 |
| records[].targetType | string | 预警对象类型 |
| records[].targetId | long | 预警对象ID |
| records[].targetName | string | 预警对象名称 |
| records[].status | string | 状态 |
| records[].sendStatus | string | 发送状态 |
| records[].sendTime | datetime | 发送时间 |
| records[].handler | string | 处理人 |
| records[].handleTime | datetime | 处理时间 |
| records[].handleResult | string | 处理结果 |
| records[].gmtCreate | datetime | 创建时间 |

---

## 5. 业务规则

1. **消息状态**：PENDING（待处理）→ CONFIRMED（已确认）→ HANDLED（已处理）
2. **发送状态**：PENDING（待发送）→ SENT（已发送）→ FAILED（发送失败）
3. **处理时效**：WARNING 级别需 24 小时内处理，ERROR 级别需 4 小时内处理
4. **重复预警**：同一对象重复预警需间隔 repeatInterval 分钟

---

## 6. 验收标准

### 6.1 功能验收

- [ ] 预警消息列表查询正常
- [ ] 多条件筛选正确
- [ ] 确认/处理功能正常
- [ ] 导出功能正常

### 6.2 性能验收

- [ ] 查询响应 < 1s（1000条以内）

---

## 7. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档

---

## 8. 关联文档

- Epic Brief：[epic-13-overview.md](../../epics/epic-13-overview.md)
