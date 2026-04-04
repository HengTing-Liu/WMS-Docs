# Story 03-05 领用退回入库

## 0. 基本信息

- Epic：入库管理
- Story ID：03-05
- 优先级：P0
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 2

---

## 1. 目标

实现领用退回入库管理，支持退回申请创建、确认入库。

---

## 2. 业务背景

领用退回是企业内部领用物料后的退回流程，处理领用物料的退货入库操作。

---

## 3. 范围

### 3.1 本 Story 包含

- 领用退回列表查询
- 领用退回新建
- 领用退回确认入库

### 3.2 本 Story 不包含

- 领用出库关联

---

## 4. 参与角色

- 仓库管理员：确认退回入库

---

## 5. 前置条件

- 仓库档案已存在
- 用户具备领用退回入库权限

---

## 6. 触发方式

- 页面入口：入库管理 → 领用退回入库
- 接口入口：GET `/api/inbound/return-use/list`

---

## 7. 输入 / 输出

### 7.1 新增输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| consumeOrderNo | string | Y | 原领用单号 |
| deptCode | string | Y | 部门编码 |
| deptName | string | Y | 部门名称 |
| warehouseCode | string | Y | 仓库编码 |
| items | array | Y | 物料明细 |
| items[].materialCode | string | Y | 物料编码 |
| items[].batchNo | string | Y | 批次号 |
| items[].returnQuantity | int | Y | 退回数量 |
| items[].returnReason | string | N | 退回原因 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 退回单ID |
| returnNo | string | 退回单号 |
| status | string | 状态 |

---

## 8. 状态流转

### 8.1 主体对象

- 对象名称：领用退回入库单

### 8.2 状态定义

| 状态 | 说明 |
|---|---|
| PENDING | 待入库 |
| IN_PROGRESS | 入库中 |
| COMPLETED | 已完成 |

### 8.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| PENDING | 确认入库 | COMPLETED | - |

---

## 9. 业务规则

1. **退回单号生成**：`INB-RET-CONSUME-{yyyyMMdd}-{6位序号}`
2. **批次校验**：必须指定原批次
3. **数量校验**：退回数量不超过原领用数量
4. **库存增加**：入库确认后增加库存
5. **流水生成**：入库确认后生成库存变更流水

---

## 10. 数据设计

### 10.1 涉及表

- `io_inventory_account`（io_type='INBOUND', biz_type='CONSUME_RETURN'）
- `io_inventory_item`
- `inv_inventory`
- `inv_inventory_change`

---

## 11. API / 接口契约

### 11.1 Schema 配置

- 表编码：WMS0130
- CRUD前缀：`/api/inbound/return-use`

### 11.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/inbound/return-use/list` | 领用退回列表 |
| POST | `/api/inbound/return-use` | 新建领用退回 |
| POST | `/api/inbound/return-use/{id}/confirm` | 确认入库 |

### 12. 权限与审计

### 12.1 权限标识

- `wms:inbound:consumeReturn:query`
- `wms:inbound:consumeReturn:add`
- `wms:inbound:consumeReturn:confirm`

---

## 13. 技术实现约束

- 入库确认必须保证库存一致性
- 使用乐观锁保障并发安全

---

## 14. 验收标准

### 14.1 功能验收

- [ ] 退回单新建成功
- [ ] 确认入库库存增加正确
- [ ] 流水生成正确

---

## 15. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 16. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0130 领用出库退回
- Epic Brief：[epic-03-overview.md](../../epics/epic-03-overview.md)
