# Cursor Task

> 版本：V1.0
> 日期：2026-04-06
> 子任务：11-01-PM

---

## 执行 Agent

**使用 MDC（Claude Code）执行开发任务**

命令：`/cursor` 或在 MDC 中启动 Claude Code

---

## 当前子任务

- **编号**：11-01-PM
- **名称**：表元数据管理-需求分析
- **所属 Story**：11-01 表元数据管理
- **所属 Epic**：Epic-11 低代码配置管理
- **串行顺序**：第 1 个子任务

---

## 本轮只处理

完成表元数据管理的需求确认，输出确认后的字段规范、接口契约、权限方案。

---

## 背景

- Epic-11 是整个项目的基础设施，所有前端页面都依赖低代码配置
- 表元数据（sys_table_meta）是低代码平台的核心配置表
- 本任务是 Epic-11 的第一个子任务，需要为后续所有 Story 提供基础

---

## 必读文件

- `WMS-Docs/stories/epic-11/story-11-01.md` — Story 11-01 完整需求
- `WMS-Docs/04-DESIGN/03-lowcode-design.md` — 低代码设计文档
- `WMS-Docs/05-TECH-STANDARDS/04-permission-design.md` — 权限设计文档

---

## 允许修改

- `WMS-Docs/stories/epic-11/story-11-01.md` — 更新需求确认状态

---

## 禁止修改

- 其他 Story 文档
- 低代码设计文档（只读参考）

---

## 完成标准

- [ ] 确认 sys_table_meta 字段规范（tableCode/tableName/tableDesc/module/crudPrefix/isEnabled）
- [ ] 确认 CRUD 接口契约（GET/POST/PUT/DELETE 路径和参数）
- [ ] 确认权限配置方案（权限标识符命名规范）
- [ ] 更新 story-11-01.md 中的「风险与待确认项」为已确认状态

---

## 输出要求

完成后必须输出到 `cursor-result.md`：

1. 实际修改文件
2. 确认的字段规范
3. 确认的接口契约
4. 确认的权限方案
5. 遗留问题（无或列出）

---

## Git 提交

任务完成后执行：

```bash
git add .
git commit -m "docs: 11-01-PM 表元数据管理需求确认完成"
git push
```

---

## 下一步

完成后通知 OpenClaw，等待下一个任务。
