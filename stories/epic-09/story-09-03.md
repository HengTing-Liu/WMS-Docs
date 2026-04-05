# Story 09-03 快递配送

## 0. 基本信息

- Epic：物流发货
- Story ID：09-03
- 优先级：P2
- 状态：Draft
- 预计工期：2.5d
- 依赖 Story：无
- 关联迭代：Sprint 5

---

## 1. 目标

实现快递计划和配送跟踪管理。

---

## 2. 业务背景

快递配送是物流最后一公里，支持快递计划制定和配送轨迹跟踪。

---

## 3. 范围

### 3.1 本 Story 包含

- 快递计划列表
- 快递计划生成
- 快递揽收确认
- 配送跟踪列表
- 轨迹查询
- 异常登记

### 3.2 本 Story 不包含

- 第三方快递系统对接（接口预留）

---

## 4. 参与角色

- 物流专员：管理快递配送

---

## 5. 前置条件

- 发货清单已生成
- 用户具备快递配送权限

---

## 6. 触发方式

- 页面入口：物流发货 → 快递计划 / 配送跟踪
- 接口入口：GET `/api/logistics/express/list`

---

## 7. 输入 / 输出

### 7.1 生成快递计划 - 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| shippingListIds | array | Y | 发货清单ID列表 |
| expressCompany | string | Y | 快递公司 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | ID |
| planNo | string | 计划单号 |
| trackingNo | string | 快递单号 |

---

## 8. 状态流转

### 8.1 快递计划状态

| 状态 | 说明 |
|---|---|
| CREATED | 已创建 |
| PICKED_UP | 已揽收 |
| IN_TRANSIT | 运输中 |
| DELIVERED | 已送达 |
| ABNORMAL | 异常 |

### 8.2 配送跟踪状态

| 状态 | 说明 |
|---|---|
| CREATED | 已创建 |
| PICKED_UP | 已揽收 |
| IN_TRANSIT | 运输中 |
| OUT_FOR_DELIVERY | 派送中 |
| DELIVERED | 已签收 |
| RETURNED | 退回 |
| ABNORMAL | 异常 |

---

## 9. 业务规则

1. **快递单号生成规则**：
   - 顺丰：`SF` + 雪花ID
   - 圆通：`YT` + 12位数字
   - 其他：雪花ID
2. **轨迹同步**：
   - 主动推送：快递公司 Webhook 回调
   - 定时拉取：XXL-Job 定时查询

---

## 10. 数据设计

### 10.1 涉及表

- `logistics_express_plan`
- `logistics_delivery_tracking`

---

## 11. API / 接口契约

### 11.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0360 |
| CRUD前缀 | `/api/logistics/express` |

### 11.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/logistics/express/plan/list` | 快递计划列表 |
| POST | `/api/logistics/express/plan` | 生成快递计划 |
| POST | `/api/logistics/express/plan/{id}/pickup` | 揽收确认 |
| GET | `/api/logistics/express/tracking/list` | 配送跟踪列表 |
| GET | `/api/logistics/express/tracking/{id}` | 轨迹查询 |
| POST | `/api/logistics/express/tracking/{id}/abnormal` | 异常登记 |

### 11.3 快递轨迹同步接口

| 方向 | 说明 |
|------|------|
| 接收 Webhook | POST `/api/logistics/express/tracking/webhook` |

---

## 12. 权限与审计

### 12.1 权限标识

- `logistics:express:query`
- `logistics:express:create`
- `logistics:delivery:tracking:query`
- `logistics:delivery:tracking:abnormal`

---

## 13. 验收标准

### 13.1 功能验收

- [ ] 快递计划生成正常
- [ ] 快递单号生成正确
- [ ] 揽收确认正常
- [ ] 配送跟踪正常
- [ ] 轨迹查询正常
- [ ] 异常登记正常
- [ ] Webhook 回调正常

---

## 14. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 15. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0410/WMS0420
- Epic Brief：[epic-09-overview.md](../../epics/epic-09-overview.md)
