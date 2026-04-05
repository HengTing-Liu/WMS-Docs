# WMS-Frontend 代码索引

> 版本：V1.0
> 日期：2026-04-06

---

## 项目结构

```
WMS-frontend/
├── apps/web-antd/src/
│   ├── api/           # API 接口定义
│   ├── components/    # 公共组件
│   │   ├── crud/     # CRUD 组件
│   │   ├── lc/       # 低代码组件
│   │   ├── wms/      # WMS 专用组件
│   │   └── common/   # 通用组件
│   ├── views/         # 页面
│   ├── layouts/       # 布局
│   ├── lowcode/       # 低代码引擎
│   └── utils/         # 工具函数
├── packages/
│   ├── @core/        # 核心组件库
│   │   ├── ui-kit/   # UI 组件包
│   │   ├── form-ui/  # 表单组件
│   │   ├── layout-ui/# 布局组件
│   │   └── menu-ui/  # 菜单组件
│   ├── effects/       # 功能组件
│   │   ├── common-ui/# 通用组件
│   │   ├── layouts/  # 布局组件
│   │   ├── plugins/  # 插件
│   │   └── access/   # 权限组件
│   └── icons/        # 图标
```

---

## 低代码核心组件

| 组件 | 说明 | 路径 |
|------|------|------|
| LcTable | 低代码表格 | `components/lc/LcTable.vue` |
| LcForm | 低代码表单 | `components/lc/LcForm.vue` |
| LcSearchBar | 低代码搜索栏 | `components/lc/LcSearchBar.vue` |
| LowcodePage | 低代码页面 | `lowcode/LowcodePage.vue` |
| LowcodeDrawer | 低代码抽屉 | `lowcode/LowcodeDrawer.vue` |
| FieldRenderer | 字段渲染器 | `lowcode/FieldRenderer.vue` |

---

## CRUD 组件

| 组件 | 说明 | 路径 |
|------|------|------|
| CrudPage | CRUD 页面基类 | `components/crud/CrudPage.vue` |
| DataTable | 数据表格 | `components/crud/DataTable.vue` |
| PageForm | 页面表单 | `components/crud/PageForm.vue` |
| QueryForm | 查询表单 | `components/crud/QueryForm.vue` |

---

## WMS 专用组件

| 组件 | 说明 | 路径 |
|------|------|------|
| WmsDataTable | WMS数据表格 | `components/wms/WmsDataTable.vue` |
| WmsFilterBar | WMS筛选栏 | `components/wms/WmsFilterBar.vue` |
| WmsPageLayout | WMS页面布局 | `components/wms/WmsPageLayout.vue` |
| WmsStatsCards | WMS统计卡片 | `components/wms/WmsStatsCards.vue` |

---

## 业务模块页面

### 系统管理 (sys)

| 页面 | 说明 | 路径 |
|------|------|------|
| warehouse | 仓库管理 | `views/sys/warehouse/index.vue` |
| warehouse/form | 仓库表单 | `views/sys/warehouse/modules/warehouse-modal.vue` |
| warehouse/detail | 仓库详情 | `views/sys/warehouse/modules/warehouse-detail.vue` |
| user | 用户管理 | `views/sys/user/index.vue` |
| user/form | 用户表单 | `views/sys/user/modules/user-modal.vue` |
| role | 角色管理 | `views/system/role/index.vue` |
| role/form | 角色表单 | `views/system/role/modules/role-modal.vue` |
| menu | 菜单管理 | `views/system/menu/index.vue` |
| dept | 部门管理 | `views/system/dept/index.vue` |
| dict | 字典管理 | `views/sys/dict/index.vue` |
| dict/data | 字典数据 | `views/sys/dict/modules/dict-data.vue` |
| log | 日志管理 | `views/sys/log/index.vue` |
| operlog | 操作日志 | `views/system/operlog/index.vue` |
| logininfor | 登录日志 | `views/system/logininfor/index.vue` |
| permission | 权限管理 | `views/sys/permission/index.vue` |
| tableMeta | 表元数据 | `views/system/tableMeta/index.vue` |
| material | 物料管理 | `views/sys/material/index.vue` |
| material/form | 物料表单 | `views/sys/material/components/material-modal.vue` |
| supplier | 供应商管理 | `views/sys/supplier/index.vue` |
| supplier/form | 供应商表单 | `views/sys/supplier/components/supplier-modal.vue` |
| customer | 客户管理 | `views/sys/customer/index.vue` |
| customer/form | 客户表单 | `views/sys/customer/components/customer-modal.vue` |
| storage | 库存查询 | `views/sys/storage/index.vue` |
| storage/form | 库存表单 | `views/sys/storage/components/storage-modal.vue` |

### 基础档案 (base)

| 页面 | 说明 | 路径 |
|------|------|------|
| warehouse | 仓库档案 | `views/base/warehouse/index.vue` |
| location | 库位档案 | `views/base/location/index.vue` |
| dict | 字典档案 | `views/base/dict/index.vue` |
| enum | 枚举管理 | `views/base/enum/index.vue` |
| enum/form | 枚举表单 | `views/base/enum/modules/enum-modal.vue` |
| user | 用户管理 | `views/base/user/index.vue` |
| permission | 权限管理 | `views/base/permission/index.vue` |

### 低代码 (lowcode)

| 页面 | 说明 | 路径 |
|------|------|------|
| meta | 元数据管理 | `views/lowcode/meta/index.vue` |
| meta/table | 表元数据 | `views/lowcode/meta/components/TableMetaForm.vue` |
| meta/column | 字段元数据 | `views/lowcode/meta/components/MetaFieldList.vue` |
| meta/operation | 操作元数据 | `views/lowcode/meta/components/OperationConfig.vue` |
| code-generator | 代码生成器 | `views/lowcode/code-generator/index.vue` |
| wms0010 | WMS0010页面 | `views/lowcode/wms0010/index.vue` |

### 入库管理 (inbound)

| 页面 | 说明 | 路径 |
|------|------|------|
| production | 生产入库 | `views/inbound/production/index.vue` |
| production/detail | 生产入库详情 | `views/inbound/production/modules/inbound-detail.vue` |
| production/form | 生产入库表单 | `views/inbound/production/modules/inbound-modal.vue` |
| purchase | 采购入库 | `views/inbound/purchase/index.vue` |
| purchase/detail | 采购入库详情 | `views/inbound/purchase/modules/inbound-detail.vue` |
| purchase/form | 采购入库表单 | `views/inbound/purchase/modules/inbound-modal.vue` |
| return | 退货入库 | `views/inbound/return/index.vue` |
| return/detail | 退货入库详情 | `views/inbound/return/modules/inbound-detail.vue` |
| return/form | 退货入库表单 | `views/inbound/return/modules/inbound-modal.vue` |
| return-material | 领用退回 | `views/inbound/return-material/index.vue` |
| transfer | 调拨入库 | `views/inbound/transfer/index.vue` |
| transfer/detail | 调拨入库详情 | `views/inbound/transfer/modules/inbound-detail.vue` |
| transfer/form | 调拨入库表单 | `views/inbound/transfer/modules/inbound-modal.vue` |

### 出库管理 (outbound)

| 页面 | 说明 | 路径 |
|------|------|------|
| sale | 销售出库 | `views/outbound/sale/index.vue` |
| sale/detail | 销售出库详情 | `views/outbound/sale/modules/outbound-detail.vue` |
| sale/form | 销售出库表单 | `views/outbound/sale/modules/outbound-modal.vue` |
| transfer | 调拨出库 | `views/outbound/transfer/index.vue` |
| transfer/detail | 调拨出库详情 | `views/outbound/transfer/modules/outbound-detail.vue` |
| transfer/form | 调拨出库表单 | `views/outbound/transfer/modules/outbound-modal.vue` |
| use | 领用出库 | `views/outbound/use/index.vue` |
| use/detail | 领用出库详情 | `views/outbound/use/modules/outbound-detail.vue` |
| use/form | 领用出库表单 | `views/outbound/use/modules/outbound-modal.vue` |
| return-purchase | 采购退回 | `views/outbound/return-purchase/index.vue` |
| return-material | 退货出库 | `views/outbound/return-material/index.vue` |

### 提货单 (pickup)

| 页面 | 说明 | 路径 |
|------|------|------|
| sale | 销售提货单 | `views/pickup/sale/index.vue` |
| sale/detail | 销售提货单详情 | `views/pickup/sale/modules/pickup-detail.vue` |
| sale/form | 销售提货单表单 | `views/pickup/sale/modules/pickup-modal.vue` |
| transfer | 调拨提货单 | `views/pickup/transfer/index.vue` |
| use | 领用提货单 | `views/pickup/use/index.vue` |
| cro | CRO提货单 | `views/pickup/cro/index.vue` |
| accompany | 随货提货单 | `views/pickup/accompany/index.vue` |
| urgent | 紧急提货单 | `views/pickup/urgent/index.vue` |

### 出库单 (out-order)

| 页面 | 说明 | 路径 |
|------|------|------|
| list | 出库单列表 | `views/out-order/list/index.vue` |
| list/detail | 出库单详情 | `views/out-order/list/modules/outorder-detail.vue` |
| list/form | 出库单表单 | `views/out-order/list/modules/outorder-modal.vue` |
| prepare | 出库准备 | `views/out-order/prepare/index.vue` |
| prepare/detail | 准备单详情 | `views/out-order/prepare/modules/prepare-detail.vue` |
| package | 包裹单 | `views/out-order/package/index.vue` |
| package/detail | 包裹单详情 | `views/out-order/package/modules/package-detail.vue` |
| shipping | 发货列表 | `views/out-order/shipping/index.vue` |
| shipping/detail | 发货详情 | `views/out-order/shipping/modules/shipping-detail.vue` |

### 物流 (transit)

| 页面 | 说明 | 路径 |
|------|------|------|
| delivery | 中转发货 | `views/transit/delivery/index.vue` |
| delivery/detail | 中转发货详情 | `views/transit/delivery/modules/delivery-detail.vue` |
| delivery/form | 中转发货表单 | `views/transit/delivery/modules/delivery-modal.vue` |
| receive | 中转收货 | `views/transit/receive/index.vue` |
| receive/detail | 中转收货详情 | `views/transit/receive/modules/receive-detail.vue` |
| receive/form | 中转收货表单 | `views/transit/receive/modules/receive-modal.vue` |

### 库存 (inv)

| 页面 | 说明 | 路径 |
|------|------|------|
| index | 库存查询 | `views/inv/index.vue` |
| qrcode-detail | 二维码详情 | `views/inv/qrcode-detail/index.vue` |

### 质检 (qc)

| 页面 | 说明 | 路径 |
|------|------|------|
| standard | 质检标准 | `views/qc/standard/index.vue` |
| standard/detail | 质检标准详情 | `views/qc/standard/modules/standard-detail.vue` |
| standard/form | 质检标准表单 | `views/qc/standard/modules/standard-modal.vue` |
| evaluate | 质检评定 | `views/qc/evaluate/index.vue` |
| evaluate/detail | 质检评定详情 | `views/qc/evaluate/modules/evaluate-detail.vue` |
| evaluate/form | 质检评定表单 | `views/qc/evaluate/modules/evaluate-modal.vue` |

### 报表 (query)

| 页面 | 说明 | 路径 |
|------|------|------|
| material | 物料库存查询 | `views/query/material/index.vue` |
| location | 库位库存查询 | `views/query/location/index.vue` |
| flow | 库存流水查询 | `views/query/flow/index.vue` |
| qrcode | 二维码查询 | `views/query/qrcode/index.vue` |

---

## 开发规范

### 新增页面步骤

1. **API** - 在 `apps/web-antd/src/api/` 创建 API 接口
2. **页面** - 在 `apps/web-antd/src/views/` 创建页面目录和 index.vue
3. **路由** - 在路由配置中添加路由
4. **菜单** - 在后台配置菜单权限

### 页面结构

```
views/模块/功能/
├── index.vue              # 主页面（列表）
├── form.vue               # 表单页（可选）
└── modules/
    ├── detail.vue         # 详情弹窗/页
    └── modal.vue          # 表单弹窗
```

### API 定义规范

```typescript
// api/模块/功能.ts
import { request } from '@/utils/request';

export const getXxxList = (params) => request.get('/api/xxx', { params });
export const getXxxById = (id) => request.get(`/api/xxx/${id}`);
export const createXxx = (data) => request.post('/api/xxx', data);
export const updateXxx = (id, data) => request.put(`/api/xxx/${id}`, data);
export const deleteXxx = (id) => request.delete(`/api/xxx/${id}`);
```

### 命名规范

- API: `getXxxList`, `getXxxById`, `createXxx`, `updateXxx`, `deleteXxx`
- 页面: `index.vue`（列表）、`form.vue`（表单）
- 组件: `PascalCase`（如 `UserModal.vue`）
- 目录: `kebab-case`（如 `user-manage`）
