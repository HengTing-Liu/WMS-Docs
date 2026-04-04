# Story 03-03 调拨入库管理

## 0. 基本信息

- Epic：入库管理
- Story ID：03-03
- 优先级：P0
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 2

---

## 1. 目标

实现调拨入库确认能力，支持从调拨出库单同步生成的入库单确认。

---

## 2. 业务背景

调拨入库是调拨流程的入库环节，接收从其他仓库调入的物料。

---

## 3. 范围

### 3.1 本 Story 包含

- 调拨入库单列表查询
- 调拨入库确认
- 调拨入库导出

### 3.2 本 Story 不包含

- 调拨入库新建（由调拨出库自动生成）
- ERP 同步

---

## 4. 参与角色

- 仓库管理员：确认调拨入库

---

## 5. 前置条件

- 调拨出库单已出库
- 用户具备调拨入库权限

---

## 6. 触发方式

- 页面入口：入库管理 → 调拨入库
- 接口入口：GET `/api/inbound/transfer/list`

---

## 7. 输入 / 输出

### 7.1 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| transferOrderNo | string | Y | 调拨单号 |
| warehouseCode | string | Y | 仓库编码 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 入库单ID |
| inboundNo | string | 入库单号 |
| status | string | 状态 |

---

## 8. 状态流转

### 8.1 主体对象

- 对象名称：调拨入库单

### 8.2 状态定义

| 状态 | 说明 |
|---|---|
| PENDING | 待接收 |
| IN_PROGRESS | 接收中 |
| COMPLETED | 已完成 |

### 8.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| PENDING | 确认接收 | COMPLETED | - |

---

## 9. 业务规则

1. **入库单号生成**：`INB-TRANS-{yyyyMMdd}-{6位序号}`
2. **关联调拨出库**：入库单关联调拨出库单
3. **库存增加**：入库确认后增加库存
4. **流水生成**：入库确认后生成库存变更流水

---

## 10. 数据设计

### 10.1 涉及表

- `io_inventory_account`（io_type='INBOUND', biz_type='TRANSFER'）
- `io_inventory_item`
- `inv_inventory`
- `inv_inventory_change`

---

## 11. API / 接口契约

### 11.1 Schema 配置

- 表编码：WMS0110
- CRUD前缀：`/api/inbound/transfer`

### 11.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/inbound/transfer/list` | 调拨入库单列表 |
| POST | `/api/inbound/transfer/{id}/confirm` | 确认入库 |
| GET | `/api/inbound/transfer/export` | 导出 |

### 12. 权限与审计

### 12.1 权限标识

- `wms:inbound:transfer:query`
- `wms:inbound:transfer:confirm`

---

## 13. 技术实现约束

- 入库确认必须保证库存一致性
- 使用乐观锁保障并发安全

---

## 14. 验收标准

### 14.1 功能验收

- [ ] 调拨入库单查询正常
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

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0110 调拨入库
- Epic Brief：[epic-03-overview.md](../../epics/epic-03-overview.md)
