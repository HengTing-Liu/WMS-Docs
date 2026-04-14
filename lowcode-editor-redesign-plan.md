# 低代码编辑页改造方案

## 1. 目标

本轮先不直接改代码，先统一改造方向。目标很明确：

1. 编辑页从当前抽屉模式改为全屏编辑。
2. 编辑内容使用标准表单布局，不再依赖当前这套偏自定义的页面样式。
3. 支持字段分组配置。
4. 每个分组支持单独标题。
5. 尽量复用项目现有框架能力，优先按官方文档配置，而不是继续堆自定义 CSS。

## 2. 当前现状

当前低代码编辑链路主要是：

1. [LowcodePage.vue](/c:/Users/LHT/Desktop/gitwms/WMS-frontend/apps/web-antd/src/lowcode/LowcodePage.vue) 负责列表页和打开编辑入口。
2. [LowcodeDrawer.vue](/c:/Users/LHT/Desktop/gitwms/WMS-frontend/apps/web-antd/src/lowcode/LowcodeDrawer.vue) 使用 `Drawer` 承载编辑界面。
3. [DynamicFormDefinitionPage.vue](/c:/Users/LHT/Desktop/gitwms/WMS-frontend/apps/web-antd/src/components/DynamicFormDefinitionPage.vue) 负责动态表单渲染。

我看下来，当前“看起来不太好看”的根因主要有 3 个：

1. 编辑页还是抽屉思路，长表单天然会显得拥挤。
2. `DynamicFormDefinitionPage.vue` 里有一整套 `.df-*` 自定义样式，视觉上已经偏离当前项目主流表单写法。
3. 分组只是当前组件内部自己渲染 section 标题，还没有形成真正可配置的“分组元数据”。

另外还有一个实现层面的风险：

1. [LowcodeDrawer.vue](/c:/Users/LHT/Desktop/gitwms/WMS-frontend/apps/web-antd/src/lowcode/LowcodeDrawer.vue) 传了 `fullscreen` 给 `ant-design-vue` 的 `Drawer`。
2. 但官方 Drawer 文档重点提供的是 `width`、`height`、`placement`、`extra` 等能力，没有把“fullscreen”作为标准能力来用。
3. 所以“全屏编辑”更适合改成独立页面，而不是继续在抽屉上硬扩。

## 3. 官方文档依据

这次方案优先贴着当前项目已经在用的框架能力走：

1. Vben Form 文档：<https://doc.vben.pro/components/common-ui/vben-form.html>
2. Ant Design Drawer 文档：<https://ant.design/components/drawer-cn/>
3. Ant Design Card 文档：<https://ant.design/components/card-cn/>
4. Ant Design Collapse 文档：<https://ant.design/components/collapse-cn/>
5. Ant Design Tabs 文档：<https://ant.design/components/tabs-cn/>

这几份文档里，对我们这次方案最关键的点是：

1. `useVbenForm` 本身支持 `layout`、`wrapperClass`、`formItemClass`、`showDefaultActions` 等表单布局配置。
2. `Card` 适合作为最稳定的“分组容器”。
3. `Collapse` 适合做“高级信息/可折叠分组”。
4. `Tabs` 适合分组很多、信息层级明显的场景，但不建议一开始就默认上 Tabs。
5. Drawer 更适合“侧滑编辑”或“快速编辑”，不适合承载越来越重的主编辑页。

## 4. 推荐方向

### 4.1 页面形态

推荐把“新建/编辑”从当前 `LowcodeDrawer` 改成独立的全屏页面：

1. 列表页仍然保留在 `LowcodePage`。
2. 点击“新建/编辑”后，跳转到独立的低代码编辑路由。
3. 页面容器使用 `Page`。
4. 分组容器默认使用 `Card`。
5. 保存/取消使用页面级按钮，不再依赖抽屉底部自定义 sticky footer。

推荐这个方向的原因：

1. 更符合“全屏编辑”的要求。
2. 长表单体验更自然。
3. 后续加分组、折叠、锚点、页内导航都更容易。
4. 不需要继续围绕 Drawer 做很多兼容处理。

### 4.2 表单渲染方式

推荐把低代码编辑页逐步切到项目已经有的 `useVbenForm` 方案，而不是继续扩 `DynamicFormDefinitionPage` 的自定义样式体系。

建议做法：

1. 后端 meta 先转成前端统一的 `group + schema[]` 结构。
2. 前端每个分组渲染一个 `VbenForm` 实例。
3. 每个分组内部仍然使用 `schema` 驱动字段。
4. 保存时把所有分组表单的值合并后提交。

这条路径和现有项目里的多段表单写法是对齐的，例如：

1. [add.vue](/c:/Users/LHT/Desktop/gitwms/WMS-frontend/apps/web-antd/src/views/system/productCategory/add.vue) 已经是“多个表单块 + 分段标题”的思路。
2. [CrudPage.vue](/c:/Users/LHT/Desktop/gitwms/WMS-frontend/apps/web-antd/src/components/crud/CrudPage.vue) 也已经在使用 `useVbenForm`。

### 4.3 分组容器策略

默认建议：

1. 普通业务表单：`Card`
2. 字段很多但不常填：`Collapse`
3. 分组数量特别多且层级明显：`Tabs`

第一阶段建议只落地两种：

1. `card`
2. `collapse`

这样复杂度最低，也最容易稳定。

## 5. 元数据设计建议

这里我建议不要只靠字段表重复写“分组标题”，否则后面很快会难维护。

推荐方案是：

### 5.1 新增分组元数据表

建议新增一张分组配置表，例如 `sys_form_group_meta`：

| 字段 | 说明 |
|---|---|
| `id` | 主键 |
| `table_code` | 对应表编码 |
| `group_code` | 分组编码，唯一标识 |
| `group_title` | 分组标题 |
| `group_order` | 分组排序 |
| `group_type` | 分组类型，建议值：`card` / `collapse` |
| `default_open` | 是否默认展开 |
| `remark` | 备注 |

### 5.2 字段元数据补充分组归属

在字段元数据里补一个字段即可，例如：

| 字段 | 说明 |
|---|---|
| `form_group_code` | 当前字段属于哪个分组 |

现有字段里的 `form_col_span` 可以继续保留，用来控制字段在表单中的宽度，不需要推翻重做。

### 5.3 为什么推荐这套设计

优点：

1. 分组标题只维护一次。
2. 一个分组下挂多个字段很自然。
3. 后面如果要支持折叠、页签、分组权限、分组描述，都有扩展点。
4. 前后端职责会更清晰。

不推荐的简化方案：

1. 在每个字段上同时写 `groupCode` 和 `groupTitle`。
2. 这样初期能跑，但后期会出现标题重复、排序冲突、维护困难的问题。

## 6. 前端落地方案

### 6.1 新增页面组件

建议新增独立页面，例如：

1. `LowcodeFormPage.vue`
2. `LowcodeFormSection.vue`

职责建议：

1. `LowcodeFormPage.vue`：负责加载 meta、加载详情、保存、取消、页面标题。
2. `LowcodeFormSection.vue`：负责单个分组容器，内部渲染 `VbenForm`。

### 6.2 路由方式

建议新建低代码编辑路由，而不是继续在列表页里直接开抽屉。

例如：

1. 新建：`/lowcode/form/:tableCode/create`
2. 编辑：`/lowcode/form/:tableCode/edit/:id`

这样后面会更方便：

1. 支持分享链接。
2. 支持浏览器前进后退。
3. 支持后续做“详情页”和“复制新增”。

### 6.3 页面结构

推荐结构：

1. 顶部：页面标题 + 返回 + 保存/取消
2. 中间：按分组渲染 `Card` 或 `Collapse`
3. 每个分组内部：`useVbenForm`
4. 底部：如果按钮已经放顶部，则底部不重复放；如果后续体验不好，再考虑保留底部操作栏

### 6.4 样式原则

这次建议明确收口：

1. 不再继续扩写 `DynamicFormDefinitionPage.vue` 里的大段 `.df-*` 视觉样式。
2. 主要依赖 Vben Form 的布局能力和 Ant Design 组件默认样式。
3. 只保留少量必要的间距类名，例如分组间距、页面留白。

## 7. 分阶段实施建议

### 第一阶段

目标：先跑通“全屏 + 表单 + 分组”主链路。

范围：

1. 新增分组元数据结构。
2. 新建 `LowcodeFormPage`。
3. 列表页点击新建/编辑时跳转到全屏页。
4. 分组默认用 `Card`。
5. 先保留 `LowcodeDrawer`，但不再作为主入口。

### 第二阶段

目标：补充分组交互能力。

范围：

1. 分组支持 `collapse`。
2. 支持默认展开/折叠。
3. 支持按分组排序。
4. 支持分组为空时隐藏。

### 第三阶段

目标：统一低代码表单渲染内核。

范围：

1. 逐步减少 `DynamicFormDefinitionPage.vue` 的使用场景。
2. 让低代码编辑页统一走 `VbenForm schema`。
3. 评估是否将旧动态表单页面迁移。

## 8. 我建议我们先这样定

如果按“先稳住架构，再慢慢打磨”的思路，我建议先采用下面这套基线：

1. 编辑页改为独立全屏页面。
2. 分组容器默认用 `Card`。
3. 每个分组标题来自分组元数据。
4. 字段通过 `form_group_code` 归组。
5. 表单渲染切到 `useVbenForm`。
6. `Collapse` 作为第二阶段能力，不在第一版强行一起做。

这条路径的优点是：

1. 方向清晰。
2. 跟当前项目已有写法兼容。
3. 不需要自己重写一套新的视觉系统。
4. 后面你想继续调“分组长什么样、分组是否可折叠、按钮放顶部还是底部”都还有空间。

## 9. 本轮结论

本轮先不改功能，只确定方案：

1. 放弃“继续美化抽屉”的思路。
2. 改为“全屏编辑页 + Vben Form + Ant Design 分组容器”。
3. 分组能力通过元数据建模，不写死在前端组件里。
4. 第一版只做 `Card` 分组，后续再加 `Collapse`。
