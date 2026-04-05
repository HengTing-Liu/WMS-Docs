# Story 10-05 日志管理

## 0. 基本信息

- Epic：系统管理
- Story ID：10-05
- 优先级：P0
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 1

---

## 1. 目标

实现系统日志查询功能，支持操作日志和登录日志查询。

---

## 2. 业务背景

日志管理用于记录系统操作和登录行为，便于问题排查和审计。

---

## 3. 范围

### 3.1 本 Story 包含

- 操作日志查询
- 登录日志查询
- 日志导出

### 3.2 本 Story 不包含

- 日志自动清理

---

## 4. 参与角色

- 系统管理员：查看所有日志
- 普通用户：查看本人日志

---

## 5. 前置条件

- 用户具备日志查询权限

---

## 6. 触发方式

- 页面入口：系统管理 → 日志管理 → 操作日志 / 登录日志
- 接口入口：GET `/api/system/log/oper/list`、GET `/api/system/log/login/list`

---

## 7. 输入 / 输出

### 7.1 操作日志查询输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| page | int | N | 页码 |
| pageSize | int | N | 每页条数 |
| title | string | N | 操作模块 |
| businessType | string | N | 业务类型 |
| operName | string | N | 操作人 |
| startTime | datetime | N | 开始时间 |
| endTime | datetime | N | 结束时间 |
| status | string | N | 操作状态 |

### 7.2 登录日志查询输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| page | int | N | 页码 |
| pageSize | int | N | 每页条数 |
| ipaddr | string | N | IP地址 |
| username | string | N | 用户账号 |
| startTime | datetime | N | 开始时间 |
| endTime | datetime | N | 结束时间 |
| status | string | N | 登录状态 |

### 7.3 操作日志输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 日志ID |
| title | string | 操作模块 |
| businessType | string | 业务类型 |
| method | string | 请求方法 |
| requestMethod | string | 请求方式 |
| operatorType | string | 操作类型 |
| operName | string | 操作人 |
| deptName | string | 部门名称 |
| operUrl | string | 请求地址 |
| operIp | string | 操作IP |
| operLocation | string | 操作地点 |
| operParam | string | 请求参数 |
| jsonResult | string | 返回结果 |
| status | int | 操作状态 |
| operTime | datetime | 操作时间 |
| costTime | long | 消耗时间(ms) |

---

## 8. 业务规则

1. **操作日志**：记录所有业务操作
2. **登录日志**：记录登录/登出行为
3. **日志保留**：默认保留 90 天
4. **敏感数据脱敏**：密码等敏感字段脱敏

---

## 9. 数据设计

### 9.1 涉及表

- `sys_oper_log`（已有）
- `sys_logininfor`（已有）

---

## 10. API / 接口契约

### 10.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0470 |
| CRUD前缀 | `/api/system/log` |

### 10.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/system/log/oper/list` | 操作日志查询 |
| GET | `/api/system/log/oper/{id}` | 操作日志详情 |
| DELETE | `/api/system/log/oper/clean` | 清理操作日志 |
| GET | `/api/system/log/login/list` | 登录日志查询 |
| DELETE | `/api/system/log/login/clean` | 清理登录日志 |

---

## 11. 权限与审计

### 11.1 权限标识

- `system:log:oper:query`
- `system:log:oper:delete`
- `system:log:login:query`
- `system:log:login:delete`

### 11.2 审计要求

- 日志本身是审计数据，无需额外审计

---

## 12. 验收标准

### 12.1 功能验收

- [ ] 操作日志查询正常
- [ ] 登录日志查询正常
- [ ] 日志详情正常
- [ ] 敏感数据已脱敏
- [ ] 日志导出正常

---

## 13. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档

---

## 14. 关联文档

- Epic Brief：[epic-10-overview.md](../../epics/epic-10-overview.md)
