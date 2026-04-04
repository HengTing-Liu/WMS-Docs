# Story 02-02 库位库存查询

## 0. 基本信息

- Epic：库存查询
- Story ID：02-02
- 优先级：P0
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 1

---

## 1. 目标

实现库位库存查询能力，支持查看库位当前存储的物料、批次和数量。

---

## 2. 业务背景

库位库存查询帮助仓库管理员了解库位使用情况，支持库位状态监控和优化。

---

## 3. 范围

### 3.1 本 Story 包含

- 库位库存分页查询
- 按仓库/库位筛选
- 库位状态看板

### 3.2 本 Story 不包含

- 物料库存查询（见 Story 02-01）
- 库位使用率统计

---

## 4. 参与角色

- 仓库管理员：查询库位库存
- 系统管理员：查询所有库位库存

---

## 5. 前置条件

- 库位档案已存在
- 用户具备库位查询权限

---

## 6. 触发方式

- 页面入口：库存管理 → 库存查询 → 库位库存
- 接口入口：GET `/api/inventory/location/list`

---

## 7. 输入 / 输出

### 7.1 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| page | int | N | 页码 |
| pageSize | int | N | 每页条数 |
| warehouseId | long | N | 仓库ID |
| locationCode | string | N | 库位编码（模糊搜索） |
| status | string | N | 状态：IDLE/OCCUPIED/FROZEN |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| total | int | 总记录数 |
| records | array | 库位库存列表 |
| records[].locationId | long | 库位ID |
| records[].locationCode | string | 库位编码 |
| records[].locationName | string | 库位名称 |
| records[].locationType | string | 库位类型 |
| records[].warehouseCode | string | 仓库编码 |
| records[].warehouseName | string | 仓库名称 |
| records[].status | string | 状态：空闲/占用/冻结 |
| records[].materialCode | string | 物料编码 |
| records[].materialName | string | 物料名称 |
| records[].batchNo | string | 批次号 |
| records[].quantity | int | 库存数量 |

---

## 8. 页面/交互要求

### 8.1 页面

- 页面名称：库位库存查询页
- 页面类型：列表页
- 菜单路径：库存管理 → 库存查询 → 库位库存

### 8.2 交互要求

- 选择仓库，筛选库位
- 点击【查询】刷新列表
- 点击【导出】下载 Excel

### 8.3 展示字段

| 字段 | 说明 |
|---|---|
| 库位编码 | - |
| 库位名称 | - |
| 库位类型 | - |
| 仓库 | - |
| 状态 | 空闲(绿)/占用(蓝)/冻结(黄) |
| 物料编码 | 占用时显示 |
| 物料名称 | 占用时显示 |
| 批次号 | 占用时显示 |
| 库存数量 | 占用时显示 |

---

## 9. 业务规则

1. **状态颜色**：空闲-绿色，占用-蓝色，冻结-黄色
2. **数据权限**：仅显示用户有权限的仓库库位
3. **占用时显示**：只有 OCCUPIED 状态的库位才显示物料信息

---

## 10. 验收标准

### 10.1 功能验收

- [ ] 库位查询正确
- [ ] 状态筛选正确
- [ ] 数据权限过滤正确
- [ ] 占用库位显示物料信息正确
- [ ] 导出正常

---

## 11. 数据设计

### 11.1 涉及表

- `wms_location`
- `inv_inventory`
- `material`
- `batch`

---

## 12. API / 接口契约

### 12.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0060 |
| CRUD 前缀 | `/api/inventory/location` |

### 12.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/inventory/location/list` | 库位库存分页查询 |
| GET | `/api/inventory/location/{id}` | 库位库存详情 |
| GET | `/api/inventory/location/export` | 库位库存导出 |

---

## 13. 权限与审计

### 13.1 权限标识

- `wms:location:viewInventory`

### 13.2 权限要求

- 谁可以查看：有仓库权限的用户

---

## 14. 测试要点

### 14.1 性能测试

- 10000 节点库位查询 < 1s

---

## 15. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 16. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0060 查询库位
- Epic Brief：[epic-02-overview.md](../../epics/epic-02-overview.md)
