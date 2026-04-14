# Story 12-01 库存台账报表

## 0. 基本信息

- Epic：报表与统计
- Story ID：12-01
- 优先级：P1
- 状态：Draft
- 预计工期：1d
- 依赖 Story：Epic-02（库存查询）
- 关联迭代：Sprint 5

---

## 1. 目标

实现库存台账报表功能，支持按物料、库位、仓库等维度查询实时库存，支持导出Excel。

---

## 2. 业务背景

库存台账是仓库管理的核心报表，展示每个物料在每个库位的实时库存情况。

---

## 3. 范围

### 3.1 本 Story 包含

- 库存台账分页列表查询
- 按物料编码/名称搜索
- 按仓库/库区/库位筛选
- 按物料分类筛选
- 库存台账导出 Excel

### 3.2 本 Story 不包含

- 库存预警配置（后续迭代）
- 库存统计看板（见 Story 12-04）

---

## 4. 参与角色

- 仓库管理员：查询库存台账
- 财务人员：核对库存数据
- 管理人员：查看库存概况

---

## 5. 前置条件

- Epic-02 库存查询已完成
- 用户具备报表查询权限（`wms:report:inventory:query`）

---

## 6. 触发方式

- 页面入口：报表中心 → 库存台账
- 接口入口：GET `/api/report/inventory`

---

## 7. 输入 / 输出

### 7.1 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| warehouseId | long | N | 仓库ID |
| zoneId | long | N | 库区ID |
| locationId | long | N | 库位ID |
| materialCode | string | N | 物料编码（模糊搜索） |
| materialName | string | N | 物料名称（模糊搜索） |
| category | string | N | 物料分类 |
| page | int | N | 页码，默认1 |
| pageSize | int | N | 每页条数，默认50 |

### 7.2 响应字段

| 字段 | 类型 | 说明 |
|------|------|------|
| total | int | 总记录数 |
| records | array | 库存列表 |
| records[].warehouseName | string | 仓库名称 |
| records[].zoneName | string | 库区名称 |
| records[].locationCode | string | 库位编码 |
| records[].materialCode | string | 物料编码 |
| records[].materialName | string | 物料名称 |
| records[].spec | string | 规格型号 |
| records[].unit | string | 单位 |
| records[].batchNo | string | 批次号 |
| records[].quantity | decimal | 库存数量 |
| records[].frozenQuantity | decimal | 冻结数量 |
| records[].availableQuantity | decimal | 可用数量 |
| records[].productionDate | date | 生产日期 |
| records[].expireDate | date | 效期 |
| records[].isFrozen | int | 是否冻结 |

---

## 8. 页面/交互要求

### 8.1 页面

- 页面名称：库存台账
- 页面类型：报表列表页
- 菜单路径：报表中心 → 库存台账

### 8.2 交互要求

- 输入搜索条件后点击【查询】按钮，列表刷新
- 点击【重置】按钮，清空搜索条件
- 点击【导出】按钮，下载 Excel 文件

### 8.3 展示字段

| 字段 | 说明 |
|------|------|
| 仓库 | - |
| 库区 | - |
| 库位 | - |
| 物料编码 | - |
| 物料名称 | - |
| 规格型号 | - |
| 单位 | - |
| 批次号 | - |
| 库存数量 | 标红显示低于预警值 |
| 冻结数量 | - |
| 可用数量 | - |
| 生产日期 | 格式：YYYY-MM-DD |
| 效期 | 格式：YYYY-MM-DD |
| 状态 | 冻结/正常 |

---

## 9. 业务规则

1. 默认按仓库+库位+物料+批次维度展示
2. 库存数量为 0 时标红显示
3. 效期低于30天显示黄色预警
4. 导出字段与列表展示字段一致
5. 导出文件名格式：`库存台账_YYYYMMDD_HHmmss.xlsx`

---

## 10. 数据设计

### 10.1 涉及表

- `wms_inventory`（库存表）
- `sys_warehouse`（仓库表）
- `wms_location`（库位表）

---

## 11. API / 接口契约

### 11.1 接口清单

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/report/inventory` | 库存台账查询 |
| GET | `/api/report/inventory/export` | 库存台账导出 |

### 11.2 响应示例

```json
{
  "code": 200,
  "data": {
    "total": 1000,
    "records": [
      {
        "warehouseName": "上海仓",
        "zoneName": "常温区",
        "locationCode": "A-01-01",
        "materialCode": "MAT001",
        "materialName": "试剂盒",
        "spec": "100T/盒",
        "unit": "盒",
        "batchNo": "B20260401",
        "quantity": 100,
        "frozenQuantity": 10,
        "availableQuantity": 90,
        "productionDate": "2026-04-01",
        "expireDate": "2027-04-01",
        "isFrozen": 0
      }
    ]
  }
}
```

---

## 12. 权限与审计

### 12.1 权限标识

- `wms:report:inventory:query`
- `wms:report:inventory:export`

### 12.2 审计要求

- 查询和导出操作记录日志

---

## 13. 验收标准

### 13.1 功能验收

- [ ] 库存台账查询正常
- [ ] 多条件筛选正确
- [ ] 分页切换正常
- [ ] 导出 Excel 功能正常
- [ ] 数据权限过滤正确

### 13.2 性能验收

- [ ] 查询响应 < 1s（1000条以内）
- [ ] 导出响应 < 3s（10000条以内）

---

## 14. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档

---

## 15. 关联文档

- Epic Brief：[epic-12-overview.md](../../epics/epic-12-overview.md)
- 数据库设计：[04-DATABASE/WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md)
