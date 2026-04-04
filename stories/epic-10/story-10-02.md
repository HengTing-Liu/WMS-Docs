# Story 10-02 用户管理

## 0. 基本信息

- Epic：系统管理
- Story ID：10-02
- 优先级：P0
- 状态：Draft
- 预计工期：1d
- 依赖 Story：10-01（组织机构）、10-03（角色管理）
- 关联迭代：Sprint 1

---

## 1. 目标

实现用户管理功能，支持用户增删改查、角色分配、仓库权限分配。

---

## 2. 业务背景

用户管理是系统的基础功能，用于管理系统用户和权限。

---

## 3. 范围

### 3.1 本 Story 包含

- 用户列表查询
- 用户新增
- 用户编辑
- 用户删除/禁用
- 用户导入
- 角色分配
- 仓库权限分配

### 3.2 本 Story 不包含

- 用户登录
- 密码重置

---

## 4. 参与角色

- 系统管理员：管理所有用户

---

## 5. 前置条件

- 角色已配置
- 用户具备用户管理权限

---

## 6. 触发方式

- 页面入口：系统管理 → 用户管理
- 接口入口：GET `/api/system/user/list`

---

## 7. 输入 / 输出

### 7.1 新增用户 - 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| username | string | Y | 用户账号 |
| realName | string | Y | 用户姓名 |
| deptId | long | Y | 部门ID |
| post | string | N | 岗位 |
| phone | string | N | 联系电话 |
| email | string | N | 邮箱 |
| roleIds | array | Y | 角色ID列表 |
| warehouseIds | array | N | 仓库ID列表 |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 用户ID |
| username | string | 用户账号 |
| realName | string | 用户姓名 |

---

## 8. 业务规则

1. **用户账号唯一性**：新增时校验账号不重复
2. **角色分配**：用户可分配多个角色
3. **仓库权限**：用户只能操作有权限的仓库

---

## 9. 数据设计

### 9.1 涉及表

- `sys_user`（已有）
- `sys_user_role`（已有）
- `sys_user_post`（已有）
- `sys_user_warehouse`（新增）

---

## 10. API / 接口契约

### 10.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0440 |
| CRUD前缀 | `/api/system/user` |

### 10.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/system/user/list` | 用户列表 |
| POST | `/api/system/user` | 新增用户 |
| PUT | `/api/system/user/{id}` | 编辑用户 |
| DELETE | `/api/system/user/{id}` | 删除用户 |
| PUT | `/api/system/user/{id}/disable` | 禁用用户 |
| PUT | `/api/system/user/{id}/enable` | 启用用户 |
| PUT | `/api/system/user/{id}/resetPwd` | 重置密码 |
| POST | `/api/system/user/import` | 用户导入 |
| PUT | `/api/system/user/{id}/roles` | 分配角色 |
| PUT | `/api/system/user/{id}/warehouses` | 分配仓库权限 |

---

## 11. 权限与审计

### 11.1 权限标识

- `system:user:query`
- `system:user:add`
- `system:user:edit`
- `system:user:delete`

### 11.2 审计要求

- 记录操作人、操作时间
- 记录权限变更

---

## 12. 验收标准

### 12.1 功能验收

- [ ] 用户 CRUD 正常
- [ ] 角色分配正常
- [ ] 仓库权限分配正常
- [ ] 用户导入正常

---

## 13. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档

---

## 14. 关联文档

- Epic Brief：[epic-10-overview.md](../../epics/epic-10-overview.md)
