# Cursor Task

> 版本：V1.0
> 日期：2026-04-06
> 子任务：11-01-FE

---

## 执行 Agent

**使用 Claude Code Subagent 执行前端开发任务**

---

## 当前子任务

- **编号**：11-01-FE
- **名称**：表元数据管理-前端开发
- **所属 Story**：11-01 表元数据管理
- **所属 Epic**：Epic-11 低代码配置管理
- **串行顺序**：第 3 个子任务
- **前置任务**：11-01-BE ✅ 已完成

---

## 本轮只处理

完成表元数据管理的前端页面开发。

---

## 需求依据

已确认的需求见：`WMS-Docs/stories/epic-11/story-11-01-pm-confirm.md`

---

## 后端接口

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/system/meta/table` | 表元数据列表查询（分页+模糊搜索） |
| GET | `/api/system/meta/table/{id}` | 表元数据详情 |
| GET | `/api/system/meta/table/code/{code}` | 通过编码查询 |
| POST | `/api/system/meta/table` | 创建表元数据 |
| PUT | `/api/system/meta/table/{id}` | 更新表元数据 |
| DELETE | `/api/system/meta/table/{id}` | 删除表元数据 |
| PUT | `/api/system/meta/table/{id}/toggle` | 启用/禁用切换 |

---

## 前端要求

1. 使用低代码配置方式开发页面
2. 列表页：搜索表单 + 表格 + 分页
3. 表单页：新增/编辑弹窗
4. 支持搜索字段：tableCode, tableName, module
5. 列表字段：tableCode, tableName, module, entityClass, serviceClass, status, gmtCreate
6. 操作按钮：新增、编辑、删除、启用禁用

---

## 允许修改

- `WMS-frontend/` — 前端代码

---

## 禁止修改

- `WMS-backend/` — 后端代码
- 数据库表结构

---

## 完成标准

- [ ] 列表页开发完成
- [ ] 新增/编辑弹窗开发完成
- [ ] 删除功能开发完成
- [ ] 启用禁用功能开发完成
- [ ] 与后端接口联调通过

---

## Git 提交

```bash
git add .
git commit -m "feat(frontend): 11-01-FE 表元数据管理前端开发完成"
git push
```

---

## 下一步

完成后通知 OpenClaw。
