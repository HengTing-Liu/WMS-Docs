# Story 06-01 质检标准管理

## 0. 基本信息

- Epic：质量控制
- Story ID：06-01
- 优先级：P1
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 3

---

## 1. 目标

实现质检标准管理，支持质检标准的增删改查。

---

## 2. 业务背景

质检标准是医疗器械仓储的合规要求，定义物料的质量检验项目和判定标准。

---

## 3. 范围

### 3.1 本 Story 包含

- 质检标准列表查询
- 质检标准新增
- 质检标准编辑
- 质检标准删除

### 3.2 本 Story 不包含

- 质检标准分类管理

---

## 4. 参与角色

- 质量管理员：管理质检标准

---

## 5. 前置条件

- 用户具备质检标准管理权限

---

## 6. 触发方式

- 页面入口：质量管理 → 质检标准
- 接口入口：GET `/api/qc/standard/list`

---

## 7. 输入 / 输出

### 7.1 新增输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| standardCode | string | Y | 标准编码 |
| standardName | string | Y | 标准名称 |
| qcCategory | string | Y | 质检分类：MEDICAL_DEVICE/DRUG/IVD |
| remark | string | N | 备注 |
| items | array | Y | 检验项目 |
| items[].itemName | string | Y | 项目名称 |
| items[].checkMethod | string | Y | 检查方法 |
| items[].qualitativeResult | string | N | 定性结果 |
| items[].quantitativeStandard | string | N | 定量标准 |
| items[].qualitativeRange | string | N | 合格范围 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 标准ID |
| standardCode | string | 标准编码 |
| standardName | string | 标准名称 |
| qcCategory | string | 质检分类 |

---

## 8. 业务规则

1. **标准编码唯一性**：新增时校验编码不重复
2. **检验项目**：一个标准可有多个检验项目
3. **分类关联**：标准关联物料分类，入库时自动匹配

---

## 9. 数据设计

### 9.1 涉及表

- `qc_standard`
- `qc_standard_item`

### 9.2 关键字段

| 表名 | 字段 | 说明 |
|---|---|---|
| qc_standard | id | 主键 |
| qc_standard | standard_code | 标准编码 |
| qc_standard | standard_name | 标准名称 |
| qc_standard | qc_category | 质检分类 |
| qc_standard_item | standard_id | 标准ID |
| qc_standard_item | item_name | 项目名称 |
| qc_standard_item | check_method | 检查方法 |

---

## 10. API / 接口契约

### 10.1 Schema 配置

- 表编码：WMS0215
- CRUD 前缀：`/api/qc/standard`

### 10.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/qc/standard/list` | 质检标准列表 |
| POST | `/api/qc/standard` | 新增质检标准 |
| PUT | `/api/qc/standard/{id}` | 编辑质检标准 |
| DELETE | `/api/qc/standard/{id}` | 删除质检标准 |

---

## 11. 权限与审计

### 11.1 权限标识

- `wms:qc:standard:query`
- `wms:qc:standard:add`
- `wms:qc:standard:edit`
- `wms:qc:standard:delete`

---

## 12. 验收标准

### 12.1 功能验收

- [ ] 质检标准 CRUD 正常
- [ ] 检验项目配置正常
- [ ] 编码唯一性校验

---

## 13. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 14. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0215 质检标准
- Epic Brief：[epic-06-overview.md](../../epics/epic-06-overview.md)
