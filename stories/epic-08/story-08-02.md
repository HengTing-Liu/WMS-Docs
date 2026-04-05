# Story 08-02 出库单

## 0. 基本信息

- Epic：出库单管理
- Story ID：08-02
- 优先级：P1
- 状态：Draft
- 预计工期：1.5d
- 依赖 Story：08-01（出库准备）
- 关联迭代：Sprint 4

---

## 1. 目标

实现出库单管理，支持出库单明细查看、拆分、取消。

---

## 2. 业务背景

出库单是具体的出库执行单据，包含拣货任务和出库明细。

---

## 3. 范围

### 3.1 本 Story 包含

- 出库单列表查询
- 出库单详情
- 出库单拆分
- 出库单取消

### 3.2 本 Story 不包含

- 出库确认

---

## 4. 参与角色

- 仓库管理员：管理出库单

---

## 5. 前置条件

- 出库准备已完成

---

## 6. 触发方式

- 页面入口：出库管理 → 出库单
- 接口入口：`GET /api/outbound/order/list`

---

## 7. 输入 / 输出

### 7.1 拆分 - 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| outboundOrderId | long | Y | 出库单ID |
| splitItems | array | Y | 拆分明细 |
| splitItems[].originalItemId | long | Y | 原明细ID |
| splitItems[].splitQuantity | int | Y | 拆分数量 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 出库单ID |
| outboundNo | string | 出库单号 |
| status | string | 状态 |

---

## 8. 状态流转

### 8.1 主体对象

- 对象名称：出库单

### 8.2 状态定义

| 状态 | 说明 |
|---|---|
| PENDING | 待出库 |
| PICKING | 拣货中 |
| PICKED | 已拣货 |
| SHIPPED | 已发货 |
| COMPLETED | 已完成 |
| CANCELLED | 已取消 |

### 8.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| PENDING | 开始拣货 | PICKING | - |
| PICKING | 完成拣货 | PICKED | - |
| PICKED | 确认发货 | SHIPPED | - |
| SHIPPED | 确认签收 | COMPLETED | - |
| PENDING | 取消 | CANCELLED | - |

---

## 9. 业务规则

1. **出库单号生成**：`OUT-{yyyyMMdd}-{6位序号}`
2. **拆分规则**：
   - 拆分数量必须小于原数量
   - 拆分后原单数量减少
   - 生成新出库单

---

## 10. 数据设计

### 10.1 涉及表

- `io_outbound`
- `io_outbound_item`

---

## 11. API / 接口契约

### 11.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0300 |
| CRUD 前缀 | `/api/outbound/order` |
| 列表字段 | outboundNo, prepareNo, customerName, status, warehouseCode, createdAt |
| 搜索字段 | outboundNo, prepareNo, status, warehouseCode |

### 11.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/outbound/order/list` | 出库单列表 |
| GET | `/api/outbound/order/{id}` | 出库单详情 |
| POST | `/api/outbound/order/{id}/split` | 拆分出库单 |
| POST | `/api/outbound/order/{id}/cancel` | 取消出库单 |
| GET | `/api/outbound/order/export` | 导出 |

---

## 12. 权限与审计

### 12.1 权限标识

- `wms:outbound:order:query`
- `wms:outbound:order:split`
- `wms:outbound:order:cancel`

---

## 13. 验收标准

### 13.1 功能验收

- [ ] 出库单列表正常
- [ ] 出库单详情正常
- [ ] 拆分功能正常
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

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0300 出库单
- Epic Brief：[epic-08-overview.md](../../epics/epic-08-overview.md)
