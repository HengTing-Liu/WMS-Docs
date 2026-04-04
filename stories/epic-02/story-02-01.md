# Story 02-01 物料库存查询

## 0. 基本信息

- Epic：库存查询
- Story ID：02-01
- 优先级：P0
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 1

---

## 1. 目标

实现物料库存查询能力，支持按物料、批次、仓库筛选，查看库存分布和预警信息。

---

## 2. 业务背景

物料库存查询是仓储业务的核心视图，为仓库管理员提供库存信息的实时查询能力，支持库存监控和追溯。

---

## 3. 范围

### 3.1 本 Story 包含

- 物料库存分页列表查询
- 按物料/批次/仓库筛选
- 库存预警标识
- 物料库存导出

### 3.2 本 Story 不包含

- 库位库存查询（见 Story 02-02）
- 库存调整
- 库存预警设置

---

## 4. 参与角色

- 仓库管理员：查询物料库存
- 系统管理员：查询所有库存

---

## 5. 前置条件

- 物料档案已存在
- 用户具备库存查询权限（`wms:inventory:query`）
- 用户有仓库数据权限

---

## 6. 触发方式

- 页面入口：库存管理 → 库存查询 → 物料库存
- 接口入口：GET `/api/inventory/material/list`

---

## 7. 输入 / 输出

### 7.1 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| page | int | N | 页码，默认 1 |
| pageSize | int | N | 每页条数，默认 20 |
| materialCode | string | N | 物料编码（模糊搜索） |
| materialName | string | N | 物料名称（模糊搜索） |
| batchNo | string | N | 批次号（模糊搜索） |
| warehouseCode | string | N | 仓库编码 |
| warehouseName | string | N | 仓库名称（模糊搜索） |
| warningFlag | boolean | N | 是否预警（true-仅显示预警） |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| total | int | 总记录数 |
| records | array | 库存列表 |
| records[].materialCode | string | 物料编码 |
| records[].materialName | string | 物料名称 |
| records[].spec | string | 规格 |
| records[].unit | string | 单位 |
| records[].batchNo | string | 批次号 |
| records[].warehouseCode | string | 仓库编码 |
| records[].warehouseName | string | 仓库名称 |
| records[].quantity | int | 现有库存数量 |
| records[].frozenQuantity | int | 冻结库存数量 |
| records[].availableQuantity | int | 可用库存数量 |
| records[].produceDate | date | 生产日期 |
| records[].expireDate | date | 失效日期 |
| records[].warningFlag | boolean | 是否预警（可用<最低库存） |
| records[].warningType | string | 预警类型：LOW_STOCK/EXPIRING/EXPIRED |

---

## 8. 页面/交互要求

### 8.1 页面

- 页面名称：物料库存查询页
- 页面类型：列表页
- 菜单路径：库存管理 → 库存查询 → 物料库存

### 8.2 交互要求

- 输入搜索条件，点击【查询】
- 点击【重置】清空条件
- 点击【导出】下载 Excel
- 点击列表行，展开查看库位分布

### 8.3 展示字段

| 字段 | 说明 |
|---|---|
| 物料编码 | - |
| 物料名称 | - |
| 批次号 | - |
| 仓库 | - |
| 现有库存 | - |
| 冻结库存 | 显示数量 |
| 可用库存 | 重点关注，红色预警 |
| 生产日期 | - |
| 失效日期 | 临期标黄 |
| 预警 | 红色：库存不足；黄色：临期 |

---

## 9. 业务规则

1. **可用库存 = 现有库存 - 冻结库存**
2. **库存预警**：可用库存 < 最低库存时标记预警
3. **效期预警**：失效日期 <= 30天标记临期预警
4. **数据权限**：仅显示用户有权限的仓库库存
5. **排序**：默认按可用库存升序（库存不足优先显示）

---

## 10. 状态流转

无（纯查询 Story）

---

## 11. 数据设计

### 11.1 涉及表

- `inv_inventory`
- `material`
- `batch`
- `sys_warehouse`

### 11.2 关键字段

| 表名 | 字段 | 说明 |
|---|---|---|
| inv_inventory | id | 主键 |
| inv_inventory | warehouse_code | 仓库编码 |
| inv_inventory | location_id | 库位ID |
| inv_inventory | material_id | 物料ID |
| inv_inventory | batch_id | 批次ID |
| inv_inventory | quantity | 现有库存 |
| inv_inventory | frozen_quantity | 冻结库存 |
| inv_inventory | available_quantity | 可用库存（计算字段） |

### 11.3 数据变更说明

- 无数据变更（纯查询 Story）

---

## 12. API / 接口契约

### 12.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0050 |
| CRUD 前缀 | `/api/inventory/material` |

### 12.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/inventory/material/list` | 物料库存分页查询 |
| GET | `/api/inventory/material/{id}` | 物料库存详情 |
| GET | `/api/inventory/material/export` | 物料库存导出 |

### 12.2 请求示例

```json
GET /api/inventory/material/list?warehouseCode=WH001&warningFlag=true
```

### 12.3 响应示例

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 100,
    "records": [
      {
        "materialCode": "MAT001",
        "materialName": "一次性注射器",
        "spec": "5ml",
        "unit": "支",
        "batchNo": "BATCH20260401",
        "warehouseCode": "WH001",
        "warehouseName": "上海仓",
        "quantity": 1000,
        "frozenQuantity": 100,
        "availableQuantity": 900,
        "produceDate": "2026-04-01",
        "expireDate": "2028-04-01",
        "warningFlag": false,
        "warningType": null
      }
    ]
  }
}
```

---

## 13. 权限与审计

### 13.1 权限标识

- `wms:inventory:query`
- `wms:inventory:export`

### 13.2 权限要求

- 谁可以查看：有仓库权限的用户
- 数据权限：仓库级过滤

### 13.3 审计要求

- 记录查询日志

---

## 14. 异常与边界场景

| 场景 | 预期处理 |
|---|---|
| 查询无数据 | 返回空列表 |
| 仓库无权限 | 返回空列表 |
| 分页越界 | 自动调整 |

---

## 15. 验收标准

### 15.1 功能验收

- [ ] 物料编码模糊搜索正确
- [ ] 仓库筛选正确
- [ ] 可用库存计算正确
- [ ] 预警标识正确
- [ ] 数据权限过滤正确
- [ ] 导出正常

### 15.2 性能验收

- [ ] 10000 条数据查询 < 1s

---

## 16. 测试要点

### 16.1 单元测试

- 可用库存计算正确
- 预警标识判断正确

### 16.2 集成测试

- 数据权限过滤正确
- 性能测试（10000 条）

---

## 17. 技术实现约束

- 查询必须走索引（warehouse_code, material_id, batch_id）
- 禁止 SELECT *，必须指定字段
- 导出使用异步方式

---

## 18. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 19. 完成定义（DoD）

- [ ] 功能开发完成
- [ ] 自测通过
- [ ] 联调通过
- [ ] 验收标准全部满足
- [ ] 无阻塞性缺陷
- [ ] 文档已更新
- [ ] 可提交评审/上线

---

## 20. 风险与待确认项

**风险**

- 大数据量查询性能

**待确认**

- 库存预警的最低库存阈值配置方式

---

## 21. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0050 查询物料
- 数据库设计：[WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md)
- Epic Brief：[epic-02-overview.md](../../epics/epic-02-overview.md)
