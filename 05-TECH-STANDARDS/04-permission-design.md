# WMS仓库物流系统 - 权限设计

> 版本：V1.0
> 日期：2026-04-03
> 适用范围：WMS 系统权限控制设计
> 核心目标：实现精细化的权限控制，包括功能权限、数据权限和字段权限

---

## 一、概述

### 1.1 权限体系架构

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                            WMS 权限体系                                      │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                          功能权限（菜单/按钮）                         │  │
│  │  ├─ 菜单权限：能看哪些菜单                                           │  │
│  │  ├─ 页面权限：能看哪些页面元素                                       │  │
│  │  └─ 按钮权限：能操作哪些按钮                                         │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                          数据权限（行级过滤）                         │  │
│  │  ├─ 租户权限：只能看自己公司的数据                                   │  │
│  │  ├─ 仓库权限：只能看有权限的仓库数据                                 │  │
│  │  ├─ 部门权限：只能看本部门及下级部门的数据                           │  │
│  │  └─ 用户权限：只能看自己的数据                                       │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                          字段权限（列级过滤）                         │  │
│  │  ├─ 敏感字段：价格、成本、利润率等对特定角色隐藏                     │  │
│  │  ├─ 编辑字段：特定角色只能看不能改                                   │  │
│  │  └─ 必填字段：特定角色可省略某些必填项                               │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 权限模型

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              RBAC + 数据权限                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│     ┌────────┐       ┌────────────┐       ┌────────┐                       │
│     │  用户   │──────▶│ 用户-角色   │──────▶│  角色   │                       │
│     │ (User) │       │(sys_user_role)│     │ (Role) │                       │
│     └────────┘       └────────────┘       └────┬────┘                       │
│                                                 │                            │
│                                                 ▼                            │
│     ┌────────┐       ┌────────────┐       ┌────────┐                       │
│     │ 菜单   │◀──────│ 角色-菜单   │──────▶│ 仓库   │                       │
│     │(Menu)  │       │(sys_role_menu)│   │(Warehouse)│                     │
│     └────────┘       └────────────┘       └────┬────┘                       │
│                                                 │                            │
│                                                 ▼                            │
│     ┌────────┐       ┌────────────┐       ┌────────┐                       │
│     │ 数据   │◀──────│ 角色-仓库   │──────▶│ 部门   │                       │
│     │权限规则│       │(sys_role_warehouse)│   │(Dept) │                       │
│     └────────┘       └────────────┘       └────────┘                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 二、功能权限设计

### 2.1 菜单结构

```
WMS 仓库管理系统
├── 首页（Dashboard）
│
├── 基础档案
│   ├── 仓库档案
│   ├── 库位档案
│   ├── 物料档案
│   ├── 批次档案
│   ├── 客户档案
│   └── 供应商档案
│
├── 入库管理
│   ├── 生产入库
│   ├── 采购入库
│   ├── 调拨入库
│   └── 退料入库
│
├── 出库管理
│   ├── 销售出库
│   ├── 调拨出库
│   ├── 领用出库
│   ├── 退库出库
│   └── 报废出库
│
├── 质检管理
│   ├── 质检标准
│   ├── 质检申请
│   └── 质检记录
│
├── 库存管理
│   ├── 库存查询
│   ├── 库存预警
│   ├── 库存调整
│   └── 库位调整
│
├── 盘点管理
│   ├── 盘点计划
│   ├── 盘点执行
│   └── 盘点结果
│
├── 提货单管理
│   ├── 销售提货单
│   ├── 调拨提货单
│   ├── 领用提货单
│   └── CRO提货单
│
├── 数据同步
│   ├── ERP同步
│   └── LIMS同步
│
├── 系统设置
│   ├── 用户管理
│   ├── 角色管理
│   ├── 菜单管理
│   ├── 字典管理
│   └── 枚举管理
│
└── 报表中心
    ├── 库存报表
    ├── 出入库报表
    └── 盘点报表
```

### 2.2 按钮权限

| 权限标识 | 说明 | 适用场景 |
|---------|------|---------|
| `wms:warehouse:add` | 新增仓库 | 仓库档案 |
| `wms:warehouse:edit` | 编辑仓库 | 仓库档案 |
| `wms:warehouse:delete` | 删除仓库 | 仓库档案 |
| `wms:warehouse:export` | 导出仓库 | 仓库档案 |
| `wms:inbound:create` | 创建入库单 | 入库管理 |
| `wms:inbound:approve` | 审批入库单 | 入库管理 |
| `wms:inbound:confirm` | 确认入库 | 入库管理 |
| `wms:outbound:create` | 创建出库单 | 出库管理 |
| `wms:outbound:allocate` | 分配库位 | 出库管理 |
| `wms:outbound:confirm` | 确认出库 | 出库管理 |
| `wms:inventory:adjust` | 调整库存 | 库存管理 |
| `wms:stocktake:start` | 启动盘点 | 盘点管理 |
| `wms:stocktake:confirm` | 确认盘点 | 盘点管理 |

### 2.3 权限注解

```java
// 方式一：@RequiresPermissions 注解
@RequiresPermissions({"wms:warehouse:add", "wms:warehouse:edit"})
@PostMapping("/save")
public Result<Void> save(@RequestBody WarehouseSaveRequest request) {
    warehouseService.save(request);
    return Result.success();
}

// 方式二：@RequiresPermissions 注解（支持权限表达式）
@RequiresPermissions(value = {"wms:outbound:confirm"}, logical = Logical.OR)
@PostMapping("/batchConfirm")
public Result<Void> batchConfirm(@RequestBody List<Long> ids) {
    outboundService.batchConfirm(ids);
    return Result.success();
}

// 方式三：服务层权限校验
@Service
@RequiredArgsConstructor
public class WarehouseService {

    public void save(WarehouseSaveRequest request) {
        // 校验新增权限
        permissionService.checkPermission("wms:warehouse:add");
        
        // 业务逻辑
    }

    public void delete(Long id) {
        // 校验删除权限
        permissionService.checkPermission("wms:warehouse:delete");
        
        // 业务逻辑
    }
}
```

---

## 三、数据权限设计

### 3.1 权限类型

| 类型 | 编码 | 说明 | SQL 条件 |
|------|------|------|----------|
| 全部数据 | ALL | 可见所有数据 | 无条件 |
| 本部门及以下 | DEPT_AND_CHILD | 可见本部门及下级部门数据 | `dept_id IN (SELECT dept_id FROM sys_dept WHERE ancestors LIKE CONCAT('%,', #{deptId}, ',%'))` |
| 本部门 | DEPT | 可见本部门数据 | `dept_id = #{deptId}` |
| 仅本人 | SELF | 可见本人数据 | `create_by = #{userId}` |
| 指定仓库 | WAREHOUSE | 可见有权限的仓库数据 | `warehouse_code IN (SELECT warehouse_code FROM sys_user_warehouse WHERE user_id = #{userId})` |
| 指定仓库及子仓库 | WAREHOUSE_AND_CHILD | 可见有权限的仓库及子仓库数据 | 自定义 |
| 自定义 | CUSTOM | 按自定义规则过滤 | 按配置规则 |

### 3.2 数据权限配置

```sql
-- 角色数据权限配置表
CREATE TABLE sys_role_data_scope (
    id           BIGINT PRIMARY KEY AUTO_INCREMENT,
    role_id      BIGINT       NOT NULL COMMENT '角色ID',
    data_scope   VARCHAR(20)  NOT NULL COMMENT '数据权限范围（ALL/DEPT/DEPT_AND_CHILD/SELF/WAREHOUSE/CUSTOM）',
    custom_sql   VARCHAR(500) COMMENT '自定义SQL条件',
    create_by    VARCHAR(64),
    create_time  DATETIME,
    update_by    VARCHAR(64),
    update_time  DATETIME,
    UNIQUE KEY uk_role_id (role_id)
) ENGINE=InnoDB COMMENT='角色数据权限配置表';

-- 仓库权限配置表（角色-仓库多对多）
CREATE TABLE sys_role_warehouse (
    id           BIGINT PRIMARY KEY AUTO_INCREMENT,
    role_id      BIGINT       NOT NULL COMMENT '角色ID',
    warehouse_code VARCHAR(50) NOT NULL COMMENT '仓库编码',
    create_by    VARCHAR(64),
    create_time  DATETIME,
    UNIQUE KEY uk_role_warehouse (role_id, warehouse_code)
) ENGINE=InnoDB COMMENT='角色仓库权限表';

-- 用户仓库权限表（用户-仓库多对多）
CREATE TABLE sys_user_warehouse (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id         BIGINT       NOT NULL COMMENT '用户ID',
    warehouse_code   VARCHAR(50) NOT NULL COMMENT '仓库编码',
    create_by       VARCHAR(64),
    create_time     DATETIME,
    UNIQUE KEY uk_user_warehouse (user_id, warehouse_code)
) ENGINE=InnoDB COMMENT='用户仓库权限表';
```

### 3.3 数据权限拦截器

```java
// DataScopeInterceptor.java - MyBatis 拦截器
@Component
@RequiredArgsConstructor
@Slf4j
public class DataScopeInterceptor implements Interceptor {

    private static final String DATA_SCOPE_SQL = "data_scope_sql";
    private static final Map<String, String> DATA_SCOPE_MAP = Map.of(
        "ALL", "1=1",
        "DEPT", "dept_id = #{dataScope.deptId}",
        "DEPT_AND_CHILD", "dept_id IN (SELECT dept_id FROM sys_dept WHERE FIND_IN_SET(dept_id, getDeptChildList(#{dataScope.deptId})))",
        "SELF", "create_by = #{dataScope.userId}",
        "WAREHOUSE", "warehouse_code IN (SELECT warehouse_code FROM sys_user_warehouse WHERE user_id = #{dataScope.userId})"
    );

    @Override
    public Object intercept(Invocation invocation) throws Throwable {
        MappedStatement ms = (MappedStatement) invocation.getArgs()[0];
        SqlSource sqlSource = ms.getSqlSource();

        // 1. 获取当前用户数据权限
        DataScope dataScope = getCurrentDataScope();

        // 2. 构造新的 SQL（追加数据权限条件）
        BoundSql boundSql = ms.getBoundSql(invocation.getArgs()[1]);
        String originalSql = boundSql.getSql();
        String dataScopeSql = buildDataScopeSql(dataScope, originalSql);

        // 3. 使用反射修改 SQL
        MetaObject metaObject = SystemMetaObject.forObject(boundSql);
        metaObject.setValue("sql", dataScopeSql);

        return invocation.proceed();
    }

    private String buildDataScopeSql(DataScope dataScope, String originalSql) {
        // 自定义SQL优先
        if (StringUtils.isNotBlank(dataScope.getCustomSql())) {
            return originalSql + " AND " + dataScope.getCustomSql();
        }
        
        // 根据权限类型追加条件
        String scopeCondition = DATA_SCOPE_MAP.get(dataScope.getScopeType());
        if (scopeCondition == null) {
            scopeCondition = "1=1";
        }
        
        // 支持多表连接的数据权限
        String dataScopeSql = originalSql;
        
        // 仓库权限（库存查询）
        if (dataScope.getScopeType().contains("WAREHOUSE")) {
            // 判断原SQL是否已有warehouse相关过滤
            if (!originalSql.contains("sys_user_warehouse")) {
                dataScopeSql = "SELECT t.* FROM (" + originalSql + ") t "
                    + " LEFT JOIN sys_user_warehouse suw ON t.warehouse_code = suw.warehouse_code "
                    + " WHERE suw.user_id = #{dataScope.userId}";
            }
        }
        
        return dataScopeSql;
    }

    private DataScope getCurrentDataScope() {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        DataScope scope = new DataScope();
        scope.setUserId(loginUser.getUserId());
        scope.setDeptId(loginUser.getDeptId());
        
        // 查询角色数据权限配置
        RoleDataScope ds = roleDataScopeMapper.selectByRoleId(loginUser.getRoleIds().get(0));
        if (ds != null) {
            scope.setScopeType(ds.getDataScope());
            scope.setCustomSql(ds.getCustomSql());
        } else {
            scope.setScopeType("ALL"); // 默认全部权限
        }
        
        return scope;
    }
}
```

### 3.4 数据权限注解

```java
// 在 Service 层使用 @DataScope 注解
@Service
@RequiredArgsConstructor
public class InventoryService {

    /**
     * 查询库存列表（自动注入数据权限）
     */
    @DataScope(deptAlias = "t.", warehouseAlias = "t.")
    public List<InvInventory> queryList(InventoryQueryRequest request) {
        // 无需手动添加数据权限条件，拦截器自动注入
        return inventoryMapper.selectList(request);
    }

    /**
     * 查询库存详情（无需数据权限限制）
     */
    @NoDataScope
    public InvInventory queryById(Long id) {
        return inventoryMapper.selectById(id);
    }
}

// 注解定义
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface DataScope {
    String deptAlias() default "";   // 部门字段别名，如 "t."
    String warehouseAlias() default ""; // 仓库字段别名
    String userAlias() default "";    // 用户字段别名
}
```

---

## 四、字段权限设计

### 4.1 字段权限类型

| 类型 | 编码 | 说明 | 处理方式 |
|------|------|------|---------|
| 隐藏字段 | HIDDEN | 对指定角色完全隐藏 | SELECT 时排除 |
| 只读字段 | READONLY | 只能看不能改 | 编辑时忽略 |
| 必填字段 | REQUIRED | 特定角色可省略 | 编辑校验时豁免 |
| 脱敏字段 | MASKED | 显示时脱敏 | 返回时处理 |

### 4.2 敏感字段配置

| 模块 | 字段 | 脱敏规则 | 可见角色 |
|------|------|---------|---------|
| 库存 | 成本价 | `***` | 管理员/财务 |
| 库存 | 采购价 | `***` | 管理员/采购 |
| 库存 | 利润率 | `***` | 管理员/财务 |
| 客户 | 信用额度 | `***` | 管理员/销售经理 |
| 客户 | 开户银行 | `***` | 管理员/财务 |
| 供应商 | 结算方式 | `***` | 管理员/采购经理 |
| 供应商 | 银行账号 | `***` | 管理员/财务 |

### 4.3 字段权限实现

```java
// FieldPermission.java - 字段权限注解
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface FieldPermission {
    FieldPermissionRule[] rules();
}

// 字段权限规则
@Data
public class FieldPermissionRule {
    private String fieldName;      // 字段名
    private String permission;     // 权限标识
    private FieldAction action;    // HIDDEN/READONLY/MASKED/REQUIRED
    private String[] roles();      // 适用的角色
}

// FieldPermissionAspect.java - 字段权限切面
@Component
@Aspect
@RequiredArgsConstructor
@Slf4j
public class FieldPermissionAspect {

    private final FieldPermissionConfig config;

    @Around("@annotation(fieldPermission)")
    public Object checkFieldPermission(ProceedingJoinPoint joinPoint, 
                                        FieldPermission fieldPermission) throws Throwable {
        // 1. 获取当前用户角色
        List<String> roles = SecurityUtils.getRoles();
        
        // 2. 获取返回结果
        Object result = joinPoint.proceed();
        
        // 3. 处理字段权限
        if (result instanceof List) {
            result = filterList((List<?>) result, fieldPermission.rules(), roles);
        } else if (result instanceof Result) {
            Result<?> r = (Result<?>) result;
            if (r.getData() != null) {
                r.setData(filterObject(r.getData(), fieldPermission.rules(), roles));
            }
        }
        
        return result;
    }

    private Object filterObject(Object obj, FieldPermissionRule[] rules, List<String> roles) {
        if (obj == null || rules.length == 0) return obj;
        
        for (FieldPermissionRule rule : rules) {
            // 检查用户是否有权限
            if (hasPermission(rule, roles)) {
                continue;
            }
            
            switch (rule.getAction()) {
                case HIDDEN:
                    // 置空或排除
                    obj = ReflectionUtils.setFieldValue(obj, rule.getFieldName(), null);
                    break;
                case MASKED:
                    // 脱敏处理
                    Object value = ReflectionUtils.getFieldValue(obj, rule.getFieldName());
                    obj = ReflectionUtils.setFieldValue(obj, rule.getFieldName(), maskValue(value));
                    break;
                case READONLY:
                    // 只读，无需处理（前端处理）
                    break;
            }
        }
        
        return obj;
    }

    private boolean hasPermission(FieldPermissionRule rule, List<String> roles) {
        for (String role : rule.roles()) {
            if (roles.contains(role)) {
                return true;
            }
        }
        return false;
    }

    private Object maskValue(Object value) {
        if (value == null) return null;
        String str = value.toString();
        if (str.length() <= 4) return "****";
        return str.substring(0, 2) + "****" + str.substring(str.length() - 2);
    }
}
```

### 4.4 使用示例

```java
// Controller 层使用
@RestController
@RequestMapping("/api/inventory")
@RequiredArgsConstructor
public class InventoryController {

    /**
     * 查询库存列表（应用字段权限）
     */
    @PostMapping("/list")
    @FieldPermission(rules = {
        @FieldPermissionRule(fieldName = "costPrice", action = FieldAction.MASKED, roles = {"common_role"}),
        @FieldPermissionRule(fieldName = "profitRate", action = FieldAction.HIDDEN, roles = {"common_role"})
    })
    public Result<List<InventoryDTO>> list(@RequestBody InventoryQueryRequest request) {
        return Result.success(inventoryService.queryList(request));
    }
}

// Vue 前端字段权限处理
<template>
  <el-table :data="tableData">
    <el-table-column prop="materialCode" label="物料编码" />
    <el-table-column prop="quantity" label="库存数量" />
    <!-- 成本价：普通角色隐藏 -->
    <el-table-column v-if="hasFieldPermission('costPrice')" 
                     prop="costPrice" label="成本价" />
    <!-- 利润率：管理员可见 -->
    <el-table-column v-if="hasRole('admin')" 
                     prop="profitRate" label="利润率" />
  </el-table>
</template>

<script>
export default {
  methods: {
    hasFieldPermission(field) {
      // 从用户权限信息中获取字段权限
      const permissions = this.$store.getters.userPermissions;
      return permissions.field && permissions.field.includes(field);
    }
  }
}
</script>
```

---

## 五、API 权限控制

### 5.1 接口权限注解

```java
// 接口权限校验
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RequiresApi {
    String[] permissions();  // 需要的权限列表
}

// 全局异常处理
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(AccessDeniedException.class)
    public Result<Void> handleAccessDenied(AccessDeniedException e) {
        log.warn("接口权限校验失败, msg={}", e.getMessage());
        return Result.fail(403, "无接口访问权限");
    }
}
```

### 5.2 接口限流

```java
// 限流注解
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RateLimiter {
    int value() default 100;           // 阈值
    int interval() default 1;          // 时间窗口（秒）
    String key() default "";           // 限流key
}

// 限流实现
@Component
@RequiredArgsConstructor
@Slf4j
public class RateLimiterAspect {

    private final RedisTemplate<String, String> redisTemplate;

    @Around("@annotation(rateLimiter)")
    public Object rateLimit(ProceedingJoinPoint joinPoint, RateLimiter rateLimiter) throws Throwable {
        String key = buildKey(rateLimiter.key(), joinPoint);
        
        // 使用 Redis 实现滑动窗口限流
        long count = redisTemplate.opsForValue().increment(key);
        if (count == 1) {
            redisTemplate.expire(key, rateLimiter.interval(), TimeUnit.SECONDS);
        }
        
        if (count > rateLimiter.value()) {
            log.warn("接口限流触发, key={}, count={}", key, count);
            throw new BusinessException("SYS011", "请求过于频繁，请稍后再试");
        }
        
        return joinPoint.proceed();
    }
}

// 使用示例
@PostMapping("/batchImport")
@RateLimiter(value = 10, interval = 60, key = "inventory:batchImport")
public Result<Void> batchImport(@RequestBody BatchImportRequest request) {
    // 批量导入接口限制每分钟最多10次
}
```

---

## 六、禁止事项

| 序号 | 禁止项 | 正确做法 |
|---|-----|----|
| 1 | 禁止在前端单独做权限控制 | 必须后端实现权限校验 |
| 2 | 禁止 SELECT * 查询 | 必须指定字段，避免字段权限泄露 |
| 3 | 禁止硬编码权限判断 | 使用 @RequiresPermissions 注解 |
| 4 | 禁止数据权限绕过 | 所有查询必须经过 DataScopeInterceptor |
| 5 | 禁止敏感数据明文传输 | 使用 HTTPS + 字段脱敏 |
| 6 | 禁止接口无权限校验 | 所有接口必须配置权限 |
| 7 | 禁止高并发接口无限流 | 必须配置限流规则 |
| 8 | 禁止权限变更实时生效 | 使用缓存，定期刷新 |
