# Story 01-05 仓库收货地址管理

## 0. 基本信息

- Epic：基础数据管理
- Story ID：01-05
- 优先级：P0
- 状态：Draft
- 负责人：PM / FE / BE / QA
- 预计工期：0.5d
- 依赖 Story：01-01（仓库档案查询）
- 关联迭代：Sprint 1

---

## 1. 目标

实现仓库收货地址（仓库收货人）的增删改查功能，支持一个仓库绑定多个收货地址。

---

## 2. 业务背景

一个仓库可能有多个收货地址（如不同温区、不同卸货区）。收货地址作为仓库的子表数据，需要在仓库详情页中关联管理。每个收货地址包含收货人信息、联系方式和详细地址。

---

## 3. 范围

### 3.1 本 Story 包含

- 仓库收货地址列表查询（按 warehouseCode）
- 仓库收货地址新增
- 仓库收货地址编辑
- 仓库收货地址删除（软删除）
- 设置默认收货地址

### 3.2 本 Story 不包含

- 仓库主档的新增/编辑/删除（见 Story 01-02）
- 收货地址的批量导入/导出

---

## 4. 参与角色

- 仓库管理员：管理仓库收货地址
- 系统管理员：管理所有仓库收货地址

---

## 5. 前置条件

- 用户已登录系统
- 目标仓库已存在
- 用户具备仓库收货地址管理权限（`wms:warehouse:receiver:*`）

---

## 6. 触发方式

- 页面入口：仓库档案列表页 → 点击仓库行「收货地址」按钮 → 打开收货地址抽屉
- 接口入口：`/api/base/warehouse-receiver/*`
- 低代码表编码：WMS0011

---

## 7. 输入 / 输出

### 7.1 输入

#### 7.1.1 查询参数

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| warehouseCode | string | Y | 仓库编码 |
| page | int | N | 页码，默认 1 |
| pageSize | int | N | 每页条数，默认 20 |

#### 7.1.2 新增/编辑参数

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| warehouseCode | string | Y | 仓库编码 |
| consignee | string | Y | 收货人姓名 |
| phoneNumber | string | Y | 手机号码 |
| country | string | N | 国家，默认"中国" |
| province | string | Y | 省份 |
| city | string | Y | 城市 |
| district | string | N | 区县 |
| detailedAddress | string | Y | 详细地址 |
| postalCode | string | N | 邮政编码 |
| isDefault | int | N | 是否默认（0-否 1-是），默认 0 |
| remark | string | N | 备注 |

### 7.2 输出

#### 7.2.1 列表响应

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 3,
    "records": [
      {
        "id": 1,
        "warehouseCode": "WH001",
        "consignee": "张三",
        "phoneNumber": "13800138000",
        "country": "中国",
        "province": "上海市",
        "city": "上海市",
        "district": "浦东新区",
        "detailedAddress": "张江高科技园区123号",
        "postalCode": "200000",
        "isDefault": 1,
        "createBy": "admin",
        "createTime": "2026-04-01 10:00:00",
        "updateBy": null,
        "updateTime": null,
        "remark": "1号卸货口"
      }
    ]
  }
}
```

---

## 8. 页面/交互要求

### 8.1 页面

- 页面名称：仓库收货地址管理抽屉
- 组件类型：抽屉（Drawer）
- 触发入口：仓库列表页「收货地址」按钮

### 8.2 交互要求

- 点击「收货地址」按钮，打开抽屉，展示该仓库的所有收货地址列表
- 点击「新增」按钮，弹出表单弹窗
- 点击列表行「编辑」按钮，弹出表单弹窗（预填数据）
- 点击「删除」按钮，二次确认后删除
- 点击「设为默认」按钮，将该地址设为主收货地址
- 同一仓库只能有一个默认收货地址

### 8.3 展示字段

| 字段 | 说明 |
|---|---|
| 收货人 | consignee |
| 手机号 | phoneNumber（脱敏显示） |
| 收货地址 | province + city + district + detailedAddress |
| 默认 | 显示标签（是/否） |
| 操作 | 编辑/删除/设为默认 |

---

## 9. 业务规则

1. 一个仓库只能有一个默认收货地址
2. 设置新默认地址时，自动取消原默认地址
3. 删除默认地址时，不自动转移默认标记
4. 收货人姓名、手机号不能为空
5. 地址信息必填项：省份、城市、详细地址
6. 删除前检查是否有未完成的出入库单关联该地址

---

## 10. 状态流转

### 10.1 主体对象

- 对象名称：仓库收货地址

### 10.2 状态定义

| 状态 | 说明 |
|---|---|
| is_default = 1 | 默认地址 |
| is_default = 0 | 非默认地址 |

### 10.3 流转规则

| 操作 | 说明 |
|---|---|
| 设为默认 | 将 is_default 从 0 改为 1，同时将该仓库其他地址 is_default 改为 0 |
| 删除 | 逻辑删除 is_deleted = 1 |

---

## 11. 数据设计

### 11.1 涉及表

- `sys_warehouse_receiver`（仓库收货人表）

### 11.2 关键字段

| 表名 | 字段 | 说明 |
|---|---|---|
| sys_warehouse_receiver | id | 主键 |
| sys_warehouse_receiver | warehouse_code | 仓库编码（外键） |
| sys_warehouse_receiver | consignee | 收货人姓名 |
| sys_warehouse_receiver | phone_number | 手机号码 |
| sys_warehouse_receiver | country | 国家 |
| sys_warehouse_receiver | province | 省份 |
| sys_warehouse_receiver | city | 城市 |
| sys_warehouse_receiver | district | 区县 |
| sys_warehouse_receiver | detailed_address | 详细地址 |
| sys_warehouse_receiver | postal_code | 邮政编码 |
| sys_warehouse_receiver | is_default | 是否默认 |
| sys_warehouse_receiver | is_deleted | 逻辑删除 |

### 11.3 数据变更说明

- 新增表数据操作记录

---

## 12. API / 接口契约

### 12.1 接口清单

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/base/warehouse-receiver/list` | 收货地址列表 |
| GET | `/api/base/warehouse-receiver/{id}` | 收货地址详情 |
| POST | `/api/base/warehouse-receiver` | 新增收货地址 |
| PUT | `/api/base/warehouse-receiver/{id}` | 编辑收货地址 |
| DELETE | `/api/base/warehouse-receiver/{id}` | 删除收货地址 |
| PUT | `/api/base/warehouse-receiver/{id}/default` | 设为默认 |

### 12.2 Schema 配置（低代码）

- **表编码**：WMS0011
- **CRUD前缀**：`/api/base/warehouse-receiver`
- **列表字段**：consignee, phoneNumber, province, city, district, detailedAddress, isDefault, remark
- **搜索字段**：warehouseCode

### 12.3 请求示例

```json
POST /api/base/warehouse-receiver
{
  "warehouseCode": "WH001",
  "consignee": "张三",
  "phoneNumber": "13800138000",
  "province": "上海市",
  "city": "上海市",
  "district": "浦东新区",
  "detailedAddress": "张江高科技园区123号",
  "isDefault": 1
}
```

### 12.4 错误码/异常返回

| 错误码 | 场景 | 提示 |
|---|---|---|
| 401 | 未登录 | 请先登录 |
| 403 | 无权限 | 没有仓库收货地址管理权限 |
| 400 | 参数校验失败 | 必填字段不能为空 |
| 500 | 系统错误 | 系统异常，请稍后重试 |

---

## 13. 权限与审计

### 13.1 权限标识

- `wms:warehouse:receiver:query` - 查询
- `wms:warehouse:receiver:add` - 新增
- `wms:warehouse:receiver:edit` - 编辑
- `wms:warehouse:receiver:delete` - 删除

### 13.2 审计要求

- 新增/编辑/删除记录操作日志

---

## 14. 异常与边界场景

| 场景 | 预期处理 |
|---|---|
| 查询条件无结果 | 返回空列表 |
| 重复手机号 | 允许（不同地址可相同联系方式） |
| 删除唯一收货地址 | 允许删除 |
| 设置默认时无其他地址 | 正常设为默认 |

---

## 15. 验收标准

### 15.1 功能验收

- [ ] 可以查看仓库的收货地址列表
- [ ] 可以新增收货地址
- [ ] 可以编辑收货地址
- [ ] 可以删除收货地址（软删除）
- [ ] 可以将地址设为默认
- [ ] 设为默认后，原默认地址自动取消

### 15.2 校验验收

- [ ] 手机号格式校验
- [ ] 必填字段校验
- [ ] 地址完整拼接正确

---

## 16. 技术实现约束

- 收货地址列表按 is_default 降序、create_time 降序排列
- 设为默认需在同一事务内更新原默认地址

---

## 17. 交付物清单

- [ ] 后端代码
- [ ] 前端页面（抽屉组件）
- [ ] 接口文档
- [ ] 测试用例

---

## 18. 完成定义（DoD）

- [x] 功能开发完成
- [x] 自测通过
- [x] 联调通过
- [x] 验收标准全部满足
- [x] 无阻塞性缺陷
- [x] 文档已更新

---

## 19. 开发回执模板

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

## 20. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0010 仓库档案
- 数据库设计：[WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md) - sys_warehouse_receiver
- Epic Brief：[epic-01-overview.md](../../epics/epic-01-overview.md)
