# Story 13-01 预警规则配置

## 0. 基本信息

- Epic：预警通知管理
- Story ID：13-01
- 优先级：P1
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 6

---

## 1. 目标

实现预警规则的配置管理，支持预警类型、触发条件、通知方式等配置。

---

## 2. 业务背景

预警规则是预警通知的基础，定义了不同类型预警的触发条件和通知方式。

---

## 3. 范围

### 3.1 本 Story 包含

- 预警规则列表查询
- 预警规则新增/编辑
- 预警规则启用/禁用
- 预警规则删除

### 3.2 本 Story 不包含

- 预警消息管理（见 Story 13-02）
- 钉钉通知集成（见 Story 13-06）

---

## 4. API / 接口契约

### 4.1 接口清单

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/warning/rule/list` | 预警规则列表 |
| GET | `/api/warning/rule/{id}` | 预警规则详情 |
| POST | `/api/warning/rule` | 新增预警规则 |
| PUT | `/api/warning/rule/{id}` | 编辑预警规则 |
| DELETE | `/api/warning/rule/{id}` | 删除预警规则 |
| PUT | `/api/warning/rule/{id}/toggle` | 启用/禁用 |

### 4.2 Schema 配置

- **表编码**：WMS0501
- **CRUD前缀**：`/api/warning/rule`

### 4.3 请求示例

```json
POST /api/warning/rule
{
  "ruleCode": "LOW_STOCK",
  "ruleName": "库存预警",
  "ruleType": "INVENTORY",
  "triggerCondition": "availableQty < minStock",
  "threshold": 10,
  "warningLevel": "WARNING",
  "notifyChannels": ["DINGTALK", "SMS"],
  "isEnabled": 1
}
```

### 4.4 预警规则字段

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| ruleCode | string | 是 | 规则编码，唯一 |
| ruleName | string | 是 | 规则名称 |
| ruleType | string | 是 | 规则类型：INVENTORY/EXPIRE/STOCKTAKE/STAGNANT |
| triggerCondition | string | 是 | 触发条件表达式 |
| threshold | int | 否 | 阈值 |
| warningLevel | string | 是 | 预警级别：INFO/WARNING/ERROR |
| notifyChannels | array | 是 | 通知渠道：DINGTALK/EMAIL/SMS |
| notifyUsers | array | 否 | 通知用户ID列表 |
| notifyRoles | array | 否 | 通知角色ID列表 |
| repeatInterval | int | 否 | 重复间隔（分钟），0表示不重复 |
| isEnabled | int | 是 | 是否启用 |

---

## 5. 预警类型定义

| 类型编码 | 类型名称 | 默认触发条件 | 默认阈值 |
|---------|---------|-------------|---------|
| LOW_STOCK | 库存不足预警 | availableQty < minStock | 10 |
| EXPIRE | 效期预警 | expireDate - today <= 30 | 30天 |
| STOCKTAKE_TIMEOUT | 盘点超时预警 | stocktake.createTime + 72h < now | 72小时 |
| STAGNANT | 呆滞预警 | lastMoveDate + 180d < today | 180天 |

---

## 6. 验收标准

### 6.1 功能验收

- [ ] 预警规则 CRUD 正常
- [ ] 规则编码唯一性校验
- [ ] 启用/禁用功能正常
- [ ] 通知渠道配置正常

---

## 7. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档

---

## 8. 关联文档

- Epic Brief：[epic-13-overview.md](../../epics/epic-13-overview.md)
- 任务调度：[03-job-scheduler-design.md](../../05-TECH-STANDARDS/03-job-scheduler-design.md)
