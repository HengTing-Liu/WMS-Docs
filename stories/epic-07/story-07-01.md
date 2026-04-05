# Story 07-01 销售提货单

## 0. 基本信息

- Epic：提货单管理
- Story ID：07-01
- 优先级：P1
- 状态：Draft
- 预计工期：1d
- 依赖 Story：无
- 关联迭代：Sprint 4

---

## 1. 目标

实现销售提货单管理，支持新建、合并生成出库单、详情查看、取消。

---

## 2. 业务背景

销售提货单是销售出库的物流单据，包含客户信息、收货地址、发货要求，驱动后续出库流程。

---

## 3. 范围

### 3.1 本 Story 包含

- 销售提货单列表查询
- 销售提货单新建
- 提货单合并生成出库单
- 提货单详情查看
- 提货单取消

### 3.2 本 Story 不包含

- ERP 同步
- 物流跟踪

---

## 4. 参与角色

- 仓库管理员：管理提货单

---

## 5. 前置条件

- 仓库档案已存在
- 用户具备提货单权限

---

## 6. 触发方式

- 页面入口：提货单管理 → 销售提货单
- 接口入口：`GET /api/pickup/sale/list`

---

## 7. 输入 / 输出

### 7.1 新增输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| salesOrderNo | string | Y | 销售订单号 |
| customerId | long | Y | 客户ID |
| customerName | string | Y | 客户名称 |
| orderOrgCode | string | Y | 订单机构编码 |
| salesDeptCode | string | Y | 销售部门编码 |
| outCompanyCode | string | Y | 发货公司编码 |
| outWarehouseCode | string | Y | 发货仓库编码 |
| invoiceCompany | string | Y | 开票公司 |
| settlementCurrency | string | Y | 结算货币 |
| deliveryType | string | Y | 发货类型：EXPRESS/PICKUP |
| consignee | string | Y | 收货人 |
| phone | string | Y | 联系电话 |
| address | string | Y | 收货地址 |
| items | array | Y | 物料明细 |
| items[].materialCode | string | Y | 物料编码 |
| items[].batchNo | string | N | 批次号 |
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

- 对象名称：销售提货单

### 8.2 状态定义

| 状态 | 说明 |
|---|---|
| PENDING | 待合并 |
| PREPARING | 准备中 |
| READY | 已生成出库单 |
| PICKED | 已拣货 |
| SHIPPED | 已发货 |
| COMPLETED | 已完成 |
| CANCELLED | 已取消 |

### 8.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| PENDING | 合并 | READY | 生成出库单 |
| PENDING | 取消 | CANCELLED | - |
| READY | 拣货完成 | PICKED | - |
| PICKED | 发货 | SHIPPED | - |
| SHIPPED | 确认签收 | COMPLETED | - |

---

## 9. 业务规则

1. **提货单单号生成**：`PICK-SALES-{yyyyMMdd}-{6位序号}`
2. **合并规则**：以下字段全部相同才可合并：
   - customerId、orderOrgCode、deliveryType、salesDeptCode
   - invoiceCompany、settlementCurrency、outCompanyCode、outWarehouseCode
   - consignee、phone、address
3. **自动合并**：相同规则的提货单自动合并生成一个出库单
4. **取消条件**：未生成出库单的提货单可取消

---

## 10. 数据设计

### 10.1 涉及表

- `io_pick_order_sale`
- `io_pick_order_sale_item`

### 10.2 关键字段

| 表名 | 字段 | 说明 |
|---|---|---|
| io_pick_order_sale | id | 主键 |
| io_pick_order_sale | pick_no | 提货单号 |
| io_pick_order_sale | sales_order_no | 销售订单号 |
| io_pick_order_sale | customer_id | 客户ID |
| io_pick_order_sale | status | 状态 |
| io_pick_order_sale | out_warehouse_code | 发货仓库编码 |

---

## 11. API / 接口契约

### 11.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0230 |
| CRUD 前缀 | `/api/pickup/sale` |
| 列表字段 | pickNo, salesOrderNo, customerName, status, outWarehouseCode, createdAt |
| 搜索字段 | pickNo, salesOrderNo, customerId, status |

### 11.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/pickup/sale/list` | 销售提货单列表 |
| POST | `/api/pickup/sale` | 新建销售提货单 |
| POST | `/api/pickup/sale/merge` | 合并生成出库单 |
| POST | `/api/pickup/sale/{id}/cancel` | 取消提货单 |
| GET | `/api/pickup/sale/{id}` | 提货单详情 |

---

## 12. 权限与审计

### 12.1 权限标识

- `wms:pick:sale:query`
- `wms:pick:sale:add`
- `wms:pick:sale:merge`
- `wms:pick:sale:cancel`

---

## 13. 验收标准

### 13.1 功能验收

- [ ] 提货单新建成功
- [ ] 合并规则正确
- [ ] 合并生成出库单正常
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

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0230 销售提货单
- Epic Brief：[epic-07-overview.md](../../epics/epic-07-overview.md)
