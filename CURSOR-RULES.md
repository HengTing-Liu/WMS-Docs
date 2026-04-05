# OpenClaw 与 Cursor 交流规则

> 版本：V1.0
> 日期：2026-04-06
> 适用范围：OpenClaw（wms总控）<-> Cursor

---

## 一、工作文件夹

```
C:\Users\Administrator\.openclaw\workspace-wms\
├── WMS-backend/          # 后端代码（Cursor 开发）
├── WMS-frontend/        # 前端代码（Cursor 开发）
├── WMS-Docs/            # 文档（共同维护）
│   ├── cursor-task.md   # Cursor 当前任务单
│   ├── cursor-result.md # Cursor 执行结果
│   ├── current-story.md # 当前 Story 状态
│   ├── story-index.md  # Story 总览
│   └── story-sequence.md # 开发顺序（254个子任务）
├── memory/              # OpenClaw 记忆
└── .learnings/          # 学习记录
```

---

## 二、文件说明

### 2.1 cursor-task.md（OpenClaw 写，Cursor 读）

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

### 2.2 cursor-result.md（Cursor 写，OpenClaw 读）

Cursor 完成任务后必须写入此文件。

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

## 三、开发流程

### 3.1 串行开发原则

- 每次只进行一个子任务
- 一个子任务完成后才能开始下一个
- 不允许并行开发

### 3.2 任务执行流程

```
1. OpenClaw 写入 cursor-task.md
2. Cursor 读取任务
3. Cursor 执行开发
4. Cursor 写入 cursor-result.md
5. OpenClaw 读取结果
6. OpenClaw 更新 story-index.md 和 current-story.md
7. OpenClaw 写入下一个任务到 cursor-task.md
8. 重复 2-7
```

---

## 四、Git 提交规范

### 4.1 提交信息格式

```
<type>(<scope>): <subject>

type: feat | fix | chore | docs | refactor | test
scope: 模块名称（warehouse/material/inbound/outbound 等）
subject: 简短描述
```

### 4.2 提交示例

```
feat(warehouse): 新增仓库档案查询接口

fix(material): 修复物料列表分页问题

chore(api): 更新入库单 API 模块
```

### 4.3 提交频率

- 每个子任务完成后提交一次
- 不要积累大量修改后再提交
- 提交信息必须描述清楚改动内容

---

## 五、代码规范

### 5.1 后端规范

| 规范 | 说明 |
|------|------|
| 分层 | Controller -> Service -> Mapper |
| 命名 | Java 驼峰，数据库下划线 |
| 事务 | 增删改操作必须加事务 |
| 日志 | 关键操作记录日志 |
| 异常 | 使用统一异常处理 |

### 5.2 前端规范

| 规范 | 说明 |
|------|------|
| 目录 | views/模块名/ |
| API | api/模块名/功能.ts |
| 组件 | 大写开头，PascalCase |
| 样式 | scoped CSS |

### 5.3 数据库规范

| 规范 | 说明 |
|------|------|
| 表名 | 小写下划线，如 wms_warehouse |
| 字段 | 小写下划线 |
| 主键 | id BIGINT |
| 时间 | gmt_create, gmt_modified |

---

## 六、Story 开发顺序

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

## 七、状态更新规则

### 7.1 OpenClaw 负责更新

| 文件 | 更新时机 |
|------|----------|
| story-index.md | 每个子任务完成后 |
| current-story.md | 每个子任务开始前 |
| cursor-task.md | 每个子任务开始前 |

### 7.2 Cursor 负责写入

| 文件 | 写入时机 |
|------|----------|
| cursor-result.md | 每个子任务完成后 |

---

## 八、Cursor 执行检查清单

完成每个任务后，Cursor 必须确认：

- [ ] 代码符合规范
- [ ] 功能按要求实现
- [ ] 自测通过
- [ ] 已提交 Git
- [ ] 已写入 cursor-result.md
- [ ] 无阻塞问题

---

## 九、问题升级规则

遇到以下情况，Cursor 必须记录到 cursor-result.md：

1. **需求不明确** → 在「遗留问题」中说明
2. **技术方案不确定** → 在「遗留问题」中说明
3. **发现关联问题** → 在「遗留问题」中说明
4. **阻塞无法前进** → 在「遗留问题」中说明

---

## 十、交流约定

| 场景 | 处理方式 |
|------|----------|
| 任务完成 | 写入 cursor-result.md |
| 任务阻塞 | 写入 cursor-result.md 说明原因 |
| 需要确认 | 写入 cursor-result.md 等待指示 |
| 有建议 | 写入 cursor-result.md 的「下一步建议」 |
