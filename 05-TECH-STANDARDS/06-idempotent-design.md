# WMS仓库物流系统 - 接口幂等设计

> 版本：V1.0
> 日期：2026-04-03
> 适用范围：WMS 所有对外接口、内部服务调用
> 核心目标：防止重复提交、重复消费、接口重试导致的幂等性问题

---

## 一、概述

### 1.1 幂等性定义

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                            幂等性定义                                         │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  幂等性：同一操作执行一次与执行多次的效果相同                                 │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                                                                    │  │
│  │   请求A ──────▶ 服务 ──────▶ 响应200 OK                           │  │
│  │                                  │                                 │  │
│  │   请求A'(重试) ──────▶ 服务 ────┼──────▶ 响应200 OK（相同结果）   │  │
│  │                                  │                                 │  │
│  │   请求A''(再重试) ───▶ 服务 ────┼──────▶ 响应200 OK（相同结果）   │  │
│  │                                                                    │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 幂等场景

| 场景 | 说明 | 示例 |
|------|------|------|
| 前端重复提交 | 用户快速点击、网络抖动导致 | 订单创建、库存扣减 |
| 接口超时重试 | 超时后自动重试 | 支付回调、出库确认 |
| MQ 消息重复 | 消息重试机制导致 | ERP同步、LIMS同步 |
| 补偿任务重试 | 定时任务失败重试 | 库存补偿、同步补偿 |

### 1.3 幂等技术方案

| 方案 | 适用场景 | 性能影响 |
|------|---------|---------|
| Token 机制 | 前端防重复提交 | 低 |
| 唯一键约束 | 数据库层面防重 | 中 |
| 分布式锁 | 临界资源保护 | 中 |
| 幂等表 | 通用幂等方案 | 中 |
| 状态机 | 单据状态流转 | 低 |
| 去重表 | 接口调用去重 | 中 |

---

## 二、Token 机制

### 2.1 原理

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            Token 幂等机制                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────┐    1. 获取Token    ┌─────────────┐                          │
│  │  前端   │ ──────────────────▶ │  Token服务   │                          │
│  └─────────┘ ◀────────────────── └─────────────┘                          │
│                                           │                                 │
│                                           │ 生成Token                       │
│                                           │ 存入Redis                       │
│                                           │ 设置过期时间(5分钟)              │
│                                           ▼                                 │
│  ┌─────────┐    2. 提交请求    ┌─────────────┐                          │
│  │  前端   │ ──────────────────▶ │  Controller │                          │
│  └─────────┘                    └──────┬──────┘                          │
│                                        │                                   │
│                                        │ 校验Token                        │
│                                        ▼                                   │
│                                 ┌─────────────┐                            │
│                                 │   Redis     │                            │
│                                 │ DELETE Token│                            │
│                                 └──────┬──────┘                            │
│                                        │                                   │
│                                  成功 │      │ 失败                         │
│                                        ▼           ▼                       │
│                                  ┌─────────┐   ┌──────────┐              │
│                                  │ 执行业务 │   │ 返回幂等  │              │
│                                  │ 并响应   │   │ 错误      │              │
│                                  └─────────┘   └──────────┘              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 实现

```java
// IdempotentTokenService.java
@Service
@RequiredArgsConstructor
@Slf4j
public class IdempotentTokenService {

    private final RedisTemplate<String, String> redisTemplate;
    private static final String TOKEN_PREFIX = "idempotent:token:";
    private static final Duration TOKEN_EXPIRE = Duration.ofMinutes(5);

    /**
     * 生成幂等Token
     */
    public String generateToken() {
        String token = UUID.randomUUID().toString().replace("-", "");
        String key = TOKEN_PREFIX + token;
        
        // 存入Redis，value为"1"
        redisTemplate.opsForValue().set(key, "1", TOKEN_EXPIRE);
        
        log.debug("生成幂等Token, token={}", token);
        return token;
    }

    /**
     * 校验并删除Token（原子操作）
     * @return true-校验通过并已删除, false-Token不存在或已使用
     */
    public boolean validateAndRemove(String token) {
        if (StringUtils.isBlank(token)) {
            return false;
        }
        
        String key = TOKEN_PREFIX + token;
        
        // Redis DELETE 操作保证原子性
        // 返回1表示Key存在并被删除，返回0表示Key不存在（已被使用或过期）
        Boolean result = redisTemplate.delete(key);
        
        if (Boolean.TRUE.equals(result)) {
            log.debug("Token校验通过并已删除, token={}", token);
            return true;
        } else {
            log.warn("Token不存在或已使用, token={}", token);
            return false;
        }
    }

    /**
     * 校验Token（不删除，用于查询类接口）
     */
    public boolean validate(String token) {
        if (StringUtils.isBlank(token)) {
            return false;
        }
        String key = TOKEN_PREFIX + token;
        return Boolean.TRUE.equals(redisTemplate.hasKey(key));
    }
}

// IdempotentTokenAspect.java
@Component
@Aspect
@RequiredArgsConstructor
@Slf4j
public class IdempotentTokenAspect {

    private final IdempotentTokenService tokenService;

    @Around("@annotation(idempotentToken)")
    public Object around(ProceedingJoinPoint point, IdempotentToken idempotentToken) throws Throwable {
        HttpServletRequest request = getHttpServletRequest();
        
        // 从Header获取Token
        String token = request.getHeader("X-Idempotent-Token");
        
        // 校验Token
        if (!tokenService.validateAndRemove(token)) {
            log.warn("幂等Token校验失败, token={}, method={}", 
                     token, point.getSignature().getName());
            throw new BusinessException("SYS012", "重复请求，请勿重复提交");
        }
        
        try {
            return point.proceed();
        } catch (Exception e) {
            // 业务异常时，重新生成Token供前端使用
            String newToken = tokenService.generateToken();
            request.setAttribute("X-Idempotent-Token", newToken);
            throw e;
        }
    }

    private HttpServletRequest getHttpServletRequest() {
        ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        return attrs.getRequest();
    }
}

// IdempotentToken.java - 注解
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface IdempotentToken {
    String headerName() default "X-Idempotent-Token";
}
```

### 2.3 使用示例

```java
// Controller 层使用
@RestController
@RequestMapping("/api/inventory")
@RequiredArgsConstructor
public class InventoryController {

    /**
     * 1. 获取Token接口（GET）
     */
    @GetMapping("/token")
    public Result<String> getToken() {
        String token = idempotentTokenService.generateToken();
        return Result.success(token);
    }

    /**
     * 2. 提交库存调整申请（POST，需幂等）
     */
    @PostMapping("/adjust")
    @IdempotentToken
    public Result<Void> adjust(@RequestBody @Valid InventoryAdjustRequest request,
                                @RequestHeader(value = "X-Idempotent-Token", required = false) String token) {
        inventoryService.adjust(request);
        return Result.success();
    }
}

// Vue 前端使用
<template>
  <div>
    <el-button @click="submitAdjust">提交调整</el-button>
  </div>
</template>

<script>
export default {
  methods: {
    async submitAdjust() {
      try {
        // 1. 先获取Token
        const tokenRes = await this.$api.getToken();
        const token = tokenRes.data;
        
        // 2. 带Token提交请求
        await this.$api.adjustInventory(this.formData, token);
        
        this.$message.success('提交成功');
      } catch (e) {
        if (e.code === 'SYS012') {
          this.$message.warning('请勿重复提交');
        } else {
          this.$message.error(e.message);
        }
      }
    }
  }
}
</script>
```

---

## 三、幂等表机制

### 3.1 幂等表设计

```sql
-- 接口幂等记录表
CREATE TABLE sys_idempotent_log (
    id            BIGINT PRIMARY KEY AUTO_INCREMENT,
    idempotent_key VARCHAR(128) NOT NULL COMMENT '幂等键（接口名+业务ID+时间戳等）',
    biz_type      VARCHAR(50)  COMMENT '业务类型',
    biz_id        VARCHAR(64)  COMMENT '业务ID',
    status        VARCHAR(20)  NOT NULL DEFAULT 'PROCESSING' COMMENT '状态（PROCESSING/SUCCESS/FAILED）',
    result_code   VARCHAR(20)  COMMENT '结果码',
    result_data   TEXT         COMMENT '响应数据（JSON）',
    retry_count   INT          NOT NULL DEFAULT 0 COMMENT '重试次数',
    expire_time   DATETIME     NOT NULL COMMENT '过期时间',
    gmt_create    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_idempotent_key (idempotent_key),
    INDEX idx_expire_time (expire_time),
    INDEX idx_status (status)
) ENGINE=InnoDB COMMENT='接口幂等记录表';
```

### 3.2 幂等键生成规则

| 接口类型 | 幂等键生成规则 | 示例 |
|---------|--------------|------|
| 创建类接口 | `{method}:{bizType}:{uuid}` | `POST:INBOUND:uuid-xxx` |
| 更新类接口 | `{method}:{bizType}:{bizId}` | `PUT:INBOUND:1001` |
| 删除类接口 | `{method}:{bizType}:{bizId}` | `DELETE:INBOUND:1001` |
| 批量接口 | `{method}:{bizType}:{batchId}` | `POST:BATCH:INBOUND:batch-xxx` |
| 同步类接口 | `{sourceSystem}:{syncType}:{syncId}` | `ERP:INBOUND:ERP-20260403-001` |

### 3.3 幂等实现

```java
// IdempotentService.java
@Service
@RequiredArgsConstructor
@Slf4j
public class IdempotentService {

    private final SysIdempotentLogMapper idempotentMapper;
    private static final Duration EXPIRE_TIME = Duration.ofHours(24);

    /**
     * 执行业务并记录幂等
     */
    public <T> Result<T> executeWithIdempotency(String idempotentKey, 
                                                  String bizType,
                                                  String bizId,
                                                  Supplier<Result<T>> businessLogic) {
        // 1. 幂等键去重
        SysIdempotentLog record = idempotentMapper.selectByKey(idempotentKey);
        
        if (record != null) {
            // 2. 已存在记录，检查状态
            if ("SUCCESS".equals(record.getStatus())) {
                // 3. 已成功，直接返回结果
                log.info("幂等命中-已成功, idempotentKey={}, bizId={}", 
                         idempotentKey, bizId);
                T data = parseData(record.getResultData());
                return Result.success(data);
            } else if ("PROCESSING".equals(record.getStatus())) {
                // 4. 处理中，返回处理中
                log.warn("幂等命中-处理中, idempotentKey={}", idempotentKey);
                return Result.fail("SYS013", "请求正在处理中，请稍后");
            } else {
                // 5. 之前失败，尝试重试（有限次）
                if (record.getRetryCount() >= 3) {
                    log.error("幂等命中-重试次数超限, idempotentKey={}, retryCount={}", 
                              idempotentKey, record.getRetryCount());
                    return Result.fail(record.getResultCode(), "处理失败，请稍后重试");
                }
            }
        }

        // 6. 首次执行，创建记录
        if (record == null) {
            record = SysIdempotentLog.builder()
                .idempotentKey(idempotentKey)
                .bizType(bizType)
                .bizId(bizId)
                .status("PROCESSING")
                .expireTime(LocalDateTime.now().plus(EXPIRE_TIME))
                .build();
            idempotentMapper.insert(record);
        } else {
            // 更新状态为处理中
            idempotentMapper.updateStatus(record.getId(), "PROCESSING", record.getRetryCount() + 1);
        }

        // 7. 执行业务逻辑
        try {
            Result<T> result = businessLogic.get();
            
            // 8. 更新结果
            idempotentMapper.updateSuccess(record.getId(), JsonUtil.toJson(result));
            
            log.info("幂等执行成功, idempotentKey={}, bizId={}", idempotentKey, bizId);
            return result;
            
        } catch (Exception e) {
            // 9. 更新失败状态
            idempotentMapper.updateFailed(record.getId(), "SYS001", e.getMessage());
            log.error("幂等执行失败, idempotentKey={}, error={}", idempotentKey, e.getMessage());
            throw e;
        }
    }
}

// Idempotent.java - 注解
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface Idempotent {
    String bizType() default "";           // 业务类型
    String bizIdField() default "id";      // 业务ID字段
    String keyPrefix() default "";          // 幂等键前缀
}
```

### 3.4 使用示例

```java
// Service 层使用
@Service
@RequiredArgsConstructor
@Slf4j
public class OutboundService {

    @Idempotent(bizType = "OUTBOUND", bizIdField = "outboundId", keyPrefix = "outbound:confirm")
    public Result<Void> confirmOutbound(OutboundConfirmRequest request) {
        // 业务逻辑...
        return Result.success();
    }
}

// MQ 消费者使用
@RocketMQMessageListener(
    topic = "wms-outbound",
    consumerGroup = "wms-outbound-confirm-consumer"
)
@Component
@RequiredArgsConstructor
@Slf4j
public class OutboundMQConsumer implements RocketMQListener<OutboundMessage> {

    private final IdempotentService idempotentService;

    @Override
    public void onMessage(OutboundMessage message) {
        String idempotentKey = String.format("MQ:OUTBOUND:%s:%s", 
                                              message.getMessageId(),
                                              message.getOutboundId());
        
        idempotentService.executeWithIdempotency(
            idempotentKey,
            "OUTBOUND",
            message.getOutboundId(),
            () -> {
                processOutbound(message);
                return Result.success(null);
            }
        );
    }
}
```

---

## 四、外部接口幂等

### 4.1 ERP 接口幂等

```java
// ErpApiClient.java
@Service
@RequiredArgsConstructor
@Slf4j
public class ErpApiClient {

    private final RestTemplate restTemplate;
    private final IdempotentService idempotentService;

    /**
     * ERP 出库同步
     */
    public Result<Void> syncOutbound(ErpOutboundRequest request) {
        // 生成幂等键：ERP系统编码 + 出库单号
        String idempotentKey = String.format("ERP:SYNC:OUTBOUND:%s:%s", 
                                              request.getErpOrgCode(),
                                              request.getOutboundNo());
        
        return idempotentService.executeWithIdempotency(
            idempotentKey,
            "ERP_OUTBOUND",
            request.getOutboundNo(),
            () -> {
                // 调用ERP接口
                String response = callErpApi("/api/outbound/sync", request);
                
                // 解析响应
                ErpResponse erpResponse = JsonUtil.parseObject(response, ErpResponse.class);
                if (!erpResponse.isSuccess()) {
                    throw new BusinessException("SYC001", erpResponse.getMessage());
                }
                
                return Result.success(null);
            }
        );
    }

    private String callErpApi(String path, Object request) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        // ERP接口要求传递请求ID用于幂等
        headers.set("X-Request-Id", generateRequestId());
        
        HttpEntity<Object> entity = new HttpEntity<>(request, headers);
        
        return restTemplate.postForObject(
            erpConfig.getBaseUrl() + path,
            entity,
            String.class
        );
    }
}
```

### 4.2 LIMS 接口幂等

```java
// LimsApiClient.java
@Service
@RequiredArgsConstructor
@Slf4j
public class LimsApiClient {

    private final IdempotentService idempotentService;

    /**
     * LIMS 质检结果同步
     */
    public Result<Void> syncQcResult(LimsQcResultRequest request) {
        // 幂等键：LIMS样本号
        String idempotentKey = String.format("LIMS:SYNC:QC:%s", request.getSampleNo());
        
        return idempotentService.executeWithIdempotency(
            idempotentKey,
            "LIMS_QC",
            request.getSampleNo(),
            () -> {
                // 调用LIMS接口
                limsApiClient.call("/qc/result", request);
                return Result.success(null);
            }
        );
    }
}
```

---

## 五、状态机幂等

### 5.1 单据状态流转幂等

```java
// StateTransitionService.java
@Service
@RequiredArgsConstructor
@Slf4j
public class StateTransitionService {

    /**
     * 状态流转（带幂等）
     */
    @Transactional
    public void transitionWithIdempotency(Long bizId, String targetState, 
                                           String operator, String requestId) {
        // 幂等键：单据ID + 目标状态 + 请求ID
        String idempotentKey = String.format("STATE:%d:%s:%s", bizId, targetState, requestId);
        
        // 查询是否已处理
        SysIdempotentLog record = idempotentMapper.selectByKey(idempotentKey);
        if (record != null) {
            log.info("状态流转幂等命中, bizId={}, targetState={}, requestId={}", 
                     bizId, targetState, requestId);
            return;
        }
        
        // 执行状态流转
        doTransition(bizId, targetState, operator);
        
        // 记录幂等
        SysIdempotentLog log = SysIdempotentLog.builder()
            .idempotentKey(idempotentKey)
            .bizType("STATE_TRANSITION")
            .bizId(String.valueOf(bizId))
            .status("SUCCESS")
            .resultCode("SUCCESS")
            .build();
        idempotentMapper.insert(log);
    }
}
```

### 5.2 库存操作幂等

```java
// InventoryService.java
@Service
@RequiredArgsConstructor
@Slf4j
public class InventoryService {

    /**
     * 库存扣减（带幂等）
     */
    @Transactional
    public void deductWithIdempotency(Long inventoryId, Integer delta, 
                                       String operator, String requestId) {
        // 幂等键：库存ID + 变更量 + 请求ID
        String idempotentKey = String.format("INV:DEDUCT:%d:%d:%s", 
                                              inventoryId, delta, requestId);
        
        // 尝试获取分布式锁
        String lockKey = "deduct:" + inventoryId;
        RLock lock = redissonClient.getLock(lockKey);
        
        try {
            if (!lock.tryLock(3, 10, TimeUnit.SECONDS)) {
                throw new BusinessException("SYS002", "系统繁忙，请稍后重试");
            }
            
            // 幂等检查
            if (idempotentMapper.existsByKey(idempotentKey)) {
                log.info("库存扣减幂等命中, invId={}, delta={}", inventoryId, delta);
                return;
            }
            
            // 执行扣减
            doDeduct(inventoryId, delta, operator);
            
            // 记录幂等
            recordIdempotent(idempotentKey);
            
        } finally {
            if (lock.isHeldByCurrentThread()) {
                lock.unlock();
            }
        }
    }
}
```

---

## 六、定时清理

### 6.1 过期数据清理

```java
/**
 * 幂等记录清理任务（每日凌晨清理7天前数据）
 */
@XxlJob("idempotentLogCleanJob")
public ReturnT<String> cleanIdempotentLog() {
    log.info("开始清理过期幂等记录...");
    
    LocalDateTime expireTime = LocalDateTime.now().minusDays(7);
    int deleted = idempotentMapper.deleteByExpireTime(expireTime);
    
    log.info("清理幂等记录完成, deletedCount={}", deleted);
    
    return ReturnT.SUCCESS;
}
```

---

## 七、禁止事项

| 序号 | 禁止项 | 正确做法 |
|---|-----|----|
| 1 | 禁止接口无幂等校验 | 所有写接口必须幂等 |
| 2 | 禁止使用数据库唯一索引作为唯一幂等依据 | 使用独立幂等表 |
| 3 | 禁止幂等键设计不唯一 | 幂等键必须包含接口+业务ID+请求标识 |
| 4 | 禁止幂等记录永不过期 | 必须设置过期时间并定期清理 |
| 5 | 禁止 MQ 消费无幂等 | 消费者必须幂等处理 |
| 6 | 禁止超时重试无幂等 | 重试前必须检查是否已处理 |
| 7 | 禁止幂等表无索引 | 必须为幂等键建立唯一索引 |
| 8 | 禁止忽略幂等失败 | 幂等失败需告警并人工介入 |
