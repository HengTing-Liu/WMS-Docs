# Story 05-02 库位调整

## 0. 基本信息

- Epic：库存调整
- Story ID：05-02
- 优先级：P1
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：01-03（库位查询）
- 关联迭代：Sprint 3

---

## 1. 目标

实现库位调整管理，支持调整单创建、执行调整。

---

## 2. 业务背景

库位调整用于处理物料实际存放位置与系统记录不一致的情况，如库位变更、整理归位等。

---

## 3. 范围

### 3.1 本 Story 包含

- 库位调整单列表查询
- 库位调整单新建
- 调整确认执行

### 3.2 本 Story 不包含

- 库位调整审批
- ERP 同步

---

## 4. 参与角色

- 仓库管理员：执行库位调整

---

## 5. 前置条件

- 库位档案已存在
- 用户具备库位调整权限

---

## 6. 触发方式

- 页面入口：库存调整 → 库位调整
- 接口入口：GET `/api/adjust/location/list`

---

## 7. 输入 / 输出

### 7.1 新建输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| warehouseCode | string | Y | 仓库编码 |
| deptCode | string | Y | 部门编码 |
| remark | string | N | 备注 |
| items | array | Y | 调整明细 |
| items[].materialCode | string | Y | 物料编码 |
| items[].batchNo | string | Y | 批次号 |
| items[].fromLocationId | long | Y | 源库位ID |
| items[].toLocationId | long | Y | 目标库位ID |
| items[].adjustQuantity | int | Y | 调整数量 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 调整单ID |
| adjustNo | string | 调整单号 |
| status | string | 状态 |

---

## 8. 状态流转

### 8.1 主体对象

- 对象名称：库位调整单

### 8.2 状态定义

| 状态 | 说明 |
|---|---|
| PENDING | 待执行 |
| COMPLETED | 已完成 |
| CANCELLED | 已取消 |

### 8.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| PENDING | 确认执行 | COMPLETED | - |
| PENDING | 取消 | CANCELLED | - |

---

## 9. 业务规则

1. **调整单号生成**：`ADJ-LOC-{yyyyMMdd}-{6位序号}`
2. **执行调整时**：
   - 冻结原库位和目标库位
   - 原库位库存减少
   - 目标库位库存增加
   - 生成库存变更流水（类型：LOCATION_TRANSFER）
3. **数量校验**：调整数量不超过原库位库存
4. **库位状态**：调整完成后更新库位状态

---

## 10. 数据设计

### 10.1 涉及表

- `adj_location`（库位调整表）
- `inv_inventory`（库存表）
- `inv_inventory_change`（变更流水）

### 10.2 关键字段

| 表名 | 字段 | 说明 |
|---|---|---|
| adj_location | id | 主键 |
| adj_location | adjust_no | 调整单号 |
| adj_location | warehouse_code | 仓库编码 |
| adj_location | dept_code | 部门编码 |
| adj_location | status | 状态 |
| adj_location | material_code | 物料编码 |
| adj_location | batch_no | 批次号 |
| adj_location | from_location_id | 源库位ID |
| adj_location | to_location_id | 目标库位ID |
| adj_location | adjust_quantity | 调整数量 |

---

## 11. API / 接口契约

### 11.1 Schema 配置

- 表编码：WMS0210
- CRUD 前缀：`/api/adjust/location`

### 11.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/adjust/location/list` | 库位调整列表 |
| POST | `/api/adjust/location` | 新建库位调整 |
| POST | `/api/adjust/location/{id}/confirm` | 确认执行 |
| POST | `/api/adjust/location/{id}/cancel` | 取消调整 |

### 11.3 请求示例

```json
POST /api/adjust/location
{
  "warehouseCode": "WH001",
  "deptCode": "DEPT001",
  "remark": "整理归位",
  "items": [
    {
      "materialCode": "MAT001",
      "batchNo": "BATCH001",
      "fromLocationId": 1,
      "toLocationId": 2,
      "adjustQuantity": 10
    }
  ]
}
```

---

## 12. 权限与审计

### 12.1 权限标识

- `wms:adjust:location:query`
- `wms:adjust:location:add`
- `wms:adjust:location:confirm`

### 12.2 审计要求

- 记录调整人、操作时间
- 记录调整前后库存

---

## 13. 验收标准

### 13.1 功能验收

- [ ] 新建调整单成功
- [ ] 调整执行原库位减少
- [ ] 调整执行目标库位增加
- [ ] 流水生成正确
- [ ] 状态流转正确

### 13.2 数据验收

- [ ] 库存转移正确
- [ ] 无库存丢失

---

## 14. 测试要点

### 14.1 单元测试

- 库存转移逻辑正确
- 数量校验正确

### 14.2 集成测试

- 调整全流程

---

## 15. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 16. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0210 库位调整
- Epic Brief：[epic-05-overview.md](../../epics/epic-05-overview.md)
