# Story 14-05 序列号规则

## 0. 基本信息

- Epic：辅助功能与外部接口
- Story ID：14-05
- 优先级：P1
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 2

---

## 1. 目标

实现序列号规则配置，支持自定义单据编号生成规则。

---

## 2. 业务背景

系统中的各类单据（入库单、出库单、盘点单等）需要按照统一规则生成编号，便于追溯和管理。

---

## 3. 范围

### 3.1 本 Story 包含

- 序列号规则列表查询
- 序列号规则新增/编辑
- 序列号规则启用/禁用
- 序列号生成服务

### 3.2 本 Story 不包含

- 序列号使用记录查询

---

## 4. API / 接口契约

### 4.1 接口清单

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/system/sequence/list` | 规则列表 |
| GET | `/api/system/sequence/{id}` | 规则详情 |
| POST | `/api/system/sequence` | 新增规则 |
| PUT | `/api/system/sequence/{id}` | 编辑规则 |
| DELETE | `/api/system/sequence/{id}` | 删除规则 |
| PUT | `/api/system/sequence/{id}/toggle` | 启用/禁用 |
| GET | `/api/system/sequence/generate/{bizType}` | 生成序列号 |

### 4.2 Schema 配置

- **表编码**：WMS0034
- **CRUD前缀**：`/api/system/sequence`

### 4.3 字段定义

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| bizType | string | 是 | 业务类型 |
| bizName | string | 是 | 业务名称 |
| prefix | string | 是 | 前缀（如 IN、OUT） |
| dateFormat | string | 是 | 日期格式（如 yyyyMMdd） |
| seqLength | int | 是 | 序号长度（如 4 表示 0001） |
| isEnabled | int | 是 | 是否启用 |

### 4.4 序列号规则表达式

| 占位符 | 说明 | 示例 |
|--------|------|------|
| {prefix} | 前缀 | IN |
| {date} | 日期 | 20260403 |
| {time} | 时间 | 143025 |
| {seq} | 序号 | 0001 |
| {warehouse} | 仓库编码 | WH01 |

### 4.5 生成示例

- 规则：{prefix}{date}{seq}
- 生成：IN202604030001

---

## 5. 验收标准

- [ ] 规则 CRUD 功能正常
- [ ] 序列号按规则正确生成
- [ ] 并发生成序号不重复

---

## 6. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档

---

## 7. 关联文档

- Epic Brief：[epic-14-overview.md](../../epics/epic-14-overview.md)
