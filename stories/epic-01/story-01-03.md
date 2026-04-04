# Story 01-03 库位档案查询与新增

## 0. 基本信息

- Epic：基础数据管理
- Story ID：01-03
- 优先级：P0
- 状态：Draft
- 负责人：PM / FE / BE / QA
- 预计工期：1d
- 依赖 Story：01-02（仓库档案新增）
- 关联迭代：Sprint 1

---

## 1. 目标

实现库位档案的查询与新增能力，支持树形展示仓库-库位层级结构。

---

## 2. 业务背景

库位是仓库内的存储单元，库位档案管理是 WMS 系统的基础功能。本 Story 提供库位的查询、新增功能，支持树形层级展示（仓库 → 库区 → 货架 → 层 → 列 → 位）。

---

## 3. 范围

### 3.1 本 Story 包含

- 库位树形列表查询（按仓库）
- 库位新增
- 库位导出

### 3.2 本 Story 不包含

- 库位编辑（后续 Story）
- 库位删除
- 库位批量导入

---

## 4. 参与角色

- 仓库管理员：查询/新增库位
- 系统管理员：查询/新增库位

---

## 5. 前置条件

- 仓库档案已存在
- 用户具备库位管理权限（`wms:location:query`、`wms:location:add`）

---

## 6. 触发方式

- 页面入口：基础设置 → 库位档案（WMS0020）
- 接口入口：GET `/api/base/location/list`
- 低代码表编码：WMS0020

---

## 7. 输入 / 输出

### 7.1 查询输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| warehouseId | long | N | 仓库ID |
| parentId | long | N | 父级库位ID，根节点传 0 |
| locationType | string | N | 库位类型 |
| status | string | N | 状态：IDLE/OCCUPIED |

### 7.2 新增输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| warehouseId | long | Y | 仓库ID |
| parentId | long | N | 父级库位ID，根库位传 0 |
| locationCode | string | Y | 库位编码 |
| locationName | string | Y | 库位名称 |
| locationType | string | Y | 库位类型：AREA/SHELF/ROW/COL/CELL |
| storageMode | string | N | 存储模式：EXCLUSIVE/SHARED |
| spec | string | N | 规格：4x4/1x1 |
| capacity | int | N | 容量 |
| remark | string | N | 备注 |

### 7.3 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 库位ID |
| locationCode | string | 库位编码 |
| locationName | string | 库位名称 |
| locationType | string | 库位类型 |
| level | int | 层级 |
| parentId | long | 父级ID |
| children | array | 子节点 |
| status | string | 状态 |

---

## 8. 页面/交互要求

### 8.1 页面

- 页面名称：库位档案列表页
- 页面类型：树形列表页
- 菜单路径：基础设置 → 库位档案

### 8.2 交互要求

- 左侧选择仓库，右侧展示库位树
- 点击节点展开/折叠
- 点击【新增】按钮，弹出新增表单
- 新增时选择父级库位，自动计算层级
- 点击【导出】按钮，导出 Excel

### 8.3 展示字段

| 字段 | 说明 |
|---|---|
| 库位编码 | 如 L0001001001 |
| 库位名称 | 如 A区-01架 |
| 库位类型 | 存储区/货架/层/列/格 |
| 存储模式 | 专属/共享 |
| 规格 | 4x4/1x1 |
| 状态 | 空闲/占用 |
| 创建时间 | - |

---

## 9. 业务规则

1. **库位编码唯一性**：同一父级下编码不可重复
2. **层级继承**：新增子库位时继承父级属性
3. **编码规则**：
   - 存储区：如 A01
   - 货架：如 01（A01 + 序号）
   - 层：如 01（A0101 + 序号）
   - 格式：`L0001` + `001` + `01` + `01` + `01` + `01`
4. **树形深度限制**：最大 6 层（存储区 → 格）
5. **状态自动更新**：有库存时状态为"占用"，无库存时为"空闲"

---

## 10. 状态流转

### 10.1 主体对象

- 对象名称：库位

### 10.2 状态定义

| 状态 | 说明 |
|---|---|
| IDLE | 空闲 |
| OCCUPIED | 占用 |
| FROZEN | 冻结（盘点中） |

### 10.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| IDLE | 入库 | OCCUPIED | 自动 |
| OCCUPIED | 出库 | IDLE | 自动 |

---

## 11. 数据设计

### 11.1 涉及表

- `wms_location`

### 11.2 关键字段

| 表名 | 字段 | 说明 |
|---|---|---|
| wms_location | id | 主键 |
| wms_location | warehouse_id | 仓库ID |
| wms_location | parent_id | 父级ID |
| wms_location | location_code | 库位编码 |
| wms_location | location_name | 库位名称 |
| wms_location | location_type | 库位类型 |
| wms_location | level | 层级深度 |
| wms_location | path | 路径 |
| wms_location | status | 状态 |

### 11.3 数据变更说明

- 新增：INSERT 库位记录
- 自动计算：`level`、`path`、`sort`

---

## 12. API / 接口契约

### 12.1 接口清单（低代码CRUD约定）

| 方法 | 路径 | 说明 | 对应低代码接口 |
|------|------|------|----------------|
| GET | `/api/base/location/list` | 库位树查询 | `{crudPrefix}/list` |
| POST | `/api/base/location` | 新增库位 | `{crudPrefix}` |
| GET | `/api/base/location/export` | 库位导出 | `{crudPrefix}/export` |

### 12.2 Schema 配置（低代码）

- **表编码**：WMS0020
- **CRUD前缀**：`/api/base/location`
- **列表字段**：locationCode, locationName, locationType, storageMode, spec, capacity, status, gmtCreate
- **搜索字段**：warehouseId, parentId, locationType, status

### 12.3 请求示例

```json
GET /api/base/location/list?warehouseId=1&parentId=0
```

### 12.3 响应示例

```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "locationCode": "L0001",
      "locationName": "A区",
      "locationType": "AREA",
      "level": 1,
      "parentId": 0,
      "children": [
        {
          "id": 2,
          "locationCode": "L0001001",
          "locationName": "A01架",
          "locationType": "SHELF",
          "level": 2,
          "children": []
        }
      ]
    }
  ]
}
```

### 12.4 错误码/异常返回

| 错误码 | 场景 | 提示 |
|--------|------|------|
| LOC001 | 库位编码已存在 | 库位编码已存在 |
| LOC003 | 库位层级错误 | 库位层级不正确 |
| VALIDATION_ERROR | 参数校验失败 | 返回具体校验失败字段 |

---

## 13. 权限与审计

### 13.1 权限标识

- `wms:location:query`
- `wms:location:add`

### 13.2 权限要求

- 谁可以查看：仓库管理员
- 谁可以新增：系统管理员

### 13.3 审计要求

- 记录新增日志
- 记录库位层级

---

## 14. 异常与边界场景

| 场景 | 预期处理 |
|---|---|
| 库位编码重复 | 返回错误提示 |
| 超过层级限制 | 返回错误提示 |
| 父级库位不存在 | 返回错误提示 |

---

## 15. 验收标准

### 15.1 功能验收

- [ ] 树形展示正常
- [ ] 点击展开/折叠正常
- [ ] 新增库位成功
- [ ] 层级自动计算正确
- [ ] 编码自动生成正确
- [ ] 导出正常

### 15.2 数据验收

- [ ] 数据写入正确
- [ ] 层级深度正确
- [ ] 路径正确

---

## 16. 测试要点

### 16.1 单元测试

- 树形结构构建正确
- 层级计算正确

### 16.2 集成测试

- 树形查询性能（10000 节点 < 1s）

---

## 17. 技术实现约束

- 树形查询使用递归或 WITH RECURSIVE
- 禁止超 6 层嵌套

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

- 树形查询性能（数据量大时）

**待确认**

- 库位编码生成规则

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

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0020 库位档案
- 数据库设计：[WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md)
- Epic Brief：[epic-01-overview.md](../../epics/epic-01-overview.md)
