# Story 02-03 库存流水查询

## 0. 基本信息

- Epic：库存查询
- Story ID：02-03
- 优先级：P0
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 1

---

## 1. 目标

实现库存流水查询能力，支持按时间范围、变更类型、物料/仓库筛选，记录所有库存变更操作。

---

## 2. 业务背景

库存流水是库存变更的全量记录，支持库存追溯和问题排查。

---

## 3. 范围

### 3.1 本 Story 包含

- 库存流水分页查询
- 按时间范围、变更类型筛选
- 按物料/仓库/操作人筛选
- 流水导出

### 3.2 本 Story 不包含

- 库存追溯（详情页）
- 流水统计报表

---

## 4. 参与角色

- 仓库管理员：查询库存流水
- 财务人员：查询库存流水
- 系统管理员：查询所有流水

---

## 5. 前置条件

- 用户具备库存流水查询权限

---

## 6. 触发方式

- 页面入口：库存管理 → 库存查询 → 库存流水
- 接口入口：GET `/api/inventory/flow/list`

---

## 7. 输入 / 输出

### 7.1 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| page | int | N | 页码 |
| pageSize | int | N | 每页条数 |
| startTime | datetime | Y | 开始时间 |
| endTime | datetime | Y | 结束时间 |
| changeType | string | N | 变更类型 |
| materialCode | string | N | 物料编码 |
| warehouseCode | string | N | 仓库编码 |
| bizNo | string | N | 关联单据号 |
| operator | string | N | 操作人 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| total | int | 总记录数 |
| records | array | 流水列表 |
| records[].id | long | 流水ID |
| records[].changeTime | datetime | 变更时间 |
| records[].changeType | string | 变更类型 |
| records[].changeTypeName | string | 变更类型中文 |
| records[].materialCode | string | 物料编码 |
| records[].materialName | string | 物料名称 |
| records[].batchNo | string | 批次号 |
| records[].warehouseCode | string | 仓库编码 |
| records[].warehouseName | string | 仓库名称 |
| records[].locationCode | string | 库位编码 |
| records[].beforeQuantity | int | 变更前数量 |
| records[].changeQuantity | int | 变更数量（正/负） |
| records[].afterQuantity | int | 变更后数量 |
| records[].bizNo | string | 关联单据号 |
| records[].operator | string | 操作人 |
| records[].remark | string | 备注 |

---

## 8. 页面/交互要求

### 8.1 页面

- 页面名称：库存流水查询页
- 页面类型：列表页
- 菜单路径：库存管理 → 库存查询 → 库存流水

### 8.2 交互要求

- 选择时间范围（必填，默认近7天）
- 选择变更类型
- 点击【查询】
- 点击【导出】下载 Excel

### 8.3 展示字段

| 字段 | 说明 |
|---|---|
| 变更时间 | - |
| 变更类型 | 入库/出库/调拨/盘点调整/冻结/解冻 |
| 物料编码 | - |
| 物料名称 | - |
| 批次号 | - |
| 仓库 | - |
| 库位 | - |
| 变更前 | - |
| 变更量 | 正数绿色，负数红色 |
| 变更后 | - |
| 关联单据 | - |
| 操作人 | - |

---

## 9. 业务规则

1. **时间范围必填**：开始时间和结束时间必填
2. **时间范围限制**：最大查询范围 90 天
3. **变更类型**：INBOUND/OUTBOUND/TRANSFER/STOCKTAKE/QC_FREEZE/QC_UNFREEZE/ADJUST
4. **数据权限**：仅显示用户有权限的仓库流水

---

## 10. 验收标准

### 10.1 功能验收

- [ ] 时间范围查询正确
- [ ] 变更类型筛选正确
- [ ] 物料/仓库筛选正确
- [ ] 数据权限过滤正确
- [ ] 变更量正负显示正确
- [ ] 导出正常

---

## 11. 数据设计

### 11.1 涉及表

- `inv_inventory_change`

### 11.2 关键字段

| 表名 | 字段 | 说明 |
|---|---|---|
| inv_inventory_change | id | 主键 |
| inv_inventory_change | change_time | 变更时间 |
| inv_inventory_change | change_type | 变更类型 |
| inv_inventory_change | material_id | 物料ID |
| inv_inventory_change | batch_id | 批次ID |
| inv_inventory_change | warehouse_code | 仓库编码 |
| inv_inventory_change | location_id | 库位ID |
| inv_inventory_change | before_quantity | 变更前数量 |
| inv_inventory_change | change_quantity | 变更数量 |
| inv_inventory_change | after_quantity | 变更后数量 |
| inv_inventory_change | biz_no | 关联单据号 |
| inv_inventory_change | operator | 操作人 |

---

## 12. API / 接口契约

### 12.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0070 |
| CRUD 前缀 | `/api/inventory/flow` |

### 12.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/inventory/flow/list` | 库存流水分页查询 |
| GET | `/api/inventory/flow/{id}` | 库存流水详情 |
| GET | `/api/inventory/flow/export` | 库存流水导出 |

---

## 13. 权限与审计

### 13.1 权限标识

- `wms:inventoryChange:query`
- `wms:inventoryChange:export`

### 13.2 权限要求

- 谁可以查看：有仓库权限的用户

---

## 14. 测试要点

### 14.1 性能测试

- 100000 条流水查询 < 1s

---

## 15. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 16. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0070 查询流水
- Epic Brief：[epic-02-overview.md](../../epics/epic-02-overview.md)
