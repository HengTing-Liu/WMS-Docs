# Story 12-02 出入库明细报表

## 0. 基本信息

- Epic：报表与统计
- Story ID：12-02
- 优先级：P1
- 状态：Draft
- 预计工期：1d
- 依赖 Story：Epic-03、Epic-04（入库、出库管理）
- 关联迭代：Sprint 5

---

## 1. 目标

实现出入库明细报表功能，支持查询出入库流水明细，支持按时间、物料、单据类型等维度筛选。

---

## 2. 业务背景

出入库明细报表展示所有出入库业务的流水记录，便于追溯和统计。

---

## 3. 范围

### 3.1 本 Story 包含

- 出入库明细分页列表查询
- 按时间范围筛选
- 按单据类型筛选（入库/出库）
- 按物料筛选
- 按仓库筛选
- 导出 Excel

### 3.2 本 Story 不包含

- 库存台账（见 Story 12-01）
- 盘点差异（见 Story 12-03）

---

## 4. 参与角色

- 仓库管理员
- 财务人员
- 管理人员

---

## 5. 前置条件

- Epic-03、Epic-04 已完成
- 用户具备报表查询权限

---

## 6. 触发方式

- 页面入口：报表中心 → 出入库明细
- 接口入口：GET `/api/report/inbound-outbound`

---

## 7. 输入 / 输出

### 7.1 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| startDate | date | N | 开始日期 |
| endDate | date | N | 结束日期 |
| bizType | string | N | 业务类型（INBOUND/OUTBOUND） |
| inboundType | string | N | 入库类型（采购入库/生产入库等） |
| outboundType | string | N | 出库类型（销售出库/领用出库等） |
| materialCode | string | N | 物料编码 |
| materialName | string | N | 物料名称 |
| warehouseId | long | N | 仓库ID |
| page | int | N | 页码 |
| pageSize | int | N | 每页条数 |

### 7.2 响应字段

| 字段 | 类型 | 说明 |
|------|------|------|
| total | int | 总记录数 |
| records | array | 明细列表 |
| records[].bizDate | date | 业务日期 |
| records[].bizType | string | 业务类型 |
| records[].bizTypeName | string | 业务类型名称 |
| records[].billNo | string | 单据编号 |
| records[].warehouseName | string | 仓库 |
| records[].locationCode | string | 库位 |
| records[].materialCode | string | 物料编码 |
| records[].materialName | string | 物料名称 |
| records[].spec | string | 规格 |
| records[].unit | string | 单位 |
| records[].quantity | decimal | 数量 |
| records[].price | decimal | 单价 |
| records[].amount | decimal | 金额 |
| records[].batchNo | string | 批次号 |
| records[].operator | string | 操作人 |

---

## 8. 业务规则

1. 默认显示最近30天的数据
2. 入库显示正数，出库显示负数
3. 按业务日期倒序排列
4. 支持按金额汇总

---

## 9. API / 接口契约

### 9.1 接口清单

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/report/inbound-outbound` | 出入库明细查询 |
| GET | `/api/report/inbound-outbound/export` | 出入库明细导出 |
| GET | `/api/report/inbound-outbound/summary` | 汇总统计 |

### 9.2 响应示例

```json
{
  "code": 200,
  "data": {
    "total": 5000,
    "records": [
      {
        "bizDate": "2026-04-03",
        "bizType": "INBOUND",
        "bizTypeName": "采购入库",
        "billNo": "IN20260403001",
        "warehouseName": "上海仓",
        "locationCode": "A-01-01",
        "materialCode": "MAT001",
        "materialName": "试剂盒",
        "spec": "100T/盒",
        "unit": "盒",
        "quantity": 100,
        "price": 50.00,
        "amount": 5000.00,
        "batchNo": "B20260401",
        "operator": "张三"
      }
    ]
  }
}
```

---

## 10. 验收标准

### 10.1 功能验收

- [ ] 出入库明细查询正常
- [ ] 时间范围筛选正确
- [ ] 单据类型筛选正确
- [ ] 导出功能正常

### 10.2 性能验收

- [ ] 查询响应 < 2s（10000条以内）

---

## 11. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档

---

## 12. 关联文档

- Epic Brief：[epic-12-overview.md](../../epics/epic-12-overview.md)
