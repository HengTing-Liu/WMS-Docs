# WmsSearchBar 组件分析

**版本：** v1.0
**创建日期：** 2026-04-03
**负责人：** FE
**关联需求：** WMS 低代码平台开发规划

---

## 1. WmsSearchBar 组件概述

WmsSearchBar 是 WMS 系统的通用查询栏组件，基于 `components/common/WmsSearchBar` 目录实现。该组件通过 `snake_case` 字段名转换为 `camelCase` 格式，支持 `ColumnMeta` 字段的 `options` 属性动态配置。

### 1.1 组件属性

| 属性名 | 类型 | 说明 |
|--------|------|------|
| fields | SearchField[] | 查询字段配置列表 |
| remoteFieldsUrl | string | 远程获取字段配置的 API 地址 |
| cacheKey | string | localStorage 缓存 key |
| modelValue | Record<string, any> | 双向绑定查询条件 |

### 1.2 事件

| 事件名 | 参数类型 | 说明 |
|--------|------|------|
| update:modelValue | Record<string, any> | 双向绑定更新查询条件 |
| search | Record<string, any> | 触发搜索事件，传递查询参数 |
| reset | — | 重置查询条件 |

### 1.3 字段类型

| 字段类型 | 组件 | 说明 |
|---------|------|------|
| input | A-Input | 文本输入框 |
| select | A-Select | 下拉选择框 |
| switch | A-Switch | 开关切换 |

### 1.4 树形数据处理

组件支持通过 `updateFieldTreeData(key, treeData)` 方法动态更新树形字段的数据源，实现按需加载树节点内容。

