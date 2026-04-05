# Story 11-06 前端低代码组件

## 0. 基本信息

- Epic：低代码配置管理
- Story ID：11-06
- 优先级：P0
- 状态：Draft
- 预计工期：1d
- 依赖 Story：11-05（低代码引擎接口）
- 关联迭代：Sprint 1

---

## 1. 目标

实现前端低代码核心组件 LowcodePage、LowcodeDrawer、FieldRenderer，为低代码页面开发提供基础设施支撑。

---

## 2. 业务背景

前端低代码组件是基于后端元数据配置动态渲染页面的核心组件。开发者只需配置元数据，即可生成完整的 CRUD 页面，大幅提升开发效率。

---

## 3. 范围

### 3.1 本 Story 包含

- LowcodePage 组件（标准列表页）
- LowcodeDrawer 组件（表单抽屉）
- FieldRenderer 组件（字段渲染器）
- 字典数据请求封装
- Schema 请求封装

### 3.2 本 Story 不包含

- 元数据管理页面（见 Story 11-01~11-04）
- 低代码引擎接口（见 Story 11-05）

---

## 4. 参与角色

- 前端开发：使用低代码组件开发页面

---

## 5. 前置条件

- Story 11-05 已完成
- 后端接口可用

---

## 6. 组件设计

### 6.1 LowcodePage（标准列表页）

**功能**：自动渲染搜索栏 + 数据表格 + 操作按钮 + 分页 + 统计卡片

**Props**：

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| tableCode | string | 是 | 表编码，对应 sys_table_meta.table_code |
| pageTitle | string | 否 | 页面标题 |
| pageDesc | string | 否 | 页面描述 |
| crudPrefix | string | 否 | CRUD接口前缀，默认按约定推断 |
| showStats | boolean | 否 | 是否显示统计卡片 |
| statsConfig | StatsCardConfig[] | 否 | 统计卡片配置 |
| enableSelection | boolean | 否 | 是否开启行选择 |
| staticColumns | any[] | 否 | 静态表格列配置（优先于meta） |
| staticOperations | LowcodeAction[] | 否 | 静态操作按钮（优先于meta） |

**Events**：

| 事件 | 参数 | 说明 |
|------|------|------|
| search | query | 搜索触发 |
| create | - | 新建按钮点击 |
| edit | record | 编辑按钮点击 |
| delete | id | 删除成功 |
| toggle | record, enabled | 启用/停用 |
| formSuccess | record | 表单保存成功 |

**Methods**：

| 方法 | 说明 |
|------|------|
| reload() | 刷新列表数据 |

**使用示例**：

```vue
<template>
  <LowcodePage
    table-code="WMS0010"
    page-title="仓库档案"
    page-desc="管理仓库基本信息"
    :crud-prefix="'/api/base/warehouse'"
    :show-stats="true"
    :stats-config="statsConfig"
    :enable-selection="true"
    @edit="handleEdit"
    @delete="handleDelete"
  />
</template>

<script setup lang="ts">
import LowcodePage from '@/components/lowcode/LowcodePage.vue';
import type { StatsCardConfig } from '@/components/lowcode/types';

const statsConfig: StatsCardConfig[] = [
  { key: 'total', label: '总仓库数', icon: 'warehouse', color: '#1677ff', field: 'totalCount' },
  { key: 'enabled', label: '已启用', icon: 'check-circle', color: '#52c41a', field: 'enabledCount' },
];
</script>
```

### 6.2 LowcodeDrawer（表单抽屉）

**功能**：动态渲染新建/编辑表单，基于后端meta配置

**Props**：

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| open | boolean | 是 | 抽屉是否打开（v-model:open） |
| tableCode | string | 是 | 表编码 |
| record | Record | 否 | 当前编辑记录（null=新增） |
| width | number\|string | 否 | 抽屉宽度，默认600 |
| readonly | boolean | 否 | 只读模式 |

**Events**：

| 事件 | 参数 | 说明 |
|------|------|------|
| success | record | 保存成功 |
| error | err | 保存失败 |
| close | - | 抽屉关闭 |

**使用示例**：

```vue
<template>
  <LowcodeDrawer
    v-model:open="drawerVisible"
    table-code="WMS0010"
    :record="currentRecord"
    width="600"
    @success="onFormSuccess"
  />
</template>

<script setup lang="ts">
import { ref } from 'vue';
import LowcodeDrawer from '@/components/lowcode/LowcodeDrawer.vue';

const drawerVisible = ref(false);
const currentRecord = ref(null);

function onFormSuccess(record) {
  console.log('保存成功', record);
  drawerVisible.value = false;
}
</script>
```

### 6.3 FieldRenderer（字段渲染器）

**功能**：根据schema配置渲染对应的表单控件

**支持字段类型**：

| 类型 | 控件 | 说明 |
|------|------|------|
| text | AInput | 单行文本 |
| textarea | AInput.TextArea | 多行文本 |
| number | AInputNumber | 数字输入 |
| select | ASelect | 下拉选择 |
| switch | ASwitch | 开关 |
| date | ADatePicker | 日期选择 |
| datetime | ADatePicker | 日期时间选择 |

**Props**：

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| field | FieldSchema | 是 | 字段配置 |
| modelValue | any | 是 | 绑定值（v-model） |
| readonly | boolean | 否 | 只读模式 |

**使用示例**：

```vue
<template>
  <FieldRenderer
    :field="fieldSchema"
    v-model="formModel.fieldName"
  />
</template>

<script setup lang="ts">
import { reactive } from 'vue';
import { FieldRenderer } from '@/components/lowcode';

const fieldSchema = {
  field: 'warehouseName',
  label: '仓库名称',
  fieldType: 'text',
  required: true,
  placeholder: '请输入仓库名称'
};

const formModel = reactive({
  warehouseName: ''
});
</script>
```

---

## 7. 技术实现

### 7.1 目录结构

```
src/
└── components/
    └── lowcode/
        ├── index.ts                    # 导出入口
        ├── types.ts                    # 类型定义
        ├── LowcodePage.vue            # 列表页组件
        ├── LowcodeDrawer.vue          # 表单抽屉组件
        ├── FieldRenderer.vue          # 字段渲染器
        ├── SearchForm.vue             # 搜索表单
        ├── DataTable.vue              # 数据表格
        ├── StatsCards.vue             # 统计卡片
        └── hooks/
            ├── useSchema.ts           # Schema获取
            ├── useDict.ts             # 字典数据
            └── useCrud.ts             # CRUD操作
```

### 7.2 Schema 获取

```typescript
// hooks/useSchema.ts
export function useSchema(tableCode: string) {
  const schema = ref<LowcodeSchema | null>(null);
  const loading = ref(false);

  async function fetchSchema() {
    loading.value = true;
    try {
      const res = await request.get('/api/system/lowcode/schema', {
        params: { tableCode }
      });
      schema.value = res.data;
    } finally {
      loading.value = false;
    }
  }

  return { schema, loading, fetchSchema };
}
```

---

## 8. 验收标准

### 8.1 功能验收

- [ ] LowcodePage 组件渲染正常
- [ ] LowcodeDrawer 组件渲染正常
- [ ] FieldRenderer 渲染各类型字段正常
- [ ] Schema 动态加载正常
- [ ] 字典数据加载正常

### 8.2 性能验收

- [ ] 组件首次渲染 < 200ms
- [ ] 表单切换 < 100ms

---

## 9. 交付物清单

- [ ] LowcodePage 组件
- [ ] LowcodeDrawer 组件
- [ ] FieldRenderer 组件
- [ ] Hooks 封装
- [ ] 使用文档

---

## 10. 关联文档

- Epic Brief：[epic-11-overview.md](../../epics/epic-11-overview.md)
- 低代码设计：[04-DESIGN/03-lowcode-design.md](../../04-DESIGN/03-lowcode-design.md)
- 前端开发指南：[05-DEV-GUIDE/02-frontend-dev-guide.md](../../05-DEV-GUIDE/02-frontend-dev-guide.md)
- 页面开发指南：[05-DEV-GUIDE/03-page-impl-guide.md](../../05-DEV-GUIDE/03-page-impl-guide.md)
