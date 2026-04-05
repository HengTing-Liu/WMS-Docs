# WMS仓库物流系统 - LIMS接口文档

> 版本：V1.0
> 日期：2026-04-03
> 适用范围：WMS与LIMS系统集成

---

## 一、接口概述

### 1.1 集成架构

```
┌─────────────┐                    ┌─────────────┐                    ┌─────────────┐
│    ERP     │                    │    WMS     │                    │   LIMS     │
│            │                    │            │                    │            │
│  ────────  │                    │  ────────  │                    │  ────────  │
│            │                    │            │                    │            │
│ 采购入库   │ ──── MM001 ──────▶│ 收货登记   │                    │            │
│            │                    │            │                    │            │
│            │                    │ 发起质检   │ ─── LIMS001 ────▶│ 质检申请   │
│            │                    │            │                    │            │
│            │                    │            │ ◀─── LIMS002 ───│ 质检结果   │
│            │                    │            │                    │            │
│            │                    │ 合格放行   │                    │            │
│  ────────  │ ◀─── MM002 ───────│ 或不合格   │                    │            │
│ 采购入库   │                    │  处理      │                    │            │
│            │                    │            │                    │            │
└─────────────┘                    └─────────────┘                    └─────────────┘
```

### 1.2 接口列表

| 接口编号 | 接口名称 | 方向 | 说明 |
|----------|----------|------|------|
| LIMS001 | 库存质检申请 | WMS→LIMS | 发起质检 |
| LIMS002 | 质检结果回传 | LIMS→WMS | 质检结果返回 |

---

## 二、接口详细定义

### 2.1 LIMS001 - 库存质检申请

**接口方向**: WMS → LIMS
**接口说明**: WMS对必检物料发起质检申请

**请求参数**:

```json
{
  "header": {
    "interfaceCode": "LIMS001",
    "requestId": "550e8400-e29b-41d4-a716-446655440100",
    "timestamp": "2024-04-03 14:30:00",
    "sourceSystem": "WMS",
    "targetSystem": "LIMS"
  },
  "body": {
    "qcApplicationNo": "QCAPP2024040300001",
    "applicationType": "PURCHASE",
    "sourceNo": "IN2024040300001",
    "warehouseCode": "WH001",
    "warehouseName": "上海仓库",
    "applicantCode": "USER001",
    "applicantName": "张三",
    "applyDate": "2024-04-03",
    "expectedTestDate": "2024-04-04",
    "remark": "采购入库质检",
    "items": [
      {
        "lineNo": 1,
        "materialCode": "MAT001",
        "materialName": "测试物料A",
        "batchNo": "BAT2404030001",
        "quantity": 100,
        "unit": "盒",
        "sampleQuantity": 3,
        "sampleUnit": "盒",
        "qcStandardCode": "QC001",
        "qcStandardName": "常规质检标准",
        "spec": "100T/盒",
        "productionDate": "2024-04-01",
        "expiryDate": "2026-04-01",
        "supplierCode": "SUP001",
        "supplierName": "测试供应商",
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
    "interfaceCode": "LIMS001",
    "requestId": "550e8400-e29b-41d4-a716-446655440100",
    "timestamp": "2024-04-03 14:30:01",
    "sourceSystem": "LIMS",
    "targetSystem": "WMS"
  },
  "body": {
    "success": true,
    "limsQcNo": "LIMS-QC-20240403001",
    "message": "质检申请接收成功"
  }
}
```

### 2.2 LIMS002 - 质检结果回传

**接口方向**: LIMS → WMS
**接口说明**: LIMS将质检结果返回给WMS

**请求参数**:

```json
{
  "header": {
    "interfaceCode": "LIMS002",
    "requestId": "550e8400-e29b-41d4-a716-446655440101",
    "timestamp": "2024-04-04 16:00:00",
    "sourceSystem": "LIMS",
    "targetSystem": "WMS"
  },
  "body": {
    "limsQcNo": "LIMS-QC-20240403001",
    "qcApplicationNo": "QCAPP2024040300001",
    "sourceNo": "IN2024040300001",
    "qcStatus": "COMPLETED",
    "qcDate": "2024-04-04",
    "qcPersonCode": "QC001",
    "qcPersonName": "李质检",
    "items": [
      {
        "lineNo": 1,
        "materialCode": "MAT001",
        "batchNo": "BAT2404030001",
        "qcResult": "QUALIFIED",
        "qcReportNo": "REP-20240404-001",
        "qcReportUrl": "https://lims.company.com/reports/REP-20240404-001.pdf",
        "testItems": [
          {
            "itemName": "外观检验",
            "result": "PASS",
            "specification": "无异物、无变色",
            "actualResult": "符合要求",
            "remark": ""
          },
          {
            "itemName": "纯度检验",
            "result": "PASS",
            "specification": "≥95%",
            "actualResult": "98.5%",
            "remark": ""
          },
          {
            "itemName": "效价检验",
            "result": "PASS",
            "specification": "≥90%",
            "actualResult": "95.2%",
            "remark": ""
          }
        ],
        "lossQuantity": 1,
        "lossUnit": "盒",
        "lossReason": "留样消耗",
        "remark": ""
      }
    ]
  }
}
```

**质检结果枚举**:

| 枚举值 | 说明 |
|--------|------|
| QUALIFIED | 合格 |
| UNQUALIFIED | 不合格 |
| CONDITIONAL | 条件合格 |

**检验项目结果枚举**:

| 枚举值 | 说明 |
|--------|------|
| PASS | 通过 |
| FAIL | 不通过 |
| NA | 不适用 |

---

## 三、质检状态流转

```
WMS发起质检申请                    LIMS处理                         WMS接收结果
      │                                │                                 │
      │                                │                                 │
      ▼                                │                                 │
┌──────────┐                          │                                 │
│ QC_PENDING │ ── LIMS001 ─────────▶ │                                 │
└──────────┘                          │                                 │
                                     ▼                                 │
                              ┌──────────┐                          │
                              │IN_PROGRESS│                          │
                              └──────────┘                          │
                                     │                                 │
                                     ▼                                 │
                              ┌──────────┐                          │
                              │ COMPLETED │ ◀── LIMS002 ─────────────┤
                              └──────────┘                          │
                                     │                                 │
                    ┌────────────────┼────────────────┐               │
                    │                │                │               │
                    ▼                ▼                ▼               │
              ┌──────────┐    ┌──────────┐    ┌──────────┐         │
              │ QUALIFIED│    │UNQUALIFIED│   │CONDITIONAL│         │
              └──────────┘    └──────────┘    └──────────┘         │
                    │                │                │               │
                    ▼                ▼                ▼               │
              ┌──────────┐    ┌──────────┐    ┌──────────┐         │
              │ 合格放行 │    │ 不合格处理 │   │ 人工判断 │         │
              └──────────┘    └──────────┘    └──────────┘         │
                    │                │                │               │
                    ▼                ▼                ▼               │
              ┌──────────┐    ┌──────────┐    ┌──────────┐         │
              │ ERP入库  │    │ ERP隔离  │    │ 人工审批 │         │
              │(大库)    │    │ 报废/退回 │    │         │         │
              └──────────┘    └──────────┘    └──────────┘         │
                                     │                                 │
                                     └─────────────────────────────────┘
```

---

## 四、损耗处理流程

当质检完成后，LIMS会返回损耗数量，WMS需要处理：

1. **计算损耗数量**: 质检样品数量 = 损耗数量
2. **更新库存**: 从入库批次中扣除损耗数量
3. **同步ERP**: 将损耗出库通知ERP

```json
{
  "header": {
    "interfaceCode": "LIMS003",
    "requestId": "550e8400-e29b-41d4-a716-446655440102",
    "timestamp": "2024-04-04 16:00:02",
    "sourceSystem": "WMS",
    "targetSystem": "ERP"
  },
  "body": {
    "qcApplicationNo": "QCAPP2024040300001",
    "sourceNo": "IN2024040300001",
    "materialCode": "MAT001",
    "batchNo": "BAT2404030001",
    "lossQuantity": 1,
    "unit": "盒",
    "lossReason": "质检留样",
    "lossDate": "2024-04-04"
  }
}
```

---

## 五、错误处理

| LIMS错误码 | 说明 | WMS处理 |
|-----------|------|---------|
| E001 | 物料不存在 | 记录错误，跳过该物料 |
| E002 | 批次不存在 | 记录错误，跳过该批次 |
| E003 | 质检标准不存在 | 使用默认标准 |
| E004 | 样品数量不足 | 提示用户补样 |
| E005 | 重复申请 | 返回成功，不重复处理 |

---

## 六、重试机制

| 参数 | 配置 |
|------|------|
| 最大重试次数 | 5次 |
| 重试间隔 | 1分钟、5分钟、15分钟、30分钟、60分钟 |
| 幂等键 | requestId |
| 死信队列 | LIMS_DLQ |
