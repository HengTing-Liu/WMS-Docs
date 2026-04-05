# WMS仓库物流系统 - ELK 日志埋点规范

> 版本：V1.0
> 日期：2026-04-03
> 适用范围：WMS 所有微服务的日志输出规范
> 技术选型：ELK Stack（Elasticsearch + Logstash + Kibana）+ Filebeat
> 核心目标：统一日志格式、问题分类、链路追踪、敏感脱敏

---

## 一、概述

### 1.1 日志架构

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                            ELK 日志架构                                      │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐             │
│  │ WMS      │    │ WMS      │    │ WMS      │    │ WMS      │             │
│  │ Service-1│    │ Service-2│    │ Service-3│    │ Service-N│             │
│  └────┬─────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘             │
│       │               │               │               │                    │
│       └───────────────┴───────────────┴───────────────┘                    │
│       │                               │                                     │
│       ▼                               ▼                                     │
│  ┌────────────────┐          ┌────────────────┐                            │
│  │  JSON格式日志  │          │  JSON格式日志  │                            │
│  │  (文件输出)    │          │  (文件输出)    │                            │
│  └───────┬────────┘          └───────┬────────┘                            │
│          │                           │                                      │
│          ▼                           ▼                                      │
│  ┌─────────────────────────────────────────┐                               │
│  │            Filebeat                     │                                │
│  │  (日志收集，多行合并，字段增强)          │                               │
│  └────────────────────┬────────────────────┘                                │
│                       │                                                     │
│                       ▼                                                     │
│  ┌─────────────────────────────────────────┐                               │
│  │            Logstash                     │                                │
│  │  (解析、过滤、脱敏、增强字段)            │                               │
│  └────────────────────┬────────────────────┘                                │
│                       │                                                     │
│                       ▼                                                     │
│  ┌─────────────────────────────────────────┐                               │
│  │            Elasticsearch                │                                │
│  │  (存储、索引)                          │                               │
│  └────────────────────┬────────────────────┘                                │
│                       │                                                     │
│                       ▼                                                     │
│  ┌─────────────────────────────────────────┐                               │
│  │            Kibana                       │                                │
│  │  (可视化、告警)                          │                               │
│  └─────────────────────────────────────────┘                               │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 日志输出组件

```xml
<!-- pom.xml 引入 logstash-logback-encoder -->
<dependency>
    <groupId>net.logstash.logback</groupId>
    <artifactId>logstash-logback-encoder</artifactId>
    <version>7.4</version>
</dependency>
```

```xml
<!-- logback-spring.xml -->
<configuration>
    <!-- 控制台输出 -->
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder class="net.logstash.logback.encoder.LogstashEncoder">
            <includeMdc>true</includeMdc>
            <includeContext>true</includeContext>
            <customFields>{"service":"${SERVICE_NAME:-wms-center-service}"}</customFields>
        </encoder>
    </appender>

    <!-- 文件输出（JSON格式） -->
    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${LOG_PATH}/wms-center-service.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>${LOG_PATH}/wms-center-service.%d{yyyy-MM-dd}.%i.log</fileNamePattern>
            <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <maxFileSize>100MB</maxFileSize>
            </timeBasedFileNamingAndTriggeringPolicy>
            <maxHistory>30</maxHistory>
        </rollingPolicy>
        <encoder class="net.logstash.logback.encoder.LogstashEncoder">
            <includeMdc>true</includeMdc>
            <customFields>{"service":"${SERVICE_NAME:-wms-center-service}"}</customFields>
        </encoder>
    </appender>

    <!-- 异步输出 -->
    <appender name="ASYNC_FILE" class="ch.qos.logback.classic.AsyncAppender">
        <appender-ref ref="FILE"/>
        <queueSize>512</queueSize>
        <discardingThreshold>0</discardingThreshold>
    </appender>

    <root level="INFO">
        <appender-ref ref="CONSOLE"/>
        <appender-ref ref="ASYNC_FILE"/>
    </root>
</configuration>
```

---

## 二、MDC 字段规范

### 2.1 必填字段

| 字段名 | 类型 | 说明 | 示例 |
|--------|------|------|------|
| traceId | String | 链路追踪ID | `4bf2f3a1b5c6d7e8` |
| spanId | String | 当前span ID | `a1b2c3d4` |
| serviceName | String | 服务名称 | `wms-center-service` |
| tenantId | String | 租户ID | `T001` |
| userId | String | 用户ID | `U001` |
| userName | String | 用户姓名 | `张三` |
| ip | String | 请求IP | `192.168.1.100` |
| problemCategory | String | 问题分类 | `BUSINESS` |

### 2.2 业务字段

| 字段名 | 类型 | 说明 | 示例 |
|--------|------|------|------|
| requestId | String | 请求ID（幂等键） | `REQ-UUID` |
| bizType | String | 业务类型 | `INBOUND` |
| bizId | String | 业务单据ID | `1001` |
| warehouseCode | String | 仓库编码 | `WH001` |
| locationCode | String | 库位编码 | `L0001001` |
| materialCode | String | 物料编码 | `MAT001` |
| batchNo | String | 批次号 | `BATCH20260401` |

### 2.3 MDC 设置

```java
// 1. Filter 中设置基础 MDC 字段
@Component
@Slf4j
public class MdcFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, 
                                    HttpServletResponse response, 
                                    FilterChain chain) throws ServletException, IOException {
        // 生成/获取 traceId
        String traceId = request.getHeader("X-Trace-Id");
        if (StringUtils.isBlank(traceId)) {
            traceId = UUID.randomUUID().toString().replace("-", "");
        }

        // 设置 MDC 基础字段
        MDC.put("traceId", traceId);
        MDC.put("spanId", generateSpanId());
        MDC.put("serviceName", getServiceName());
        MDC.put("ip", getClientIp(request));
        MDC.put("timestamp", String.valueOf(System.currentTimeMillis()));

        // 获取租户ID
        String tenantId = request.getHeader("X-Tenant-Id");
        if (StringUtils.isNotBlank(tenantId)) {
            MDC.put("tenantId", tenantId);
        }

        // 获取用户信息
        LoginUser loginUser = getLoginUser(request);
        if (loginUser != null) {
            MDC.put("userId", String.valueOf(loginUser.getUserId()));
            MDC.put("userName", loginUser.getUserName());
        }

        try {
            chain.doFilter(request, response);
        } finally {
            MDC.clear();
        }
    }
}

// 2. 拦截器中设置业务字段
@Component
@RequiredArgsConstructor
@Slf4j
public class BizContextInterceptor extends HandlerInterceptorAdapter {

    @Override
    public void afterCompletion(HttpServletRequest request, 
                                 HttpServletResponse response, 
                                 Object handler, Exception ex) {
        // 记录请求耗时
        Long startTime = (Long) request.getAttribute("startTime");
        if (startTime != null) {
            long cost = System.currentTimeMillis() - startTime;
            MDC.put("costTime", String.valueOf(cost));
            
            // 慢请求告警
            if (cost > 3000) {
                log.warn("请求耗时过长, cost={}ms, uri={}, traceId={}",
                         cost, request.getRequestURI(), MDC.get("traceId"));
            }
        }
    }
}

// 3. AOP 中设置业务上下文
@Aspect
@Component
@RequiredArgsConstructor
@Slf4j
public class BizLogAspect {

    @Around("@annotation(bizLog)")
    public Object around(ProceedingJoinPoint point, BizLog bizLog) throws Throwable {
        MethodSignature signature = (MethodSignature) point.getSignature();
        
        // 设置业务上下文
        MDC.put("bizType", bizLog.type().name());
        
        // 获取方法参数中的业务ID
        Object[] args = point.getArgs();
        String bizId = extractBizId(signature.getParameterNames(), args, bizLog.bizIdField());
        if (bizId != null) {
            MDC.put("bizId", bizId);
        }
        
        long startTime = System.currentTimeMillis();
        log.info("业务操作开始, bizType={}, bizId={}, method={}", 
                 bizLog.type().name(), bizId, signature.getMethod().getName());
        
        try {
            Object result = point.proceed();
            
            long cost = System.currentTimeMillis() - startTime;
            log.info("业务操作成功, bizType={}, bizId={}, cost={}ms",
                     bizLog.type().name(), bizId, cost);
            
            return result;
        } catch (Exception e) {
            MDC.put("errorMsg", e.getMessage());
            log.error("业务操作失败, bizType={}, bizId={}, error={}",
                      bizLog.type().name(), bizId, e.getMessage());
            throw e;
        } finally {
            // 清除业务上下文
            MDC.remove("bizType");
            MDC.remove("bizId");
        }
    }
}
```

---

## 三、日志分类规范

### 3.1 问题分类体系

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                          问题分类体系                                          │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  BUSINESS (业务问题)                                                         │
│  ├─ VALIDATION → 参数校验失败                                                │
│  │   ├── 必填参数为空                                                        │
│  │   ├── 格式不正确                                                          │
│  │   └── 业务规则校验失败                                                     │
│  ├─ PROCESS → 流程异常                                                      │
│  │   ├── 状态不允许操作                                                      │
│  │   ├── 流程未完成                                                          │
│  │   └── 流程超时                                                            │
│  └─ DATA → 数据问题                                                          │
│      ├── 数据不存在                                                           │
│      ├── 数据重复                                                             │
│      ├── 数据冲突                                                             │
│      └── 数据约束违反                                                         │
│                                                                              │
│  SYSTEM (系统问题)                                                           │
│  ├─ PERFORMANCE → 性能问题                                                   │
│  │   ├── 慢查询 (slow_query > 1s)                                            │
│  │   ├── 超时 (timeout > 阈值)                                               │
│  │   └── 高并发 (concurrency > 阈值)                                          │
│  ├─ RESOURCE → 资源问题                                                      │
│  │   ├── 内存 (memory > 80%)                                                 │
│  │   ├── 磁盘 (disk > 90%)                                                  │
│  │   └── 连接池 (connection > 80%)                                           │
│  └─ DEPENDENCY → 依赖问题                                                    │
│      ├── 超时 (timeout)                                                       │
│      ├── 不可用 (unavailable)                                                 │
│      └── 熔断打开 (circuit_open)                                              │
│                                                                              │
│  SECURITY (安全问题)                                                         │
│  ├─ AUTH → 认证问题                                                          │
│  │   ├── Token过期                                                           │
│  │   ├── Token无效                                                           │
│  │   └── 签名失败                                                            │
│  └─ ACCESS → 访问控制                                                        │
│      ├── 无权限                                                              │
│      ├── SQL注入                                                              │
│      └── 恶意请求                                                             │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 日志级别使用

| 级别 | 使用场景 | 示例 |
|------|---------|------|
| DEBUG | 调试信息 | 入参、出参、分支判断 |
| INFO | 正常业务流程 | 方法开始/结束、业务操作成功 |
| WARN | 警告信息 | 慢请求、参数异常、库存不足 |
| ERROR | 错误信息 | 业务异常、系统异常 |
| FATAL | 严重错误 | 内存溢出、数据库宕机 |

### 3.3 日志格式模板

```json
{
  "timestamp": "2026-04-03T10:15:30.123+08:00",
  "level": "INFO",
  "logger": "com.abclonal.wms.service.InventoryService",
  "thread": "http-nio-8080-exec-1",
  "message": "库存扣减成功",
  "traceId": "4bf2f3a1b5c6d7e8",
  "spanId": "a1b2c3d4",
  "serviceName": "wms-center-service",
  "tenantId": "T001",
  "userId": "U001",
  "userName": "张三",
  "ip": "192.168.1.100",
  "problemCategory": "BUSINESS",
  "bizType": "OUTBOUND",
  "bizId": "1001",
  "warehouseCode": "WH001",
  "costTime": 125,
  "inventoryId": 10001,
  "delta": -10,
  "beforeQuantity": 100,
  "afterQuantity": 90,
  "version": 5
}
```

---

## 四、业务日志埋点规范

### 4.1 日志注解

```java
// BizLog.java - 业务日志注解
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface BizLog {
    BizType type() default BizType.OTHER;  // 业务类型
    String bizIdField() default "id";       // 业务ID字段名
    String[] paramFields() default {};      // 需记录的参数字段
}

// 业务类型枚举
public enum BizType {
    INBOUND,           // 入库
    OUTBOUND,          // 出库
    QC,                // 质检
    STOCKTAKE,         // 盘点
    ADJUST,            // 调整
    TRANSFER,          // 调拨
    SYNC,              // 同步
    AUTH,              // 认证
    OTHER              // 其他
}

// 使用示例
@Service
@RequiredArgsConstructor
@Slf4j
public class InventoryService {

    @BizLog(type = BizType.OUTBOUND, bizIdField = "outboundId", paramFields = {"warehouseCode", "materialCode"})
    public void confirmOutbound(OutboundConfirmRequest request, String userId) {
        // 业务逻辑...
    }
}
```

### 4.2 入库日志

```java
// 入库操作日志
log.info("入库单创建, inboundId={}, sourceNo={}, warehouseCode={}, itemCount={}, operator={}",
         inbound.getId(), inbound.getSourceNo(), inbound.getWarehouseCode(), 
         inbound.getItems().size(), userId);

log.info("入库开始, inboundId={}, itemId={}, materialCode={}, planQty={}",
         inboundId, item.getId(), item.getMaterialCode(), item.getPlanQuantity());

log.info("入库完成, inboundId={}, itemId={}, actualQty={}, operator={}",
         inboundId, item.getId(), item.getActualQuantity(), userId);

// 质检相关
log.info("质检冻结库存, qcId={}, invId={}, freezeQty={}",
         qcId, invId, freezeQty);

log.info("质检解冻库存, qcId={}, result={}, unfreezeQty={}",
         qcId, result, unfreezeQty);

// 异常情况
log.warn("入库数量超限, inboundId={}, itemId={}, planQty={}, actualQty={}",
          inboundId, itemId, planQty, actualQty);

log.error("入库失败, inboundId={}, error={}", inboundId, e.getMessage(), e);
```

### 4.3 出库日志

```java
// 出库操作日志
log.info("出库单创建, outboundId={}, customerCode={}, warehouseCode={}, itemCount={}",
         outbound.getId(), outbound.getCustomerCode(), outbound.getWarehouseCode(), 
         outbound.getItems().size());

log.info("库位分配, outboundId={}, itemId={}, locationCode={}, qty={}",
         outboundId, itemId, locationCode, qty);

log.info("出库确认, outboundId={}, itemId={}, deductQty={}, beforeQty={}, afterQty={}, version={}",
         outboundId, itemId, deductQty, beforeQty, afterQty, newVersion);

// 异常情况
log.warn("库存不足, outboundId={}, materialCode={}, required={}, available={}",
         outboundId, materialCode, required, available);

log.warn("乐观锁冲突, outboundId={}, itemId={}, expectedVersion={}, actualVersion={}",
         outboundId, itemId, expectedVersion, actualVersion);

log.error("出库失败, outboundId={}, error={}", outboundId, e.getMessage(), e);
```

### 4.4 盘点日志

```java
// 盘点操作日志
log.info("盘点计划创建, stocktakeId={}, warehouseCode={}, locationCount={}",
         stocktakeId, warehouseCode, locationIds.size());

log.info("盘点启动, stocktakeId={}, lockedLocationCount={}, operator={}",
         stocktakeId, lockedCount, operator);

log.info("盘点完成, stocktakeId={}, itemId={}, systemQty={}, actualQty={}, diffQty={}",
         stocktakeId, itemId, systemQty, actualQty, diffQty);

log.info("盘点确认, stocktakeId={}, adjustedCount={}, operator={}",
         stocktakeId, adjustedCount, operator);

// 异常情况
log.warn("盘点差异率超阈值, stocktakeId={}, itemId={}, diffRate={}, threshold={}",
         stocktakeId, itemId, diffRate, threshold);

log.error("盘点确认失败, stocktakeId={}, error={}", stocktakeId, e.getMessage(), e);
```

---

## 五、敏感数据脱敏

### 5.1 脱敏规则

| 字段类型 | 脱敏规则 | 示例 |
|---------|---------|------|
| 手机号 | 中间4位脱敏 | `138****5678` |
| 身份证 | 出生日期脱敏 | `310***********1234` |
| 银行卡号 | 末4位可见 | `****1234` |
| 邮箱 | 域名可见 | `a***@163.com` |
| 姓名 | 末位脱敏 | `张*` |
| 地址 | 中间脱敏 | `上海市****区` |
| 密码 | 全部隐藏 | `******` |
| Token | 前后各4位 | `tok***en` |

### 5.2 脱敏实现

```java
// DataMaskUtil.java - 数据脱敏工具
@Component
@Slf4j
public class DataMaskUtil {

    private static final Map<String, MaskStrategy> MASK_RULES = new HashMap<>();

    static {
        MASK_RULES.put("mobile", value -> {
            if (StringUtils.isBlank(value) || value.length() < 11) return value;
            return value.substring(0, 3) + "****" + value.substring(7);
        });
        
        MASK_RULES.put("idCard", value -> {
            if (StringUtils.isBlank(value) || value.length() < 15) return value;
            return value.substring(0, 6) + "********" + value.substring(14);
        });
        
        MASK_RULES.put("bankCard", value -> {
            if (StringUtils.isBlank(value) || value.length() < 8) return value;
            return "****" + value.substring(value.length() - 4);
        });
        
        MASK_RULES.put("email", value -> {
            if (StringUtils.isBlank(value) || !value.contains("@")) return value;
            int atIndex = value.indexOf("@");
            return value.charAt(0) + "***" + value.substring(atIndex);
        });
        
        MASK_RULES.put("name", value -> {
            if (StringUtils.isBlank(value) || value.length() < 2) return value;
            return value.charAt(0) + "*";
        });
    }

    public static String mask(String type, String value) {
        MaskStrategy strategy = MASK_RULES.get(type);
        if (strategy == null) {
            return value;
        }
        return strategy.mask(value);
    }

    public static String maskMobile(String mobile) {
        return MASK_RULES.get("mobile").mask(mobile);
    }

    public static String maskIdCard(String idCard) {
        return MASK_RULES.get("idCard").mask(idCard);
    }
}

// Logstash Filter 中配置脱敏（避免日志中出现明文敏感信息）
/*
  # logstash pipeline.conf
  filter {
    mutate {
      # 脱敏手机号
      gsub => [
        "message", "\b(1[3-9]\d{9})\b", "${1}****%{+1,4,head:3,tail:4}"
      ]
    }
  }
*/
```

---

## 六、Kibana 看板

### 6.1 核心看板

| 看板名称 | 说明 | 关键指标 |
|---------|------|---------|
| 系统概览 | 整体运行状态 | QPS、响应时间、错误率 |
| 业务监控 | 入库/出库/盘点等 | 操作量、成功率、耗时 |
| 错误分析 | 错误日志分析 | 错误类型、错误趋势 |
| 链路追踪 | 请求链路追踪 | 慢请求、异常请求 |
| 性能分析 | SQL、接口性能 | 慢SQL、慢接口 |

### 6.2 告警规则

| 告警名称 | 条件 | 级别 | 处理方式 |
|---------|------|------|---------|
| 服务宕机 | `status > 0` 持续5分钟 | 严重 | 电话通知 |
| 错误率飙升 | `errorRate > 5%` 持续1分钟 | 警告 | 钉钉通知 |
| 响应超时 | `costTime > 5000ms` 持续5分钟 | 警告 | 钉钉通知 |
| 库存为负 | `inventoryQuantity < 0` | 严重 | 电话通知 |
| 库存对账差异 | `reconcileDiff > 0` | 严重 | 钉钉+邮件 |
| 接口限流 | `rateLimit > 0` | 警告 | 钉钉通知 |

---

## 七、禁止事项

| 序号 | 禁止项 | 正确做法 |
|---|-----|----|
| 1 | 禁止使用 `System.out` | 使用 log.info/warn/error |
| 2 | 禁止打印密码/Token明文 | 使用脱敏工具类 |
| 3 | 禁止打印敏感字段（手机号/身份证） | 必须脱敏 |
| 4 | 禁止打印大数据字段（如图片Base64） | 限制长度或跳过 |
| 5 | 禁止日志中打印 SQL 参数拼接 | 使用 mybatis 原生日志 |
| 6 | 禁止 ERROR 日志无堆栈 | 必须记录完整堆栈信息 |
| 7 | 禁止日志无 traceId | 必须经过 MdcFilter |
| 8 | 禁止 DEBUG 日志在生产开启 | 调整 logback 级别 |
