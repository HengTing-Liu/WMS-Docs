# Story 05-01 库存盘点

## 0. 基本信息

- Epic：库存调整
- Story ID：05-01
- 优先级：P1
- 状态：Draft
- 预计工期：1.5d
- 依赖 Story：01-01（仓库查询）、01-03（库位查询）
- 关联迭代：Sprint 3

---

## 1. 目标

实现库存盘点全流程管理，支持盘点计划创建、启动盘点、扫码盘点、确认更新。

---

## 2. 业务背景

库存盘点用于核对实际库存与账面库存是否一致，确保库存数据准确性。盘点期间需锁定相关库位，禁止出入库操作。

---

## 3. 范围

### 3.1 本 Story 包含

- 盘点计划列表查询
- 盘点计划新建
- 盘点计划审批
- 启动盘点（锁定库位、生成盘点清单）
- 扫码盘点
- 确认盘点（差异处理）
- 盘点报表导出
- ERP 同步

### 3.2 本 Story 不包含

- 循环盘点
- 动态盘点

---

## 4. 参与角色

- 仓库管理员：创建/执行盘点
- 审批人：审批盘点计划
- 仓库作业员：扫码盘点

---

## 5. 前置条件

- 仓库档案已存在
- 库位档案已存在
- 用户具备盘点权限

---

## 6. 触发方式

- 页面入口：库存调整 → 库存盘点
- 接口入口：GET `/api/adjust/stocktake/list`

---

## 7. 输入 / 输出

### 7.1 新建盘点计划 - 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| warehouseId | long | Y | 仓库ID |
| stocktakeType | string | Y | 盘点类型：FULL/PARTIAL/CYCLE |
| locationIds | array | N | 库位ID列表（抽盘时必填） |
| stocktakeDate | date | Y | 盘点日期 |
| remark | string | N | 备注 |

### 7.2 扫码盘点 - 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| stocktakeId | long | Y | 盘点单ID |
| items | array | Y | 盘点明细 |
| items[].itemId | long | Y | 盘点明细ID |
| items[].stocktakeQuantity | int | Y | 实际盘点数量 |
| items[].remark | string | N | 备注 |

### 7.3 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 盘点单ID |
| stocktakeNo | string | 盘点单号 |
| status | string | 状态 |

---

## 8. 页面/交互要求

### 8.1 页面

- 页面名称：库存盘点列表页 + 盘点执行页
- 页面类型：列表页 + 详情页
- 菜单路径：库存调整 → 库存盘点

### 8.2 交互要求

- 选择仓库和盘点类型
- 抽盘时选择库位
- 扫码录入实际数量
- 差异自动计算
- 提交盘点结果

### 8.3 展示字段

| 字段 | 说明 |
|---|---|
| 盘点单号 | - |
| 盘点类型 | 全盘/抽盘/循环盘点 |
| 仓库 | - |
| 盘点日期 | - |
| 状态 | 草稿/已启动/盘点中/已完成/已确认 |
| 账面数量 | - |
| 实际数量 | - |
| 差异数量 | - |

---

## 9. 业务规则

1. **盘点单号生成**：`STK-{yyyyMMdd}-{6位序号}`
2. **盘点类型**：
   - 全盘：盘点所有库位
   - 抽盘：盘点指定库位
   - 循环盘点：按规则轮流盘点
3. **启动盘点时**：
   - 锁定库位（状态设为 FROZEN）
   - 冻结库存（冻结 = 账面数量）
   - 生成盘点清单（读取当前库存）
4. **差异处理**：
   - 差异率 < 阈值（如 5%）：自动调整库存
   - 差异率 >= 阈值：需审批后调整
5. **确认盘点时**：
   - 盘盈：增加库存
   - 盘亏：扣减库存
   - 解冻库存
   - 解锁库位
   - 生成库存变更流水（类型：STOCKTAKE）
6. **禁止出入库**：盘点启动后，禁止该库位的出入库操作

---

## 10. 状态流转

### 10.1 主体对象

- 对象名称：盘点单

### 10.2 状态定义

| 状态 | 说明 |
|---|---|
| DRAFT | 草稿 |
| PENDING_APPROVAL | 待审批 |
| STARTED | 已启动 |
| IN_PROGRESS | 盘点中 |
| COMPLETED | 已完成 |
| CONFIRMED | 已确认 |
| CANCELLED | 已取消 |

### 10.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| DRAFT | 提交审批 | PENDING_APPROVAL | - |
| DRAFT | 取消 | CANCELLED | - |
| PENDING_APPROVAL | 审批通过 | STARTED | - |
| PENDING_APPROVAL | 审批驳回 | DRAFT | - |
| STARTED | 开始盘点 | IN_PROGRESS | 生成盘点清单 |
| IN_PROGRESS | 提交盘点 | COMPLETED | 计算差异 |
| COMPLETED | 审批确认 | CONFIRMED | 差异率>=阈值时 |
| COMPLETED | 自动确认 | CONFIRMED | 差异率<阈值时 |

---

## 11. 数据设计

### 11.1 涉及表

- `st_stocktake`（盘点主表）
- `st_stocktake_location`（盘点库位）
- `st_stocktake_item`（盘点明细）
- `inv_inventory`（冻结库存）
- `inv_inventory_change`（变更流水）

### 11.2 关键字段

| 表名 | 字段 | 说明 |
|---|---|---|
| st_stocktake | id | 主键 |
| st_stocktake | stocktake_no | 盘点单号 |
| st_stocktake | warehouse_id | 仓库ID |
| st_stocktake | stocktake_type | 盘点类型 |
| st_stocktake | status | 状态 |
| st_stocktake | stocktake_date | 盘点日期 |
| st_stocktake_item | stocktake_id | 盘点单ID |
| st_stocktake_item | material_id | 物料ID |
| st_stocktake_item | batch_id | 批次ID |
| st_stocktake_item | location_id | 库位ID |
| st_stocktake_item | system_quantity | 账面数量 |
| st_stocktake_item | stocktake_quantity | 实际数量 |
| st_stocktake_item | diff_quantity | 差异数量 |

### 11.3 数据变更说明

- 新增：盘点主表、明细表
- 修改：盘点状态
- 冻结：盘点期间冻结相关库位库存
- 解冻：盘点完成后解冻库存

---

## 12. API / 接口契约

### 12.1 Schema 配置

- 表编码：WMS0190
- CRUD 前缀：`/api/adjust/stocktake`

### 12.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/adjust/stocktake/list` | 盘点列表 |
| POST | `/api/adjust/stocktake` | 新建盘点 |
| PUT | `/api/adjust/stocktake/{id}` | 编辑盘点 |
| POST | `/api/adjust/stocktake/{id}/submit` | 提交审批 |
| POST | `/api/adjust/stocktake/{id}/approve` | 审批 |
| POST | `/api/adjust/stocktake/{id}/start` | 启动盘点 |
| POST | `/api/adjust/stocktake/{id}/items` | 扫码盘点 |
| POST | `/api/adjust/stocktake/{id}/complete` | 提交盘点 |
| POST | `/api/adjust/stocktake/{id}/confirm` | 确认盘点 |
| POST | `/api/adjust/stocktake/{id}/cancel` | 取消盘点 |
| GET | `/api/adjust/stocktake/{id}/report` | 盘点报表 |
| GET | `/api/adjust/stocktake/export` | 盘点导出 |

### 12.3 请求示例

```json
POST /api/adjust/stocktake
{
  "warehouseId": 1,
  "stocktakeType": "PARTIAL",
  "locationIds": [1, 2, 3],
  "stocktakeDate": "2026-04-10"
}
```

### 12.4 响应示例

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "stocktakeNo": "STK-20260410-000001",
    "status": "DRAFT"
  }
}
```

### 12.5 错误码/异常返回

| 错误码 | 场景 | 提示 |
|---|---|---|
| STK001 | 盘点期间禁止出入库 | 该库位正在盘点中 |
| STK002 | 差异率超限 | 差异率超过阈值，需审批 |
| STK003 | 盘点已完成 | 盘点已完成，无法操作 |

---

## 13. 权限与审计

### 13.1 权限标识

- `wms:stocktake:query`
- `wms:stocktake:add`
- `wms:stocktake:start`
- `wms:stocktake:confirm`

### 13.2 权限要求

- 谁可以查看：仓库管理员
- 谁可以创建：仓库管理员
- 谁可以审批：审批人
- 谁可以确认：仓库管理员

### 13.3 审计要求

- 记录盘点操作人、操作时间
- 记录盘点数量
- 记录状态变更

---

## 14. 异常与边界场景

| 场景 | 预期处理 |
|---|---|
| 盘点期间出入库 | 拒绝操作，提示库位盘点中 |
| 差异率超限 | 提示需审批 |
| 重复提交盘点 | 幂等处理 |
| 取消盘点 | 解锁库位、解冻库存 |

---

## 15. 验收标准

### 15.1 功能验收

- [ ] 新建盘点计划成功
- [ ] 审批流程正常
- [ ] 启动盘点锁定库位
- [ ] 扫码盘点录入正确
- [ ] 差异计算正确
- [ ] 确认盘点库存调整正确
- [ ] 流水生成正确
- [ ] 状态流转正确
- [ ] 盘点期间禁止出入库

### 15.2 数据验收

- [ ] 库存冻结/解冻正确
- [ ] 库位锁定/解锁正确
- [ ] 盘盈/盘亏处理正确

---

## 16. 测试要点

### 16.1 单元测试

- 差异计算正确
- 冻结/解冻逻辑正确

### 16.2 集成测试

- 盘点全流程
- 权限过滤正确

### 16.3 边界测试

- 盘点期间禁止出入库
- 差异率阈值判断

---

## 17. 技术实现约束

- **盘点启动必须在事务内完成**
- 库位锁定使用乐观锁
- 冻结库存不影响可用库存计算
- 并发盘点需检查库位冲突

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

- 盘点期间禁止出入库影响业务

**待确认**

- 盘点差异率阈值（建议 5%）
- 循环盘点规则

---

## 21. 开发回执模板

**改动文件**

```
(开发完成后填写)
```

**实现内容**

```
(开发完成后填写)
```

**验证结果**

```
(开发完成后填写)
```

**未完成/风险**

```
(开发完成后填写)
```

---

## 22. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0190 库存盘点
- 数据库设计：[WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md)
- Epic Brief：[epic-05-overview.md](../../epics/epic-05-overview.md)
- 事务设计：[01-transaction-design.md](../../05-TECH-STANDARDS/01-transaction-design.md)
