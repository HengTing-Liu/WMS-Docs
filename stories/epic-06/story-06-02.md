# Story 06-02 质量放行

## 0. 基本信息

- Epic：质量控制
- Story ID：06-02
- 优先级：P1
- 状态：Draft
- 预计工期：1d
- 依赖 Story：06-01（质检标准）
- 关联迭代：Sprint 3

---

## 1. 目标

实现质量放行全流程，支持请验申请、LIMS 同步、放行决策。

---

## 2. 业务背景

质量放行是医疗器械仓储的核心合规流程，请验单物料需等待质检结果后才能放行使用。

---

## 3. 范围

### 3.1 本 Story 包含

- 请验单列表查询
- 请验单新建
- 请验执行（LIMS 同步）
- 放行决策（合格/不合格/让步放行）
- ERP 同步

### 3.2 本 Story 不包含

- LIMS 系统对接（仅同步接口）

---

## 4. 参与角色

- 仓库管理员：创建请验单
- 质量管理员：放行决策
- 审批人：让步放行审批

---

## 5. 前置条件

- 质检标准已配置
- 用户具备放行权限

---

## 6. 触发方式

- 页面入口：质量管理 → 质量放行
- 接口入口：GET `/api/qc/release/list`

---

## 7. 输入 / 输出

### 7.1 新增请验 - 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| qcType | string | Y | 请验类型：INBOUND/OUTBOUND |
| sourceNo | string | Y | 来源单据号 |
| warehouseCode | string | Y | 仓库编码 |
| items | array | Y | 请验明细 |
| items[].materialCode | string | Y | 物料编码 |
| items[].batchNo | string | Y | 批次号 |
| items[].locationId | long | Y | 库位ID |
| items[].sampleQuantity | int | Y | 样品数量 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 请验单ID |
| qcNo | string | 请验单号 |
| status | string | 状态 |

---

## 8. 状态流转

### 8.1 主体对象

- 对象名称：请验单

### 8.2 状态定义

| 状态 | 说明 |
|---|---|
| PENDING | 待检验 |
| IN_PROGRESS | 检验中 |
| QUALIFIED | 合格 |
| UNQUALIFIED | 不合格 |
| CONDITIONAL | 让步放行 |
| RELEASED | 已放行 |

### 8.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| PENDING | 开始检验 | IN_PROGRESS | - |
| IN_PROGRESS | LIMS同步结果 | QUALIFIED/UNQUALIFIED/CONDITIONAL | - |
| QUALIFIED | 确认放行 | RELEASED | 解冻库存 |
| UNQUALIFIED | 隔离处置 | - | 维持冻结 |
| CONDITIONAL | 审批通过 | RELEASED | 部分解冻 |
| CONDITIONAL | 审批驳回 | IN_PROGRESS | - |

---

## 9. 业务规则

1. **请验单号生成**：`QC-{yyyyMMdd}-{6位序号}`
2. **请验期间冻结库存**：
   - 可用库存 = 账面库存 - 冻结库存
   - 冻结数量 = 请验数量
3. **LIMS 同步**：
   - WMS → LIMS：发送请验信息
   - LIMS → WMS：接收检验结果
4. **合格放行**：
   - 解冻全部库存
   - 物料可正常出库
5. **不合格**：
   - 维持冻结状态
   - 触发隔离处置流程
6. **让步放行**：
   - 解冻部分库存（按审批比例）
   - 需上级审批
7. **ERP 同步**：放行结果同步 ERP

---

## 10. 数据设计

### 10.1 涉及表

- `qc_record`（请验记录）
- `qc_record_item`（请验明细）
- `inv_inventory`（冻结库存）

### 10.2 关键字段

| 表名 | 字段 | 说明 |
|---|---|---|
| qc_record | id | 主键 |
| qc_record | qc_no | 请验单号 |
| qc_record | qc_type | 请验类型 |
| qc_record | source_no | 来源单据号 |
| qc_record | warehouse_code | 仓库编码 |
| qc_record | status | 状态 |
| qc_record | result | 检验结果 |
| qc_record_item | record_id | 请验单ID |
| qc_record_item | material_code | 物料编码 |
| qc_record_item | batch_no | 批次号 |
| qc_record_item | sample_quantity | 样品数量 |
| qc_record_item | frozen_quantity | 冻结数量 |

---

## 11. API / 接口契约

### 11.1 Schema 配置

- 表编码：WMS0220
- CRUD 前缀：`/api/qc/release`

### 11.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/qc/release/list` | 请验单列表 |
| POST | `/api/qc/release` | 新建请验单 |
| POST | `/api/qc/release/{id}/submit` | 提交请验 |
| POST | `/api/qc/release/{id}/sync` | LIMS同步 |
| POST | `/api/qc/release/{id}/result` | 录入检验结果 |
| POST | `/api/qc/release/{id}/release` | 确认放行 |
| POST | `/api/qc/release/{id}/conditional` | 让步放行申请 |
| POST | `/api/qc/release/{id}/approve` | 让步放行审批 |

### 11.3 LIMS 同步接口

| 方向 | 说明 |
|------|------|
| WMS → LIMS | 推送请验信息（MQ） |
| LIMS → WMS | 接收检验结果（Webhook/定时） |

---

## 12. 权限与审计

### 12.1 权限标识

- `wms:qc:record:query`
- `wms:qc:record:add`
- `wms:qc:record:approve`
- `wms:qc:record:release`

### 12.2 审计要求

- 记录请验操作人、操作时间
- 记录检验结果
- 记录放行决策

---

## 13. 异常与边界场景

| 场景 | 预期处理 |
|---|---|
| 请验期间出库 | 禁止，使用冻结库存 |
| LIMS 同步失败 | 重试机制，记录日志 |
| 让步放行驳回 | 返回检验中状态 |

---

## 14. 验收标准

### 14.1 功能验收

- [ ] 请验单新建成功
- [ ] 请验提交冻结库存
- [ ] LIMS 同步正常
- [ ] 合格放行解冻库存
- [ ] 不合格维持冻结
- [ ] 让步放行部分解冻
- [ ] 状态流转正确

### 14.2 数据验收

- [ ] 库存冻结/解冻正确
- [ ] 可用库存计算正确

---

## 15. 测试要点

### 15.1 单元测试

- 冻结/解冻逻辑正确
- 让步放行比例计算正确

### 15.2 集成测试

- LIMS 同步流程
- ERP 同步流程

---

## 16. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 17. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0220 质量放行
- LIMS接口：[02-lims-interface.md](../../07-INTERFACE/02-lims-interface.md)
- Epic Brief：[epic-06-overview.md](../../epics/epic-06-overview.md)
