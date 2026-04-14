# 低代码工具栏按钮事件配置设计文档

> 版本：v1.0
> 日期：2026-04-09
> 状态：草稿

---

## 一、背景与目标

### 1.1 现状问题

当前 `LowcodePage.vue` 的工具栏按钮存在以下问题：

1. **硬编码匹配**：按钮类型只能通过 `action.key === 'create'` 或 `action.key === 'export'` 匹配
2. **事件固定**：无法灵活配置按钮触发的事件类型和参数
3. **扩展困难**：新增业务按钮（如审核、打印、打印标签等）需要修改前端代码

### 1.2 设计目标

1. **配置化**：通过数据库配置按钮，无需改代码即可新增/修改按钮
2. **事件多样化**：支持多种事件类型（API调用、文件下载、页面跳转、弹窗等）
3. **参数灵活**：通过 JSON 配置事件参数
4. **权限联动**：按钮级权限控制，前后端双重校验

---

## 二、现有系统分析

### 2.1 权限系统

| 组件 | 说明 |
|------|------|
| `v-access:code` 指令 | 前端权限控制，基于权限码 |
| `accessStore.accessCodes` | 权限码存储（从后端获取） |
| `@RequiresPermissions` | 后端接口权限注解 |

**权限码格式**：`模块:功能:操作`，如 `wms:base:warehouse:export`

### 2.2 Excel 导出能力

后端已有完整的 Excel 导出工具 `ExcelUtil`，支持：
- 注解方式定义导出字段
- 下拉框、日期格式化等
- 大数据量分 Sheet 导出

仓库模块示例：
```java
@Log(title = "仓库档案", businessType = BusinessType.EXPORT)
@PostMapping("/export")
@RequiresPermissions("wms:base:warehouse:export")
public void export(HttpServletResponse response, @RequestBody WarehouseQueryRequest request) {
    List<WarehouseResponse> list = warehouseBiz.exportList(request);
    ExcelUtil<WarehouseResponse> util = new ExcelUtil<>(WarehouseResponse.class);
    util.exportExcel(response, list, fileName);
}
```

### 2.3 现有按钮配置表

`sys_table_operation` 表结构：

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | 主键 |
| table_code | varchar(100) | 表编码 |
| operation_code | varchar(50) | 操作标识 |
| operation_name | varchar(50) | 按钮显示名 |
| operation_type | varchar(20) | 按钮样式（button/link） |
| icon | varchar(100) | 图标 |
| permission | varchar(100) | 权限码 |
| position | varchar(20) | 位置（toolbar/row） |
| sort_order | int | 排序号 |
| status | int | 状态（0禁用/1启用） |

---

## 三、数据库扩展设计

### 3.1 表结构变更

在 `sys_table_operation` 表中增加以下字段：

```sql
ALTER TABLE sys_table_operation
ADD COLUMN event_type VARCHAR(50) DEFAULT NULL COMMENT '事件类型: redirect|api|download|modal|drawer|builtin',
ADD COLUMN event_config TEXT COMMENT '事件配置JSON',
ADD COLUMN confirm_message VARCHAR(200) DEFAULT NULL COMMENT '确认提示消息',
ADD COLUMN is_enabled TINYINT(1) DEFAULT 1 COMMENT '是否启用（用于动态控制）';
```

### 3.2 event_type 类型定义

| event_type | 说明 | event_config 示例 |
|------------|------|-------------------|
| `builtin` | 内置动作（create/edit/delete/toggle/export） | `{"handler": "create"}` |
| `api` | 调用 REST API 接口 | `{"url": "/api/xxx", "method": "POST"}` |
| `download` | 文件下载/导出 | `{"url": "/api/xxx/export", "method": "POST"}` |
| `redirect` | 页面跳转 | `{"path": "/xxx"}` |
| `modal` | 打开弹窗 | `{"component": "xxx-modal"}` |
| `drawer` | 打开抽屉 | `{"component": "xxx-drawer"}` |
| `custom` | 自定义 JS 函数 | `{"handler": "handleCustomAction"}` |

### 3.3 event_config JSON 结构

#### 3.3.1 builtin 类型

```json
{
  "handler": "create|edit|delete|toggle|export"
}
```

#### 3.3.2 api 类型

```json
{
  "url": "/api/xxx/xxx",
  "method": "GET|POST|PUT|DELETE",
  "params": {
    "field1": "value1"
  },
  "payloadType": "none|filtered|selected|currentPage|all",
  "successMessage": "操作成功",
  "failMessage": "操作失败"
}
```

| payloadType | 说明 |
|-------------|------|
| `none` | 不传递任何数据 |
| `filtered` | 传递当前搜索条件 |
| `selected` | 传递选中的行 ID 列表 |
| `currentPage` | 传递当前分页参数 |
| `all` | 传递搜索条件 + 全部数据（忽略分页） |

#### 3.3.3 download 类型

```json
{
  "url": "/api/xxx/export",
  "method": "POST",
  "payloadType": "filtered|selected|currentPage|all",
  "fileName": "导出文件.xlsx",
  "responseType": "blob"
}
```

#### 3.3.4 redirect 类型

```json
{
  "path": "/xxx/yyy",
  "query": {
    "id": "${id}"
  }
}
```

### 3.4 按钮配置示例

#### 3.4.1 新建按钮

```json
{
  "operationCode": "create",
  "operationName": "新建",
  "operationType": "button",
  "icon": "material-symbols:add",
  "permission": "wms:base:warehouse:add",
  "position": "toolbar",
  "eventType": "builtin",
  "eventConfig": "{\"handler\": \"create\"}",
  "sortOrder": 1,
  "status": 1
}
```

#### 3.4.2 导出按钮（筛选导出）

```json
{
  "operationCode": "export",
  "operationName": "导出",
  "operationType": "button",
  "icon": "material-symbols:download",
  "permission": "wms:base:warehouse:export",
  "position": "toolbar",
  "eventType": "download",
  "eventConfig": "{\"url\": \"/api/base/warehouse/export\", \"method\": \"POST\", \"payloadType\": \"filtered\", \"fileName\": \"仓库档案.xlsx\"}",
  "confirmMessage": "确定要导出筛选后的数据吗？",
  "sortOrder": 2,
  "status": 1
}
```

#### 3.4.3 导出按钮（勾选导出）

```json
{
  "operationCode": "exportSelected",
  "operationName": "导出选中",
  "operationType": "button",
  "icon": "material-symbols:download",
  "permission": "wms:base:warehouse:export",
  "position": "toolbar",
  "eventType": "download",
  "eventConfig": "{\"url\": \"/api/base/warehouse/export\", \"method\": \"POST\", \"payloadType\": \"selected\"}",
  "confirmMessage": "确定要导出选中的 {count} 条数据吗？",
  "sortOrder": 3,
  "status": 1
}
```

#### 3.4.4 自定义 API 调用

```json
{
  "operationCode": "approve",
  "operationName": "审核通过",
  "operationType": "button",
  "icon": "material-symbols:check-circle",
  "permission": "wms:order:approve",
  "position": "row",
  "eventType": "api",
  "eventConfig": "{\"url\": \"/api/wms/order/{id}/approve\", \"method\": \"POST\", \"payloadType\": \"none\"}",
  "confirmMessage": "确定要审核通过吗？",
  "sortOrder": 10,
  "status": 1
}
```

#### 3.4.5 行内操作按钮

```json
{
  "operationCode": "printLabel",
  "operationName": "打印标签",
  "operationType": "link",
  "icon": "material-symbols:print",
  "permission": "wms:inventory:label:print",
  "position": "row",
  "eventType": "api",
  "eventConfig": "{\"url\": \"/api/wms/label/print\", \"method\": \"POST\", \"payloadType\": \"selected\"}",
  "confirmMessage": "确定要打印这 {count} 条数据的标签吗？",
  "sortOrder": 5,
  "status": 1
}
```

---

## 四、前端设计

### 4.1 事件处理映射表

新建文件 `src/lowcode/events.ts`：

```typescript
// 内置动作处理器
export const BUILTIN_HANDLERS: Record<string, Function> = {
  create: (ctx: ActionContext) => ctx.handleCreate(),
  edit: (ctx: ActionContext, record?: any) => ctx.handleEdit(record),
  delete: (ctx: ActionContext, record: any) => ctx.handleDelete(record.id),
  toggle: (ctx: ActionContext, record: any) => ctx.handleToggle(record),
  export: (ctx: ActionContext) => ctx.handleExport(),
};
```

### 4.2 工具栏渲染逻辑

改造 `LowcodePage.vue` 工具栏部分：

```vue
<!-- 工具栏按钮渲染 -->
<div v-if="toolbarActions.length" class="flex gap-2">
  <template v-for="action in toolbarActions" :key="action.key">
    <Button
      v-if="canRenderAction(action)"
      :type="getButtonType(action)"
      :loading="actionLoading[action.key]"
      @click="handleAction(action)"
    >
      <IconifyIcon v-if="action.icon" :icon="action.icon" class="mr-1" />
      {{ action.label }}
    </Button>
  </template>
</div>
```

### 4.3 权限控制

```typescript
// 检查按钮是否有权限渲染
function canRenderAction(action: LowcodeAction): boolean {
  if (action.permission && !hasAccessByCodes([action.permission])) {
    return false;
  }
  return true;
}
```

### 4.4 统一事件分发

```typescript
async function handleAction(action: LowcodeAction) {
  // 1. 确认提示
  if (action.confirmMessage) {
    const confirmed = await showConfirm(action);
    if (!confirmed) return;
  }

  // 2. 根据 eventType 分发
  switch (action.eventType) {
    case 'builtin':
      executeBuiltinHandler(action);
      break;
    case 'api':
      await executeApiAction(action);
      break;
    case 'download':
      await executeDownloadAction(action);
      break;
    case 'redirect':
      executeRedirectAction(action);
      break;
    default:
      console.warn(`Unknown eventType: ${action.eventType}`);
  }
}
```

---

## 五、后端设计

### 5.1 MetaService 扩展

修改 `MetaServiceImpl.getOperationList()` 方法，返回完整的按钮配置（包括新增的字段）。

### 5.2 通用导出接口

新增低代码通用导出接口：

```
POST /api/wms/crud/{tableCode}/export
```

支持：
- 按表编码动态查询
- 根据列配置生成 Excel
- 支持筛选条件

### 5.3 权限注解

每个具体业务的导出接口仍需 `@RequiresPermissions` 注解控制权限。

---

## 六、实现计划

### 阶段一：基础设施

| 任务 | 负责人 | 状态 |
|------|--------|------|
| 扩展 sys_table_operation 表结构 | - | 待实现 |
| 创建 DDL 脚本 | - | 待实现 |

### 阶段二：后端实现

| 任务 | 负责人 | 状态 |
|------|--------|------|
| 修改 MetaService 返回完整配置 | - | 待实现 |
| 新增通用导出接口 | - | 待实现 |

### 阶段三：前端实现

| 任务 | 负责人 | 状态 |
|------|--------|------|
| 新增 event-handlers.ts | - | 待实现 |
| 改造 LowcodePage.vue | - | 待实现 |
| 新增类型定义 | - | 待实现 |
| 实现统一事件分发 | - | 待实现 |

### 阶段四：测试验证

| 任务 | 负责人 | 状态 |
|------|--------|------|
| 按钮配置测试 | - | 待实现 |
| 导出功能测试 | - | 待实现 |
| 权限控制测试 | - | 待实现 |

---

## 七、向后兼容

### 7.1 旧数据处理

对于已存在的按钮配置数据，需要：
1. `event_type` 默认为 `builtin`
2. 根据 `operation_code` 推断 `event_config`，如：
   - `create` → `{"handler": "create"}`
   - `export` → `{"handler": "export"}`

### 7.2 前端兼容

前端代码需要兼容两种情况：
1. 旧数据无 `event_type` 字段 → 按 builtin 处理
2. 新数据有 `event_type` 字段 → 按配置处理

---

## 八、风险与注意事项

1. **安全性**：API 类型事件需要在后端校验权限
2. **性能**：导出功能大数据量时需要考虑超时
3. **兼容性**：需要兼容已有的按钮配置数据
4. **扩展性**：预留 event_type 扩展接口

---

## 九、变更记录

| 版本 | 日期 | 修改内容 | 作者 |
|------|------|----------|------|
| v1.0 | 2026-04-09 | 初始版本 | - |

---

## 十、附录

### A. 操作按钮 DDL

```sql
CREATE TABLE IF NOT EXISTS `sys_table_operation` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `table_code` varchar(100) NOT NULL COMMENT '表标识',
  `operation_code` varchar(50) NOT NULL COMMENT '操作标识',
  `operation_name` varchar(50) NOT NULL COMMENT '操作名称',
  `operation_type` varchar(20) DEFAULT 'button' COMMENT '操作类型: button/link',
  `icon` varchar(100) DEFAULT NULL COMMENT '图标',
  `permission` varchar(100) DEFAULT NULL COMMENT '权限标识',
  `position` varchar(20) DEFAULT 'row' COMMENT '位置: toolbar-工具栏 row-行内',
  `event_type` varchar(50) DEFAULT 'builtin' COMMENT '事件类型: builtin|api|download|redirect|modal|drawer',
  `event_config` text COMMENT '事件配置JSON',
  `confirm_message` varchar(200) DEFAULT NULL COMMENT '确认提示消息',
  `sort_order` int DEFAULT 0 COMMENT '排序号',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_table_operation` (`table_code`, `operation_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='表操作按钮配置表';
```

### B. 前端类型定义

```typescript
// src/lowcode/types.ts

/** 事件类型 */
export type EventType = 'builtin' | 'api' | 'download' | 'redirect' | 'modal' | 'drawer' | 'custom';

/** 内置动作配置 */
export interface BuiltinEventConfig {
  handler: 'create' | 'edit' | 'delete' | 'toggle' | 'export';
}

/** API 调用配置 */
export interface ApiEventConfig {
  url: string;
  method: 'GET' | 'POST' | 'PUT' | 'DELETE';
  params?: Record<string, any>;
  payloadType: 'none' | 'filtered' | 'selected' | 'currentPage' | 'all';
  successMessage?: string;
  failMessage?: string;
}

/** 文件下载配置 */
export interface DownloadEventConfig {
  url: string;
  method: 'GET' | 'POST';
  payloadType: 'filtered' | 'selected' | 'currentPage' | 'all';
  fileName?: string;
  responseType?: 'blob';
}

/** 页面跳转配置 */
export interface RedirectEventConfig {
  path: string;
  query?: Record<string, string>;
}

/** 操作按钮完整配置 */
export interface LowcodeAction {
  key: string;
  label: string;
  type: 'primary' | 'default' | 'danger' | 'link';
  icon?: string;
  permission?: string;
  position: 'toolbar' | 'row';
  eventType: EventType;
  eventConfig?: any;
  confirmMessage?: string;
  confirm?: string;
}
```
