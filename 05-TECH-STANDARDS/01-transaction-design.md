# WMS仓库物流系统 - 库存一致性保障设计

> 版本：V1.0
> 日期：2026-04-03
> 适用范围：WMS 所有库存相关业务操作
> 核心目标：保障库存数据在并发场景下的准确性、一致性、可用性

---

## 一、概述

### 1.1 设计目标

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                            库存一致性保障体系                                  │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │
│  │  准确性     │    │  一致性     │    │  可用性     │    │  可追溯性   │  │
│  │  扣减不超量 │    │  多端同步   │    │  并发不死锁 │    │  全链路流水 │  │
│  └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘  │
│                                                                              │
│  核心技术手段：                                                                │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │ 分布式锁（Redisson） │ 乐观锁（版本号） │ 本地锁（读写分离）│ 事务保障   │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 核心挑战

| 挑战 | 场景描述 | 风险等级 |
|------|---------|---------|
| 超卖 | 多用户同时抢购同一批次物料 | **高** |
| 负库存 | 扣减后库存变为负数 | **高** |
| 幻影读 | 同一事务内两次读取库存不一致 | **中** |
| 死锁 | 多库位按不同顺序锁定导致死锁 | **中** |
| 分布式事务 | 库存扣减 + 流水记录跨库失败 | **高** |

### 1.3 性能指标

根据需求文档（WMS-3.6）：日常并发 50 人、峰值 100 人、系统吞吐量 ≥ 50 TPS。库存操作需在 **200ms** 内完成，避免成为系统瓶颈。

---

## 二、库存模型

### 2.1 库存实体结构

```
inv_inventory（库存余量表）
├── warehouse_code     公司+仓库维度
├── location_id        库位维度
├── material_id        物料维度
├── batch_id           批次维度
├── quantity           现有库存数量
├── frozen_quantity    冻结库存数量（请验/盘点锁定）
├── available_quantity  可用库存数量（computed: quantity - frozen_quantity）
├── occupy_quantity     在途占用数量（出库在途）
└── version            乐观锁版本号
```

**核心公式**：
```
可用库存 = 现有库存 - 冻结库存 - 在途占用
扣减后可用库存 = 原可用库存 - 扣减数量 ≥ 0
```

### 2.2 库存变更类型

| 变更类型 | 代码 | 说明 |
|---------|------|------|
| 入库 | INBOUND | 采购/生产入库 |
| 出库 | OUTBOUND | 销售/调拨/领用出库 |
| 调拨 | TRANSFER | 库位调整 |
| 质检冻结 | QC_FREEZE | 请验冻结 |
| 质检解冻 | QC_UNFREEZE | 质检完成解冻 |
| 盘点调整 | STOCKTAKE | 盘点盈亏 |
| 报废 | SCRAP | 报废扣减 |

---

## 三、并发控制机制

### 3.1 分层锁策略

```
┌─────────────────────────────────────────────────────────────────┐
│                        分层锁策略                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  L1  乐观锁（首选）                                             │
│  ├─ 适用场景：低并发、无锁等待的业务操作（入库、盘点调整）         │
│  ├─ 实现方式：UPDATE SET quantity = quantity - ?, version = version + 1   │
│  │              WHERE id = ? AND version = ? AND available_quantity >= ?  │
│  └─ 优点：无需等待，性能最优                                      │
│                                                                 │
│  L2  分布式锁（强一致）                                         │
│  ├─ 适用场景：高并发、涉及多行库存扣减、出库确认                   │
│  ├─ 实现方式：Redisson RLock，按 "仓库+库位+物料+批次" 粒度加锁    │
│  ├─ 锁超时：10秒（业务操作超时）                                  │
│  └─ 优点：跨 JVM 保证全局互斥                                     │
│                                                                 │
│  L3  本地锁（辅助）                                              │
│  ├─ 适用场景：同一 JVM 内的快速校验（如表单重复提交拦截）          │
│  └─ 实现方式：ReentrantLock 或 ConcurrentHashMap                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 乐观锁实现

#### 3.2.1 SQL 实现

```sql
-- 扣减库存（乐观锁）
UPDATE inv_inventory
SET quantity = quantity - #{delta},
    available_quantity = quantity - #{delta} - frozen_quantity - occupy_quantity,
    version = version + 1,
    update_time = NOW(),
    update_by = #{userId}
WHERE id = #{id}
  AND version = #{version}
  AND (quantity - frozen_quantity - occupy_quantity) >= #{delta};
```

```sql
-- 增加库存（乐观锁）
UPDATE inv_inventory
SET quantity = quantity + #{delta},
    available_quantity = quantity + #{delta} - frozen_quantity - occupy_quantity,
    version = version + 1,
    update_time = NOW(),
    update_by = #{userId}
WHERE id = #{id}
  AND version = #{version};
```

#### 3.2.2 Java 实现

```java
// InventoryService.java
@Slf4j
@Service
@RequiredArgsConstructor
public class InventoryService {

    private final InvInventoryMapper inventoryMapper;

    /**
     * 乐观锁扣减库存
     * @return true-扣减成功, false-版本冲突或库存不足
     */
    public boolean deductStock(Long inventoryId, Integer delta, Long version, String userId) {
        // 1. 执行乐观锁更新
        int rows = inventoryMapper.deductByVersion(inventoryId, delta, version, userId);
        if (rows == 0) {
            // 2. 记录冲突日志
            log.warn("库存扣减乐观锁冲突, inventoryId={}, delta={}, version={}", 
                     inventoryId, delta, version);
            return false;
        }
        return true;
    }

    /**
     * 乐观锁 + 重试（推荐）
     */
    public boolean deductStockWithRetry(Long inventoryId, Integer delta, String userId) {
        const int MAX_RETRY = 3;
        for (int i = 0; i < MAX_RETRY; i++) {
            InvInventory inv = inventoryMapper.selectById(inventoryId);
            if (inv.getAvailableQuantity() < delta) {
                throw new BusinessException("INV001", "库存不足");
            }
            if (deductStock(inventoryId, delta, inv.getVersion(), userId)) {
                return true;
            }
            // 退避重试：100ms * 重试次数
            Thread.sleep(100L * (i + 1));
        }
        throw new BusinessException("SYS002", "库存扣减失败，请重试");
    }
}
```

#### 3.2.3 MyBatis Mapper

```xml
<!-- InvInventoryMapper.xml -->
<update id="deductByVersion">
    UPDATE inv_inventory
    SET quantity = quantity - #{delta},
        available_quantity = quantity - #{delta} - frozen_quantity - occupy_quantity,
        version = version + 1,
        update_time = NOW(),
        update_by = #{userId}
    WHERE id = #{id}
      AND version = #{version}
      AND (quantity - frozen_quantity - occupy_quantity) >= #{delta}
</update>
```

### 3.3 分布式锁实现

#### 3.3.1 锁粒度设计

```
锁粒度 = warehouse_code + ":" + location_id + ":" + material_id + ":" + batch_id
示例：  WH001:A001:MAT001:BATCH001
```

**锁粒度选择原则**：
- 同一 SKU 的多批次：按 `batch_id` 分离锁
- 同一库位的多 SKU：按 `location_id` 粒度加锁
- 全仓库操作：禁止使用仓库级锁，必须细化到具体物料+批次

#### 3.3.2 Redisson 封装

```java
// DistributedLockService.java
@Component
@Slf4j
public class DistributedLockService {

    @Autowired
    private RedissonClient redissonClient;

    private static final Duration LOCK_TIMEOUT = Duration.ofSeconds(10);
    private static final Duration WAIT_TIMEOUT = Duration.ofSeconds(5);

    /**
     * 执行库存操作（带分布式锁）
     * @param lockKey     锁键（仓库:库位:物料:批次）
     * @param operation    业务操作
     * @return 操作结果
     */
    public <T> T executeWithLock(String lockKey, Supplier<T> operation) {
        RLock lock = redissonClient.getLock(lockKey);
        boolean locked = false;
        try {
            locked = lock.tryLock(WAIT_TIMEOUT.toMillis(), LOCK_TIMEOUT.toMillis(),
                                   TimeUnit.MILLISECONDS);
            if (!locked) {
                log.warn("获取分布式锁失败, lockKey={}", lockKey);
                throw new BusinessException("SYS002", "系统繁忙，请稍后重试");
            }
            log.debug("获取分布式锁成功, lockKey={}", lockKey);
            return operation.get();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new BusinessException("SYS002", "操作被中断");
        } finally {
            if (locked && lock.isHeldByCurrentThread()) {
                lock.unlock();
                log.debug("释放分布式锁, lockKey={}", lockKey);
            }
        }
    }

    /**
     * 批量获取锁（出库确认时使用）
     */
    public List<RLock> acquireMultipleLocks(List<String> lockKeys) {
        List<RLock> locks = lockKeys.stream()
            .map(redissonClient::getLock)
            .collect(Collectors.toList());
        
        // 按字典序排序，避免死锁
        locks.sort(Comparator.comparing(RLock::getName));
        
        for (RLock lock : locks) {
            try {
                if (!lock.tryLock(WAIT_TIMEOUT.toMillis(), LOCK_TIMEOUT.toMillis(),
                                  TimeUnit.MILLISECONDS)) {
                    // 获取失败，释放已获取的锁
                    locks.stream()
                        .filter(RLock::isLocked)
                        .filter(l -> l.isHeldByCurrentThread())
                        .forEach(RLock::unlock);
                    throw new BusinessException("SYS002", "系统繁忙，请稍后重试");
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                throw new BusinessException("SYS002", "操作被中断");
            }
        }
        return locks;
    }

    /**
     * 释放批量锁
     */
    public void releaseMultipleLocks(List<RLock> locks) {
        locks.stream()
            .filter(RLock::isHeldByCurrentThread)
            .forEach(RLock::unlock);
    }
}
```

#### 3.3.3 出库确认分布式锁应用

```java
// OutboundService.java
@Service
@RequiredArgsConstructor
@Slf4j
public class OutboundService {

    private final DistributedLockService lockService;
    private final InventoryService inventoryService;
    private final InvInventoryChangeMapper changeMapper;

    /**
     * 确认出库（分布式锁保障）
     */
    @Transactional(rollbackFor = Exception.class)
    public void confirmOutbound(OutboundConfirmRequest request, String userId) {
        // 1. 查询待出库明细
        List<OutboundItem> items = outboundItemMapper.selectByOutboundId(request.getOutboundId());

        // 2. 生成锁键列表（按仓库:库位:物料:批次）
        List<String> lockKeys = items.stream()
            .map(item -> String.format("%s:%s:%s:%s",
                item.getWarehouseCode(),
                item.getLocationId(),
                item.getMaterialId(),
                item.getBatchId()))
            .distinct()
            .sorted() // 字典序排序避免死锁
            .collect(Collectors.toList());

        // 3. 批量获取分布式锁
        List<RLock> locks = lockService.acquireMultipleLocks(lockKeys);
        try {
            for (OutboundItem item : items) {
                // 4. 乐观锁扣减库存
                boolean success = inventoryService.deductStockWithRetry(
                    item.getInventoryId(), item.getQuantity(), userId);

                if (!success) {
                    throw new BusinessException("INV001", 
                        String.format("物料[%s]库存不足", item.getMaterialCode()));
                }

                // 5. 生成库存变更流水
                InvInventoryChange change = buildChangeRecord(item, userId);
                changeMapper.insert(change);
            }

            // 6. 更新出库单状态
            outboundMapper.updateStatus(request.getOutboundId(), "SHIPPED", userId);

            log.info("出库确认成功, outboundId={}, userId={}", request.getOutboundId(), userId);
        } finally {
            // 7. 释放批量锁
            lockService.releaseMultipleLocks(locks);
        }
    }
}
```

### 3.4 死锁预防

#### 3.4.1 锁排序规则

```
规则：所有分布式锁的获取必须按字典序升序排列
```

```java
// 反例（可能死锁）
acquireLock("WH001:A001:MAT001:BATCH001");
acquireLock("WH001:A002:MAT002:BATCH002");

// 正例（安全）
acquireLock("WH001:A001:MAT001:BATCH001");  // A001 < A002
acquireLock("WH001:A002:MAT002:BATCH002");
```

#### 3.4.2 超时设置

| 锁类型 | 等待超时 | 持有超时 | 说明 |
|-------|---------|---------|------|
| 分布式写锁 | 5秒 | 10秒 | 库存扣减 |
| 分布式读锁 | 3秒 | 5秒 | 库存查询 |
| 乐观锁重试 | - | 3次 | 无需等待 |

---

## 四、事务设计

### 4.1 事务边界

```
┌────────────────────────────────────────────────────────────────────┐
│                        事务边界设计                                  │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  出库确认事务                                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ BEGIN TRANSACTION                                            │  │
│  │  1. [悲观锁] SELECT ... FOR UPDATE（库存行锁）                 │  │
│  │  2. [业务] 扣减库存（乐观锁 UPDATE）                           │  │
│  │  3. [业务] 生成库存变更流水                                     │  │
│  │  4. [业务] 更新出库单状态                                       │  │
│  │  5. [业务] 解锁在途占用                                        │  │
│  │  COMMIT                                                       │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  入库确认事务                                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ BEGIN TRANSACTION                                            │  │
│  │  1. [业务] 插入/更新库存记录（库存不存在时 INSERT）             │  │
│  │  2. [业务] 增加库存数量                                        │  │
│  │  3. [业务] 生成库存变更流水                                     │  │
│  │  4. [业务] 更新入库单状态                                       │  │
│  │  COMMIT                                                       │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  盘点调整事务                                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ BEGIN TRANSACTION                                            │  │
│  │  1. [业务] 锁定库位（状态=盘点中）                             │  │
│  │  2. [业务] 批量调整库存                                        │  │
│  │  3. [业务] 生成盘点流水                                         │  │
│  │  4. [业务] 解锁库位                                            │  │
│  │  5. [MQ] 同步至 ERP（异步，不在事务内）                         │  │
│  │  COMMIT                                                       │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

### 4.2 事务传播行为

| 方法 | 传播行为 | 原因 |
|------|---------|------|
| 库存扣减 | `REQUIRED` | 加入当前事务 |
| 库存查询 | `REQUIRED` | 加入当前事务（读已提交） |
| 流水记录 | `REQUIRED` | 加入当前事务 |
| MQ 消息发送 | `NESTED` | 嵌套事务，失败回滚 |
| ERP 同步 | `REQUIRES_NEW` | 新事务，独立提交 |
| 日志记录 | 无事务 | 独立执行 |

### 4.3 本地事务与分布式事务

```
小事务（单库操作）：使用 Spring @Transactional
大事务（跨库/跨服务）：使用 Seata AT 模式
```

```java
// Seata AT 模式（跨库操作时使用）
@GlobalTransactional(name = "wms-outbound-confirm", timeoutMills = 30000)
public void confirmOutboundGlobal(OutboundConfirmRequest request) {
    // 1. 库存扣减（本库）
    inventoryService.deduct(request);

    // 2. 调用 ERP 服务（远程）
    erpFeignClient.syncOutbound(request);

    // 3. MQ 通知（异步）
    mqProducer.sendOutboundMessage(request);
}
```

---

## 五、库存冻结机制

### 5.1 冻结场景

| 场景 | 冻结类型 | 解冻时机 | 说明 |
|------|---------|---------|------|
| 请验 | QC_FREEZE | 质检完成（合格/不合格） | 冻结 = 请验数量 |
| 盘点 | STOCKTAKE_FREEZE | 盘点确认完成 | 冻结盘点范围 |
| 调拨 | TRANSFER_FREEZE | 调拨完成 | 冻结原库位 |

### 5.2 冻结实现

```java
// InventoryFreezeService.java
@Service
@RequiredArgsConstructor
@Slf4j
public class InventoryFreezeService {

    /**
     * 冻结库存（请验时调用）
     */
    @Transactional
    public void freezeForQc(QcApplyRequest request, String userId) {
        for (QcApplyItem item : request.getItems()) {
            // 查询库存
            InvInventory inv = inventoryMapper.selectByUk(
                item.getWarehouseCode(),
                item.getLocationId(),
                item.getMaterialId(),
                item.getBatchId()
            );

            if (inv == null) {
                throw new BusinessException("INV002", "库存数据异常");
            }

            // 检查可用库存
            if (inv.getAvailableQuantity() < item.getQuantity()) {
                throw new BusinessException("INV001", "可用库存不足");
            }

            // 更新冻结数量
            int rows = inventoryMapper.freezeQuantity(
                inv.getId(), item.getQuantity(), userId);
            if (rows == 0) {
                throw new BusinessException("INV003", "库存冻结失败");
            }

            log.info("库存冻结成功, invId={}, freezeQty={}, type=QC_FREEZE",
                     inv.getId(), item.getQuantity());
        }
    }

    /**
     * 解冻库存（质检完成时调用）
     */
    @Transactional
    public void unfreezeForQc(QcRecord record, String userId) {
        // 根据质检结果处理
        if ("QUALIFIED".equals(record.getResult())) {
            // 合格：全额解冻
            unfreeze(record.getInventoryId(), record.getFreezeQuantity(), userId);
        } else if ("CONDITIONAL".equals(record.getResult())) {
            // 让步放行：部分解冻
            unfreeze(record.getInventoryId(), record.getActualQuantity(), userId);
            // 剩余转为冻结/报废
            int remaining = record.getFreezeQuantity() - record.getActualQuantity();
            // 触发报废流程...
        } else {
            // 不合格：全额冻结，等待处置
            log.info("质检不合格，维持冻结, invId={}", record.getInventoryId());
        }
    }

    /**
     * 批量解冻（盘点确认时调用）
     */
    @Transactional
    public void unfreezeForStocktake(Long stocktakeId, String userId) {
        List<InvInventory> freezedInvs = inventoryMapper.selectByStocktakeId(stocktakeId);
        for (InvInventory inv : freezedInvs) {
            unfreeze(inv.getId(), inv.getFrozenQuantity(), userId);
            inventoryMapper.clearStocktakeId(inv.getId());
        }
    }
}
```

---

## 六、库存一致性校验

### 6.1 校验规则

| 规则 | 描述 | 校验时机 |
|------|------|---------|
| 非负校验 | `available_quantity >= 0` | 扣减后立即校验 |
| 冻结校验 | `frozen_quantity <= quantity` | 冻结操作前 |
| 批次校验 | 批次号必须有效且未过期 | 入库/出库 |
| 效期校验 | `expire_date > 当前日期` | 出库时（FIFO/FEFO） |
| 库位校验 | 库位状态必须为"空闲"或"占用" | 入库时 |

### 6.2 异步对账

```java
/**
 * 每日库存一致性对账任务（XXL-Job）
 */
@XxlJob("inventoryReconciliationJob")
public ReturnT<String> inventoryReconciliation() {
    log.info("开始库存一致性对账...");
    
    // 1. 汇总库存汇总表
    List<InventorySummary> summary = inventoryMapper.summaryByGroup();
    
    // 2. 汇总流水表（期初 + 入库 - 出库）
    List<InventoryLedger> ledger = changeMapper.calculateByPeriod(
        LocalDate.now().minusDays(1), LocalDate.now());
    
    // 3. 比对差异
    List<InventoryDiff> diffs = compare(summary, ledger);
    
    // 4. 记录差异
    if (!diffs.isEmpty()) {
        diffMapper.insertBatch(diffs);
        alertService.sendAlert("库存对账差异", diffs);
        log.warn("发现 {} 条库存差异", diffs.size());
    } else {
        log.info("库存一致性对账完成，无差异");
    }
    
    return ReturnT.SUCCESS;
}
```

---

## 七、补偿机制

### 7.1 失败补偿流程

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            库存操作失败补偿流程                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  操作请求                                                                   │
│     │                                                                      │
│     ▼                                                                      │
│  ┌─────────┐     失败      ┌──────────────┐     仍失败     ┌────────────┐  │
│  │ 执行操作 │ ──────────▶ │ 重试(3次/退避) │ ──────────────▶│ 记录补偿表 │  │
│  └─────────┘              └──────────────┘                └────────────┘  │
│     │                            │                              │         │
│     │ 成功                       │ 恢复成功                      │ 人工介入 │
│     ▼                            ▼                              ▼         │
│  ┌─────────┐              ┌──────────────┐                ┌────────────┐  │
│  │ 成功返回 │              │  更新补偿表  │                │ 发送告警   │  │
│  └─────────┘              └──────────────┘                └────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.2 补偿表设计

```sql
-- 库存操作补偿表
CREATE TABLE inv_compensation (
    id           BIGINT PRIMARY KEY AUTO_INCREMENT,
    biz_type     VARCHAR(30)  NOT NULL COMMENT '业务类型（OUTBOUND/INBOUND）',
    biz_id       VARCHAR(64)  NOT NULL COMMENT '业务单据ID',
    inventory_id BIGINT       NOT NULL COMMENT '库存ID',
    delta        INT          NOT NULL COMMENT '变更数量',
    status       VARCHAR(20)  NOT NULL DEFAULT 'PENDING' COMMENT '状态（PENDING/COMPLETED/FAILED）',
    retry_count  INT          NOT NULL DEFAULT 0 COMMENT '重试次数',
    max_retry    INT          NOT NULL DEFAULT 3 COMMENT '最大重试次数',
    error_msg    VARCHAR(500) COMMENT '错误信息',
    gmt_create   DATETIME     NOT NULL,
    gmt_modified DATETIME     NOT NULL,
    INDEX idx_status (status),
    INDEX idx_biz (biz_type, biz_id)
) ENGINE=InnoDB COMMENT='库存操作补偿表';
```

### 7.3 补偿任务

```java
/**
 * 库存补偿任务（XXL-Job，每5分钟执行）
 */
@XxlJob("inventoryCompensationJob")
public ReturnT<String> inventoryCompensation() {
    List<InvCompensation> pendings = compensationMapper.selectPending(3);
    for (InvCompensation comp : pendings) {
        try {
            if ("OUTBOUND".equals(comp.getBizType())) {
                inventoryService.deductStock(comp.getInventoryId(),
                    comp.getDelta(), comp.getUserId());
            } else {
                inventoryService.increaseStock(comp.getInventoryId(),
                    comp.getDelta(), comp.getUserId());
            }
            compensationMapper.updateStatus(comp.getId(), "COMPLETED");
        } catch (Exception e) {
            int retry = comp.getRetryCount() + 1;
            if (retry >= comp.getMaxRetry()) {
                compensationMapper.updateStatus(comp.getId(), "FAILED", e.getMessage());
                alertService.sendCritical("库存补偿失败", comp);
            } else {
                compensationMapper.updateRetry(comp.getId(), retry);
            }
        }
    }
    return ReturnT.SUCCESS;
}
```

---

## 八、监控与告警

### 8.1 监控指标

| 指标 | 阈值 | 告警级别 |
|------|------|---------|
| 库存为负数量 | > 0 | **严重** |
| 乐观锁冲突次数/分钟 | > 50 | 警告 |
| 分布式锁等待时间 | > 3秒 | 警告 |
| 库存扣减耗时 | > 500ms | 警告 |
| 库存对账差异数 | > 0 | **严重** |

### 8.2 关键日志埋点

```java
// 必须记录以下日志
log.info("库存扣减成功, invId={}, delta={}, before={}, after={}, version={}",
         invId, delta, beforeQty, afterQty, newVersion);

log.warn("库存不足, invId={}, required={}, available={}",
         invId, required, available);

log.warn("乐观锁冲突, invId={}, expectedVersion={}, actualVersion={}",
         invId, expected, actual);

log.error("库存操作异常, bizId={}, error={}", bizId, e.getMessage());
```

---

## 九、禁止事项

| 序号 | 禁止项 | 正确做法 |
|---|-----|----|
| 1 | 禁止直接 `UPDATE quantity = #{newValue}` | 必须使用 `quantity +/- delta` |
| 2 | 禁止在 Controller 层开启事务 | 事务边界在 Service 层 |
| 3 | 禁止长事务（> 10秒） | 拆分为同步+异步 |
| 4 | 禁止用仓库级分布式锁 | 必须细化到 物料+批次 粒度 |
| 5 | 禁止忽略库存为负 | 触发告警并立即处理 |
| 6 | 禁止串行化所有库存操作 | 按库位/批次分离锁 |
| 7 | 禁止在事务内调用外部接口 | 使用消息队列异步处理 |
| 8 | 禁止硬编码版本号 | 必须从数据库读取当前版本 |
