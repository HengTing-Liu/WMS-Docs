# Story 08-01 出库准备

## 0. 基本信息

- Epic：出库单管理
- Story ID：08-01
- 优先级：P1
- 状态：Draft
- 预计工期：1d
- 依赖 Story：07-01（销售提货单）
- 关联迭代：Sprint 4

---

## 1. 目标

实现出库准备管理，支持从提货单生成出库任务、库位分配、标签打印。

---

## 2. 业务背景

出库准备是出库流程的准备阶段，将提货单拆分为出库任务，分配库位，准备拣货。

---

## 3. 范围

### 3.1 本 Story 包含

- 出库准备列表查询
- 从提货单生成出库任务
- 库位分配
- 标签打印

### 3.2 本 Story 不包含

- 拣货确认（见 Story 08-02）
- 出库确认

---

## 4. 参与角色

- 仓库管理员：管理出库准备
- 标签打印员：打印标签

---

## 5. 前置条件

- 提货单已生成
- 用户具备出库准备权限

---

## 6. 触发方式

- 页面入口：出库管理 → 出库准备
- 接口入口：`GET /api/outbound/prepare/list`

---

## 7. 输入 / 输出

### 7.1 生成出库任务 - 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| pickOrderIds | array | Y | 提货单ID列表 |

### 7.2 库位分配 - 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| prepareId | long | Y | 出库准备ID |

### 7.3 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 出库准备ID |
| prepareNo | string | 出库准备单号 |
| status | string | 状态 |

---

## 8. 状态流转

### 8.1 主体对象

- 对象名称：出库准备

### 8.2 状态定义

| 状态 | 说明 |
|---|---|
| PENDING | 待分配 |
| ALLOCATED | 已分配库位 |
| PRINTED | 已打印 |
| CANCELLED | 已取消 |

### 8.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| PENDING | 分配库位 | ALLOCATED | - |
| PENDING | 取消 | CANCELLED | - |
| ALLOCATED | 打印标签 | PRINTED | - |
| ALLOCATED | 取消 | CANCELLED | - |

---

## 9. 业务规则

1. **出库准备单号生成**：`PRE-{yyyyMMdd}-{6位序号}`
2. **库位分配**：
   - 按 FEFO 原则分配
   - 支持手动调整
3. **标签打印**：
   - 物料标签：ZPL 格式
   - 说明书：PDF 格式
   - 发货清单：Excel 格式

---

## 10. 数据设计

### 10.1 涉及表

- `io_outbound_prepare`
- `io_outbound_prepare_item`
- `io_location_selection`

---

## 11. API / 接口契约

### 11.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0290 |
| CRUD 前缀 | `/api/outbound/prepare` |
| 列表字段 | prepareNo, status, pickOrderCount, createdAt |
| 搜索字段 | prepareNo, status |

### 11.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/outbound/prepare/list` | 出库准备列表 |
| POST | `/api/outbound/prepare/generate` | 生成出库任务 |
| POST | `/api/outbound/prepare/{id}/allocate` | 库位分配 |
| POST | `/api/outbound/prepare/{id}/print` | 标签打印 |
| POST | `/api/outbound/prepare/{id}/cancel` | 取消 |

---

## 12. 权限与审计

### 12.1 权限标识

- `wms:outbound:prepare:query`
- `wms:outbound:prepare:generate`
- `wms:outbound:prepare:allocate`
- `wms:outbound:prepare:print`

---

## 13. 验收标准

### 13.1 功能验收

- [ ] 出库任务生成正常
- [ ] 库位分配正确
- [ ] 标签打印正常
- [ ] 状态流转正确

---

## 14. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 15. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0290 出库准备
- Epic Brief：[epic-08-overview.md](../../epics/epic-08-overview.md)
