# OpenClaw 与 Subagent 交流规则

> 版本：V2.0
> 日期：2026-04-06
> 更新说明：改用 OpenClaw subagent 执行代码开发

---

## 一、Agent 选择

| 任务类型 | Agent | 命令 |
|----------|-------|------|
| 后端开发 | Claude Code | `claude --permission-mode bypassPermissions --print` |
| 前端开发 | Claude Code | `claude --permission-mode bypassPermissions --print` |
| 测试验证 | Claude Code | `claude --permission-mode bypassPermissions --print` |

---

## 二、工作文件夹

```
C:\Users\Administrator\.openclaw\workspace-wms\
├── WMS-backend/          # 后端代码
├── WMS-frontend/        # 前端代码
├── WMS-Docs/           # 文档
```

---

## 三、开发流程

```
OpenClaw PM确认 → 发布 BE 任务 → Subagent 执行 → OpenClaw 接收结果 → 发布 FE 任务 → Subagent 执行 → ...
```

### Subagent 启动命令

```bash
# 后端任务
bash workdir:C:\Users\Administrator\.openclaw\workspace-wms\WMS-backend background:true command:"claude --permission-mode bypassPermissions --print '任务描述'"

# 前端任务
bash workdir:C:\Users\Administrator\.openclaw\workspace-wms\WMS-frontend background:true command:"claude --permission-mode bypassPermissions --print '任务描述'"
```

---

## 四、任务执行

### 4.1 BE 后端任务

1. 读取 `WMS-Docs/cursor-task.md` 获取任务
2. 读取 `WMS-Docs/stories/epic-xx/story-xx-xx-pm-confirm.md` 获取需求
3. 执行后端代码开发
4. Git 提交推送
5. 通知 OpenClaw

### 4.2 FE 前端任务

1. 读取 `WMS-Docs/cursor-task.md` 获取任务
2. 读取 `WMS-Docs/stories/epic-xx/story-xx-xx-pm-confirm.md` 获取需求
3. 执行前端代码开发
4. Git 提交推送
5. 通知 OpenClaw

---

## 五、Git 规范

### 提交格式

```
<type>(<scope>): <subject>

type: feat | fix | chore | docs | test
scope: backend | frontend
subject: 简短描述
```

### 示例

```
feat(backend): 11-01-BE 表元数据管理后端开发完成

feat(frontend): 11-01-FE 表元数据管理前端开发完成
```

---

## 六、代码规范

### 后端规范

| 规范 | 说明 |
|------|------|
| 分层 | Controller -> Service -> Mapper |
| 命名 | Java 驼峰，数据库下划线 |
| 事务 | 增删改操作加 @Transactional |
| 日志 | 关键操作加日志记录 |

### 前端规范

| 规范 | 说明 |
|------|------|
| 目录 | views/模块名/ |
| API | api/模块名/功能.ts |
| 组件 | 大写开头 PascalCase |

---

## 七、检查清单

Subagent 完成任务时必须确认：

- [ ] 代码符合规范
- [ ] 功能按要求实现
- [ ] 自测通过
- [ ] 已提交 Git
- [ ] 已推送 Git
- [ ] 已写入 cursor-result.md
