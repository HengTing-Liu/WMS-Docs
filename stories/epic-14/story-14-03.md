# Story 14-03 供应商档案

## 0. 基本信息

- Epic：辅助功能与外部接口
- Story ID：14-03
- 优先级：P1
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 2

---

## 1. 目标

实现供应商档案的查询、新增、编辑功能。

---

## 2. 业务背景

供应商档案用于管理采购来源，是采购入库的重要基础数据。

---

## 3. 范围

### 3.1 本 Story 包含

- 供应商档案列表查询
- 供应商档案新增
- 供应商档案编辑
- 供应商档案启用/禁用

### 3.2 本 Story 不包含

- 供应商资质管理（后续迭代）

---

## 4. API / 接口契约

### 4.1 接口清单

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/base/supplier/list` | 供应商列表 |
| GET | `/api/base/supplier/{id}` | 供应商详情 |
| POST | `/api/base/supplier` | 新增供应商 |
| PUT | `/api/base/supplier/{id}` | 编辑供应商 |
| DELETE | `/api/base/supplier/{id}` | 删除供应商 |
| PUT | `/api/base/supplier/{id}/toggle` | 启用/禁用 |

### 4.2 Schema 配置

- **表编码**：WMS0032
- **CRUD前缀**：`/api/base/supplier`

### 4.3 字段定义

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| supplierCode | string | 是 | 供应商编码 |
| supplierName | string | 是 | 供应商名称 |
| contact | string | 否 | 联系人 |
| phone | string | 否 | 联系电话 |
| address | string | 否 | 地址 |
| type | string | 否 | 供应商类型 |
| status | string | 是 | 状态：ENABLED/DISABLED |
| remark | string | 否 | 备注 |

---

## 5. 验收标准

- [ ] 供应商 CRUD 功能正常
- [ ] 编码唯一性校验
- [ ] 关联入库单检查

---

## 6. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档

---

## 7. 关联文档

- Epic Brief：[epic-14-overview.md](../../epics/epic-14-overview.md)
