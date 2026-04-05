# WMS仓库物流系统 - ERP接口文档

> 版本：V1.0
> 日期：2026-04-03
> 适用范围：WMS与ERP系统集成

---

## 一、接口概述

### 1.1 集成架构

```
┌─────────────┐                    ┌─────────────┐
│    ERP     │                    │    WMS     │
│            │                    │            │
│  ────────  │                    │  ────────  │
│            │                    │            │
│ 采购管理   │ ──── MM001 ──────▶│ 采购入库   │
│            │                    │            │
│            │ ◀──── MM002 ───────│入库确认   │
│            │                    │            │
│ 库存管理   │ ◀──── MM006 ───────│ 调拨出库   │
│            │                    │            │
│            │ ──── MM007 ──────▶│            │
│            │ ◀──── MM008 ───────│            │
│            │                    │            │
│ 物料管理   │ ──── MM014 ──────▶│ 物料同步   │
│            │                    │            │
│ 供应商管理 │ ──── MM015 ──────▶│ 供应商同步 │
│            │                    │            │
└─────────────┘                    └─────────────┘
```

### 1.2 接口规范

| 项目 | 规范 |
|------|------|
| 通信协议 | HTTP/HTTPS RESTful API |
| 数据格式 | JSON |
| 字符编码 | UTF-8 |
| 认证方式 | API Key / OAuth2 |
| 请求ID | UUID，幂等性保证 |
| 签名 | HMAC-SHA256（可选） |
| 时间戳 | yyyy-MM-dd HH:mm:ss |

---

## 二、接口列表

### 2.1 ERP → WMS（推送给WMS）

| 接口编号 | 接口名称 | 方向 | 说明 |
|----------|----------|------|------|
| MM001 | 采购到货计划 | ERP→WMS | 采购到货通知 |
| MM006 | 库存调拨申请 | ERP→WMS | 调拨出库申请 |
| MM009 | 库存领用出库申请 | ERP→WMS | 领用出库申请 |
| MM011 | 库存退料入库申请 | ERP→WMS | 退料入库申请 |
| MM014 | 物料基础数据同步 | ERP→WMS | 物料主数据同步 |
| MM015 | 供应商基础数据同步 | ERP→WMS | 供应商数据同步 |

### 2.2 WMS → ERP（WMS推送给ERP）

| 接口编号 | 接口名称 | 方向 | 说明 |
|----------|----------|------|------|
| MM002 | 采购入库完成 | WMS→ERP | 入库确认 |
| MM004 | 库存质检损耗出库 | WMS→ERP | 质检损耗出库 |
| MM005 | 库存质量不合格品处理 | WMS→ERP | 不合格品处理 |
| MM007 | 库存调拨出库完成 | WMS→ERP | 调拨出库确认 |
| MM008 | 库存调拨入库完成 | WMS→ERP | 调拨入库确认 |
| MM010 | 库存领用出库完成 | WMS→ERP | 领用出库确认 |
| MM012 | 库存退料入库完成 | WMS→ERP | 退料入库确认 |
| MM013 | 库存报废出库完成 | WMS→ERP | 报废出库确认 |

---

## 三、接口详细定义

### 3.1 MM001 - 采购到货计划

**接口方向**: ERP → WMS
**接口说明**: ERP将采购到货计划推送给WMS，WMS进行收货操作

**请求参数**:

```json
{
  "header": {
    "interfaceCode": "MM001",
    "requestId": "550e8400-e29b-41d4-a716-446655440000",
    "timestamp": "2024-04-03 10:00:00",
    "sourceSystem": "ERP",
    "targetSystem": "WMS"
  },
  "body": {
    "purchaseOrderNo": "PO2024040300001",
    "purchaseOrderType": "NORMAL",
    "supplierCode": "SUP001",
    "supplierName": "测试供应商有限公司",
    "expectedDate": "2024-04-10",
    "warehouseCode": "WH001",
    "remark": "紧急订单",
    "items": [
      {
        "lineNo": 1,
        "materialCode": "MAT001",
        "materialName": "测试物料A",
        "spec": "100T/盒",
        "unit": "盒",
        "quantity": 100,
        "batchNo": "",
        "productionDate": "",
        "expiryDate": "",
        "qcRequired": true,
        "remark": ""
      },
      {
        "lineNo": 2,
        "materialCode": "MAT002",
        "materialName": "测试物料B",
        "spec": "50支/盒",
        "unit": "盒",
        "quantity": 50,
        "batchNo": "",
        "productionDate": "",
        "expiryDate": "",
        "qcRequired": false,
        "remark": ""
      }
    ]
  }
}
```

**响应参数**:

```json
{
  "header": {
    "interfaceCode": "MM001",
    "requestId": "550e8400-e29b-41d4-a716-446655440000",
    "timestamp": "2024-04-03 10:00:01",
    "sourceSystem": "WMS",
    "targetSystem": "ERP"
  },
  "body": {
    "success": true,
    "wmsInboundNo": "IN2024040300001",
    "message": "接收成功"
  }
}
```

### 3.2 MM002 - 采购入库完成

**接口方向**: WMS → ERP
**接口说明**: WMS采购入库完成后，通知ERP进行后续处理

**请求参数**:

```json
{
  "header": {
    "interfaceCode": "MM002",
    "requestId": "550e8400-e29b-41d4-a716-446655440001",
    "timestamp": "2024-04-03 14:00:00",
    "sourceSystem": "WMS",
    "targetSystem": "ERP"
  },
  "body": {
    "wmsInboundNo": "IN2024040300001",
    "erpPurchaseOrderNo": "PO2024040300001",
    "inboundDate": "2024-04-03",
    "warehouseCode": "WH001",
    "warehouseName": "上海仓库",
    "qcRequired": true,
    "items": [
      {
        "lineNo": 1,
        "materialCode": "MAT001",
        "materialName": "测试物料A",
        "batchNo": "BAT2404030001",
        "quantity": 100,
        "unit": "盒",
        "locationCode": "A01-01-01-01",
        "qcStatus": "QUALIFIED",
        "productionDate": "2024-04-01",
        "expiryDate": "2026-04-01"
      }
    ]
  }
}
```

**响应参数**:

```json
{
  "header": {
    "interfaceCode": "MM002",
    "requestId": "550e8400-e29b-41d4-a716-446655440001",
    "timestamp": "2024-04-03 14:00:01",
    "sourceSystem": "ERP",
    "targetSystem": "WMS"
  },
  "body": {
    "success": true,
    "erpInboundNo": "RK2024040300001",
    "message": "入库完成"
  }
}
```

### 3.3 MM003 - 库存质检申请

**接口方向**: WMS → LIMS（见LIMS接口文档）

### 3.4 MM006 - 库存调拨申请

**接口方向**: ERP → WMS
**接口说明**: ERP将调拨申请推送给WMS，WMS进行调拨出库和入库操作

**请求参数**:

```json
{
  "header": {
    "interfaceCode": "MM006",
    "requestId": "550e8400-e29b-41d4-a716-446655440002",
    "timestamp": "2024-04-03 10:00:00",
    "sourceSystem": "ERP",
    "targetSystem": "WMS"
  },
  "body": {
    "transferOrderNo": "TO2024040300001",
    "transferType": "TRANSFER",
    "sourceWarehouseCode": "WH001",
    "sourceWarehouseName": "上海仓库",
    "targetWarehouseCode": "WH002",
    "targetWarehouseName": "北京仓库",
    "expectedDate": "2024-04-05",
    "remark": "跨区域调拨",
    "items": [
      {
        "lineNo": 1,
        "materialCode": "MAT001",
        "materialName": "测试物料A",
        "batchNo": "BAT2404010001",
        "quantity": 50,
        "unit": "盒"
      }
    ]
  }
}
```

### 3.5 MM007 - 库存调拨出库完成

**接口方向**: WMS → ERP
**接口说明**: WMS调拨出库完成后，通知ERP

**请求参数**:

```json
{
  "header": {
    "interfaceCode": "MM007",
    "requestId": "550e8400-e29b-41d4-a716-446655440003",
    "timestamp": "2024-04-03 15:00:00",
    "sourceSystem": "WMS",
    "targetSystem": "ERP"
  },
  "body": {
    "transferOrderNo": "TO2024040300001",
    "wmsOutboundNo": "OUT2024040300001",
    "outboundDate": "2024-04-03",
    "sourceWarehouseCode": "WH001",
    "items": [
      {
        "lineNo": 1,
        "materialCode": "MAT001",
        "batchNo": "BAT2404010001",
        "outboundQuantity": 50,
        "unit": "盒"
      }
    ]
  }
}
```

### 3.6 MM008 - 库存调拨入库完成

**接口方向**: WMS → ERP
**接口说明**: WMS调拨入库完成后，通知ERP

**请求参数**:

```json
{
  "header": {
    "interfaceCode": "MM008",
    "requestId": "550e8400-e29b-41d4-a716-446655440004",
    "timestamp": "2024-04-03 16:00:00",
    "sourceSystem": "WMS",
    "targetSystem": "ERP"
  },
  "body": {
    "transferOrderNo": "TO2024040300001",
    "wmsInboundNo": "IN2024040300002",
    "inboundDate": "2024-04-03",
    "targetWarehouseCode": "WH002",
    "items": [
      {
        "lineNo": 1,
        "materialCode": "MAT001",
        "batchNo": "BAT2404010001",
        "newBatchNo": "BAT2404030002",
        "inboundQuantity": 50,
        "unit": "盒",
        "locationCode": "B01-01-01-01"
      }
    ]
  }
}
```

### 3.7 MM009 - 库存领用出库申请

**接口方向**: ERP → WMS

**请求参数**:

```json
{
  "header": {
    "interfaceCode": "MM009",
    "requestId": "550e8400-e29b-41d4-a716-446655440005",
    "timestamp": "2024-04-03 10:00:00",
    "sourceSystem": "ERP",
    "targetSystem": "WMS"
  },
  "body": {
    "requisitionOrderNo": "RE2024040300001",
    "departmentCode": "DEPT001",
    "departmentName": "研发部",
    "applicantCode": "USER001",
    "applicantName": "张三",
    "warehouseCode": "WH001",
    "expectedDate": "2024-04-04",
    "remark": "研发项目使用",
    "items": [
      {
        "lineNo": 1,
        "materialCode": "MAT001",
        "materialName": "测试物料A",
        "quantity": 10,
        "unit": "盒"
      }
    ]
  }
}
```

### 3.8 MM010 - 库存领用出库完成

**接口方向**: WMS → ERP

**请求参数**:

```json
{
  "header": {
    "interfaceCode": "MM010",
    "requestId": "550e8400-e29b-41d4-a716-446655440006",
    "timestamp": "2024-04-03 17:00:00",
    "sourceSystem": "WMS",
    "targetSystem": "ERP"
  },
  "body": {
    "requisitionOrderNo": "RE2024040300001",
    "wmsOutboundNo": "OUT2024040300002",
    "outboundDate": "2024-04-03",
    "warehouseCode": "WH001",
    "items": [
      {
        "lineNo": 1,
        "materialCode": "MAT001",
        "batchNo": "BAT2404010001",
        "outboundQuantity": 10,
        "unit": "盒"
      }
    ]
  }
}
```

### 3.9 MM013 - 库存报废出库完成

**接口方向**: WMS → ERP

**请求参数**:

```json
{
  "header": {
    "interfaceCode": "MM013",
    "requestId": "550e8400-e29b-41d4-a716-446655440007",
    "timestamp": "2024-04-03 18:00:00",
    "sourceSystem": "WMS",
    "targetSystem": "ERP"
  },
  "body": {
    "scrapNo": "SC2024040300001",
    "scrapDate": "2024-04-03",
    "warehouseCode": "WH001",
    "reason": "物料过期",
    "remark": "超过效期",
    "items": [
      {
        "lineNo": 1,
        "materialCode": "MAT003",
        "batchNo": "BAT2312010001",
        "scrapQuantity": 5,
        "unit": "盒"
      }
    ]
  }
}
```

### 3.10 MM014 - 物料基础数据同步

**接口方向**: ERP → WMS

**请求参数**:

```json
{
  "header": {
    "interfaceCode": "MM014",
    "requestId": "550e8400-e29b-41d4-a716-446655440008",
    "timestamp": "2024-04-03 02:00:00",
    "sourceSystem": "ERP",
    "targetSystem": "WMS"
  },
  "body": {
    "syncType": "FULL",
    "items": [
      {
        "materialCode": "MAT001",
        "materialNameCn": "测试物料A",
        "materialNameEn": "Test Material A",
        "exportName": "Test Material A",
        "brand": "测试品牌",
        "articleNo": "ART001",
        "category": "ANTIBODY",
        "spec": "100T/盒",
        "unit": "盒",
        "packageSpec": "10盒/箱",
        "qcRequired": true,
        "udiDi": "123456789012345678",
        "status": "ACTIVE"
      }
    ]
  }
}
```

### 3.11 MM015 - 供应商基础数据同步

**接口方向**: ERP → WMS

**请求参数**:

```json
{
  "header": {
    "interfaceCode": "MM015",
    "requestId": "550e8400-e29b-41d4-a716-446655440009",
    "timestamp": "2024-04-03 03:00:00",
    "sourceSystem": "ERP",
    "targetSystem": "WMS"
  },
  "body": {
    "syncType": "FULL",
    "items": [
      {
        "supplierCode": "SUP001",
        "supplierName": "测试供应商有限公司",
        "supplierType": "DOMESTIC",
        "contactPerson": "李四",
        "contactPhone": "13800138000",
        "contactEmail": "lisi@example.com",
        "address": "上海市浦东新区xxx路",
        "status": "ACTIVE"
      }
    ]
  }
}
```

---

## 四、错误码对照

| ERP错误码 | WMS错误码 | 说明 |
|-----------|-----------|------|
| E001 | WMS001 | 单据已存在 |
| E002 | WMS002 | 单据不存在 |
| E003 | WMS003 | 物料不存在 |
| E004 | WMS004 | 仓库不存在 |
| E005 | WMS005 | 数量不足 |
| E006 | WMS006 | 状态不允许 |
| E007 | SYS007 | 参数校验失败 |
| E008 | SYS002 | 接口超时 |

---

## 五、重试机制

| 参数 | 配置 |
|------|------|
| 最大重试次数 | 3次 |
| 重试间隔 | 1分钟、5分钟、15分钟 |
| 幂等键 | requestId |
| 死信队列 | ERP_MM_DLQ |
