# FE 前端开发任务清单

> FE Agent 前端任务进度 | 2026-04-03
> **FE 前端开发任务清单参考：** [项目总览](../项目状态.md)

---

## Phase 0 开发任务总览

## 任务清单：FE-001 搭建 Vben Admin Monorepo 前端工程

**任务描述：** 初始化 WMS-frontend 的 lowcode 前端工程结构

**操作步骤：**
1. 分析 `WMS-frontend/packages/` 目录结构
2. 分析 `WMS-frontend/apps/` 目录结构
3. 分析 `WMS-frontend/internal/` 目录结构
4. 分析 `WMS-frontend/components/common/` 目录，找到 WmsSearchBar 组件
5. **特别注意：** 将前端工程分析结果写入 `docs/FE低代码前端工程分析.md`

**验收标准：** FE 低代码前端工程分析文档参考 `docs/FE低代码前端工程分析.md`

---

## 任务清单：FE-002 创建 Lowcode 业务组件包

**任务描述：** 在 apps/web-antd 下创建 lowcode 业务组件包

**包结构设计：**
```
apps/web-antd/src/lowcode/
│  index.ts              # 入口文件
│  types.ts              # TypeScript 类型定义
│  api.ts                # Meta API + CRUD API
│  LowcodePage.vue        # 动态页面容器（支持查询+表单+表格）
│  LowcodeDrawer.vue      # 动态抽屉表单（支持新建+编辑）
│  README.md              # 组件说明文档
```

**验收标准：** package.json 配置正确

---

## 任务清单：FE-003 WmsSearchBar 组件扩展

**组件功能：** WmsSearchBar 是 WMS 的通用查询栏组件，支持动态配置字段类型

**字段类型映射表：**

| Schema字段类型 | 组件 | 说明 |
|------|------|------|
| `treeSelect` | ATreeSelect | 需要配置 treeUrl，组件内自动请求获取 TreeData 并渲染 |
| `dateRange` | ARangePicker | 配置 `YYYY-MM-DD` 格式，返回 DateTime 字符串 |
| `numberRange` | AInputNumber 输入范围 | 参数 `{key}Min` + `{key}Max` 传给后端 |

**字段数据更新方法：** `updateFieldTreeData(key, treeData)` 手动更新组件树形数据

**验收标准：** 用 3 个以上真实字段测试组件

---

## 任务清单：FE-004 FieldRenderer 字段渲染器

**任务描述：** 实现基于 schema 动态渲染不同类型表单字段

**字段类型映射：**
```typescript
const fieldTypeMap = {
  text: Input,
  textarea: TextArea,
  number: InputNumber,
  select: Select,
  switch: Switch,
  date: DatePicker,
  datetime: DatePicker,
  dateRange: DatePicker.RangePicker,
  treeSelect: TreeSelect,
};
```

**验收标准：** FieldRenderer 根据 schema 渲染正确的表单组件

---

## Phase 1 开发任务

## 任务清单：FE-005 LowcodeLayout 动态页面布局

**任务描述：** 实现支持多 Section 分组的动态页面布局组件

**页面结构设计：**
1. **多 Tab 布局：** 仓库信息 + 联系人信息 + 收货信息 + 备注
2. **多 Column 网格：** 每行按 col_span 权重分配列数

**验收标准：** 低代码页面布局美观整洁

---

## 任务清单：FE-006 LowcodeForm 动态表单

**任务描述：** 基于 Meta Schema 渲染动态表单

**表单渲染逻辑：**
- 按 section_key 分组渲染
- 按 col_span 分配列宽
- 处理必填校验
- 处理 visible_condition 条件字段

**验收标准：** 动态表单数据验证通过

---

## 任务清单：FE-007 WMS0010 仓库管理完整页面

**任务描述：** 完成 WMS0010 仓库管理的完整低代码页面

**页面涉及表：**
- sys_table_meta（仓库主表）
- sys_column_meta（约 20 个字段）
- sys_table_operation（新增、编辑、删除、启禁用操作）
- sys_dict + sys_dict_data（温度区间、品质区间字典）

**验收标准：** 完整页面端到端测试通过

---

## 前端依赖关系

- 字典缓存依赖：`sys_dict` + `dict_type`
- 前端依赖关系：WmsSearchBar → schema → WmsDataTable → LowcodeForm
- 字段渲染依赖：Schema 中的 `ColumnMeta` 字段的 `SearchField` 属性
- Lowcode 业务组件包位置：`apps/web-antd/src/lowcode/`

---

## Phase 1 开发周计划

```
Week 2（FE开发）：
  - FE-001: 前端工程搭建
  - FE-002: Lowcode 包结构
  - FE-003: WmsSearchBar 扩展
  - FE-004: FieldRenderer 字段渲染

Week 3（FE + BE联调）：
  - FE-005: LowcodeLayout 布局
  - FE-006: LowcodeForm 表单
  - FE-007: WMS0010 完整页面
  - 后端接口联调
```

