# Story 01-01 仓库档案查询

## 0. 基本信息

- Epic：基础数据管理
- Story ID：01-01
- 优先级：P0
- 状态：Draft
- 负责人：PM / FE / BE / QA
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 1

---

## 1. 目标

实现仓库档案查询能力，支持分页、模糊搜索、导出功能。

---

## 2. 业务背景

仓库档案是 WMS 系统的基础主数据，所有出入库、库存业务都依赖仓库档案。本 Story 为仓库管理员提供仓库信息查询入口，为后续仓库档案维护（新增/编辑/删除）做准备。

---

## 3. 范围

### 3.1 本 Story 包含

- 仓库档案分页列表查询
- 仓库名称/编码模糊搜索
- 按仓库状态（启用/禁用）筛选
- 按温区类型筛选
- 仓库档案导出 Excel

### 3.2 本 Story 不包含

- 仓库档案新增（见 Story 01-02）
- 仓库档案编辑（见 Story 01-02）
- 仓库档案删除（见 Story 01-02）
- 仓库详情页

---

## 4. 参与角色

- 仓库管理员：查询仓库列表、导出仓库信息
- 系统管理员：查询所有仓库
- 其他业务人员：查询仓库基础信息

---

## 5. 前置条件

- 用户已登录系统
- 用户具备仓库查询权限（`wms:warehouse:query`）

---

## 6. 触发方式

- 页面入口：基础设置 → 仓库档案（WMS0010）
- 接口入口：GET `/api/base/warehouse/list`
- 低代码表编码：WMS0010

---

## 7. 输入 / 输出

### 7.1 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| page | int | N | 页码，默认 1 |
| pageSize | int | N | 每页条数，默认 20 |
| warehouseCode | string | N | 仓库编码（模糊搜索） |
| warehouseName | string | N | 仓库名称（模糊搜索） |
| status | string | N | 状态：ENABLED / DISABLED |
| temperatureZone | string | N | 温区：COLD / ROOM / FROZEN |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| total | int | 总记录数 |
| records | array | 仓库列表 |
| records[].id | long | 仓库ID |
| records[].warehouseCode | string | 仓库编码 |
| records[].warehouseName | string | 仓库名称 |
| records[].temperatureZone | string | 温区 |
| records[].warehouseType | string | 仓库类型 |
| records[].companyName | string | 所属公司 |
| records[].address | string | 详细地址 |
| records[].contact | string | 联系人 |
| records[].phone | string | 联系电话 |
| records[].status | string | 状态 |
| records[].gmtCreate | datetime | 创建时间 |

---

## 8. 页面/交互要求

### 8.1 页面

- 页面名称：仓库档案列表页
- 页面类型：列表页
- 菜单路径：基础设置 → 仓库档案

### 8.2 交互要求

- 输入搜索条件后点击【查询】按钮，列表刷新
- 点击【重置】按钮，清空搜索条件
- 点击【导出】按钮，下载 Excel 文件
- 点击列表行，进入详情页（后续 Story）

### 8.3 展示字段

| 字段 | 说明 |
|---|---|
| 仓库编码 | - |
| 仓库名称 | - |
| 温区 | 显示中文：冷藏/常温/冷冻 |
| 仓库类型 | 显示中文：自管/第三方 |
| 所属公司 | - |
| 联系人 | - |
| 联系电话 | - |
| 状态 | 显示启用/禁用标签 |
| 创建时间 | 格式：YYYY-MM-DD HH:mm |

---

## 9. 业务规则

1. 仓库编码支持模糊搜索
2. 仓库名称支持模糊搜索
3. 多条件筛选时为 AND 关系
4. 默认按创建时间倒序排列
5. 导出字段与列表展示字段一致
6. 导出文件名格式：`仓库档案_YYYYMMDD_HHmmss.xlsx`

---

## 10. 状态流转

### 10.1 主体对象

- 对象名称：仓库

### 10.2 状态定义

| 状态 | 说明 |
|---|---|
| ENABLED | 启用 |
| DISABLED | 禁用 |

### 10.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| ENABLED | 禁用 | DISABLED | Story 01-02 |
| DISABLED | 启用 | ENABLED | Story 01-02 |

---

## 11. 数据设计

### 11.1 涉及表

- `sys_warehouse`

### 11.2 关键字段

| 表名 | 字段 | 说明 |
|---|---|---|
| sys_warehouse | id | 主键 |
| sys_warehouse | warehouse_code | 仓库编码 |
| sys_warehouse | warehouse_name | 仓库名称 |
| sys_warehouse | temperature_zone | 温区 |
| sys_warehouse | warehouse_type | 仓库类型 |
| sys_warehouse | status | 状态 |

### 11.3 数据变更说明

- 无数据变更（纯查询 Story）

---

## 12. API / 接口契约

### 12.1 接口清单（低代码CRUD约定）

| 方法 | 路径 | 说明 | 对应低代码接口 |
|------|------|------|----------------|
| GET | `/api/base/warehouse/list` | 仓库分页查询 | `{crudPrefix}/list` |
| GET | `/api/base/warehouse/{id}` | 仓库详情 | `{crudPrefix}/{id}` |
| GET | `/api/base/warehouse/export` | 仓库导出 | `{crudPrefix}/export` |

### 12.2 Schema 配置（低代码）

- **表编码**：WMS0010
- **CRUD前缀**：`/api/base/warehouse`
- **列表字段**：warehouseCode, warehouseName, temperatureZone, warehouseType, companyName, contact, phone, status, gmtCreate
- **搜索字段**：warehouseCode, warehouseName, status, temperatureZone

### 12.3 请求示例

```json
GET /api/base/warehouse/list?page=1&pageSize=20&warehouseName=上海
```

### 12.3 响应示例

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 100,
    "records": [
      {
        "id": 1,
        "warehouseCode": "WH001",
        "warehouseName": "上海仓",
        "temperatureZone": "ROOM",
        "warehouseType": "SELF",
        "companyName": "XX公司",
        "address": "上海市浦东新区...",
        "contact": "张三",
        "phone": "13800138000",
        "status": "ENABLED",
        "gmtCreate": "2026-04-01 10:00:00"
      }
    ]
  }
}
```

### 12.4 错误码/异常返回

| 错误码 | 场景 | 提示 |
|---|---|---|
| 401 | 未登录 | 请先登录 |
| 403 | 无权限 | 没有仓库查询权限 |
| 500 | 系统错误 | 系统异常，请稍后重试 |

---

## 13. 权限与审计

### 13.1 权限标识

- `wms:warehouse:query`

### 13.2 权限要求

- 谁可以查看：所有用户
- 谁可以新增：无（查看页无此操作）
- 谁可以修改：无
- 谁可以作废/确认：无

### 13.3 审计要求

- 记录查询日志（操作人、操作时间）
- 导出时记录导出日志

---

## 14. 异常与边界场景

| 场景 | 预期处理 |
|---|---|
| 查询条件无结果 | 返回空列表，提示"暂无数据" |
| 导出数据为空 | 提示"无可导出的数据" |
| 分页参数越界 | 自动调整为有效范围 |
| 并发查询 | 正常返回，服务端处理 |

---

## 15. 验收标准

### 15.1 功能验收

- [ ] 输入仓库编码可模糊搜索到对应仓库
- [ ] 输入仓库名称可模糊搜索到对应仓库
- [ ] 选择温区可筛选对应仓库
- [ ] 选择状态可筛选对应仓库
- [ ] 多条件组合可正确筛选
- [ ] 分页切换正常
- [ ] 导出 Excel 文件可正常下载
- [ ] 导出文件字段与列表一致

### 15.2 数据验收

- [ ] 返回数据字段完整
- [ ] 日期格式正确
- [ ] 状态值正确显示中文

### 15.3 权限验收

- [ ] 无权限用户不可访问接口
- [ ] 有权限用户可正常访问

### 15.4 日志验收

- [ ] 查询操作有日志记录
- [ ] 导出操作有日志记录

---

## 16. 测试要点

### 16.1 单元测试

- 模糊搜索条件拼接正确
- 分页参数处理正确
- 空结果处理正确

### 16.2 集成测试

- 多条件查询正确
- 权限过滤正确
- 导出功能正常

### 16.3 页面/联调测试

- 页面加载性能 < 1s
- 搜索响应性能 < 500ms

### 16.4 回归测试

- 不影响其他模块

---

## 17. 技术实现约束

- 禁止超出本 Story 范围扩展功能
- 查询必须走索引，避免全表扫描
- 导出使用异步方式，避免超时

---

## 18. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 19. 完成定义（DoD）

- [x] 功能开发完成
- [x] 自测通过
- [x] 联调通过
- [x] 验收标准全部满足
- [x] 无阻塞性缺陷
- [x] 文档已更新
- [ ] 可提交评审/上线

---

## 20. 风险与待确认项

**风险**

- 无

**待确认**

- 导出数据量上限（建议 10000 条）

---

## 21. 开发回执模板

**改动文件**

```
(开发完成后填写)
```

**实现内容**

```
(开发完成后填写)
```

**验证结果**

```
(开发完成后填写)
```

**未完成/风险**

```
(开发完成后填写)
```

---

## 22. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0010 仓库档案
- 数据库设计：[WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md)
- Epic Brief：[epic-01-overview.md](../../epics/epic-01-overview.md)
