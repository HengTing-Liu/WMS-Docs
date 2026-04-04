# Story 07-02 调拨提货单

## 0. 基本信息

- Epic：提货单管理
- Story ID：07-02
- 优先级：P1
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 4

---

## 1. 目标

实现调拨提货单管理，支持从调拨出库自动生成提货单。

---

## 2. 业务背景

调拨提货单是调拨出库的物流单据，跟随调拨出库单生成。

---

## 3. 范围

### 3.1 本 Story 包含

- 调拨提货单列表查询
- 调拨提货单发货确认
- 调拨提货单取消

### 3.2 本 Story 不包含

- 新建（由调拨出库自动生成）

---

## 4. 参与角色

- 仓库管理员：管理调拨提货单

---

## 5. 前置条件

- 调拨出库单已出库

---

## 6. 触发方式

- 页面入口：提货单管理 → 调拨提货单
- 接口入口：`GET /api/pickup/transfer/list`

---

## 7. 输入 / 输出

### 7.1 发货确认 - 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| expressNo | string | N | 快递单号 |
| expressCompany | string | N | 快递公司 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 提货单ID |
| pickNo | string | 提货单号 |
| status | string | 状态 |

---

## 8. 状态流转

### 8.1 主体对象

- 对象名称：调拨提货单

### 8.2 状态定义

| 状态 | 说明 |
|---|---|
| PENDING | 待发货 |
| SHIPPED | 已发货 |
| COMPLETED | 已完成 |
| CANCELLED | 已取消 |

### 8.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| PENDING | 发货 | SHIPPED | - |
| PENDING | 取消 | CANCELLED | - |
| SHIPPED | 确认收货 | COMPLETED | - |

---

## 9. 数据设计

### 9.1 涉及表

- `io_pick_order_transfer`

### 9.2 关键字段

| 表名 | 字段 | 说明 |
|---|---|---|
| io_pick_order_transfer | id | 主键 |
| io_pick_order_transfer | pick_no | 提货单号 |
| io_pick_order_transfer | transfer_order_no | 调拨单号 |
| io_pick_order_transfer | status | 状态 |

---

## 10. API / 接口契约

### 10.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0240 |
| CRUD 前缀 | `/api/pickup/transfer` |
| 列表字段 | pickNo, transferOrderNo, status, createdAt |
| 搜索字段 | pickNo, transferOrderNo, status |

### 10.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/pickup/transfer/list` | 调拨提货单列表 |
| POST | `/api/pickup/transfer/{id}/ship` | 发货确认 |
| POST | `/api/pickup/transfer/{id}/cancel` | 取消提货单 |

---

## 11. 权限与审计

### 11.1 权限标识

- `wms:pick:transfer:query`
- `wms:pick:transfer:ship`
- `wms:pick:transfer:cancel`

---

## 12. 验收标准

### 12.1 功能验收

- [ ] 提货单列表正常
- [ ] 发货确认正常
- [ ] 取消功能正常
- [ ] 状态流转正确

---

## 13. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 14. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0240 调拨提货单
- Epic Brief：[epic-07-overview.md](../../epics/epic-07-overview.md)
