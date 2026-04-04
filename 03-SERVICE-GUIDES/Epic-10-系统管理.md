# Epic-10：系统管理

> Epic编号：Epic-10
> Epic名称：系统管理
> PRD来源：WMS需求说明书 第3.12节
> 优先级：P0
> 预计工时：3天

---

## 一、Epic 概述

### 1.1 业务背景

系统管理是系统的基础支撑模块，包括组织机构、用户管理、角色管理、菜单管理等，为其他业务模块提供权限控制能力。

### 1.2 包含模块

| 模块编号 | 模块名称 | Story数 | 开发顺序 |
|---------|---------|---------|---------|
| WMS0430 | 组织机构 | 3 | 1 |
| WMS0440 | 用户管理 | 5 | 2 |
| WMS0450 | 角色管理 | 5 | 3 |
| WMS0460 | 菜单管理 | 4 | 4 |
| WMS0470 | 系统日志 | 3 | 5 |

---

## 二、模块 Story 拆分

### 2.1 WMS0430 组织机构

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0430-01 | 组织机构查询 | 树形展示、层级缩进 | - |
| S-0430-02 | 组织机构详情 | 查看机构信息 | S-0430-01 |
| S-0430-03 | 组织机构同步 | 从主系统同步 | ERP/MDM接口 |

**数据来源**：从主系统同步，定时/实时同步机制

**数据库表**：`sys_dept`（已有）

**权限标识**：`system:dept:query`

---

### 2.2 WMS0440 用户管理

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0440-01 | 用户列表查询 | 按部门、状态筛选 | - |
| S-0440-02 | 用户新增 | 填写用户信息、分配角色、仓库权限 | S-0440-01 |
| S-0440-03 | 用户编辑 | 修改用户信息、重新分配角色 | S-0440-01 |
| S-0440-04 | 用户删除/禁用 | 逻辑删除、重置密码 | S-0440-01 |
| S-0440-05 | 用户导入 | Excel批量导入 | S-0440-01 |

**关键字段**：
- 用户账号、用户姓名、部门、岗位、联系电话、邮箱
- 角色列表、仓库权限列表

**数据库表**：`sys_user`、`sys_user_role`、`sys_user_post`、`sys_user_warehouse`（已有）

**权限标识**：`system:user:query`、`system:user:add`、`system:user:edit`、`system:user:delete`、`system:user:import`

---

### 2.3 WMS0450 角色管理

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0450-01 | 角色列表查询 | 按角色名筛选 | - |
| S-0450-02 | 角色新增 | 填写角色信息、分配菜单权限 | S-0450-01 |
| S-0450-03 | 角色编辑 | 修改角色信息、重新分配菜单 | S-0450-01 |
| S-0450-04 | 角色删除 | 检查用户关联、逻辑删除 | S-0450-01 |
| S-0450-05 | 数据权限配置 | 配置角色数据权限（仓库/部门） | S-0450-02 |

**关键字段**：
- 角色名称、角色编码、角色描述
- 菜单权限列表、数据权限范围

**数据库表**：`sys_role`、`sys_role_menu`、`sys_role_dept`、`sys_role_warehouse`（已有）

**权限标识**：`system:role:query`、`system:role:add`、`system:role:edit`、`system:role:delete`

---

### 2.4 WMS0460 菜单管理

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0460-01 | 菜单树查询 | 树形展示、层级缩进 | - |
| S-0460-02 | 菜单新增 | 支持新增菜单/按钮 | S-0460-01 |
| S-0460-03 | 菜单编辑 | 修改菜单信息 | S-0460-01 |
| S-0460-04 | 菜单删除 | 检查子菜单/按钮关联 | S-0460-01 |

**菜单结构**：
```
├── system          # 系统管理
│   ├── user       # 用户管理
│   ├── role       # 角色管理
│   ├── menu       # 菜单管理
│   └── dept       # 部门管理
├── warehouse      # 仓库管理
│   ├── warehouse  # 仓库档案
│   └── location  # 库位档案
├── inventory      # 库存管理
│   ├── query     # 库存查询
│   ├── change    # 库存流水
│   └── adjust    # 库存调整
├── inbound        # 入库管理
│   ├── production # 生产入库
│   ├── purchase  # 采购入库
│   └── transfer  # 调拨入库
├── outbound      # 出库管理
│   ├── sales    # 销售出库
│   ├── transfer # 调拨出库
│   └── consume  # 领用出库
├── qc            # 质检管理
│   ├── standard # 质检标准
│   └── record   # 质检记录
├── pick          # 提货单管理
│   ├── sale     # 销售提货单
│   └── transfer # 调拨提货单
├── logistics     # 物流发货
│   ├── shipment # 发货列表
│   └── tracking # 配送跟踪
└── report       # 报表中心
```

**数据库表**：`sys_menu`（已有）

**权限标识**：`system:menu:query`、`system:menu:add`、`system:menu:edit`、`system:menu:delete`

---

### 2.5 WMS0470 系统日志

| Story编号 | Story名称 | 验收标准 | 依赖关系 |
|---------|---------|---------|---------|
| S-0470-01 | 操作日志查询 | 按时间、操作人、操作类型筛选 | - |
| S-0470-02 | 登录日志查询 | 按时间、账号筛选 | - |
| S-0470-03 | 日志导出 | 导出日志记录 | S-0470-01 |

**数据库表**：`sys_oper_log`、`sys_logininfor`（已有）

**权限标识**：`system:log:oper:query`、`system:log:login:query`

---

## 三、技术实现要点

### 3.1 权限框架

| 组件 | 说明 |
|------|------|
| @RequiresPermissions | 功能权限校验 |
| DataScopeInterceptor | 数据权限拦截 |
| FieldPermissionAspect | 字段权限处理 |

### 3.2 缓存策略

| 数据类型 | 缓存策略 | 过期时间 |
|---------|---------|---------|
| 用户信息 | Redis缓存 | 30分钟 |
| 角色权限 | Redis缓存 | 30分钟 |
| 菜单树 | 本地缓存 + Redis | 1小时 |

### 3.3 权限变更刷新

```java
// 权限变更时清除缓存
@CacheEvict(value = {"userPermissions", "rolePermissions"}, key = "#userId")
public void clearUserCache(Long userId) {
    // 通知所有节点刷新
    stringRedisTemplate.convertAndSend("permission:refresh", userId.toString());
}
```

---

## 四、交付物清单

| 交付物 | 状态 |
|-------|------|
| 数据库建表SQL | ✅ 已完成（系统管理相关） |
| 实体类 | ✅ 已完成 |
| Mapper接口与XML | ✅ 部分完成 |
| Service接口与实现 | ✅ 部分完成 |
| Controller接口 | ✅ 部分完成 |
| 前端页面 | ✅ 部分完成 |
| 单元测试 | ⬜ 待开发 |
| 接口文档 | ⬜ 待开发 |

---

## 五、相关文档

| 文档 | 路径 |
|------|------|
| 数据库设计 | [WMS-DATABASE-DESIGN.md](../../04-DATABASE/WMS-DATABASE-DESIGN.md) |
| 权限设计 | [04-permission-design.md](../../05-TECH-STANDARDS/04-permission-design.md) |
| 日志埋点规范 | [05-elk-log-design.md](../../05-TECH-STANDARDS/05-elk-log-design.md) |
| Epic索引 | [00-Epic-Index.md](00-Epic-Index.md) |
