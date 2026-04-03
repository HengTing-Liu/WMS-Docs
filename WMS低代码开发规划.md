# WMS 低代码平台开发规划

**版本：** v1.0
**创建日期：** 2026-04-03
**负责人：** PM

---

## WMS 低代码平台概述

WMS 低代码平台旨在通过配置化的方式，快速搭建 WMS 系统中的通用管理页面，包括仓库管理、客户管理、供应商管理等。

### 核心功能

| 功能模块 | 技术方案 | 说明 |
|------|------|------------|
| **A 类页面** | 通用 CRUD 页面 | 简单的增删改查页面 |
| **B 类页面** | 通用 CRUD + 树形选择 | 包含树形数据选择器的页面 |
| **C 类页面** | 通用 CRUD + 导入导出 | 包含 Excel 导入导出功能的页面 |

### A 类页面清单

| 模块编码 | 名称 | 字段数 | 表单类型 | 查询条件 | 特点 |
|------|------|----------|----------|---------|-------|
| WMS0010 | 仓库管理 | ~20字段 | 新增+编辑 | 仓库编码+名称+状态 | 通用页面 |
| WMS0030 | 库区管理 | ~35字段 | 新增+编辑 | 库区编码+仓库+状态 | 仓库下级 |
| WMS0040 | 库位管理 | ~10字段 | 新增+编辑 | 库位编码+库区+状态 | 库区下级 |
| WMS0050 | 客户管理 | ~15字段 | 新增+编辑+详情 | 客户编码+名称+状态 | — |
| WMS0060 | 供应商管理 | ~12字段 | 新增+编辑+详情 | 供应商编码+名称+状态 | — |
| WMS0070 | 物料管理 | ~10字段 | 新增+编辑+详情 | 物料编码+名称+规格 | — |
| WMS0215 | 库位映射管理 | ~15字段 | 新增+编辑 | 映射关系 | 仓库下级 |
| WMS0220 | 库存账本 | ~15字段 | 审核+详情 | 物料+批次+仓库 | 账务页面 |
| WMS0430 | 温度区间管理 | ~15字段 | 新增+编辑 | 温度区间编码+名称 | 基础数据 |
| WMS0440 | 品质区间管理 | ~20字段 | 新增+编辑 | 品质区间编码+名称 | 基础数据 |
| WMS0450 | 计量单位管理 | ~10字段 | 新增+编辑 | 单位编码+名称 | 基础数据 |
| WMS0460 | 包装单位管理 | ~15字段 | 新增+编辑 | 包装单位编码+名称 | 基础数据 |
| WMS0470 | 仓库类型管理 | ~10字段 | 新增+编辑 | 类型编码+名称 | 基础数据 |

### B 类页面清单

| 模块编码 | 名称 | WMS 组合 | 查询条件 | 树形字段 | 特殊字段 |
|------|------|----------|---------|---------|-------|
| **WMS0020** | **货主管理** | **独立页面** | 货主编码+货主名称+联系人+电话 | **货主类型** | 货主类型(树形) + 计量单位(多选) + 地址信息 |
| WMS0090 | 库存查询 | 物料+批次+仓库 | 物料编码+批次+仓库+货主 | 物料分类 | 计量单位 + 质量状态(树形) |
| WMS0100 | 入库单管理 | 入库单头+行 | 入库单号+供应商+状态 | 供应商(树形) + 入库类型 | 计量单位 + 入库明细 |
| WMS0110 | 出库单管理 | 出库单头+行 | 出库单号+客户+状态 | 客户(树形) + 出库类型 | 计量单位 + 出库明细 |
| WMS0120~0180 | 各类单据管理 | 单据头+行 | 单据号+类型+状态 | 相关业务类型 | 明细行管理 |
| WMS0190 | 批次属性管理 | 批次属性定义 | 属性编码+属性名称+数据类型 | **物料分类(树形)** | 属性定义 |
| WMS0200 | 计量单位转换 | 单位转换规则 | 源单位+目标单位 | 物料分类(树形) | 转换系数 |
| WMS0210 | 库位分配规则 | 分配规则定义 | 规则编码+规则名称 | **仓库(树形)** | 分配策略 |

### C 类页面清单

| 模块编码 | 名称 | WMS 组合 | 说明 |
|------|------|------|
| WMS0080 | 物料批量导入 | 物料基础数据导入 | Excel 导入 + 模板下载 |
| WMS0230~0280 | 各类单据批量导入 | 单据批量导入 | Excel 导入 + 模板下载 |
| WMS0290~0330 | 各类单据批量导出 | 单据批量导出 | Excel 导出 + 模板配置 |
| WMS0340~0420 | 各类报表导出 | 报表数据导出 | Excel 导出 + 报表配置 |
| WMS0410~0420 | 系统参数配置 | 系统参数管理 | 参数定义 + 参数值 |

---

## MVP 核心能力 & WMS 典型页面

### MVP 核心能力

| 核心能力 | 技术方案 | WMS 典型页面 |
|------------|--------------|--------------|
| **通用列表页** | WmsDataTable 组件 + Schema 配置 | WMS0010/WMS0030/WMS0040 |
| **通用表单页** | WmsFormSchema 动态表单 + meta 表配置 | WMS0010 新增/编辑 |
| **字段渲染** | FieldRenderer 字段渲染器 | text/select/number/treeSelect |
| **字段渲染** | FieldRenderer Select | dict 数据源字典渲染 |
| **字段渲染** | FieldRenderer Number | 数字输入 |
| **字段渲染** | FieldRenderer Textarea | 多行文本 |
| **字段渲染** | FieldRenderer Date/datetime | 日期选择 |
| **字段渲染** | FieldRenderer Switch | 开关切换 |
| **字段渲染** | FieldRenderer TreeSelect | 树形选择 |
| **字典数据渲染** | 字典下拉组件 | 温度区间、品质区间等字典选择 |
| **数据权限** | injectDataScope 数据范围过滤 | 基于用户的仓库权限 |
| **树形数据查询** | treeSelect 树形数据查询 | WMS0020 货主类型 |

### MVP 后续阶段

| 核心能力 | 说明 | 目标页面 |
|------------|------|----------|
| 树形数据管理 | 树形 CRUD + Schema 配置 | WMS0020 货主管理 |
| 数据导入 | Excel 导入 + 数据校验 | MVP 完成后 |
| 数据导出 | Excel 导出 + 模板配置 | MVP 完成后 |
| 高级查询 | 复杂查询条件 | WMS0220 库存账本 |

---

## 开发任务总览

### Phase 0：基础设施搭建（本周）

**目标：** 完成数据库设计和后端基础设施搭建

| 开发任务 | 负责人 | 工期 |
|------|--------|------|
| 1.1 创建 Meta 表 DDL | 后端 | 3d |
| 1.2 前端工程分析 | 前端 | 3d |
| 1.3 Meta Schema 查询 | 后端 | 3d |
| 1.4 WMS0010 配置 | 全员 | 2d |

### Phase 1：MVP 阶段（次周）

**目标：** 完成动态表单 CRUD + WmsSearchBar + Lowcode 前端组件开发

#### Week 1（后端开发）

| 开发任务 | 工期 | 验收标准 |
|------|--------|---------|
| sys_column_meta 扩展字段 | 1d | DDL 执行成功 |
| 动态 CRUD 接口 | 2d | Postman 测试通过 |
| LowcodeTreeService | 1d | 树形数据查询 |
| 数据权限注入 | 1d | 数据范围过滤 |
| 启禁用接口 | 0.5d | toggleStatus 接口 |
| 字段占用检查 | 0.5d | occupancy check |

#### Week 2（前端开发）

| 开发任务 | 工期 | 验收标准 |
|------|--------|---------|
| LowcodeLayout 布局 | 1d | 多 Tab + 多 Column 布局 |
| LowcodeForm 表单 | 2d | text/select/number/textarea/date/switch |
| WmsSearchBar 扩展 | 1d | treeSelect 字段查询 |
| WmsDataTable 列表 | 1d | 分页+排序+过滤 |
| 字典数据渲染 | 1d | 字典下拉组件 |

#### Week 3（联调 & WMS0010 完整页面）

| 开发任务 | 工期 | 验收标准 |
|------|--------|---------|
| 仓库管理表配置 | 0.5d | sys_table_meta 配置 |
| 字段元数据配置 | 1d | ~20个字段配置 |
| 操作按钮配置 | 0.5d | 新增+编辑+删除+启禁用 |
| 字典数据配置 | 0.5d | 温度区间+品质区间字典 |
| 联调测试 | 1.5d | 完整页面端到端测试 |

**Phase 1 里程碑：** MVP 功能完成 + WMS0010 仓库管理完整页面上线

### Phase 2：高级功能（待定）

| 开发任务 | 说明 | 目标页面 |
|------------|------|----------|
| treeSelect 字段渲染 | 树形数据选择器 | WMS0440/WMS0450 |
| 表格列配置 | 可配置显示列 | WMS0030 |
| 树形数据管理 | 树形 CRUD + Schema 配置 | WMS0020 |
| 表格批量操作 | 批量选择+批量操作 | WMS0030 |
| Excel 导入 | Excel 导入 + 数据校验 | WMS0020 |
| Excel 导出 | Excel 导出 + 模板配置 | WMS0020 |

### Phase 3：复杂页面（待定）

**目标：** 实现批次管理 + 计量单位转换 + 多表关联页面

### Phase 4：平台扩展（待定）

**目标：** 实现平台级别的配置能力，支持多业务线扩展

---

## 数据库表结构设计

### 1. sys_table_meta 表结构

```sql
-- WMS0010 仓库管理参考
INSERT INTO sys_table_meta (table_code, table_name, module, entity_class, service_class,
  permission_code, page_size, is_tree, status, remark)
VALUES
  ('WMS0010', '仓库管理', '仓储管理',
   'com.xxx.wms.entity.WmsWarehouse',
   'com.xxx.wms.service.WmsWarehouseService',
   'wms:warehouse', 20, 0, 1,
   '仓库管理页面，支持仓库信息维护、启禁用等功能');
```

### 2. sys_column_meta 表结构

```sql
-- WMS0010 字段元数据参考
INSERT INTO sys_column_meta (table_code, field, title, data_type, form_type, dict_type,
  is_show_in_list, is_show_in_form, is_searchable, is_required, is_sortable,
  width, sort_order, placeholder, default_value, col_span, section_key)
VALUES
  ('WMS0010', 'warehouse_code', '仓库编码', 'string', 'text', null,
   1, 1, 1, 1, 1, 120, 1, '请输入仓库编码', null, 6, 'basic'),
  ('WMS0010', 'warehouse_name', '仓库名称', 'string', 'text', null,
   1, 1, 1, 1, 0, 150, 2, '请输入仓库名称', null, 6, 'basic'),
  ('WMS0010', 'temperature_zone', '温度区间', 'string', 'select', 'wms_temperature_zone',
   1, 1, 1, 1, 0, 100, 3, null, null, 6, 'basic'),
  ('WMS0010', 'quality_zone', '品质区间', 'string', 'select', 'wms_quality_zone',
   1, 1, 0, 1, 0, 120, 4, null, null, 6, 'basic'),
  ('WMS0010', 'is_enabled', '启用状态', 'boolean', 'switch', null,
   1, 1, 0, 0, 0, 80, 5, null, '1', 6, 'basic');
```

### 3. sys_table_operation 表结构

```sql
INSERT INTO sys_table_operation (table_code, operation_code, operation_name,
  operation_type, button_type, icon, permission, position, sort_order, status)
VALUES
  ('WMS0010', 'create', '新增', 'form', 'primary', 'Plus', 'wms:warehouse:create', 'toolbar', 1, 1),
  ('WMS0010', 'edit', '编辑', 'form', 'default', 'Edit', 'wms:warehouse:edit', 'row', 1, 1),
  ('WMS0010', 'delete', '删除', 'confirm', 'danger', 'Delete', 'wms:warehouse:delete', 'row', 2, 1),
  ('WMS0010', 'toggle', '启禁用', 'confirm', 'warning', 'Swap', 'wms:warehouse:toggle', 'row', 3, 1);
```

### 4. sys_dict + sys_dict_data 表结构

```sql
-- 温度区间字典
INSERT INTO sys_dict (dict_type, dict_name, status) VALUES ('wms_temperature_zone', '温度区间', 1);

INSERT INTO sys_dict_data (dict_type, dict_label, dict_value, sort_order) VALUES
  ('wms_temperature_zone', '常温(RT)', 'RT', 1),
  ('wms_temperature_zone', '4℃', '4C', 2),
  ('wms_temperature_zone', '-20℃', 'N20', 3),
  ('wms_temperature_zone', '-40℃', 'N40', 4),
  ('wms_temperature_zone', '-80℃', 'N80', 5),
  ('wms_temperature_zone', '液氮(-196℃)', 'LN2', 6);

-- 品质区间字典
INSERT INTO sys_dict (dict_type, dict_name, status) VALUES ('wms_quality_zone', '品质区间', 1);

INSERT INTO sys_dict_data (dict_type, dict_label, dict_value, sort_order) VALUES
  ('wms_quality_zone', '待检', 'pending', 1),
  ('wms_quality_zone', '合格', 'qualified', 2),
  ('wms_quality_zone', '不合格', 'unqualified', 3),
  ('wms_quality_zone', '留样', 'sample', 4),
  ('wms_quality_zone', '隔离', 'isolated', 5);
```

---

## 技术架构总览

| 模块编码 | 名称 | 类型 | 开发优先级 | 备注 |
|------|------|------|---------|------|
| WMS0010 | 仓库管理 | A | **P0 MVP** | 通用页面MVP |
| WMS0020 | 货主管理 | B | P1 | 树形选择 |
| WMS0030 | 库区管理 | A | P1 | 仓库下级 |
| WMS0040 | 库位管理 | A | P2 | 库区下级 |
| WMS0050 | 客户管理 | A | P1 | — |
| WMS0060 | 供应商管理 | A | P2 | — |
| WMS0070 | 物料管理 | A | P2 | — |
| WMS0080 | 物料批量导入 | C | P3 | — |
| WMS0090 | 库存查询 | B | P2 | 物料分类 |
| WMS0100 | 入库单管理 | B | P1 | 供应商 |
| WMS0110 | 出库单管理 | B | P2 | 客户 |
| WMS0120 | 入库明细管理 | B | P2 | — |
| WMS0130 | 出库明细管理 | B | P2 | — |
| WMS0140 | 入库审核 | B | P1 | — |
| WMS0150 | 出库审核 | B | P2 | — |
| WMS0160 | 库存冻结 | B | P2 | — |
| WMS0170 | 库存调整 | B | P3 | — |
| WMS0180 | 批次调整 | B | P3 | — |
| WMS0190 | 批次属性管理 | B | P1 | 物料分类 |
| WMS0200 | 计量单位转换 | B | P2 | 物料分类 |
| WMS0210 | 库位分配规则 | B | P2 | 仓库 |
| WMS0215 | 库位映射管理 | A | P2 | 仓库下级 |
| WMS0220 | 库存账本 | A | P1 | 账务页面 |
| WMS0230~0280 | 各类单据批量导入 | C | P3 | — |
| WMS0290~0330 | 各类单据批量导出 | C | P2 | — |
| WMS0340~0420 | 各类报表导出 | C | P3 | — |
| WMS0430 | 温度区间管理 | A | P2 | — |
| WMS0440 | 品质区间管理 | A | P2 | — |
| WMS0450 | 计量单位管理 | A | P2 | — |
| WMS0460 | 包装单位管理 | A | P2 | — |
| WMS0470 | 仓库类型管理 | A | P2 | — |

---

## 风险与注意事项

1. **WMS 40+ 页面中 50% 可通过低代码平台配置实现，剩余 50% 需要定制开发**
2. **Phase 1 MVP 优先完成 WMS0010 仓库管理 1 个页面作为试点，验证技术方案可行性**
3. **通用组件（LowcodeForm + WmsSearchBar）需要 2-3 周开发时间**，涉及 A 类页面和部分 B 类页面
4. **B 类页面**需要额外开发树形数据管理功能，包括树形 CRUD + Schema 配置 + 树形选择器组件
5. **C 类页面**需要额外开发 Excel 导入导出功能，包括模板设计 + 数据校验 + 批量处理能力

---

## 开发计划

### 风险提示

1. **WMS 40+ 页面中 50% 可通过低代码平台配置实现，剩余 50% 需要定制开发**
2. **Phase 1 MVP 优先完成 WMS0010 仓库管理 1 个页面作为试点，验证技术方案可行性**
3. **通用组件（LowcodeForm + WmsSearchBar）需要 2-3 周开发时间**

### 详细计划

| 阶段 | 内容 | 负责人 | 工期 |
|------|------|--------|------|
| Phase 0 第 1 步 | 低代码平台基础设施搭建 | 后端 | T+3d |
| Phase 0 第 2 步 | Lowcode 前端工程分析 | 前端 | T+5d |
| Phase 0 第 3 步 | Meta Schema 查询 + DDL | 后端 | T+5d |
| Phase 1 第 1 步 | WMS0010 仓库管理完整页面 | 全员 | T+6d |

