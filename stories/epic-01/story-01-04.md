# Story 01-04 物料档案查询与新增

## 0. 基本信息

- Epic：基础数据管理
- Story ID：01-04
- 优先级：P0
- 状态：Completed
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

- 物料档案编辑（已实现）
- 物料档案删除（已实现）
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
| category | string | N | 物料分类（模糊搜索） |
| status | int | N | 状态：1启用/0禁用 |

### 7.2 新增输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| materialCode | string | Y | 物料编码 |
| materialName | string | Y | 物料名称 |
| spec | string | N | 规格 |
| unit | string | Y | 单位 |
| category | string | N | 物料分类 |
| isEnabled | int | Y | 状态：1启用/0禁用 |
| remark | string | N | 备注 |

> **注意**：brand、udi_flag、qc_flag、expire_flag 等字段在 DB material 表中暂无（需后续扩展），当前版本已实现基础字段。

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
| records[].category | string | 物料分类 |
| records[].isEnabled | int | 状态（1启用/0禁用） |
| records[].createTime | datetime | 创建时间 |

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
| 状态 | 启用/禁用 Switch |
| 创建时间 | - |

---

## 9. 业务规则

1. **物料编码唯一性**：新增时校验编码不重复
2. **必填校验**：materialCode、materialName、unit 必填
3. **状态切换**：Switch 启用/禁用物料

---

## 10. 状态流转

### 10.1 主体对象

- 对象名称：物料

### 10.2 状态定义

| 状态 | 说明 |
|---|---|
| 1 | 启用 |
| 0 | 禁用 |

### 10.3 流转规则

| 当前状态 | 操作 | 下一个状态 | 说明 |
|---|---|---|---|
| 0 | Switch | 1 | 启用 |
| 1 | Switch | 0 | 禁用 |

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
| material | category | 物料分类 |
| material | status | 状态（1启用/0禁用） |

> **注意**：brand、udi_flag、qc_flag、expire_flag 等字段不在当前 DB 表中，后续 Story 扩展。

### 11.3 数据变更说明

- 新增：INSERT 物料记录
- 查询支持分类模糊筛选

---

## 12. API / 接口契约

### 12.1 接口清单

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/base/material/list` | 物料分页查询 |
| POST | `/api/base/material` | 新增物料 |
| PUT | `/api/base/material/{id}` | 更新物料 |
| DELETE | `/api/base/material/{id}` | 删除物料 |
| PATCH | `/api/base/material/{id}/status` | 切换状态 |
| POST | `/api/base/material/export` | 导出 Excel |

### 12.2 请求示例

```
GET /api/base/material/list?materialCode=MAT&materialName=注射器&status=1&page=1&size=20
```

### 12.3 响应示例

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 1,
    "rows": [
      {
        "id": 1,
        "material_code": "MAT001",
        "material_name": "一次性注射器",
        "spec": "5ml",
        "unit": "支",
        "category": "医疗器械",
        "status": 1,
        "create_time": "2026-04-05 10:00:00"
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

---

## 15. 验收标准

### 15.1 功能验收

- [x] 物料查询正常
- [x] 模糊搜索正常（编码/名称/分类）
- [x] 分类筛选正常
- [x] 新增物料成功
- [x] 编码唯一性校验
- [x] 状态切换正常
- [x] 导出正常

### 15.2 数据验收

- [x] 数据写入正确
- [x] 状态正确

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

- [x] 后端代码
- [x] 前端页面
- [x] 接口文档
- [x] 测试用例

---

## 19. 完成定义（DoD）

- [x] 功能开发完成
- [x] 自测通过
- [x] 联调通过
- [x] 验收标准全部满足
- [x] 无阻塞性缺陷
- [x] 文档已更新
- [x] 可提交评审/上线

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
WMS-backend/
├── wms-center-web/.../controller/sys/MaterialController.java   # + toggleStatus + export 接口
├── wms-center-service/.../sys/service/MaterialService.java    # + toggleStatus + export 方法
├── wms-center-service/.../sys/impl/MaterialServiceImpl.java  # + toggleStatus + export 实现
├── wms-center-dao/.../mapper/MaterialMapper.java              # + updateStatus
├── wms-center-dao/.../resources/mapper/MaterialMapper.xml     # + updateStatus + 模糊查询修复

WMS-frontend/
├── apps/web-antd/src/api/sys/material.ts          # 修复 API 路径 + toggle/export
├── apps/web-antd/src/views/sys/material/index.vue # 修复编辑打开逻辑
├── apps/web-antd/src/views/sys/material/components/material-modal.vue
```

**实现内容**

1. **物料分页列表** — GET `/api/base/material/list`，支持分页 + 物料编码/名称/分类模糊搜索 + 状态筛选，使用 PageHelper 分页
2. **物料新增** — POST `/api/base/material`
3. **物料编辑** — PUT `/api/base/material/{id}`
4. **物料删除** — DELETE `/api/base/material/{id}`（逻辑删除）
5. **状态切换** — PATCH `/api/base/material/{id}/status?enabled=1`
6. **物料导出** — POST `/api/base/material/export

**验证结果**

| 验收项 | 结果 |
|--------|------|
| 物料查询正常 | ✅ 通过 |
| 模糊搜索正常（编码/名称/分类） | ✅ 通过 |
| 分类筛选正常 | ✅ 通过 |
| 新增物料成功 | ✅ 通过 |
| 编码唯一性校验 | ✅ 通过 |
| 导出正常 | ✅ 通过 |

**未完成/风险**

```
1. [已知差异] 字段差异：Story 定义字段 brand/udi_flag/qc_flag/expire_flag 等，
   DB material 表仅有: material_code, material_name, spec, unit, category, status。
   额外字段需后续 Story 扩展时 DB 同步变更。

2. [已修复] 物料编码/名称搜索为精确匹配 → 改为模糊查询。

3. [已修复] 分页未生效（listByKeyword 绕过了 PageHelper） → 统一使用 selectList。

4. [已修复] 前端 API 路径缺少 /api/base 前缀 → 补全路径。

5. [已修复] 弹窗打开时数据加载时机错误 → 改为 v-model 控制 open，数据加载在 modal 内部触发。

6. [已修复] 编辑时 modal.open(record.id) 在 v-model:open 之前调用 → 移除显式 open 调用，由 v-model 触发。
```

---

## 22. 关联文档

- PRD：[WMS需求说明书 20260331 完成3.1-3.6.md](../../WMS需求说明书%20260331%20完成3.1-3.6.md) - WMS0030 物料档案
- 数据库设计：[WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md)
- Epic Brief：[epic-01-overview.md](../../epics/epic-01-overview.md)
