# Story 01-02 仓库档案新增/编辑/删除

## 0. 基本信息

- Epic：基础数据管理
- Story ID：01-02
- 优先级：P0
- 状态：Draft
- 负责人：PM / FE / BE / QA
- 预计工期：1d
- 依赖 Story：01-01（仓库档案查询）
- 关联迭代：Sprint 1

---

## 1. 目标

实现仓库档案的增删改能力，支持仓库信息维护。

---

## 2. 业务背景

仓库档案是 WMS 系统的基础主数据，本 Story 提供仓库的完整生命周期管理（新增、编辑、删除、启用/禁用），确保仓库基础数据准确有效。

---

## 3. 范围

### 3.1 本 Story 包含

- 仓库档案新增（含表单校验）
- 仓库档案编辑（含表单校验）
- 仓库档案删除（含关联检查）
- 仓库档案启用/禁用

### 3.2 本 Story 不包含

- 仓库档案查询（见 Story 01-01）
- 仓库收货人管理
- 仓库详情页（与编辑合并）

---

## 4. 参与角色

- 系统管理员：新增/编辑/删除仓库
- 仓库管理员：查看仓库信息

---

## 5. 前置条件

- 用户已登录系统
- 用户具备仓库管理权限（`wms:warehouse:add`、`wms:warehouse:edit`、`wms:warehouse:delete`）

---

## 6. 触发方式

- 页面入口：基础设置 → 仓库档案 → 【新增】/【编辑】/【删除】按钮（WMS0010）
- 接口入口：CRUD `/api/base/warehouse`
- 低代码表编码：WMS0010

---

## 7. 输入 / 输出

### 7.1 新增仓库 - 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| warehouseCode | string | Y | 仓库编码 |
| warehouseName | string | Y | 仓库名称 |
| temperatureZone | string | Y | 温区：COLD/ROOM/FROZEN |
| warehouseType | string | Y | 仓库类型：SELF/THIRD_PARTY |
| companyName | string | N | 所属公司 |
| province | string | N | 省份 |
| city | string | N | 城市 |
| district | string | N | 区县 |
| address | string | N | 详细地址 |
| contact | string | N | 联系人 |
| phone | string | N | 联系电话 |
| remark | string | N | 备注 |

### 7.2 编辑仓库 - 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | long | Y | 仓库ID |
| warehouseName | string | Y | 仓库名称 |
| temperatureZone | string | Y | 温区 |
| companyName | string | N | 所属公司 |
| address | string | N | 详细地址 |
| contact | string | N | 联系人 |
| phone | string | N | 联系电话 |
| remark | string | N | 备注 |

### 7.3 输出

| 字段 | 类型 | 说明 |
|---|---|
| success | boolean | 操作是否成功 |
| data | object | 仓库信息 |

---

## 8. 页面/交互要求

### 8.1 页面

- 页面名称：仓库档案列表页 + 新增/编辑弹窗
- 页面类型：列表页 + 弹窗表单
- 菜单路径：基础设置 → 仓库档案

### 8.2 交互要求

- 点击【新增】按钮，弹出新增表单弹窗
- 点击列表【编辑】按钮，弹出编辑表单弹窗（数据回填）
- 点击【删除】按钮，弹出确认提示
- 点击【启用/禁用】按钮，切换状态
- 保存成功后关闭弹窗，刷新列表
- 失败时显示错误提示

### 8.3 展示字段

（同 Story 01-01）

---

## 9. 业务规则

1. **仓库编码唯一性**：新增时校验编码不重复
2. **仓库编码不可修改**：编辑时不允许修改编码
3. **启用仓库不可删除**：已启用的仓库不允许删除
4. **关联检查**：删除时检查是否有关联库位/库存数据
5. **删除提示**：删除前弹出确认提示
6. **手机号格式**：必须为 11 位数字
7. **必填校验**：warehouseCode、warehouseName、temperatureZone、warehouseType 必填

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
| DISABLED | 启用 | ENABLED | 点击启用按钮 |
| ENABLED | 禁用 | DISABLED | 点击禁用按钮 |
| - | 新增 | ENABLED | 默认启用 |
| ENABLED | 删除 | - | 需先禁用 |

---

## 11. 数据设计

### 11.1 涉及表

- `sys_warehouse`

### 11.2 关键字段

| 表名 | 字段 | 说明 |
|---|---|---|
| sys_warehouse | id | 主键 |
| sys_warehouse | warehouse_code | 仓库编码（唯一索引） |
| sys_warehouse | warehouse_name | 仓库名称 |
| sys_warehouse | temperature_zone | 温区 |
| sys_warehouse | warehouse_type | 仓库类型 |
| sys_warehouse | status | 状态 |
| sys_warehouse | gmt_create | 创建时间 |
| sys_warehouse | gmt_modified | 修改时间 |
| sys_warehouse | create_by | 创建人 |
| sys_warehouse | update_by | 修改人 |

### 11.3 数据变更说明

- 新增：INSERT 仓库记录
- 修改：UPDATE 仓库记录
- 删除：逻辑删除（UPDATE deleted = 1）

---

## 12. API / 接口契约

### 12.1 接口清单（低代码CRUD约定）

| 方法 | 路径 | 说明 | 对应低代码接口 |
|------|------|------|----------------|
| POST | `/api/base/warehouse` | 新增仓库 | `{crudPrefix}` |
| PUT | `/api/base/warehouse/{id}` | 编辑仓库 | `{crudPrefix}/{id}` |
| DELETE | `/api/base/warehouse/{id}` | 删除仓库 | `{crudPrefix}/{id}` |
| PUT | `/api/base/warehouse/{id}/toggle` | 启用/禁用 | `{crudPrefix}/{id}/toggle` |

### 12.2 Schema 配置（低代码）

- **表编码**：WMS0010
- **CRUD前缀**：`/api/base/warehouse`
- **表单字段**：warehouseCode, warehouseName, temperatureZone, warehouseType, companyName, province, city, district, address, contact, phone, remark

### 12.3 请求示例

```json
POST /api/base/warehouse
{
  "warehouseCode": "WH002",
  "warehouseName": "北京仓",
  "temperatureZone": "COLD",
  "warehouseType": "SELF",
  "companyName": "XX公司",
  "address": "北京市朝阳区...",
  "contact": "李四",
  "phone": "13900139000"
}
```

### 12.4 响应示例

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "warehouseCode": "WH002",
    "warehouseName": "北京仓"
  }
}
```

### 12.4 错误码/异常返回

| 错误码 | 场景 | 提示 |
|--------|------|------|
| WMS001 | 仓库编码已存在 | 仓库编码已存在 |
| WMS003 | 仓库已停用 | 仓库已停用，无法删除 |
| WMS004 | 仓库有关联数据 | 仓库有关联数据，无法删除 |
| VALIDATION_ERROR | 参数校验失败 | 返回具体校验失败字段 |

---

## 13. 权限与审计

### 13.1 权限标识

- `wms:warehouse:add`
- `wms:warehouse:edit`
- `wms:warehouse:delete`

### 13.2 权限要求

- 谁可以查看：所有用户
- 谁可以新增：系统管理员
- 谁可以修改：系统管理员
- 谁可以删除：系统管理员

### 13.3 审计要求

- 记录操作人、操作时间
- 记录变更字段（编辑时）
- 记录删除原因

---

## 14. 异常与边界场景

| 场景 | 预期处理 |
|---|---|
| 仓库编码重复 | 返回错误提示，不允许保存 |
| 删除已启用的仓库 | 返回错误提示 |
| 删除有关联数据的仓库 | 返回错误提示，列出关联信息 |
| 并发编辑 | 乐观锁处理 |
| 禁用后再次编辑 | 允许编辑基本信息 |

---

## 15. 验收标准

### 15.1 功能验收

- [ ] 新增仓库成功，编码不可重复
- [ ] 编辑仓库成功，编码不可修改
- [ ] 删除仓库前检查关联
- [ ] 启用/禁用切换正常
- [ ] 表单校验提示清晰
- [ ] 操作成功后列表刷新

### 15.2 数据验收

- [ ] 数据正确写入数据库
- [ ] 创建人/创建时间正确
- [ ] 修改人/修改时间正确
- [ ] 删除为逻辑删除

### 15.3 权限验收

- [ ] 无权限用户不可操作
- [ ] 有权限用户可正常操作

### 15.4 日志验收

- [ ] 新增日志完整
- [ ] 编辑日志记录变更字段
- [ ] 删除日志完整

---

## 16. 测试要点

### 16.1 单元测试

- 编码唯一性校验
- 手机号格式校验
- 关联数据检查

### 16.2 集成测试

- CRUD 全流程
- 权限过滤正确

### 16.3 页面/联调测试

- 表单校验提示
- 弹窗交互流畅

### 16.4 回归测试

- 不影响仓库查询功能

---

## 17. 技术实现约束

- 禁止擅自修改核心表结构
- 禁止超出本 Story 范围扩展
- 删除前必须检查关联数据
- 所有操作必须记录审计日志

---

## 18. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档
- [ ] 测试用例

---

## 19. 完成定义（DoD）

- [ ] 功能开发完成
- [ ] 自测通过
- [ ] 联调通过
- [ ] 验收标准全部满足
- [ ] 无阻塞性缺陷
- [ ] 文档已更新
- [ ] 可提交评审/上线

---

## 20. 风险与待确认项

**风险**

- 无

**待确认**

- 删除时关联检查范围（库位、库存、业务单据）

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
- 前置 Story：[story-01-01.md](story-01-01.md)
