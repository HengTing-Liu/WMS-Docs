# Story 12-03 盘点差异报表

## 0. 基本信息

- Epic：报表与统计
- Story ID：12-03
- 优先级：P1
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：Epic-05（库存调整-盘点）
- 关联迭代：Sprint 5

---

## 1. 目标

实现盘点差异报表功能，展示盘点结果和盘盈盘亏数据。

---

## 2. 业务背景

盘点差异报表帮助仓库管理员了解盘点结果，分析差异原因。

---

## 3. 范围

### 3.1 本 Story 包含

- 盘点差异列表查询
- 按盘点单号筛选
- 按仓库/库区筛选
- 按差异类型筛选（盘盈/盘亏/正常）
- 导出 Excel

### 3.2 本 Story 不包含

- 盘点单管理（见 Epic-05）

---

## 4. API / 接口契约

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/report/stocktake/difference` | 盘点差异查询 |
| GET | `/api/report/stocktake/difference/export` | 导出 |

### 4.1 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| stocktakeNo | string | N | 盘点单号 |
| warehouseId | long | N | 仓库ID |
| diffType | string | N | 差异类型（PROFIT/LOSS/NORMAL） |
| page | int | N | 页码 |
| pageSize | int | N | 每页条数 |

### 4.2 响应字段

| 字段 | 类型 | 说明 |
|------|------|------|
| total | int | 总记录数 |
| records | array | 差异列表 |
| records[].stocktakeNo | string | 盘点单号 |
| records[].warehouseName | string | 仓库 |
| records[].locationCode | string | 库位 |
| records[].materialCode | string | 物料编码 |
| records[].materialName | string | 物料名称 |
| records[].batchNo | string | 批次号 |
| records[].systemQty | decimal | 系统数量 |
| records[].actualQty | decimal | 实际数量 |
| records[].diffQty | decimal | 差异数量 |
| records[].diffRate | decimal | 差异率(%) |
| records[].diffType | string | 差异类型 |
| records[].remark | string | 备注 |
| records[].stocktakeDate | date | 盘点日期 |

---

## 5. 业务规则

1. diffQty > 0 为盘盈，< 0 为盘亏，= 0 为正常
2. diffRate = diffQty / systemQty * 100%
3. 差异率超过 5% 标红预警

---

## 6. 验收标准

- [ ] 盘点差异查询正常
- [ ] 差异类型筛选正确
- [ ] 导出功能正常

---

## 7. 关联文档

- Epic Brief：[epic-12-overview.md](../../epics/epic-12-overview.md)
- Epic-05 库存调整：[epic-05-overview.md](../../epics/epic-05-overview.md)
