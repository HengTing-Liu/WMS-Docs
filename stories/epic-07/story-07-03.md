# Story 07-03 领用提货单

## 0. 基本信息

- Epic：提货单管理
- Story ID：07-03
- 优先级：P1
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 4

---

## 1. 目标

实现领用提货单管理，支持从领用出库自动生成提货单。

---

## 2. 业务背景

领用提货单是领用出库的物流单据，跟随领用出库单生成。

---

## 3. 范围

### 3.1 本 Story 包含

- 领用提货单列表查询
- 领用提货单发货确认
- 领用提货单取消

### 3.2 本 Story 不包含

- 新建（由领用出库自动生成）

---

## 4. 参与角色

- 仓库管理员：管理领用提货单

---

## 5. 前置条件

- 领用出库单已出库

---

## 6. 触发方式

- 页面入口：提货单管理 → 领用提货单
- 接口入口：`GET /api/pickup/use/list`

---

## 7. 状态流转

### 7.1 主体对象

- 对象名称：领用提货单

### 7.2 状态定义

| 状态 | 说明 |
|---|---|
| PENDING | 待发货 |
| SHIPPED | 已发货 |
| COMPLETED | 已完成 |
| CANCELLED | 已取消 |

---

## 8. 数据设计

### 8.1 涉及表

- `io_pick_order_consume`

---

## 9. API / 接口契约

### 9.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0250 |
| CRUD 前缀 | `/api/pickup/use` |
| 列表字段 | pickNo, consumeOrderNo, status, createdAt |
| 搜索字段 | pickNo, consumeOrderNo, status |

### 9.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/pickup/use/list` | 领用提货单列表 |
| POST | `/api/pickup/use/{id}/ship` | 发货确认 |
| POST | `/api/pickup/use/{id}/cancel` | 取消提货单 |

---

## 10. 权限与审计

### 10.1 权限标识

- `wms:pick:consume:query`
- `wms:pick:consume:ship`
- `wms:pick:consume:cancel`

---

## 11. 验收标准

### 11.1 功能验收

- [ ] 提货单列表正常
- [ ] 发货确认正常
- [ ] 取消功能正常
- [ ] 状态流转正确

---

## 12. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 13. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0250 领用提货单
- Epic Brief：[epic-07-overview.md](../../epics/epic-07-overview.md)
