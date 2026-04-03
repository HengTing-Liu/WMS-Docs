# WMS 低代码平台 - 任务清单导航

> **使用说明：**本文档是 WMS 低代码平台项目的任务导航入口。所有 Agent 在 `docs/tasks/` 目录下维护各自的任务清单 Markdown 文件。Cursor 用户可通过 @ 引用任务文件来与对应 Agent 沟通。

---

## 角色 & Agent 导航

| 角色 | 职责 | Agent UUID | 任务清单 |
|------|------|-----------|---------|
| **PM** | 项目管理、需求评审、进度跟踪 | `90e37f9f-47ff-4395-b223-b75f92a0505f` | 暂无 |
| **BE** | 后端：Dynamic Meta DDL + CRUD Service | `8e83b6b3-dd9a-4853-873d-2e19c06efca1` | [BE-任务清单.md](./BE-任务清单.md) |
| **FE** | 前端：Vue3/VbenAdmin Lowcode 前端组件 | `939b8d86-fc2c-4561-ba60-2ef9e24b47eb` | [FE-任务清单.md](./FE-任务清单.md) |
| **QA** | 测试：可测性评审 + 测试用例 + E2E | `94396ced-fbb2-4cca-b8df-2b3bb550b43e` | [QA-任务清单.md](./QA-任务清单.md) |

---

## 文件导航

### PM
1. 参考文档：[项目总览](../项目状态.md) 了解项目整体进度
2. 参考文档：[PM-任务清单.md](./PM-任务清单.md) 查看 PM 待办事项

### BE后端任务
1. 参考文档：[BE-任务清单.md](./BE-任务清单.md)
2. 参考文档：[WMS低代码开发规划.md](../WMS低代码开发规划.md)
   - **BE-001** Phase 0：创建 SCM 系统的 Meta 表 DDL
   - **BE-002** Phase 0：创建 sys_column_meta 扩展字段 DDL
   - **BE-003** Phase 0：创建 ColumnMeta 实体类 + Schema 查询
   - **BE-004** Phase 0：实现动态 CRUD 接口

### FE前端任务
1. 参考文档：[FE-任务清单.md](./FE-任务清单.md)
2. 参考文档：[WMS低代码开发规划.md](../WMS低代码开发规划.md)
   - **FE-001** Phase 0：搭建 Vben Admin monorepo 工程
   - **FE-002** Phase 0：创建 Lowcode 业务组件包
   - **FE-003** Phase 0：WmsSearchBar 组件扩展
   - **FE-004** Phase 0：FieldRenderer 字段渲染器
   - **FE-005** Phase 1：LowcodeLayout 动态页面布局
   - **FE-006** Phase 1：LowcodeForm 动态表单
   - **FE-007** Phase 1：WMS0010 仓库管理完整页面

### QA测试任务
1. 参考文档：[QA-任务清单.md](./QA-任务清单.md)
2. 参考文档：[PM-通知汇总.md](./PM-通知汇总.md)
   - **QA-001** Phase 0：需求可测性评审
   - **QA-002** Phase 0：测试策略文档评审
   - **QA-003** Phase 1：Phase 1 测试用例设计
   - **QA-004** Phase 1：BE/FE 功能验收测试

---

## 项目文档结构

```
docs/
│  项目状态.md                    ← 项目总览和进度
│  WMS低代码开发规划.md            ← 低代码平台开发规划
│  WmsSearchBar组件分析.md        ← WmsSearchBar 组件分析
│  半低代码平台PRD-V1.0.md        ← PRD 需求文档
│  tasks/
│     README.md                   ← 本文件：任务导航
│     BE-任务清单.md              ← BE 开发任务
│     FE-任务清单.md              ← FE 开发任务
│     PM-任务清单.md              ← PM 任务
│     PM-通知汇总.md              ← PM 通知汇总
│     QA-任务清单.md              ← QA 测试任务
│     QA-001-需求可测性评审.md    ← 需求可测性评审
│     测试策略.md                 ← 测试策略文档
│     测试用例-Phase1.md          ← Phase 1 测试用例
│     验收记录.md                 ← 验收记录
```

---

> 所有 Agent 在 `docs/tasks/` 目录下维护各自的任务清单 Markdown 文件。Cursor 用户可通过 @ 引用任务文件与对应 Agent 沟通。参考 [docs/tasks/README.md](./README.md) 了解任务管理规范。
> 请各 Agent 在完成任务后更新 `docs/项目状态.md` 的里程碑记录，并通知 PM Agent 进行验收。
