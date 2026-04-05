# Story 14-04 客户档案

## 0. 基本信息

- Epic：辅助功能与外部接口
- Story ID：14-04
- 优先级：P1
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 2

---

## 1. 目标

实现客户档案的查询、新增、编辑功能。

---

## 2. 业务背景

客户档案用于管理销售出库的目的方，是销售出库的重要基础数据。

---

## 3. 范围

### 3.1 本 Story 包含

- 客户档案列表查询
- 客户档案新增
- 客户档案编辑
- 客户档案启用/禁用

### 3.2 本 Story 不包含

- 客户信用管理（后续迭代）

---

## 4. API / 接口契约

### 4.1 接口清单

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/base/customer/list` | 客户列表 |
| GET | `/api/base/customer/{id}` | 客户详情 |
| POST | `/api/base/customer` | 新增客户 |
| PUT | `/api/base/customer/{id}` | 编辑客户 |
| DELETE | `/api/base/customer/{id}` | 删除客户 |
| PUT | `/api/base/customer/{id}/toggle` | 启用/禁用 |

### 4.2 Schema 配置

- **表编码**：WMS0033
- **CRUD前缀**：`/api/base/customer`

### 4.3 字段定义

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| customerCode | string | 是 | 客户编码 |
| customerName | string | 是 | 客户名称 |
| contact | string | 否 | 联系人 |
| phone | string | 否 | 联系电话 |
| address | string | 否 | 地址 |
| type | string | 否 | 客户类型 |
| taxNo | string | 否 | 税号 |
| bankName | string | 否 | 开户行 |
| bankAccount | string | 否 | 银行账号 |
| status | string | 是 | 状态：ENABLED/DISABLED |
| remark | string | 否 | 备注 |

---

## 5. 验收标准

- [ ] 客户 CRUD 功能正常
- [ ] 编码唯一性校验
- [ ] 关联出库单检查

---

## 6. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档

---

## 7. 关联文档

- Epic Brief：[epic-14-overview.md](../../epics/epic-14-overview.md)
