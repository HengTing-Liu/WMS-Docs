# Story 07-06 紧急提货单

## 0. 基本信息

- Epic：提货单管理
- Story ID：07-06
- 优先级：P1
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 4

---

## 1. 目标

实现紧急提货单管理，支持优先处理的紧急提货。

---

## 2. 业务背景

紧急提货单用于处理客户紧急需求的特殊单据，需要优先处理。

---

## 3. 范围

### 3.1 本 Story 包含

- 紧急提货单列表查询
- 紧急提货单新建
- 紧急提货单发货确认
- 紧急提货单取消

### 3.2 本 Story 不包含

- 紧急审批流程

---

## 4. 参与角色

- 仓库管理员：管理紧急提货单

---

## 5. 前置条件

- 仓库档案已存在
- 用户具备紧急提货单权限

---

## 6. 触发方式

- 页面入口：提货单管理 → 紧急提货单
- 接口入口：`GET /api/pickup/urgent/list`

---

## 7. 输入 / 输出

### 7.1 新增输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| urgentLevel | string | Y | 紧急级别：URGENT/HIGH |
| salesOrderNo | string | Y | 销售订单号 |
| customerName | string | Y | 客户名称 |
| outWarehouseCode | string | Y | 发货仓库编码 |
| consignee | string | Y | 收货人 |
| phone | string | Y | 联系电话 |
| address | string | Y | 收货地址 |
| remark | string | N | 紧急原因 |
| items | array | Y | 物料明细 |
| items[].materialCode | string | Y | 物料编码 |
| items[].planQuantity | int | Y | 计划数量 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 提货单ID |
| pickNo | string | 提货单号 |
| status | string | 状态 |

---

## 8. 状态流转

### 8.1 主体对象

- 对象名称：紧急提货单

### 8.2 状态定义

| 状态 | 说明 |
|---|---|
| PENDING | 待处理 |
| SHIPPED | 已发货 |
| COMPLETED | 已完成 |
| CANCELLED | 已取消 |

### 8.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| PENDING | 发货 | SHIPPED | 优先处理 |
| PENDING | 取消 | CANCELLED | - |
| SHIPPED | 确认签收 | COMPLETED | - |

---

## 9. 业务规则

1. **提货单号生成**：`PICK-URGENT-{yyyyMMdd}-{6位序号}`
2. **优先展示**：紧急提货单在列表中置顶显示
3. **快速发货**：紧急提货单快速处理流程

---

## 10. 数据设计

### 10.1 涉及表

- `io_pick_order_urgent`

### 10.2 关键字段

| 表名 | 字段 | 说明 |
|---|---|---|
| io_pick_order_urgent | id | 主键 |
| io_pick_order_urgent | pick_no | 提货单号 |
| io_pick_order_urgent | urgent_level | 紧急级别 |
| io_pick_order_urgent | status | 状态 |

---

## 11. API / 接口契约

### 11.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0280 |
| CRUD 前缀 | `/api/pickup/urgent` |
| 列表字段 | pickNo, urgentLevel, customerName, status, outWarehouseCode, createdAt |
| 搜索字段 | pickNo, urgentLevel, customerName, status |

### 11.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/pickup/urgent/list` | 紧急提货单列表 |
| POST | `/api/pickup/urgent` | 新建紧急提货单 |
| POST | `/api/pickup/urgent/{id}/ship` | 发货确认 |
| POST | `/api/pickup/urgent/{id}/cancel` | 取消提货单 |

---

## 12. 权限与审计

### 12.1 权限标识

- `wms:pick:urgent:query`
- `wms:pick:urgent:add`
- `wms:pick:urgent:ship`
- `wms:pick:urgent:cancel`

---

## 13. 验收标准

### 13.1 功能验收

- [ ] 紧急提货单新建成功
- [ ] 列表置顶显示
- [ ] 发货确认正常
- [ ] 取消功能正常
- [ ] 状态流转正确

---

## 14. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 15. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0280 紧急提货单
- Epic Brief：[epic-07-overview.md](../../epics/epic-07-overview.md)
