# OpenClaw 与 Cursor 交流规则

> 版本：V1.1
> 日期：2026-04-06
> 更新说明：使用 Git 推送文件交流，Cursor 使用 MDC

---

## 一、Git 交流机制

### 1.1 文件传输流程

```
OpenClaw 写文件 → Git 提交 → Git 推送 → Cursor Git 拉取 → Cursor 读取
Cursor 写文件 → Git 提交 → Git 推送 → OpenClaw Git 拉取 → OpenClaw 读取
```

### 1.2 Git 仓库

| 仓库 | 地址 | 用途 |
|------|------|------|
| WMS-Docs | git@github.com:HengTing-Liu/WMS-Docs.git | 文档交流 |
| WMS-backend | git@github.com:HengTing-Liu/WMS-backend.git | 后端代码 |
| WMS-frontend | git@github.com:HengTing-Liu/WMS-frontend.git | 前端代码 |

### 1.3 Git 操作频率

| 时机 | 操作 |
|------|------|
| 任务开始前 | OpenClaw Git 推送任务文件 |
| 任务完成后 | Cursor Git 推送结果文件 |
| OpenClaw 响应前 | OpenClaw Git 拉取最新 |

---

## 二、工作文件夹

```
C:\Users\Administrator\.openclaw\workspace-wms\
├── WMS-backend/          # 后端代码
├── WMS-frontend/        # 前端代码
├── WMS-Docs/           # 文档（通过 Git 交流）
│   ├── cursor-task.md   # Cursor 当前任务单
│   ├── cursor-result.md # Cursor 执行结果
│   ├── current-story.md # 当前 Story 状态
│   ├── story-index.md  # Story 总览
│   ├── story-sequence.md # 开发顺序
│   └── CURSOR-RULES.md # 交流规则
├── memory/              # OpenClaw 记忆
└── .learnings/         # 学习记录
```

---

## 三、文件说明

### 3.1 cursor-task.md（OpenClaw 写，Cursor 读）

Cursor 每次只读这个文件，按要求执行任务。

```markdown
# Cursor Task

## 当前子任务
- **编号**：11-01-PM
- **名称**：表元数据管理-需求分析

## 本轮只处理
- [具体任务描述]

## 必读文件
- 文件1路径
- 文件2路径

## 允许修改
- 文件1
- 文件2

## 禁止修改
- 其他文件

## 完成标准
- [ ] 标准1
- [ ] 标准2

## 输出要求
完成后必须输出：
1. 实际修改文件
2. 改动摘要
3. 验证方式
4. 验证结果
5. 遗留问题
```

### 3.2 cursor-result.md（Cursor 写，OpenClaw 读）

Cursor 完成任务后必须写入此文件，然后 Git 推送。

```markdown
# Cursor 执行结果

## 任务编号
11-01-PM

## 任务名称
表元数据管理-需求分析

## 实际修改文件
- file1.md
- file2.ts

## 改动摘要
- 改动1
- 改动2

## 验证方式
- 验证方式1
- 验证方式2

## 验证结果
- [x] 完成
- [ ] 未完成（原因）

## 遗留问题
- 问题1（无 / 列出）

## 下一步建议
- 建议1
```

---

## 四、开发流程

### 4.1 串行开发原则

- 每次只进行一个子任务
- 一个子任务完成后才能开始下一个
- 不允许并行开发

### 4.2 完整交互流程

```
┌─────────────────────────────────────────────────────────────┐
│ OpenClaw（wms总控）                                          │
├─────────────────────────────────────────────────────────────┤
│ 1. 写入 cursor-task.md                                       │
│ 2. Git 提交 WMS-Docs                                        │
│ 3. Git 推送 WMS-Docs                                        │
│ 4. 等待 Cursor 推送                                         │
│ 5. Git 拉取 WMS-Docs                                        │
│ 6. 读取 cursor-result.md                                    │
│ 7. 更新 story-index.md / current-story.md                    │
│ 8. 写入下一个 cursor-task.md                                 │
│ 9. Git 提交推送                                             │
│ 10. 重复 4-9                                                │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Cursor（MDC）                                                │
├─────────────────────────────────────────────────────────────┤
│ 1. Git 拉取 WMS-Docs                                        │
│ 2. 读取 cursor-task.md                                      │
│ 3. 执行开发任务                                             │
│ 4. Git 提交代码 + WMS-Docs（结果）                          │
│ 5. Git 推送所有修改                                          │
│ 6. 等待下一个任务                                           │
│ 7. 重复 1-6                                                │
└─────────────────────────────────────────────────────────────┘
```

### 4.3 Git 提交时机

| 操作方 | 时机 | 提交内容 |
|--------|------|----------|
| OpenClaw | 任务开始前 | cursor-task.md + 更新状态文件 |
| Cursor | 任务完成后 | 代码修改 + cursor-result.md |

---

## 五、Git 提交规范

### 5.1 提交信息格式

```
<type>(<scope>): <subject>

type: feat | fix | chore | docs | refactor | test
scope: 模块名称（warehouse/material/inbound/outbound 等）
subject: 简短描述
```

### 5.2 提交示例

```
feat(warehouse): 新增仓库档案查询接口

fix(material): 修复物料列表分页问题

chore(api): 更新入库单 API 模块

docs: 更新 cursor-task.md 11-01-PM
```

### 5.3 OpenClaw 提交示例

```
docs: 更新 story-index.md 当前进度

docs: 写入 11-02-PM 任务单
```

### 5.4 Cursor 提交示例

```
feat(material): 完成物料档案动态表单功能

fix(warehouse): 修复收货地址 Controller 路径

docs: 11-01-PM 任务完成，更新需求确认
```

---

## 六、代码规范

### 6.1 后端规范

| 规范 | 说明 |
|------|------|
| 分层 | Controller -> Service -> Mapper |
| 命名 | Java 驼峰，数据库下划线 |
| 事务 | 增删改操作必须加事务 |
| 日志 | 关键操作记录日志 |
| 异常 | 使用统一异常处理 |

### 6.2 前端规范

| 规范 | 说明 |
|------|------|
| 目录 | views/模块名/ |
| API | api/模块名/功能.ts |
| 组件 | 大写开头，PascalCase |
| 样式 | scoped CSS |

### 6.3 数据库规范

| 规范 | 说明 |
|------|------|
| 表名 | 小写下划线，如 wms_warehouse |
| 字段 | 小写下划线 |
| 主键 | id BIGINT |
| 时间 | gmt_create, gmt_modified |

---

## 七、Story 开发顺序

详见 `WMS-Docs/story-sequence.md`

### 当前开发顺序（Phase 0 - 低代码配置）

```
11-01-PM → 11-01-BE → 11-01-FE → 11-01-QA
    ↓
11-02-PM → 11-02-BE → 11-02-FE → 11-02-QA
    ↓
...（严格串行）
```

---

## 八、状态更新规则

### 8.1 OpenClaw 负责更新

| 文件 | 更新时机 |
|------|----------|
| story-index.md | 每个子任务完成后 |
| current-story.md | 每个子任务开始前 |
| cursor-task.md | 每个子任务开始前 |

### 8.2 Cursor 负责写入

| 文件 | 写入时机 |
|------|----------|
| cursor-result.md | 每个子任务完成后 |

---

## 九、Cursor 执行检查清单

完成每个任务后，Cursor 必须确认：

- [ ] 代码符合规范
- [ ] 功能按要求实现
- [ ] 自测通过
- [ ] 已提交 Git
- [ ] 已推送 Git
- [ ] 已写入 cursor-result.md
- [ ] 无阻塞问题

---

## 十、问题升级规则

遇到以下情况，Cursor 必须记录到 cursor-result.md：

1. **需求不明确** → 在「遗留问题」中说明
2. **技术方案不确定** → 在「遗留问题」中说明
3. **发现关联问题** → 在「遗留问题」中说明
4. **阻塞无法前进** → 在「遗留问题」中说明

---

## 十一、交流约定

| 场景 | 处理方式 |
|------|----------|
| 任务完成 | 写入 cursor-result.md + Git 推送 |
| 任务阻塞 | 写入 cursor-result.md 说明原因 + Git 推送 |
| 需要确认 | 写入 cursor-result.md 等待指示 + Git 推送 |
| 有建议 | 写入 cursor-result.md 的「下一步建议」 |

---

## 十二、Cursor 使用 MDC

Cursor 使用 MDC（或其他 Cursor AI 工具）执行开发任务。

MDC 操作方式：
- 使用 MDC 的 `/cursor` 命令启动 Cursor
- 通过 MDC 与 Cursor 交互执行代码开发
- 所有代码修改通过 MDC/Cursor 完成
