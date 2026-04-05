# WMS仓库物流系统 - API接口规范

> 版本：V1.0
> 日期：2026-04-03
> 适用范围：WMS系统RESTful API设计

---

## 一、API设计原则

### 1.1 RESTful规范

| 原则 | 说明 |
|------|------|
| 使用HTTP动词 | GET/POST/PUT/DELETE |
| 使用名词复数 | /warehouses 而非 /warehouse |
| 使用子资源 | /warehouses/{id}/locations |
| 使用HTTP状态码 | 200/201/400/401/404/500 |
| 版本控制 | /api/v1/warehouses |

### 1.2 URL规范

```
# 资源命名
GET    /api/v1/warehouses              → 列表查询
GET    /api/v1/warehouses/{id}         → 详情查询
POST   /api/v1/warehouses               → 新增
PUT    /api/v1/warehouses/{id}         → 修改
DELETE /api/v1/warehouses/{id}         → 删除
PUT    /api/v1/warehouses/{id}/toggle  → 启用/停用
GET    /api/v1/warehouses/export       → 导出

# 特殊操作（使用动词）
POST   /api/v1/warehouses/batch-delete  → 批量删除
POST   /api/v1/warehouses/import        → 导入
GET    /api/v1/warehouses/tree          → 树形结构
```

### 1.3 Header规范

| Header | 说明 | 必填 |
|--------|------|------|
| Content-Type | application/json | 是 |
| Authorization | Bearer Token | 是（需认证时） |
| X-Tenant-Id | 租户ID | 是 |
| X-User-Id | 用户ID | 是（需认证时） |
| X-Request-Id | 请求追踪ID（UUID） | 建议 |
| Accept-Language | zh-CN/en | 否 |

---

## 二、统一响应格式

### 2.1 成功响应

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "warehouseCode": "WH001",
    "warehouseName": "上海仓"
  },
  "traceId": "abc123",
  "timestamp": 1709500800000
}
```

### 2.2 列表响应

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "rows": [
      { "id": 1, "warehouseCode": "WH001" },
      { "id": 2, "warehouseCode": "WH002" }
    ],
    "total": 100,
    "pageNum": 1,
    "pageSize": 20,
    "pages": 5
  },
  "traceId": "abc123",
  "timestamp": 1709500800000
}
```

### 2.3 错误响应

```json
{
  "code": 400,
  "message": "参数校验失败：仓库编码不能为空",
  "data": null,
  "errors": [
    { "field": "warehouseCode", "message": "不能为空" }
  ],
  "traceId": "abc123",
  "timestamp": 1709500800000
}
```

### 2.4 状态码定义

| HTTP状态码 | 业务状态码 | 说明 |
|------------|------------|------|
| 200 | 200 | 成功 |
| 201 | 201 | 创建成功 |
| 400 | 400 | 请求参数错误 |
| 401 | 401 | 未认证 |
| 403 | 403 | 无权限 |
| 404 | 404 | 资源不存在 |
| 409 | 409 | 资源冲突 |
| 500 | 500 | 服务器内部错误 |

---

## 三、API模块划分

### 3.1 基础设置模块 (/api/base)

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/base/warehouse | GET/POST | 仓库列表/新增 |
| /api/base/warehouse/{id} | GET/PUT/DELETE | 仓库详情/修改/删除 |
| /api/base/warehouse/{id}/toggle | PUT | 启用/停用 |
| /api/base/warehouse/export | GET | 导出仓库 |
| /api/base/location | GET/POST | 库位列表/新增 |
| /api/base/location/{id} | GET/PUT/DELETE | 库位详情/修改/删除 |
| /api/base/location/tree | GET | 库位树形结构 |
| /api/base/material | GET/POST | 物料列表/新增 |
| /api/base/material/{id} | GET/PUT/DELETE | 物料详情/修改/删除 |
| /api/base/supplier | GET/POST | 供应商列表/新增 |
| /api/base/supplier/{id} | GET/PUT/DELETE | 供应商详情/修改/删除 |
| /api/base/customer | GET/POST | 客户列表/新增 |
| /api/base/customer/{id} | GET/PUT/DELETE | 客户详情/修改/删除 |

### 3.2 库存查询模块 (/api/inventory)

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/inventory/material | GET | 查询物料库存 |
| /api/inventory/location | GET | 查询库位库存 |
| /api/inventory/flow | GET | 库存变更流水 |
| /api/inventory/qrcode | GET | 二维码查询 |
| /api/inventory/qrcode/apply | POST | 申请二维码 |
| /api/inventory/qrcode/print | POST | 打印二维码 |

### 3.3 入库操作模块 (/api/inbound)

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/inbound/production | GET/POST | 生产入库列表/新增 |
| /api/inbound/production/{id} | GET/PUT | 生产入库详情/修改 |
| /api/inbound/production/{id}/allocate | POST | 库位分配 |
| /api/inbound/production/{id}/confirm | POST | 确认入库 |
| /api/inbound/production/{id}/qc | POST | QC请验 |
| /api/inbound/purchase | GET/POST | 采购入库列表/新增 |
| /api/inbound/purchase/{id} | GET/PUT | 采购入库详情/修改 |
| /api/inbound/transfer | GET | 调拨入库列表 |
| /api/inbound/transfer/{id}/allocate | POST | 调拨库位分配 |
| /api/inbound/transfer/{id}/confirm | POST | 确认调拨入库 |
| /api/inbound/return/sales | GET/POST | 销售退回列表/新增 |
| /api/inbound/return/requisition | GET/POST | 领用退回列表/新增 |

### 3.4 出库操作模块 (/api/outbound)

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/outbound/sales | GET | 销售出库列表 |
| /api/outbound/sales/{id}/allocate | POST | 库位分配 |
| /api/outbound/sales/{id}/print | POST | 打印标签 |
| /api/outbound/sales/{id}/confirm | POST | 确认出库 |
| /api/outbound/transfer | GET/POST | 调拨出库列表/新增 |
| /api/outbound/transfer/{id} | GET/PUT | 调拨出库详情/修改 |
| /api/outbound/requisition | GET/POST | 领用出库列表/新增 |
| /api/outbound/return/production | GET/POST | 生产退回列表/新增 |
| /api/outbound/return/purchase | GET/POST | 采购退回列表/新增 |

### 3.5 库存调整模块 (/api/adjust)

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/adjust/stocktake | GET/POST | 盘点单列表/新增 |
| /api/adjust/stocktake/{id} | GET/PUT | 盘点单详情/修改 |
| /api/adjust/stocktake/{id}/start | POST | 启动盘点 |
| /api/adjust/stocktake/{id}/confirm | POST | 确认更新 |
| /api/adjust/scrap | GET/POST | 报废单列表/新增 |
| /api/adjust/scrap/{id}/confirm | POST | 确认报废 |
| /api/adjust/location | GET/POST | 库位调整列表/新增 |
| /api/adjust/location/{id}/confirm | POST | 确认调整 |

### 3.6 质量控制模块 (/api/quality)

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/quality/standard | GET/POST | 质检标准列表/新增 |
| /api/quality/standard/{id} | GET/PUT/DELETE | 质检标准详情/修改/删除 |
| /api/quality/release | GET | 质量放行列表 |
| /api/quality/release/{id} | GET/PUT | 质量放行详情/修改 |
| /api/quality/release/{id}/judge | POST | 质量判断 |
| /api/quality/release/{id}/approve | POST | 审批放行 |

### 3.7 提货单模块 (/api/pick)

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/pick/sales | GET/POST | 销售提货单列表/新增 |
| /api/pick/sales/{id}/prepare | POST | 准备出库 |
| /api/pick/sales/{id}/cancel | POST | 取消出库 |
| /api/pick/transfer | GET | 调拨提货单列表 |
| /api/pick/requisition | GET/POST | 领用提货单列表/新增 |
| /api/pick/cro | GET/POST | CRO提货单列表/新增 |
| /api/pick/urgent | GET/POST | 紧急提货单列表/新增 |

### 3.8 出库单模块 (/api/outbound-order)

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/outbound-order/prepare | GET | 出库准备列表 |
| /api/outbound-order/prepare/{id}/allocate | POST | 库位分配 |
| /api/outbound-order/prepare/{id}/print | POST | 打印清单 |
| /api/outbound-order/prepare/{id}/scan | POST | 扫码关联 |
| /api/outbound-order/prepare/{id}/confirm | POST | 确认出库 |
| /api/outbound-order | GET | 出库单列表 |
| /api/outbound-order/{id}/merge | POST | 合并出库单 |
| /api/outbound-order/{id}/split | POST | 拆分出库单 |
| /api/outbound-order/{id}/package | POST | 新建包裹 |
| /api/outbound-order/{id}/express | POST | 新建快递 |
| /api/outbound-order/{id}/ship | POST | 确认发货 |
| /api/outbound-order/package | GET | 包裹单列表 |
| /api/outbound-order/shipping | GET | 发货列表 |

### 3.9 中转仓模块 (/api/transit)

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/transit/receive | GET | 收货列表 |
| /api/transit/receive/{id}/register | POST | 收货登记 |
| /api/transit/receive/{id}/scan | POST | 扫码收货 |
| /api/transit/delivery | GET | 送货列表 |
| /api/transit/delivery/{id}/print | POST | 打印 |
| /api/transit/delivery/{id}/merge | POST | 合并 |
| /api/transit/delivery/{id}/split | POST | 拆分 |
| /api/transit/delivery/{id}/confirm | POST | 确认送货 |
| /api/transit/delivery/{id}/scan | POST | 扫码送货 |

### 3.10 外贸发货模块 (/api/foreign)

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/foreign/pending | GET | 待处理列表 |
| /api/foreign/pending/{id}/prepare-inspect | POST | 准备报检 |
| /api/foreign/pending/{id}/prepare-customs | POST | 准备报关 |
| /api/foreign/pending/{id}/prepare-ship | POST | 准备发货 |
| /api/foreign/inspect | GET | 报检清单列表 |
| /api/foreign/customs | GET | 报关清单列表 |
| /api/foreign/shipping-pending | GET | 待发货列表 |
| /api/foreign/shipping | GET | 发货清单列表 |

### 3.11 运单配送模块 (/api/delivery)

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/delivery/express | GET/POST | 快递计划列表/新增 |
| /api/delivery/express/{id} | GET/PUT | 快递计划详情/修改 |
| /api/delivery/track | GET | 配送跟踪列表 |
| /api/delivery/track/{id} | GET | 配送详情 |

### 3.12 系统管理模块 (/api/system)

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/system/user | GET/POST | 用户列表/新增 |
| /api/system/user/{id} | GET/PUT/DELETE | 用户详情/修改/删除 |
| /api/system/user/{id}/reset-password | POST | 重置密码 |
| /api/system/user/{id}/assign-roles | POST | 分配角色 |
| /api/system/role | GET/POST | 角色列表/新增 |
| /api/system/role/{id} | GET/PUT/DELETE | 角色详情/修改/删除 |
| /api/system/menu | GET | 菜单列表 |
| /api/system/menu/tree | GET | 菜单树形结构 |
| /api/system/dept | GET/POST | 部门列表/新增 |
| /api/system/dept/{id} | GET/PUT/DELETE | 部门详情/修改/删除 |
| /api/system/dict/type | GET/POST | 字典类型列表/新增 |
| /api/system/dict/data/{type} | GET | 字典数据 |
| /api/system/meta/column/schema | GET | 字段Schema |
| /api/system/meta/table/{code} | GET | 表元数据 |
| /api/system/meta/operation/list/{code} | GET | 操作按钮 |
| /api/system/operlog | GET | 操作日志 |
| /api/system/logininfor | GET | 登录日志 |

### 3.13 认证模块 (/api/auth)

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/auth/login | POST | 用户登录 |
| /api/auth/logout | POST | 用户登出 |
| /api/auth/refresh | POST | 刷新Token |
| /api/auth/getInfo | GET | 获取用户信息 |
| /api/auth/getRouters | GET | 获取路由菜单 |

---

## 四、接口详细定义示例

### 4.1 仓库管理接口

#### 4.1.1 仓库列表

```
GET /api/base/warehouse
```

**请求参数**：

| 参数 | 类型 | 位置 | 必填 | 说明 |
|------|------|------|------|------|
| pageNum | Integer | Query | 否 | 页码，默认1 |
| pageSize | Integer | Query | 否 | 页大小，默认20 |
| warehouseCode | String | Query | 否 | 仓库编码 |
| warehouseName | String | Query | 否 | 仓库名称 |
| warehouseType | String | Query | 否 | 仓库类型 |
| isEnabled | Integer | Query | 否 | 状态（1启用/0停用） |

**响应示例**：

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
        "warehouseType": "SALES",
        "company": "ABC公司",
        "temperatureZone": "NORMAL",
        "qualityZone": "QUALIFIED",
        "managerName": "张三",
        "isEnabled": 1,
        "remark": "备注",
        "createdAt": "2024-01-01 10:00:00",
        "updatedAt": "2024-01-01 10:00:00"
      }
    ],
    "total": 100,
    "pageNum": 1,
    "pageSize": 20,
    "pages": 5
  }
}
```

#### 4.1.2 新增仓库

```
POST /api/base/warehouse
```

**请求参数**：

```json
{
  "warehouseCode": "WH001",
  "warehouseName": "上海仓",
  "warehouseType": "SALES",
  "company": "ABC公司",
  "temperatureZone": "NORMAL",
  "qualityZone": "QUALIFIED",
  "managerName": "张三",
  "isEnabled": 1,
  "remark": "备注"
}
```

**响应示例**：

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1
  }
}
```

#### 4.1.3 修改仓库

```
PUT /api/base/warehouse/{id}
```

**请求参数**：

```json
{
  "warehouseName": "上海仓(新)",
  "remark": "新备注"
}
```

#### 4.1.4 删除仓库

```
DELETE /api/base/warehouse/{id}
```

**响应示例**：

```json
{
  "code": 200,
  "message": "success",
  "data": null
}
```

#### 4.1.5 启用/停用仓库

```
PUT /api/base/warehouse/{id}/toggle
```

**请求参数**：

```json
{
  "isEnabled": 1
}
```

---

## 五、分页参数规范

### 5.1 分页请求

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| pageNum | Integer | 1 | 页码 |
| pageSize | Integer | 20 | 每页条数 |
| sortField | String | - | 排序字段 |
| sortOrder | String | ASC | 排序方向（ASC/DESC） |

### 5.2 分页响应

| 参数 | 类型 | 说明 |
|------|------|------|
| rows | Array | 数据列表 |
| total | Long | 总记录数 |
| pageNum | Integer | 当前页码 |
| pageSize | Integer | 每页条数 |
| pages | Integer | 总页数 |

---

## 六、错误码定义

| 错误码 | 错误信息 | 说明 |
|--------|----------|------|
| 200 | success | 成功 |
| 400 | 请求参数错误 | 参数校验失败 |
| 401 | 未认证 | Token无效或已过期 |
| 403 | 无权限 | 没有访问权限 |
| 404 | 资源不存在 | 数据不存在 |
| 409 | 资源冲突 | 数据已存在 |
| 500 | 系统异常 | 服务器内部错误 |
| WMS001 | 仓库编码已存在 | 仓库重复 |
| WMS002 | 仓库不存在 | 仓库未找到 |
| WMS003 | 库存不足 | 库存数量不足 |
| WMS004 | 库位已被占用 | 库位无法分配 |
| WMS005 | 单据状态不允许操作 | 状态机校验失败 |
| WMS006 | 批次号已存在 | 批次重复 |
| WMS007 | 物料不存在 | 物料未找到 |
| WMS008 | 库位不存在 | 库位未找到 |
| WMS009 | 不允许删除 | 数据有关联 |
| WMS010 | 操作时间超时 | 会话超时 |
