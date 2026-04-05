# Story 05-03 库存报废

## 0. 基本信息

- Epic：库存调整
- Story ID：05-03
- 优先级：P1
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 3

---

## 1. 目标

实现库存报废管理，支持报废计划创建、审批、确认。

---

## 2. 业务背景

库存报废用于处理过期、损坏、变质等无法使用的物料，将其从可用库存中移除。

---

## 3. 范围

### 3.1 本 Story 包含

- 报废计划列表查询
- 报废计划新建
- 报废审批
- 报废确认

### 3.2 本 Story 不包含

- 报废原因配置
- ERP 同步

---

## 4. 参与角色

- 仓库管理员：创建/确认报废
- 审批人：审批报废

---

## 5. 前置条件

- 物料档案已存在
- 用户具备报废权限

---

## 6. 触发方式

- 页面入口：库存调整 → 库存报废
- 接口入口：GET `/api/adjust/scrap/list`

---

## 7. 输入 / 输出

### 7.1 新建输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| warehouseCode | string | Y | 仓库编码 |
| remark | string | N | 备注 |
| items | array | Y | 报废明细 |
| items[].materialCode | string | Y | 物料编码 |
| items[].batchNo | string | Y | 批次号 |
| items[].locationId | long | Y | 库位ID |
| items[].scrapQuantity | int | Y | 报废数量 |
| items[].scrapReason | string | Y | 报废原因 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 报废单ID |
| scrapNo | string | 报废单号 |
| status | string | 状态 |

---

## 8. 状态流转

### 8.1 主体对象

- 对象名称：报废单

### 8.2 状态定义

| 状态 | 说明 |
|---|---|
| PENDING | 待审批 |
| APPROVED | 已审批 |
| COMPLETED | 已完成 |
| REJECTED | 已驳回 |

### 8.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| PENDING | 审批通过 | APPROVED | - |
| PENDING | 审批驳回 | REJECTED | - |
| APPROVED | 确认报废 | COMPLETED | - |

---

## 9. 业务规则

1. **报废单号生成**：`SCRAP-{yyyyMMdd}-{6位序号}`
2. **报废确认时**：
   - 扣减库存
   - 转移至报废隔离库位（如有配置）
   - 生成库存变更流水（类型：SCRAP）
3. **报废审批**：高价值物料报废需多级审批
4. **ERP 同步**：报废完成后同步 ERP

---

## 10. 数据设计

### 10.1 涉及表

- `st_scrap`（报废表）
- `inv_inventory`（库存表）
- `inv_inventory_change`（变更流水）

### 10.2 关键字段

| 表名 | 字段 | 说明 |
|---|---|---|
| st_scrap | id | 主键 |
| st_scrap | scrap_no | 报废单号 |
| st_scrap | warehouse_code | 仓库编码 |
| st_scrap | status | 状态 |
| st_scrap | material_code | 物料编码 |
| st_scrap | batch_no | 批次号 |
| st_scrap | location_id | 库位ID |
| st_scrap | scrap_quantity | 报废数量 |
| st_scrap | scrap_reason | 报废原因 |

---

## 11. API / 接口契约

### 11.1 Schema 配置

- 表编码：WMS0200
- CRUD 前缀：`/api/adjust/scrap`

### 11.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/adjust/scrap/list` | 报废列表 |
| POST | `/api/adjust/scrap` | 新建报废 |
| POST | `/api/adjust/scrap/{id}/approve` | 审批报废 |
| POST | `/api/adjust/scrap/{id}/confirm` | 确认报废 |
| POST | `/api/adjust/scrap/{id}/reject` | 驳回报废 |

### 11.3 请求示例

```json
POST /api/adjust/scrap
{
  "warehouseCode": "WH001",
  "remark": "过期物料",
  "items": [
    {
      "materialCode": "MAT001",
      "batchNo": "BATCH001",
      "locationId": 1,
      "scrapQuantity": 100,
      "scrapReason": "超过效期"
    }
  ]
}
```

---

## 12. 权限与审计

### 12.1 权限标识

- `wms:scrap:query`
- `wms:scrap:add`
- `wms:scrap:approve`
- `wms:scrap:confirm`

### 12.2 审计要求

- 记录报废操作人、操作时间
- 记录报废数量和原因

---

## 13. 验收标准

### 13.1 功能验收

- [ ] 新建报废单成功
- [ ] 审批流程正常
- [ ] 确认报废库存扣减正确
- [ ] 流水生成正确
- [ ] 状态流转正确

### 13.2 数据验收

- [ ] 库存扣减正确
- [ ] 无超报废

---

## 14. 测试要点

### 14.1 单元测试

- 报废数量校验正确
- 库存扣减正确

### 14.2 集成测试

- 报废全流程

---

## 15. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 16. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0200 库存报废
- Epic Brief：[epic-05-overview.md](../../epics/epic-05-overview.md)
