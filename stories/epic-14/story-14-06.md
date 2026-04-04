# Story 14-06 ERP接口集成

## 0. 基本信息

- Epic：辅助功能与外部接口
- Story ID：14-06
- 优先级：P1
- 状态：Draft
- 预计工期：1.5d
- 依赖 Story：Epic-01、Epic-03、Epic-04
- 关联迭代：Sprint 3

---

## 1. 目标

实现与ERP系统的接口集成，包括基础数据同步和业务单据回传。

---

## 2. 业务背景

WMS需要与ERP系统保持数据一致，通过接口实现基础数据同步和业务数据回传。

---

## 3. 范围

### 3.1 本 Story 包含

- ERP基础数据同步（物料、仓库、供应商等）
- ERP采购入库通知
- ERP销售出库通知
- ERP库存同步
- 接口日志记录

### 3.2 本 Story 不包含

- LIMS系统对接（V2.0）

---

## 4. 接口设计

### 4.1 ERP → WMS（接收）

| 接口 | 方向 | 说明 |
|------|------|------|
| POST `/api/integration/erp/material/sync` | ERP→WMS | 物料同步 |
| POST `/api/integration/erp/warehouse/sync` | ERP→WMS | 仓库同步 |
| POST `/api/integration/erp/purchase-arrival` | ERP→WMS | 采购到货通知 |
| POST `/api/integration/erp/sale-order` | ERP→WMS | 销售订单通知 |
| POST `/api/integration/erp/allocation` | ERP→WMS | 调拨通知 |

### 4.2 WMS → ERP（回传）

| 接口 | 方向 | 说明 |
|------|------|------|
| POST `{erpUrl}/api/inbound/notify` | WMS→ERP | 入库完成通知 |
| POST `{erpUrl}/api/outbound/notify` | WMS→ERP | 出库完成通知 |
| POST `{erpUrl}/api/inventory/sync` | WMS→ERP | 库存同步 |

### 4.3 同步日志字段

| 字段 | 类型 | 说明 |
|------|------|------|
| id | long | 主键 |
| direction | string | 方向：IN/OUT |
| bizType | string | 业务类型 |
| requestUrl | string | 请求地址 |
| requestMethod | string | 请求方法 |
| requestBody | text | 请求体 |
| responseBody | text | 响应体 |
| responseCode | int | 响应码 |
| costTime | long | 耗时(ms) |
| status | string | 状态：SUCCESS/FAIL |
| errorMessage | string | 错误信息 |
| createTime | datetime | 创建时间 |

---

## 5. 定时同步任务

| 任务名 | JobHandler | Cron | 说明 |
|--------|-----------|------|------|
| ERP物料同步 | `erpMaterialSyncJob` | `0 0/5 * * * ?` | 每5分钟同步物料 |
| ERP仓库同步 | `erpWarehouseSyncJob` | `0 0 2 * * ?` | 每日凌晨2点同步仓库 |
| WMS库存回传 | `inventorySyncToErpJob` | `0 0/10 * * * ?` | 每10分钟回传库存 |

---

## 6. 验收标准

### 6.1 功能验收

- [ ] 物料同步正常
- [ ] 采购到货接收正常
- [ ] 销售订单接收正常
- [ ] 入库完成回传正常
- [ ] 出库完成回传正常
- [ ] 库存回传正常

### 6.2 可靠性验收

- [ ] 接口幂等处理
- [ ] 失败重试机制
- [ ] 接口日志完整

---

## 7. 交付物清单

- [ ] 后端代码（接口服务）
- [ ] 定时任务
- [ ] 接口文档

---

## 8. 关联文档

- Epic Brief：[epic-14-overview.md](../../epics/epic-14-overview.md)
- ERP接口规范：[07-INTERFACE/01-erp-interface.md](../../07-INTERFACE/01-erp-interface.md)
