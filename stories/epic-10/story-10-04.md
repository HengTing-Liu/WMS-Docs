# Story 10-04 菜单管理

## 0. 基本信息

- Epic：系统管理
- Story ID：10-04
- 优先级：P0
- 状态：Draft
- 预计工期：0.5d
- 依赖 Story：无
- 关联迭代：Sprint 1

---

## 1. 目标

实现菜单管理功能，支持菜单增删改查。

---

## 2. 业务背景

菜单管理用于配置系统的功能菜单和按钮权限。

---

## 3. 范围

### 3.1 本 Story 包含

- 菜单树查询
- 菜单新增
- 菜单编辑
- 菜单删除

### 3.2 本 Story 不包含

- 菜单导入/导出

---

## 4. 参与角色

- 系统管理员：管理所有菜单

---

## 5. 前置条件

- 用户具备菜单管理权限

---

## 6. 触发方式

- 页面入口：系统管理 → 菜单管理
- 接口入口：GET `/api/system/menu/tree`

---

## 7. 输入 / 输出

### 7.1 新增菜单 - 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| menuName | string | Y | 菜单名称 |
| parentId | long | N | 父级ID |
| menuType | string | Y | 菜单类型：CATALOG/MENU/BUTTON |
| path | string | N | 路由地址 |
| component | string | N | 组件路径 |
| permission | string | N | 权限标识 |
| icon | string | N | 图标 |
| orderNum | int | N | 显示顺序 |
| visible | boolean | N | 是否显示 |
| status | string | N | 状态：ENABLED/DISABLED |

### 7.2 输出

| 字段 | 类型 | 说明 |
|---|---|
| id | long | 菜单ID |
| menuName | string | 菜单名称 |

---

## 8. 业务规则

1. **菜单类型**：
   - CATALOG：目录
   - MENU：菜单
   - BUTTON：按钮
2. **权限标识**：按钮必须有权限标识，用于权限控制

---

## 9. 数据设计

### 9.1 涉及表

- `sys_menu`（已有）

---

## 10. API / 接口契约

### 10.1 Schema 配置

| 配置项 | 值 |
|---|---|
| 表编码 | WMS0460 |
| CRUD前缀 | `/api/system/menu` |

### 10.2 接口清单

| 方法 | 路径 | 说明 |
|---|---|
| GET | `/api/system/menu/tree` | 菜单树查询 |
| POST | `/api/system/menu` | 新增菜单 |
| PUT | `/api/system/menu/{id}` | 编辑菜单 |
| DELETE | `/api/system/menu/{id}` | 删除菜单 |

---

## 11. 权限与审计

### 11.1 权限标识

- `system:menu:query`
- `system:menu:add`
- `system:menu:edit`
- `system:menu:delete`

---

## 12. 验收标准

### 12.1 功能验收

- [ ] 菜单树展示正常
- [ ] 菜单 CRUD 正常
- [ ] 权限标识配置正常

---

## 13. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档

---

## 14. 关联文档

- Epic Brief：[epic-10-overview.md](../../epics/epic-10-overview.md)
