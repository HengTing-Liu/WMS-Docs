# Cursor Task

> 版本：V2.0
> 日期：2026-04-06
> 子任务：11-01-QA

---

## 执行 Agent

**使用 Claude Code Subagent 执行测试验收任务**

---

## 当前子任务

- **编号**：11-01-QA
- **名称**：表元数据管理-测试验收
- **所属 Story**：11-01 表元数据管理
- **所属 Epic**：Epic-11 低代码配置管理
- **串行顺序**：第 4 个子任务
- **前置任务**：11-01-FE ✅ 已完成

---

## 本轮只处理

完成表元数据管理的功能测试验收。

---

## 测试范围

### 功能测试
1. 列表查询（分页 + 模糊搜索）
2. 新增表元数据
3. 编辑表元数据
4. 删除表元数据（含关联字段检查）
5. 启用/禁用切换

### 接口测试
| 方法 | 路径 | 测试点 |
|------|------|--------|
| GET | `/api/system/meta/table` | 分页查询、模糊搜索 |
| GET | `/api/system/meta/table/{id}` | 详情查询 |
| GET | `/api/system/meta/table/code/{code}` | 按编码查询 |
| POST | `/api/system/meta/table` | 新增（编码唯一性） |
| PUT | `/api/system/meta/table/{id}` | 更新 |
| DELETE | `/api/system/meta/table/{id}` | 删除（含关联检查） |
| PUT | `/api/system/meta/table/{id}/toggle` | 启用/禁用 |

---

## 测试数据

| 字段 | 值 |
|------|-----|
| tableCode | TEST_TABLE_001 |
| tableName | 测试表 |
| module | system |
| status | 1 |

---

## 允许修改

- `WMS-Docs/` — 文档

---

## 禁止修改

- `WMS-backend/` — 后端代码
- `WMS-frontend/` — 前端代码
- 数据库表结构

---

## 完成标准

- [ ] 接口逐一测试通过
- [ ] 功能流程测试通过
- [ ] 异常场景测试通过（编码重复、删除有关联等）
- [ ] 记录测试结果

---

## 下一步

测试通过后，更新 story-index.md 中 11-01 状态为完成，并开始下一个 Story。
