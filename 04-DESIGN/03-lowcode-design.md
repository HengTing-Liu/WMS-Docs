# WMS仓库物流系统 - 低代码架构设计

> 版本：V1.0
> 日期：2026-04-03
> 适用范围：前端低代码页面开发

---

## 一、概述

### 1.1 设计目标

WMS低代码平台旨在通过**数据库驱动的元数据配置**，实现档案页面的零代码开发。开发者只需在数据库中配置表结构、字段属性、操作按钮，即可自动生成完整的CRUD页面。

### 1.2 核心价值

| 价值点 | 说明 |
|--------|------|
| **提效** | 新增档案页面从3天缩短至30分钟 |
| **统一** | 所有档案页面风格一致，用户体验好 |
| **降本** | 减少前端开发工作量，聚焦复杂业务 |
| **灵活** | 字段调整无需改代码，修改配置即可 |

---

## 二、整体架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           低代码渲染引擎                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐              │
│  │ LowcodePage  │    │ LowcodeDrawer │    │FieldRenderer │              │
│  │  (列表页)    │    │  (表单抽屉)   │    │  (字段渲染)  │              │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘              │
│         │                   │                   │                       │
│         └───────────────────┼───────────────────┘                       │
│                             ▼                                           │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    前端组件库 (Vue3 + Ant Design Vue)              │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           Meta API 层                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  GET /api/system/meta/column/schema?tableCode=xxx   → 获取字段Schema     │
│  GET /api/system/meta/table/{code}                 → 获取表元数据        │
│  GET /api/system/meta/operation/list/{code}        → 获取操作按钮        │
│  GET /api/system/dict/data/{dictType}              → 获取字典选项        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        MetaController (后端)                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  sys_table_meta     → 表元数据（名称、编码、描述）                        │
│  sys_column_meta    → 字段元数据（类型、必填、显示等）                    │
│  sys_table_operation→ 操作元数据（按钮、权限、位置）                       │
│  sys_dict           → 字典类型                                           │
│  sys_dict_data      → 字典数据                                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 三、核心组件

### 3.1 LowcodePage（标准列表页）

**功能**: 自动渲染搜索栏 + 数据表格 + 操作按钮 + 新建/编辑抽屉

**使用示例**:

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
  />
</template>

<script setup lang="ts">
import LowcodePage from '#/lowcode/LowcodePage.vue';
import type { StatsCardConfig } from '#/lowcode/types';

const statsConfig: StatsCardConfig[] = [
  { key: 'total', label: '总仓库数', icon: 'material-symbols:warehouse', color: '#1677ff', field: 'totalCount' },
  { key: 'enabled', label: '已启用', icon: 'material-symbols:check-circle', color: '#52c41a', field: 'enabledCount' },
];
</script>
```

**组件Props**:

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

**组件Events**:

| 事件 | 参数 | 说明 |
|------|------|------|
| search | query | 搜索触发 |
| create | - | 新建按钮点击 |
| edit | record | 编辑按钮点击 |
| delete | id | 删除成功 |
| toggle | record, enabled | 启用/停用 |
| formSuccess | record | 表单保存成功 |

**组件Methods**:

| 方法 | 说明 |
|------|------|
| reload() | 刷新列表数据 |

---

### 3.2 LowcodeDrawer（表单抽屉）

**功能**: 动态渲染新建/编辑表单，基于后端meta配置

**使用示例**:

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
import LowcodeDrawer from '#/lowcode/LowcodeDrawer.vue';

const drawerVisible = ref(false);
const currentRecord = ref(null);

function onFormSuccess(record) {
  console.log('保存成功', record);
  drawerVisible.value = false;
}
</script>
```

**组件Props**:

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| open | boolean | 是 | 抽屉是否打开（v-model:open） |
| tableCode | string | 是 | 表编码 |
| record | Record | 否 | 当前编辑记录（null=新增） |
| width | number\|string | 否 | 抽屉宽度，默认600 |
| readonly | boolean | 否 | 只读模式 |
| formDefinitionUrl | string | 否 | 表单定义接口路径 |
| submitUrl | string | 否 | 提交接口路径 |

**组件Events**:

| 事件 | 参数 | 说明 |
|------|------|------|
| success | record | 保存成功 |
| error | err | 保存失败 |
| close | - | 抽屉关闭 |

---

### 3.3 FieldRenderer（字段渲染器）

**功能**: 根据schema配置渲染对应的表单控件

**支持字段类型**:

| 类型 | 控件 | 说明 |
|------|------|------|
| text | AInput | 单行文本 |
| textarea | AInput.TextArea | 多行文本 |
| number | AInputNumber | 数字输入 |
| select | ASelect | 下拉选择 |
| switch | ASwitch | 开关 |
| date | ADatePicker | 日期选择 |
| datetime | ADatePicker | 日期时间选择 |

**使用示例**:

```vue
<template>
  <FieldRenderer
    :field="fieldSchema"
    v-model="formModel.fieldName"
  />
</template>

<script setup lang="ts">
import { reactive } from 'vue';
import { FieldRenderer } from '#/lowcode';

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

## 四、Meta 数据结构

### 4.1 sys_table_meta（表元数据）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT | 主键 |
| table_code | VARCHAR(50) | 表编码（如 WMS0010） |
| table_name | VARCHAR(100) | 表名称 |
| table_desc | VARCHAR(500) | 表描述 |
| module | VARCHAR(50) | 所属模块 |
| crud_prefix | VARCHAR(100) | CRUD接口前缀 |
| is_enabled | TINYINT | 是否启用 |
| created_at | DATETIME | 创建时间 |
| updated_at | DATETIME | 更新时间 |

### 4.2 sys_column_meta（字段元数据）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT | 主键 |
| table_id | BIGINT | 表ID（关联sys_table_meta） |
| column_code | VARCHAR(50) | 字段编码 |
| column_name | VARCHAR(100) | 字段名称 |
| field_type | VARCHAR(20) | 字段类型（text/textarea/number/select/switch/date/datetime） |
| data_type | VARCHAR(20) | 数据类型（string/int/decimal/datetime） |
| dict_type | VARCHAR(50) | 字典类型编码 |
| is_required | TINYINT | 是否必填 |
| is_unique | TINYINT | 是否唯一 |
| is_show_in_list | TINYINT | 是否在列表显示 |
| is_show_in_form | TINYINT | 是否在表单显示 |
| is_sortable | TINYINT | 是否可排序 |
| list_width | INT | 列表列宽 |
| form_col_span | INT | 表单列宽占比 |
| default_value | VARCHAR(100) | 默认值 |
| placeholder | VARCHAR(100) | 占位符 |
| valid_rules | VARCHAR(500) | 校验规则（JSON格式） |
| sort_order | INT | 排序 |
| is_enabled | TINYINT | 是否启用 |

### 4.3 sys_table_operation（操作元数据）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT | 主键 |
| table_id | BIGINT | 表ID |
| operation_code | VARCHAR(50) | 操作编码（如 create/edit/delete/export） |
| operation_name | VARCHAR(50) | 操作名称 |
| button_type | VARCHAR(20) | 按钮类型（primary/default/danger） |
| icon | VARCHAR(50) | 图标 |
| permission | VARCHAR(100) | 权限标识 |
| position | VARCHAR(20) | 位置（toolbar/row） |
| operation_type | VARCHAR(20) | 操作类型（normal/confirm） |
| confirm_message | VARCHAR(200) | 确认提示 |
| sort_order | INT | 排序 |
| is_enabled | TINYINT | 是否启用 |

---

## 五、CRUD 接口约定

### 5.1 接口列表

```
GET    /api/{module}/{entity}/list      → 列表查询
GET    /api/{module}/{entity}/{id}       → 详情
POST   /api/{module}/{entity}            → 新增
PUT    /api/{module}/{entity}/{id}       → 修改
DELETE /api/{module}/{entity}/{id}       → 删除
PUT    /api/{module}/{entity}/{id}/toggle → 启用/停用
GET    /api/{module}/{entity}/export     → 导出
```

### 5.2 请求响应格式

**列表查询请求**:

```json
{
  "pageNum": 1,
  "pageSize": 20,
  "warehouseCode": "WH001",
  "warehouseName": "上海仓"
}
```

**列表查询响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "rows": [
      {
        "id": 1,
        "warehouseCode": "WH001",
        "warehouseName": "上海仓",
        "isEnabled": 1
      }
    ],
    "total": 100
  }
}
```

**新增/修改请求**:

```json
{
  "warehouseCode": "WH001",
  "warehouseName": "上海仓",
  "company": "ABC公司",
  "isEnabled": 1
}
```

**新增/修改响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1
  }
}
```

---

## 六、页面开发流程

### 6.1 新增档案页面步骤

**Step 1: 后端配置 Meta 数据（约10分钟）**

在数据库中插入配置数据：

```sql
-- 1. 插入表元数据
INSERT INTO sys_table_meta (table_code, table_name, module, crud_prefix)
VALUES ('WMS0090', '生产入库', 'inbound', '/api/inbound/production');

-- 2. 插入字段元数据
INSERT INTO sys_column_meta (table_id, column_code, column_name, field_type, is_show_in_list, is_show_in_form, sort_order)
VALUES
  (@table_id, 'inbound_no', '入库单号', 'text', 1, 1, 1),
  (@table_id, 'warehouse_id', '仓库', 'select', 1, 1, 2),
  (@table_id, 'inbound_date', '入库日期', 'date', 1, 1, 3);

-- 3. 插入操作元数据
INSERT INTO sys_table_operation (table_id, operation_code, operation_name, button_type, position)
VALUES
  (@table_id, 'create', '新建', 'primary', 'toolbar'),
  (@table_id, 'edit', '编辑', 'default', 'row'),
  (@table_id, 'delete', '删除', 'danger', 'row');
```

**Step 2: 前端新建页面（约5分钟）**

在 `views/lowcode/` 下新建目录：

```vue
<!-- views/lowcode/wms0090/index.vue -->
<template>
  <LowcodePage
    table-code="WMS0090"
    page-title="生产入库"
    page-desc="管理生产入库单据"
    crud-prefix="/api/inbound/production"
    :show-stats="true"
    :stats-config="statsConfig"
  />
</template>

<script setup lang="ts">
import LowcodePage from '#/lowcode/LowcodePage.vue';
import type { StatsCardConfig } from '#/lowcode/types';

const statsConfig: StatsCardConfig[] = [
  { key: 'total', label: '总单数', icon: 'material-symbols:receipt', color: '#1677ff', field: 'total' },
  { key: 'pending', label: '待入库', icon: 'material-symbols:pending', color: '#faad14', field: 'pending' },
];
</script>
```

**Step 3: 配置路由（约1分钟）**

在路由配置中添加：

```typescript
{
  path: '/lowcode/wms0090',
  name: 'WMS0090',
  component: () => import('#/views/lowcode/wms0090/index.vue'),
  meta: { title: '生产入库', icon: 'material-symbols:inventory' }
}
```

**Step 4: 完成！**

三步即可上线一个新页面。

---

## 七、适用场景

### 7.1 适用场景

| 场景 | 说明 |
|------|------|
| ✅ 纯档案页面 | 增删改查、启用停用、导出（仓库、物料、供应商等） |
| ✅ 简单单据 | 单表数据 + 状态流转（部分入库、出库单） |
| ✅ 快速原型 | 需求不确定时的快速验证 |

### 7.2 不适用场景

| 场景 | 说明 |
|------|------|
| ❌ 多行明细 | 订单明细、入库明细等行项目 |
| ❌ 复杂状态机 | 多阶段审批流程 |
| ❌ 特殊交互 | 扫码、打印、二维码等特殊操作 |
| ❌ 自定义布局 | 非标准表单布局 |

---

## 八、扩展计划

### 8.1 v2.0 扩展功能

| 功能 | 说明 |
|------|------|
| 子表支持 | 支持主子表布局 |
| 条件显示 | 根据字段值显示/隐藏字段 |
| 联动下拉 | 级联选择 |
| 自定义校验 | 业务规则校验 |
| 行内编辑 | 表格行内直接编辑 |

### 8.2 v3.0 扩展功能

| 功能 | 说明 |
|------|------|
| 流程表单 | 审批流程集成 |
| 自定义组件 | 注册自定义字段类型 |
| 页面模板 | 保存/复用页面模板 |
| 灰度发布 | 配置灰度开关 |
