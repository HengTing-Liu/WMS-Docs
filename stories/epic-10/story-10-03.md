# Story 10-03 角色管理

## 0. 基本信息

- Epic：系统管理
- Story ID：10-03
- 优先级：P0
- 状态：Draft
- 预计工期：1d
- 依赖 Story：10-04（菜单管理）
- 关联迭代：Sprint 1

---

## 1. 目标

实现角色管理功能，支持角色增删改查、菜单权限分配、数据权限配置。

---

## 2. 业务背景

角色管理用于管理系统的权限角色，支持菜单权限和数据权限配置。

---

## 3. 范围

### 3.1 本 Story 包含

- 角色列表查询
- 角色新增
- 角色编辑
- 角色删除
- 菜单权限分配
- 数据权限配置

### 3.2 本 Story 不包含

- 系统预置角色编辑

---

## 4. 参与角色

- 系统管理员：管理所有角色

---

## 5. 前置条件

- 菜单已配置
- 用户具备角色管理权限

---

## 6. 触发方式

- 页面入口：系统管理 → 角色管理
- 接口入口：GET `/api/system/role/list`

---

## 7. 输入 / 输出

### 7.1 新增角色 - 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| roleCode | string | Y | 角色编码 |
| roleName | string | Y | 角色名称 |
| remark | string | N | 备注 |
| menuIds | array | Y | 菜单ID列表 |
| dataScope | string | N | 数据权限范围 |

### 7.2 数据权限范围

| 值 | 说明 |
|---|---|
| ALL | 全部数据 |
| DEPT | 本部门数据 |
| DEPT_AND_CHILD | 本部门及以下数据 |
| SELF | 仅本人数据 |
| CUSTOM | 自定义 |

### 7.3 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 角色ID |
| roleCode | string | 角色编码 |
| roleName | string | 角色名称 |

---

## 8. 业务规则

1. **角色编码唯一性**：新增时校验编码不重复
2. **菜单权限**：勾选菜单后自动包含子菜单
3. **数据权限**：配置角色可访问的数据范围

---

## 9. 数据设计

### 9.1 涉及表

- `sys_role`（已有）
- `sys_role_menu`（已有）
- `sys_role_dept`（已有）
- `sys_role_warehouse`（新增）

---

## 10. API / 接口契约

### 10.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0450 |
| CRUD前缀 | `/api/system/role` |

### 10.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/system/role/list` | 角色列表 |
| POST | `/api/system/role` | 新增角色 |
| PUT | `/api/system/role/{id}` | 编辑角色 |
| DELETE | `/api/system/role/{id}` | 删除角色 |
| GET | `/api/system/role/{id}` | 角色详情（含菜单） |
| PUT | `/api/system/role/{id}/menus` | 分配菜单权限 |
| PUT | `/api/system/role/{id}/dataScope` | 配置数据权限 |

---

## 11. 权限与审计

### 11.1 权限标识

- `system:role:query`
- `system:role:add`
- `system:role:edit`
- `system:role:delete`

### 11.2 审计要求

- 记录操作人、操作时间
- 记录权限变更

---

## 12. 验收标准

### 12.1 功能验收

- [ ] 角色 CRUD 正常
- [ ] 菜单权限分配正常
- [ ] 数据权限配置正常
- [ ] 权限变更后即时生效

---

## 13. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档

---

## 14. 关联文档

- Epic Brief：[epic-10-overview.md](../../epics/epic-10-overview.md)
