# WMS仓库物流系统 - 后端开发规范

> 版本：V1.0
> 日期：2026-04-03
> 适用范围：WMS后端Java开发

---

## 一、项目结构

### 1.1 模块结构

```
wms-center/
├── wms-center-api/         # API模块
│   └── src/main/java/com/aboclonal/product/api/
│       ├── client/          # Feign Client
│       ├── domain/request/  # 请求DTO
│       └── domain/response/ # 响应DTO
│
├── wms-center-biz/         # 业务模块
│   └── src/main/java/com/aboclonal/product/biz/
│       ├── manager/        # 编排服务
│       └── validator/      # 业务校验
│
├── wms-center-common/      # 公共模块
│   └── src/main/java/com/aboclonal/product/common/
│       ├── constant/        # 常量
│       ├── enums/          # 枚举
│       ├── exception/      # 异常
│       └── util/           # 工具类
│
├── wms-center-dao/         # 数据访问模块
│   └── src/main/java/com/aboclonal/product/dao/
│       ├── entity/         # DO实体
│       ├── mapper/         # Mapper接口
│       └── repository/     # 仓储实现
│
├── wms-center-domain/      # 领域模块
│   └── src/main/java/com/aboclonal/product/domain/
│       ├── entity/         # 领域实体
│       ├── valobj/        # 值对象
│       ├── event/         # 领域事件
│       ├── repository/     # 仓储接口
│       └── service/        # 领域服务
│
├── wms-center-service/     # 应用服务模块
│   └── src/main/java/com/aboclonal/product/service/
│       ├── sys/           # 系统服务
│       ├── inbound/       # 入库服务
│       ├── outbound/      # 出库服务
│       └── inventory/     # 库存服务
│
└── wms-center-web/         # Web模块
    └── src/main/java/com/aboclonal/product/web/
        ├── controller/    # 控制器
        ├── config/        # 配置
        ├── interceptor/   # 拦截器
        └── security/     # 安全相关
```

### 1.2 依赖关系

```
Controller → Service → Domain/Biz → DAO/Domain
                ↑
           Feign Client ← API模块（仅定义接口）
```

---

## 二、命名规范

### 2.1 类命名

| 类型 | 规范 | 示例 |
|------|------|------|
| Controller | XxxController | WarehouseController |
| Service | XxxService | WarehouseService |
| ServiceImpl | XxxServiceImpl | WarehouseServiceImpl |
| Mapper | XxxMapper | WarehouseMapper |
| Entity/DO | XxxDO | WarehouseDO |
| Domain | XxxDomain | WarehouseDomain |
| DTO | XxxDTO | WarehouseDTO |
| Request | XxxRequest | WarehouseRequest |
| Response | XxxResponse | WarehouseResponse |
| VO | XxxVO | WarehouseVO |
| Validator | XxxValidator | WarehouseValidator |
| Manager | XxxManager | WarehouseManager |

### 2.2 方法命名

| 操作 | 命名 | 示例 |
|------|------|------|
| 查询单条 | getXxxByXxx | getWarehouseById |
| 查询列表 | listXxx | listWarehouse |
| 分页查询 | pageXxx | pageWarehouse |
| 新增 | createXxx / addXxx | createWarehouse |
| 修改 | updateXxx / modifyXxx | updateWarehouse |
| 删除 | deleteXxx / removeXxx | deleteWarehouse |
| 导出 | exportXxx | exportWarehouse |
| 导入 | importXxx | importWarehouse |

---

## 三、代码示例

### 3.1 Controller层

```java
@RestController
@RequestMapping("/api/base/warehouse")
@RequiredArgsConstructor
@Slf4j
public class WarehouseController {
    
    private final WarehouseService warehouseService;
    
    /**
     * 仓库列表查询
     */
    @GetMapping
    public Result<PageResult<WarehouseVO>> list(
            WarehouseRequest request,
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId) {
        return Result.success(warehouseService.pageWarehouse(request, tenantId));
    }
    
    /**
     * 仓库详情
     */
    @GetMapping("/{id}")
    public Result<WarehouseVO> getById(
            @PathVariable Long id,
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId) {
        return Result.success(warehouseService.getWarehouseById(id, tenantId));
    }
    
    /**
     * 新增仓库
     */
    @PostMapping
    @RequiresPermissions("wms:warehouse:add")
    public Result<Long> create(
            @Validated @RequestBody WarehouseCreateRequest request,
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId,
            @RequestHeader(value = "X-User-Id", required = false) String userId) {
        return Result.success(warehouseService.createWarehouse(request, tenantId, userId));
    }
    
    /**
     * 修改仓库
     */
    @PutMapping("/{id}")
    @RequiresPermissions("wms:warehouse:edit")
    public Result<Void> update(
            @PathVariable Long id,
            @Validated @RequestBody WarehouseUpdateRequest request,
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId,
            @RequestHeader(value = "X-User-Id", required = false) String userId) {
        warehouseService.updateWarehouse(id, request, tenantId, userId);
        return Result.success();
    }
    
    /**
     * 删除仓库
     */
    @DeleteMapping("/{id}")
    @RequiresPermissions("wms:warehouse:remove")
    public Result<Void> delete(
            @PathVariable Long id,
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId) {
        warehouseService.deleteWarehouse(id, tenantId);
        return Result.success();
    }
    
    /**
     * 启用/停用仓库
     */
    @PutMapping("/{id}/toggle")
    @RequiresPermissions("wms:warehouse:toggle")
    public Result<Void> toggle(
            @PathVariable Long id,
            @RequestBody ToggleRequest request,
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId) {
        warehouseService.toggleWarehouse(id, request.getIsEnabled(), tenantId);
        return Result.success();
    }
    
    /**
     * 导出仓库
     */
    @GetMapping("/export")
    @RequiresPermissions("wms:warehouse:export")
    public void export(
            WarehouseRequest request,
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId,
            HttpServletResponse response) {
        warehouseService.exportWarehouse(request, tenantId, response);
    }
}
```

### 3.2 Service层

```java
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(rollbackFor = Exception.class)
public class WarehouseServiceImpl implements WarehouseService {
    
    private final WarehouseMapper warehouseMapper;
    private final WarehouseValidator warehouseValidator;
    
    @Override
    @Transactional(readOnly = true)
    public WarehouseVO getWarehouseById(Long id, String tenantId) {
        WarehouseDO warehouse = warehouseMapper.selectByIdAndTenant(id, tenantId);
        if (warehouse == null) {
            throw new BusinessException("WMS002", "仓库不存在");
        }
        return BeanCopyUtils.copy(warehouse, WarehouseVO.class);
    }
    
    @Override
    @Transactional(readOnly = true)
    public PageResult<WarehouseVO> pageWarehouse(WarehouseRequest request, String tenantId) {
        Page<WarehouseDO> page = Page.of(request.getPageNum(), request.getPageSize());
        LambdaQueryWrapper<WarehouseDO> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(WarehouseDO::getTenantId, tenantId);
        wrapper.eq(WarehouseDO::getDeleted, 0);
        
        if (StrUtil.isNotBlank(request.getWarehouseCode())) {
            wrapper.like(WarehouseDO::getWarehouseCode, request.getWarehouseCode());
        }
        if (StrUtil.isNotBlank(request.getWarehouseName())) {
            wrapper.like(WarehouseDO::getWarehouseName, request.getWarehouseName());
        }
        if (request.getIsEnabled() != null) {
            wrapper.eq(WarehouseDO::getIsEnabled, request.getIsEnabled());
        }
        
        wrapper.orderByDesc(WarehouseDO::getCreatedAt);
        
        Page<WarehouseDO> result = warehouseMapper.selectPage(page, wrapper);
        return PageResult.of(
            result.getRecords().stream()
                .map(w -> BeanCopyUtils.copy(w, WarehouseVO.class))
                .collect(Collectors.toList()),
            result.getTotal()
        );
    }
    
    @Override
    public Long createWarehouse(WarehouseCreateRequest request, String tenantId, String userId) {
        // 1. 业务校验
        warehouseValidator.validateCreate(request);
        
        // 2. 构建实体
        WarehouseDO warehouse = BeanCopyUtils.copy(request, WarehouseDO.class);
        warehouse.setId(null);
        warehouse.setTenantId(tenantId);
        warehouse.setIsEnabled(1);
        warehouse.setDeleted(0);
        warehouse.setVersion(0);
        warehouse.setCreatedBy(userId);
        warehouse.setCreatedAt(LocalDateTime.now());
        
        // 3. 保存数据
        warehouseMapper.insert(warehouse);
        
        log.info("Warehouse created: id={}, code={}, operator={}", 
            warehouse.getId(), warehouse.getWarehouseCode(), userId);
        
        return warehouse.getId();
    }
    
    @Override
    public void updateWarehouse(Long id, WarehouseUpdateRequest request, String tenantId, String userId) {
        // 1. 查询原数据
        WarehouseDO warehouse = warehouseMapper.selectByIdAndTenant(id, tenantId);
        if (warehouse == null) {
            throw new BusinessException("WMS002", "仓库不存在");
        }
        
        // 2. 业务校验
        warehouseValidator.validateUpdate(request, warehouse);
        
        // 3. 更新数据
        BeanCopyUtils.copyNonNullProperties(request, warehouse);
        warehouse.setUpdatedBy(userId);
        warehouse.setUpdatedAt(LocalDateTime.now());
        warehouseMapper.updateById(warehouse);
        
        log.info("Warehouse updated: id={}, code={}, operator={}", 
            warehouse.getId(), warehouse.getWarehouseCode(), userId);
    }
    
    @Override
    public void deleteWarehouse(Long id, String tenantId) {
        WarehouseDO warehouse = warehouseMapper.selectByIdAndTenant(id, tenantId);
        if (warehouse == null) {
            throw new BusinessException("WMS002", "仓库不存在");
        }
        
        // 逻辑删除
        warehouse.setDeleted(1);
        warehouse.setUpdatedAt(LocalDateTime.now());
        warehouseMapper.updateById(warehouse);
        
        log.info("Warehouse deleted: id={}, code={}", id, warehouse.getWarehouseCode());
    }
}
```

### 3.3 Mapper层

```java
@Mapper
public interface WarehouseMapper extends BaseMapper<WarehouseDO> {
    
    /**
     * 根据ID和租户ID查询
     */
    default WarehouseDO selectByIdAndTenant(Long id, String tenantId) {
        return this.selectOne(
            new LambdaQueryWrapper<WarehouseDO>()
                .eq(WarehouseDO::getId, id)
                .eq(WarehouseDO::getTenantId, tenantId)
                .eq(WarehouseDO::getDeleted, 0)
        );
    }
    
    /**
     * 根据编码和租户ID查询
     */
    default WarehouseDO selectByCodeAndTenant(String code, String tenantId) {
        return this.selectOne(
            new LambdaQueryWrapper<WarehouseDO>()
                .eq(WarehouseDO::getWarehouseCode, code)
                .eq(WarehouseDO::getTenantId, tenantId)
                .eq(WarehouseDO::getDeleted, 0)
        );
    }
    
    /**
     * 检查编码是否存在
     */
    default boolean existsByCodeAndTenant(String code, String tenantId, Long excludeId) {
        return this.selectCount(
            new LambdaQueryWrapper<WarehouseDO>()
                .eq(WarehouseDO::getWarehouseCode, code)
                .eq(WarehouseDO::getTenantId, tenantId)
                .eq(WarehouseDO::getDeleted, 0)
                .ne(excludeId != null, WarehouseDO::getId, excludeId)
        ) > 0;
    }
}
```

---

## 四、业务校验

### 4.1 Validator示例

```java
@Component
@RequiredArgsConstructor
@Slf4j
public class WarehouseValidator {
    
    private final WarehouseMapper warehouseMapper;
    
    /**
     * 创建校验
     */
    public void validateCreate(WarehouseCreateRequest request) {
        Assert.notBlank(request.getWarehouseCode(), "仓库编码不能为空");
        Assert.notBlank(request.getWarehouseName(), "仓库名称不能为空");
        
        // 编码唯一性校验
        if (warehouseMapper.existsByCodeAndTenant(request.getWarehouseCode(), request.getTenantId(), null)) {
            throw new BusinessException("WMS001", "仓库编码已存在");
        }
        
        // 枚举值校验
        if (request.getWarehouseType() != null && !WarehouseType.contains(request.getWarehouseType())) {
            throw new BusinessException("WAREHOUSE_TYPE_INVALID", "仓库类型不正确");
        }
    }
    
    /**
     * 更新校验
     */
    public void validateUpdate(WarehouseUpdateRequest request, WarehouseDO warehouse) {
        // 如果修改了编码，检查唯一性
        if (request.getWarehouseCode() != null 
            && !request.getWarehouseCode().equals(warehouse.getWarehouseCode())) {
            if (warehouseMapper.existsByCodeAndTenant(
                    request.getWarehouseCode(), warehouse.getTenantId(), warehouse.getId())) {
                throw new BusinessException("WMS001", "仓库编码已存在");
            }
        }
    }
}
```

---

## 五、日志规范

### 5.1 日志记录要求

| 操作 | 日志级别 | 内容 |
|------|----------|------|
| 新增成功 | INFO | id, 关键字段, 操作人 |
| 修改成功 | INFO | id, 变更字段, 操作人 |
| 删除成功 | INFO | id, 关键字段, 操作人 |
| 业务校验失败 | WARN | 校验失败原因 |
| 数据不存在 | WARN | 查询条件 |
| 系统异常 | ERROR | 完整堆栈信息 |

### 5.2 日志示例

```java
// ✅ 正确日志格式
log.info("Warehouse created: id={}, code={}, operator={}", 
    warehouse.getId(), warehouse.getWarehouseCode(), operator);
log.warn("Warehouse code already exists: code={}", request.getWarehouseCode());
log.error("Query warehouse failed: id={}, error={}", id, e.getMessage(), e);

// ❌ 禁止的日志
log.info("成功");
log.error("出错了");
log.debug("方法开始");
```

### 5.3 MDC日志

```java
// 在Controller或Interceptor中设置
MDC.put("traceId", TraceContext.getTraceId());
MDC.put("tenantId", tenantId);
MDC.put("userId", userId);
MDC.put("operation", "CREATE_WAREHOUSE");
```

---

## 六、异常处理

### 6.1 自定义异常

```java
@Data
@EqualsAndHashCode(callSuper = true)
public class BusinessException extends RuntimeException {
    
    private final String code;
    
    public BusinessException(String code, String message) {
        super(message);
        this.code = code;
    }
    
    public BusinessException(String code, String message, Throwable cause) {
        super(message, cause);
        this.code = code;
    }
}
```

### 6.2 全局异常处理

```java
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {
    
    /**
     * 业务异常
     */
    @ExceptionHandler(BusinessException.class)
    public Result<Void> handleBusiness(BusinessException e) {
        log.warn("Business exception: code={}, message={}", e.getCode(), e.getMessage());
        return Result.fail(e.getCode(), e.getMessage());
    }
    
    /**
     * 参数校验异常
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Result<Void> handleValidation(MethodArgumentNotValidException e) {
        String message = e.getBindingResult().getFieldErrors().stream()
            .map(error -> error.getField() + ": " + error.getDefaultMessage())
            .collect(Collectors.joining(", "));
        log.warn("Validation exception: {}", message);
        return Result.fail("VALIDATION_ERROR", message);
    }
    
    /**
     * 权限异常
     */
    @ExceptionHandler(AccessDeniedException.class)
    public Result<Void> handleAccessDenied(AccessDeniedException e) {
        log.warn("Access denied: {}", e.getMessage());
        return Result.fail("ACCESS_DENIED", "没有访问权限");
    }
    
    /**
     * 未知异常
     */
    @ExceptionHandler(Exception.class)
    public Result<Void> handleException(Exception e) {
        log.error("Unexpected exception", e);
        return Result.fail("SYSTEM_ERROR", "系统异常，请稍后重试");
    }
}
```

---

## 七、事务规范

### 7.1 事务配置

| 场景 | 配置 | 说明 |
|------|------|------|
| 写方法 | @Transactional(rollbackFor = Exception.class) | 回滚所有异常 |
| 读方法 | @Transactional(readOnly = true) | 只读事务 |
| 独立事务 | @Transactional(propagation = REQUIRES_NEW) | 独立事务 |

### 7.2 事务边界

```java
// ✅ 正确：事务边界在Service层
@Service
public class WarehouseServiceImpl {
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createWarehouse(WarehouseCreateRequest request) {
        // 1. 保存主表
        warehouseMapper.insert(warehouse);
        
        // 2. 保存关联表
        warehouseConfigService.saveConfig(warehouse.getId(), request.getConfig());
        
        // 3. 发送消息
        mqProducer.sendWarehouseCreatedEvent(warehouse);
    }
}

// ❌ 错误：事务边界过大
@RestController
@Transactional(rollbackFor = Exception.class)  // 不要在Controller加事务
public class WarehouseController {
    // ...
}
```

---

## 八、Redis缓存

### 8.1 缓存注解

```java
@Service
@RequiredArgsConstructor
public class WarehouseService {
    
    /**
     * 查询单个 - 带缓存
     */
    @Override
    @Cacheable(value = "warehouse", key = "#id + ':' + #tenantId", expire = 3600)
    @Transactional(readOnly = true)
    public WarehouseVO getWarehouseById(Long id, String tenantId) {
        WarehouseDO warehouse = warehouseMapper.selectByIdAndTenant(id, tenantId);
        return warehouse == null ? null : BeanCopyUtils.copy(warehouse, WarehouseVO.class);
    }
    
    /**
     * 修改 - 删除缓存
     */
    @Override
    @CacheEvict(value = "warehouse", key = "#id + ':' + #tenantId")
    public void updateWarehouse(Long id, WarehouseUpdateRequest request, String tenantId) {
        // ...
    }
    
    /**
     * 删除 - 删除缓存
     */
    @Override
    @CacheEvict(value = "warehouse", key = "#id + ':' + #tenantId")
    public void deleteWarehouse(Long id, String tenantId) {
        // ...
    }
}
```

---

## 九、代码自检清单

- [ ] 代码符合命名规范
- [ ] 所有异常被捕获或抛出
- [ ] 敏感数据已脱敏
- [ ] 日志已正确埋点
- [ ] SQL使用参数绑定
- [ ] 事务边界合理
- [ ] 缓存正确使用
- [ ] 接口权限注解正确
- [ ] 参数校验注解完整
- [ ] 无硬编码配置
