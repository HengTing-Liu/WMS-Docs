# Story 01-04 物料档案查询与新增

## 0. 基本信息

- Epic：基础数据管理
- Story ID：01-04
- 优先级：P0
- 状态：Draft
- 负责人：PM / FE / BE / QA
- 预计工期：1d
- 依赖 Story：无（可独立开发）
- 关联迭代：Sprint 1

---

## 1. 目标

实现物料档案的查询与新增能力，支持物料信息维护。

---

## 2. 业务背景

物料档案是 WMS 系统的核心主数据，所有出入库、库存业务都依赖物料档案。本 Story 提供物料的查询、新增功能。

---

## 3. 范围

### 3.1 本 Story 包含

- 物料档案分页列表查询
- 物料名称/编码模糊搜索
- 按物料分类筛选
- 按状态筛选（启用/禁用）
- 物料档案新增
- 物料档案导出

### 3.2 本 Story 不包含

- 物料档案编辑
- 物料档案删除
- 物料批量导入
- 物料分类管理

---

## 4. 参与角色

- 仓库管理员：查询物料
- 系统管理员：查询/新增物料

---

## 5. 前置条件

- 用户已登录系统
- 用户具备物料管理权限（`wms:material:query`、`wms:material:add`）

---

## 6. 触发方式

- 页面入口：基础设置 → 物料档案（WMS0030）
- 接口入口：GET `/api/base/material/list`
- 低代码表编码：WMS0030

---

## 7. 输入 / 输出

### 7.1 查询输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| page | int | N | 页码，默认 1 |
| pageSize | int | N | 每页条数，默认 20 |
| materialCode | string | N | 物料编码（模糊搜索） |
| materialName | string | N | 物料名称（模糊搜索） |
| categoryId | long | N | 物料分类ID |
| status | string | N | 状态：ENABLED/DISABLED |
| udiFlag | boolean | N | 是否UDI管理 |

### 7.2 新增输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| materialCode | string | Y | 物料编码 |
| materialName | string | Y | 物料名称 |
| spec | string | N | 规格 |
| unit | string | Y | 单位 |
| categoryId | long | N | 物料分类ID |
| brand | string | N | 品牌 |
| articleNo | string | N | 货号 |
| udiFlag | boolean | N | 是否UDI管理 |
| expireFlag | boolean | N | 是否效期管理 |
| defaultExpireDays | int | N | 默认效期天数 |
| qcFlag | boolean | N | 是否必检 |
| qcCategory | string | N | 质检标准分类 |
| remark | string | N | 备注 |

### 7.3 输出

| 字段 | 类型 | 说明 |
|---|---|
| total | int | 总记录数 |
| records | array | 物料列表 |
| records[].id | long | 物料ID |
| records[].materialCode | string | 物料编码 |
| records[].materialName | string | 物料名称 |
| records[].spec | string | 规格 |
| records[].unit | string | 单位 |
| records[].categoryName | string | 物料分类 |
| records[].brand | string | 品牌 |
| records[].udiFlag | boolean | 是否UDI |
| records[].expireFlag | boolean | 是否效期管理 |
| records[].qcFlag | boolean | 是否必检 |
| records[].status | string | 状态 |

---

## 8. 页面/交互要求

### 8.1 页面

- 页面名称：物料档案列表页
- 页面类型：列表页 + 表单弹窗
- 菜单路径：基础设置 → 物料档案

### 8.2 交互要求

- 输入搜索条件，点击【查询】
- 点击【新增】按钮，弹出新增表单
- 保存成功后关闭弹窗，刷新列表
- 点击【导出】按钮，下载 Excel

### 8.3 展示字段

| 字段 | 说明 |
|---|---|
| 物料编码 | - |
| 物料名称 | - |
| 规格 | - |
| 单位 | - |
| 物料分类 | - |
| 品牌 | - |
| UDI管理 | 显示是/否 |
| 效期管理 | 显示是/否 |
| 必检 | 显示是/否 |
| 状态 | 启用/禁用标签 |

---

## 9. 业务规则

1. **物料编码唯一性**：新增时校验编码不重复
2. **必填校验**：materialCode、materialName、unit 必填
3. **UDI管理**：医疗器械必须 UDI 管理
4. **效期管理**：启用效期管理时，可设置默认效期天数
5. **必检标识**：必检物料入库时需要送检

---

## 10. 状态流转

### 10.1 主体对象

- 对象名称：物料

### 10.2 状态定义

| 状态 | 说明 |
|---|---|
| ENABLED | 启用 |
| DISABLED | 禁用 |

### 10.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| DISABLED | 启用 | ENABLED | Story 01-05 |
| ENABLED | 禁用 | DISABLED | Story 01-05 |

---

## 11. 数据设计

### 11.1 涉及表

- `material`

### 11.2 关键字段

| 表名 | 字段 | 说明 |
|---|---|---|
| material | id | 主键 |
| material | material_code | 物料编码 |
| material | material_name | 物料名称 |
| material | spec | 规格 |
| material | unit | 单位 |
| material | category_id | 物料分类ID |
| material | brand | 品牌 |
| material | udi_flag | 是否UDI |
| material | expire_flag | 是否效期管理 |
| material | qc_flag | 是否必检 |
| material | status | 状态 |

### 11.3 数据变更说明

- 新增：INSERT 物料记录
- 查询支持分类筛选

---

## 12. API / 接口契约

### 12.1 接口清单（低代码CRUD约定）

| 方法 | 路径 | 说明 | 对应低代码接口 |
|------|------|------|----------------|
| GET | `/api/base/material/list` | 物料分页查询 | `{crudPrefix}/list` |
| POST | `/api/base/material` | 新增物料 | `{crudPrefix}` |
| GET | `/api/base/material/export` | 物料导出 | `{crudPrefix}/export` |

### 12.2 Schema 配置（低代码）

- **表编码**：WMS0030
- **CRUD前缀**：`/api/base/material`
- **列表字段**：materialCode, materialName, spec, unit, categoryName, brand, udiFlag, expireFlag, qcFlag, status
- **搜索字段**：materialCode, materialName, categoryId, status, udiFlag

### 12.3 请求示例

```json
GET /api/base/material/list?materialName=注射器&qcFlag=true
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
        "materialCode": "MAT001",
        "materialName": "一次性注射器",
        "spec": "5ml",
        "unit": "支",
        "categoryName": "医疗器械",
        "brand": "强生",
        "udiFlag": true,
        "expireFlag": true,
        "qcFlag": true,
        "status": "ENABLED"
      }
    ]
  }
}
```

### 12.4 错误码/异常返回

| 错误码 | 场景 | 提示 |
|--------|------|------|
| MAT001 | 物料编码已存在 | 物料编码已存在 |
| VALIDATION_ERROR | 参数校验失败 | 返回具体校验失败字段 |

---

## 13. 权限与审计

### 13.1 权限标识

- `wms:material:query`
- `wms:material:add`

### 13.2 权限要求

- 谁可以查看：所有用户
- 谁可以新增：系统管理员

### 13.3 审计要求

- 记录新增日志

---

## 14. 异常与边界场景

| 场景 | 预期处理 |
|---|---|
| 物料编码重复 | 返回错误提示 |
| 效期天数为负数 | 校验失败 |

---

## 15. 验收标准

### 15.1 功能验收

- [ ] 物料查询正常
- [ ] 模糊搜索正常
- [ ] 分类筛选正常
- [ ] 新增物料成功
- [ ] 编码唯一性校验
- [ ] 导出正常

### 15.2 数据验收

- [ ] 数据写入正确
- [ ] 状态正确

---

## 16. 测试要点

### 16.1 单元测试

- 编码唯一性校验

### 16.2 集成测试

- CRUD 全流程

---

## 17. 技术实现约束

- 物料编码必须有唯一索引
- 禁止超范围扩展

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

- 无

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

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0030 物料档案
- 数据库设计：[WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md)
- Epic Brief：[epic-01-overview.md](../../epics/epic-01-overview.md)
