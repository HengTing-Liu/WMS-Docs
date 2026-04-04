# Story 14-02 物料分类管理

## 0. 基本信息

- Epic：辅助功能与外部接口
- Story ID：14-02
- 优先级：P1
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 1

---

## 1. 目标

实现物料分类的树形管理，支持多层级分类结构。

---

## 2. 业务背景

物料分类用于对物料进行归类，便于管理和统计。

---

## 3. 范围

### 3.1 本 Story 包含

- 物料分类树形查询
- 物料分类新增/编辑/删除
- 拖拽排序

### 3.2 本 Story 不包含

- 物料档案（见 Story 01-04）

---

## 4. API / 接口契约

### 4.1 接口清单

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/base/material-category/tree` | 分类树查询 |
| GET | `/api/base/material-category/{id}` | 分类详情 |
| POST | `/api/base/material-category` | 新增分类 |
| PUT | `/api/base/material-category/{id}` | 编辑分类 |
| DELETE | `/api/base/material-category/{id}` | 删除分类 |
| PUT | `/api/base/material-category/sort` | 批量排序 |

### 4.2 Schema 配置

- **表编码**：WMS0031
- **CRUD前缀**：`/api/base/material-category`

### 4.3 字段定义

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| parentId | long | N | 父级ID，根节点传 0 |
| categoryCode | string | 是 | 分类编码 |
| categoryName | string | 是 | 分类名称 |
| sortOrder | int | 否 | 排序号 |
| remark | string | 否 | 备注 |

---

## 5. 验收标准

- [ ] 分类树形展示正常
- [ ] 拖拽排序功能正常
- [ ] 删除时检查关联物料

---

## 6. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档

---

## 7. 关联文档

- Epic Brief：[epic-14-overview.md](../../epics/epic-14-overview.md)
