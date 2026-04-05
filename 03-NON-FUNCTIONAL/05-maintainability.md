# WMS仓库物流系统 - 可维护性需求

> 版本：V1.0
> 日期：2026-04-03
> 适用范围：系统可维护性设计

---

## 一、代码规范

### 1.1 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| Java类名 | PascalCase | WarehouseService |
| Java方法名 | camelCase | getWarehouseById |
| Java变量名 | camelCase | warehouseCode |
| 常量 | UPPER_SNAKE | MAX_RETRY_COUNT |
| 数据库表名 | snake_case复数 | wms_warehouse |
| 数据库列名 | snake_case | warehouse_code |
| Vue组件名 | PascalCase | WarehouseList.vue |
| Vue变量名 | camelCase | warehouseList |

### 1.2 代码注释

```java
/**
 * 仓库服务
 *
 * @author zhangsan
 * @date 2024-01-01
 */
@Service
@Slf4j
public class WarehouseService {
    
    /**
     * 根据ID查询仓库
     *
     * @param id 仓库ID
     * @return 仓库信息
     */
    public Warehouse getById(Long id) {
        return warehouseMapper.selectById(id);
    }
}
```

### 1.3 方法长度

| 规则 | 说明 |
|------|------|
| 方法行数 | ≤50行 |
| 方法参数 | ≤3个 |
| 圈复杂度 | ≤10 |
| 方法职责 | 单一职责 |

---

## 二、日志规范

### 2.1 日志级别使用

| 级别 | 使用场景 |
|------|----------|
| DEBUG | 开发调试信息 |
| INFO | 正常业务流程 |
| WARN | 潜在问题（如参数校验） |
| ERROR | 异常错误（如数据库连接失败） |

### 2.2 日志内容规范

```java
// ✅ 正确示例
log.info("Warehouse created: id={}, code={}, operator={}", 
    warehouse.getId(), warehouse.getCode(), operator);
log.warn("Inventory insufficient: materialId={}, required={}, available={}", 
    materialId, required, available);
log.error("Database error: sql={}, error={}", sql, e.getMessage(), e);

// ❌ 错误示例
log.info("成功");
log.error("出错了");
log.debug("方法开始执行");
```

### 2.3 日志脱敏

| 敏感字段 | 脱敏规则 | 示例 |
|----------|----------|------|
| 手机号 | 138****5678 | 脱敏展示 |
| 身份证 | ************1234 | 脱敏展示 |
| 密码 | ******** | 不记录 |

---

## 三、异常处理

### 3.1 异常分类

| 异常类型 | 父类 | 处理方式 |
|----------|------|----------|
| 业务异常 | BusinessException | 业务提示 |
| 参数异常 | ValidationException | 参数提示 |
| 权限异常 | AccessDeniedException | 权限提示 |
| 系统异常 | SystemException | 统一处理 |

### 3.2 全局异常处理

```java
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {
    
    @ExceptionHandler(BusinessException.class)
    public Result<Void> handleBusiness(BusinessException e) {
        log.warn("Business error: code={}, message={}", e.getCode(), e.getMessage());
        return Result.fail(e.getCode(), e.getMessage());
    }
    
    @ExceptionHandler(ValidationException.class)
    public Result<Void> handleValidation(ValidationException e) {
        log.warn("Validation error: {}", e.getMessage());
        return Result.fail("VALIDATION_ERROR", e.getMessage());
    }
    
    @ExceptionHandler(Exception.class)
    public Result<Void> handleException(Exception e) {
        log.error("System error", e);
        return Result.fail("SYSTEM_ERROR", "系统异常，请稍后重试");
    }
}
```

### 3.3 异常返回格式

```json
{
  "code": "BUSINESS_ERROR",
  "message": "仓库编码已存在",
  "data": null,
  "traceId": "abc123",
  "timestamp": 1709500800000
}
```

---

## 四、配置管理

### 4.1 多环境配置

| 环境 | 配置方式 | 说明 |
|------|----------|------|
| 开发环境 | application-dev.yml | 本地开发 |
| 测试环境 | application-test.yml | 测试环境 |
| 预发环境 | application-pre.yml | 预发布 |
| 生产环境 | application-prod.yml | 生产环境 |

### 4.2 Nacos配置

```yaml
# 公共配置
spring:
  redis:
    host: ${REDIS_HOST:localhost}
    port: ${REDIS_PORT:6379}
  datasource:
    url: jdbc:mysql://${DB_HOST:localhost}:${DB_PORT:3306}/${DB_NAME:wms}

# 业务配置
wms:
  warehouse:
    max-capacity: 10000
  inventory:
    check-enabled: true
  sync:
    erp-cron: "0 */5 * * * ?"
```

### 4.3 配置示例

```java
@Configuration
@ConfigurationProperties(prefix = "wms.warehouse")
public class WarehouseProperties {
    private Integer maxCapacity = 10000;
    private Boolean autoAllocate = true;
}
```

---

## 五、监控告警

### 5.1 监控指标

| 指标类型 | 监控项 | 告警阈值 |
|----------|--------|----------|
| 应用 | 接口QPS | > 1000 |
| 应用 | 接口耗时P99 | > 3秒 |
| 应用 | 错误率 | > 1% |
| JVM | CPU使用率 | > 80% |
| JVM | 堆内存使用 | > 85% |
| 数据库 | 连接池使用 | > 80% |
| 数据库 | 慢查询 | > 100ms |
| Redis | 内存使用 | > 80% |
| MQ | 消息堆积 | > 10000 |

### 5.2 告警方式

| 告警级别 | 方式 | 场景 |
|----------|------|------|
| P1紧急 | 短信+电话 | 系统宕机 |
| P2重要 | 短信+邮件 | 关键指标异常 |
| P3一般 | 邮件+站内信 | 非关键异常 |
| P4提示 | 站内信 | 例行通知 |

---

## 六、运维文档

### 6.1 必需文档

| 文档 | 更新频率 | 负责人 |
|------|----------|--------|
| 部署手册 | 每次发布 | DevOps |
| 运维手册 | 每周检查 | 运维 |
| 故障处理手册 | 每次故障后 | 运维 |
| 备份恢复手册 | 每季度演练 | DBA |

### 6.2 部署检查清单

- [ ] 环境变量配置正确
- [ ] 数据库连接池配置正确
- [ ] Redis连接配置正确
- [ ] 日志目录已创建
- [ ] 文件上传目录已创建
- [ ] Nacos配置已同步
- [ ] 健康检查接口正常
- [ ] 监控指标正常

---

## 七、版本管理

### 7.1 版本命名

```
格式：主版本.次版本.修订版本
示例：V1.0.0, V1.1.0, V2.0.0

说明：
- 主版本：不兼容的API变更
- 次版本：向后兼容的功能新增
- 修订版本：向后兼容的问题修复
```

### 7.2 发布流程

```
需求评审 → 开发 → 代码评审 → 测试 → 预发布 → 生产发布 → 监控验证
```

### 7.3 回滚流程

```
发现问题 → 评估影响 → 选择回滚版本 → 执行回滚 → 验证 → 通知相关方
```
