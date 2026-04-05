# WMS仓库物流系统 - 状态机流转设计

> 版本：V1.0
> 日期：2026-04-03
> 适用范围：WMS 所有业务单据的状态定义与流转规则
> 核心目标：明确各业务单据的状态枚举、流转路径、触发条件与合法性校验

---

## 一、概述

### 1.1 设计目标

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                            状态机设计体系                                    │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                   │
│  │  状态定义    │    │  流转规则    │    │  合法性校验  │                   │
│  │  统一枚举    │    │  触发条件    │    │  前置检查    │                   │
│  └──────────────┘    └──────────────┘    └──────────────┘                   │
│                                                                              │
│  核心原则：                                                                   │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │ 1. 状态不可逆：已完成的单据不可回退到草稿                                │  │
│  │ 2. 单向流转：禁止跨状态跳跃（如 PENDING → COMPLETED）                   │  │
│  │ 3. 前置校验：每个流转必须校验前置条件                                     │  │
│  │ 4. 原子操作：状态变更必须在同一事务内完成                                 │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 状态分类

| 类别 | 说明 | 示例 |
|------|------|------|
| 草稿 | 初始状态，可编辑 | DRAFT |
| 待处理 | 等待操作 | PENDING, QC_PENDING |
| 进行中 | 操作执行中 | IN_PROGRESS, QC_IN_PROGRESS |
| 已完成 | 最终成功状态 | COMPLETED, QUALIFIED, CONFIRMED |
| 已取消 | 最终失败/终止状态 | CANCELLED, UNQUALIFIED |
| 中间状态 | 可继续流转 | ALLOCATED, PRINTED, PICKED |

### 1.3 通用状态码（参考 docs/06-DICTIONARY/01-status-codes.md）

```
入库单：PENDING / IN_PROGRESS / QC_PENDING / QC_IN_PROGRESS / PARTIAL / COMPLETED / CANCELLED
出库单：PENDING / ALLOCATED / PRINTED / PICKING / PICKED / PACKED / SHIPPED / COMPLETED / CANCELLED
质检单：PENDING / IN_PROGRESS / QUALIFIED / UNQUALIFIED / CONDITIONAL
盘点单：DRAFT / STARTED / IN_PROGRESS / COMPLETED / CONFIRMED / CANCELLED
提货单：PENDING / PREPARING / READY / PICKED / SHIPPED / COMPLETED / CANCELLED
```

---

## 二、入库单状态机

### 2.1 状态定义

| 状态码 | 中文名 | 说明 |
|--------|--------|------|
| DRAFT | 草稿 | 初始状态，可编辑 |
| PENDING | 待入库 | 单据已提交，等待入库 |
| IN_PROGRESS | 入库中 | 入库操作进行中 |
| QC_PENDING | 待质检 | 物料需要质检 |
| QC_IN_PROGRESS | 质检中 | 质检进行中 |
| PARTIAL | 部分入库 | 部分物料已入库 |
| COMPLETED | 已完成 | 入库全部完成 |
| CANCELLED | 已取消 | 入库单已取消 |

### 2.2 状态流转图

```
                              ┌──────────────────────────────────────────┐
                              │                                          │
                              ▼                                          │
┌─────────┐    提交     ┌───────────┐    开始入库     ┌──────────────┐   │
│  DRAFT  │ ──────────▶ │  PENDING  │ ──────────────▶ │ IN_PROGRESS  │   │
└─────────┘             └───────────┘                └──────┬───────┘   │
      │                        │                              │           │
      │ 取消                  │ 物料必检                       │ 完成入库  │
      │                        │                              ▼           │
      │                        ▼                       ┌──────────────┐   │
      │                 ┌─────────────┐                │   PARTIAL    │   │
      │                 │ QC_PENDING  │                └──────┬───────┘   │
      │                 └──────┬──────┘                       │           │
      │                        │                              │           │
      │ 取消                   │ 送检                         │           │
      │                        ▼                              │           │
      │                 ┌──────────────┐                      │           │
      │                 │QC_IN_PROGRESS│                     │           │
      │                 └──────┬───────┘                      │           │
      │                        │                              │           │
      │                        ├──────────────────────────────┤           │
      │                        │                              │           │
      │                        ▼                              ▼           │
      │                 ┌────────────────┐            ┌──────────────┐   │
      │                 │   QUALIFIED    │            │  COMPLETED   │   │
      │                 │   (合格)       │            │              │   │
      │                 └───────┬────────┘            └──────────────┘   │
      │                         │                                        │
      │ 不合格/让步放行         │                                        │
      │                         ▼                                        │
      │                 ┌────────────────┐                              │
      │                 │  CONDITIONAL   │                              │
      │                 │  (条件合格)    │                              │
      │                 └────────────────┘                              │
      │                                                                  │
      │ 取消/驳回                                                      │
      ▼                                                                  │
┌─────────────┐                                                           │
│ CANCELLED  │◀──────────────────────────────────────────────────────────┘
└─────────────┘
```

### 2.3 流转规则详解

| 当前状态 | 目标状态 | 触发操作 | 前置条件 | 后置动作 |
|---------|---------|---------|---------|---------|
| DRAFT | PENDING | 提交 | 所有必填字段已填写 | - |
| DRAFT | CANCELLED | 取消 | 无 | - |
| PENDING | IN_PROGRESS | 开始入库 | 仓库已确认 | - |
| PENDING | QC_PENDING | 送检 | 物料为必检类型 | 冻结库存 |
| PENDING | CANCELLED | 取消 | 单据未被锁定 | 解冻已冻结库存 |
| QC_PENDING | QC_IN_PROGRESS | 开始质检 | 样品已送达 | - |
| QC_IN_PROGRESS | QUALIFIED | 质检通过 | 检验结果合格 | 解冻库存 |
| QC_IN_PROGRESS | UNQUALIFIED | 质检不通过 | 检验结果不合格 | 维持冻结 |
| QC_IN_PROGRESS | CONDITIONAL | 让步放行 | 需审批通过 | 解冻部分库存 |
| IN_PROGRESS | PARTIAL | 部分入库 | 部分物料已入库 | - |
| IN_PROGRESS | COMPLETED | 完成入库 | 所有物料已入库 | 更新库存 |
| PARTIAL | IN_PROGRESS | 继续入库 | 剩余物料可入库 | - |
| PARTIAL | COMPLETED | 完成入库 | 剩余物料已入库 | 更新库存 |

### 2.4 合法性校验

```java
// InboundStateValidator.java
@Component
@Slf4j
public class InboundStateValidator {

    /**
     * 入库单状态流转校验
     */
    public void validateTransition(InboundOrder current, String targetState, String operator) {
        String currentState = current.getStatus();
        
        // 1. 基础校验：是否存在合法流转路径
        if (!isValidTransition(currentState, targetState)) {
            throw new BusinessException("INB003", 
                String.format("入库单状态不允许从 [%s] 流转至 [%s]", currentState, targetState));
        }

        // 2. 前置条件校验
        switch (targetState) {
            case "IN_PROGRESS":
                validateStartInbound(current);
                break;
            case "QC_PENDING":
                validateQcRequired(current);
                break;
            case "COMPLETED":
                validateAllInbounded(current);
                break;
            case "CANCELLED":
                validateCancelable(current);
                break;
        }

        // 3. 权限校验
        validateOperatorPermission(current, targetState, operator);
        
        log.info("入库单状态流转校验通过, orderId={}, {} -> {}, operator={}",
                 current.getId(), currentState, targetState, operator);
    }

    private boolean isValidTransition(String from, String to) {
        Map<String, Set<String>> transitions = Map.of(
            "DRAFT", Set.of("PENDING", "CANCELLED"),
            "PENDING", Set.of("IN_PROGRESS", "QC_PENDING", "CANCELLED"),
            "QC_PENDING", Set.of("QC_IN_PROGRESS", "CANCELLED"),
            "QC_IN_PROGRESS", Set.of("QUALIFIED", "UNQUALIFIED", "CONDITIONAL"),
            "IN_PROGRESS", Set.of("PARTIAL", "COMPLETED"),
            "PARTIAL", Set.of("IN_PROGRESS", "COMPLETED")
        );
        return transitions.getOrDefault(from, Set.of()).contains(to);
    }

    private void validateStartInbound(InboundOrder order) {
        if (StringUtils.isBlank(order.getWarehouseCode())) {
            throw new BusinessException("INB003", "仓库未指定");
        }
        if (CollectionUtils.isEmpty(order.getItems())) {
            throw new BusinessException("INB003", "入库物料不能为空");
        }
    }

    private void validateQcRequired(InboundOrder order) {
        List<InboundItem> qcItems = order.getItems().stream()
            .filter(InboundItem::getIsQcRequired)
            .collect(Collectors.toList());
        if (qcItems.isEmpty()) {
            throw new BusinessException("INB003", "无必检物料，无需送检");
        }
    }

    private void validateAllInbounded(InboundOrder order) {
        boolean allComplete = order.getItems().stream()
            .allMatch(item -> item.getInboundedQuantity() >= item.getPlanQuantity());
        if (!allComplete) {
            throw new BusinessException("INB003", "存在未完成入库的物料");
        }
    }

    private void validateCancelable(InboundOrder order) {
        // 已完成的单据不可取消
        if ("COMPLETED".equals(order.getStatus())) {
            throw new BusinessException("INB005", "已完成入库单不可取消");
        }
        // 有冻结库存的单据需先解冻
        if (order.getFrozenQuantity() > 0) {
            throw new BusinessException("INB003", "存在冻结库存，请先解除冻结");
        }
    }

    private void validateOperatorPermission(InboundOrder order, String targetState, String operator) {
        // 根据目标状态校验操作员权限
        if ("CANCELLED".equals(targetState) && !hasCancelPermission(operator)) {
            throw new BusinessException("SYS006", "无取消入库单权限");
        }
    }
}
```

---

## 三、出库单状态机

### 3.1 状态定义

| 状态码 | 中文名 | 说明 |
|--------|--------|------|
| PENDING | 待出库 | 单据已创建，等待出库 |
| ALLOCATED | 已分配 | 库位已分配 |
| PRINTED | 已打印 | 标签/单据已打印 |
| PICKING | 拣货中 | 拣货操作进行中 |
| PICKED | 已拣货 | 拣货完成 |
| PACKED | 已打包 | 打包完成 |
| SHIPPED | 已发货 | 已交付快递 |
| COMPLETED | 已完成 | 出库全部完成 |
| CANCELLED | 已取消 | 出库单已取消 |

### 3.2 状态流转图

```
┌─────────┐    分配库位     ┌───────────┐    打印      ┌──────────┐    拣货     ┌─────────┐
│ PENDING │ ──────────────▶ │ ALLOCATED │ ───────────▶ │ PRINTED  │ ──────────▶ │ PICKING │
└─────────┘                └───────────┘              └──────────┘             └────┬────┘
     │                          │                          │                      │
     │ 取消                     │ 取消                     │ 取消                 │ 完成拣货
     │                          │                          │                      ▼
     │                          │                          │               ┌─────────┐
     │                          │                          │               │ PICKED  │
     │                          │                          │               └────┬────┘
     │                          │                          │                      │
     │                          │                          │                      │ 打包
     │                          │                          │                      ▼
     │                          │                          │               ┌─────────┐
     │                          │                          │               │ PACKED  │
     │                          │                          │               └────┬────┘
     │                          │                          │                      │
     │                          │                          │                      │ 发货
     │                          │                          │                      ▼
     │                          │                          │               ┌─────────┐
     │                          │                          │               │ SHIPPED │
     │                          │                          │               └────┬────┘
     │                          │                          │                      │
     │                          │                          │                      │ 确认完成
     │                          │                          │                      ▼
     │                          │                          │               ┌─────────┐
     │                          │                          │               │COMPLETED│
     │                          │                          │               └─────────┘
     │                          │                          │
     │◀──────────────────────────┴──────────────────────────┘
     │
     ▼
┌─────────────┐
│ CANCELLED  │
└─────────────┘
```

### 3.3 流转规则详解

| 当前状态 | 目标状态 | 触发操作 | 前置条件 | 后置动作 |
|---------|---------|---------|---------|---------|
| PENDING | ALLOCATED | 分配库位 | 库存可用 | 锁定库位库存 |
| PENDING | CANCELLED | 取消 | 未被锁定 | - |
| ALLOCATED | PRINTED | 打印标签 | 已分配库位 | - |
| ALLOCATED | CANCELLED | 取消 | 未出库 | 解锁库位 |
| PRINTED | PICKING | 开始拣货 | 标签已打印 | - |
| PRINTED | CANCELLED | 取消 | 未拣货 | 解锁库位 |
| PICKING | PICKED | 完成拣货 | 物料已拣完 | 更新拣货数量 |
| PICKED | PACKED | 打包 | 物料已复核 | - |
| PACKED | SHIPPED | 发货 | 打包完成 | 生成物流单号 |
| SHIPPED | COMPLETED | 确认完成 | 物流已签收 | - |

### 3.4 合法性校验

```java
// OutboundStateValidator.java
@Component
@Slf4j
public class OutboundStateValidator {

    /**
     * 出库单状态流转校验
     */
    public void validateTransition(OutboundOrder current, String targetState, String operator) {
        String currentState = current.getStatus();

        // 1. 校验流转路径
        if (!isValidTransition(currentState, targetState)) {
            throw new BusinessException("OUT003",
                String.format("出库单状态不允许从 [%s] 流转至 [%s]", currentState, targetState));
        }

        // 2. 前置条件
        switch (targetState) {
            case "ALLOCATED":
                validateAllocation(current);
                break;
            case "PICKING":
                validatePicking(current);
                break;
            case "COMPLETED":
                validateShipped(current);
                break;
            case "CANCELLED":
                validateCancelable(current);
                break;
        }

        // 3. 库存校验（出库操作）
        if (isDeductInventoryAction(targetState)) {
            validateInventory(current);
        }

        log.info("出库单状态流转校验通过, orderId={}, {} -> {}, operator={}",
                 current.getId(), currentState, targetState, operator);
    }

    private boolean isValidTransition(String from, String to) {
        Map<String, Set<String>> transitions = Map.of(
            "PENDING", Set.of("ALLOCATED", "CANCELLED"),
            "ALLOCATED", Set.of("PRINTED", "CANCELLED"),
            "PRINTED", Set.of("PICKING", "CANCELLED"),
            "PICKING", Set.of("PICKED"),
            "PICKED", Set.of("PACKED"),
            "PACKED", Set.of("SHIPPED"),
            "SHIPPED", Set.of("COMPLETED")
        );
        return transitions.getOrDefault(from, Set.of()).contains(to);
    }

    private boolean isDeductInventoryAction(String targetState) {
        // 只有 SHIPPED 才扣减库存
        return "SHIPPED".equals(targetState);
    }

    private void validateAllocation(OutboundOrder order) {
        // 校验库存是否充足
        for (OutboundItem item : order.getItems()) {
            InvInventory inv = inventoryService.getInventory(
                order.getWarehouseCode(),
                item.getLocationId(),
                item.getMaterialId(),
                item.getBatchId()
            );
            if (inv == null || inv.getAvailableQuantity() < item.getQuantity()) {
                throw new BusinessException("OUT004",
                    String.format("物料[%s]库存不足", item.getMaterialCode()));
            }
        }
    }

    private void validateInventory(OutboundOrder order) {
        // 出库确认前最终校验库存
        for (OutboundItem item : order.getItems()) {
            InvInventory inv = inventoryService.getInventory(item.getInventoryId());
            if (inv.getAvailableQuantity() < item.getQuantity()) {
                throw new BusinessException("INV001",
                    String.format("物料[%s]库存不足，无法出库", item.getMaterialCode()));
            }
        }
    }

    private void validateCancelable(OutboundOrder order) {
        // 已发货的单据不可取消
        if ("SHIPPED".equals(order.getStatus()) || "COMPLETED".equals(order.getStatus())) {
            throw new BusinessException("OUT006", "已出库单据不可取消");
        }
    }
}
```

---

## 四、质检单状态机

### 4.1 状态定义

| 状态码 | 中文名 | 说明 |
|--------|--------|------|
| PENDING | 待质检 | 等待质检 |
| IN_PROGRESS | 质检中 | 质检进行中 |
| QUALIFIED | 合格 | 质检合格 |
| UNQUALIFIED | 不合格 | 质检不合格 |
| CONDITIONAL | 条件合格 | 让步放行，需审批 |

### 4.2 状态流转图

```
┌─────────┐    开始质检     ┌─────────────┐    合格     ┌───────────┐
│ PENDING │ ──────────────▶ │ IN_PROGRESS │ ──────────▶ │ QUALIFIED │
└─────────┘                └──────┬──────┘            └───────────┘
                                    │
                                    │ 不合格              │ 让步放行
                                    ▼                    ▼
                             ┌─────────────┐      ┌─────────────┐
                             │ UNQUALIFIED │      │ CONDITIONAL │
                             └─────────────┘      └──────┬──────┘
                                                          │
                                                    审批通过/驳回
                                                          ▼
                                                    ┌───────────┐
                                                    │  跳转结果  │
                                                    └───────────┘
```

---

## 五、盘点单状态机

### 5.1 状态定义

| 状态码 | 中文名 | 说明 |
|--------|--------|------|
| DRAFT | 草稿 | 盘点单草稿 |
| STARTED | 已启动 | 盘点已启动 |
| IN_PROGRESS | 盘点中 | 盘点进行中 |
| COMPLETED | 已完成 | 盘点已完成 |
| CONFIRMED | 已确认 | 盘点结果已确认 |
| CANCELLED | 已取消 | 盘点已取消 |

### 5.2 状态流转图

```
┌─────────┐    启动盘点     ┌──────────┐    完成      ┌───────────┐   确认     ┌───────────┐
│  DRAFT  │ ──────────────▶ │ STARTED  │ ───────────▶ │ COMPLETED │ ─────────▶ │ CONFIRMED │
└─────────┘                └─────┬────┘              └───────────┘            └───────────┘
                                   │                                               │
                                   │ 终止盘点                                      │
                                   ▼                                               │
                              ┌───────────┐                                      │
                              │ CANCELLED │                                      │
                              └───────────┘                                      │
                                                                                  │
      ◀───────────────────────────────────────────────────────────────────────────┘
                                       差异审批驳回
```

---

## 六、提货单状态机

### 6.1 状态定义

| 状态码 | 中文名 | 说明 |
|--------|--------|------|
| PENDING | 待提货 | 等待提货 |
| PREPARING | 准备中 | 准备出库 |
| READY | 已就绪 | 可提货 |
| PICKED | 已拣货 | 拣货完成 |
| SHIPPED | 已发货 | 已发货 |
| COMPLETED | 已完成 | 提货完成 |
| CANCELLED | 已取消 | 提货取消 |

### 6.2 流转规则

| 当前状态 | 目标状态 | 触发操作 | 前置条件 |
|---------|---------|---------|---------|
| PENDING | PREPARING | 开始备货 | - |
| PENDING | CANCELLED | 取消提货 | 未发货 |
| PREPARING | READY | 备货完成 | 物料已备齐 |
| READY | PICKED | 完成拣货 | 拣货完成 |
| PICKED | SHIPPED | 发货 | - |
| SHIPPED | COMPLETED | 确认签收 | 客户已签收 |

---

## 七、通用状态机框架

### 7.1 状态机配置

```java
// StateMachineConfig.java
@Configuration
public class StateMachineConfig {

    @Bean
    public StateMachineFactory<String, String> stateMachineFactory() {
        // 通用状态机工厂
        return new DefaultStateMachineFactory<>();
    }
}

// BizStateMachine.java - 通用业务状态机
@Component
@Slf4j
public class BizStateMachine {

    /**
     * 执行状态流转
     * @param bizType   业务类型（如 INBOUND, OUTBOUND）
     * @param bizId     业务单据ID
     * @param targetState 目标状态
     * @param operator  操作人
     */
    @Transactional
    public void transition(String bizType, Long bizId, String targetState, String operator) {
        // 1. 获取当前状态
        BaseBizEntity biz = bizRepository.findById(bizId);
        String currentState = biz.getStatus();

        // 2. 校验流转合法性
        stateValidator.validateTransition(bizType, currentState, targetState);

        // 3. 执行前置动作（如冻结库存）
        preActionExecutor.execute(bizType, biz, targetState);

        // 4. 更新状态
        biz.setStatus(targetState);
        biz.setUpdateBy(operator);
        biz.setUpdateTime(LocalDateTime.now());
        bizRepository.save(biz);

        // 5. 记录状态变更日志
        stateChangeLogService.log(bizType, bizId, currentState, targetState, operator);

        // 6. 执行后置动作（如发送MQ）
        postActionExecutor.execute(bizType, biz, targetState);

        log.info("状态流转成功, bizType={}, bizId={}, {} -> {}, operator={}",
                 bizType, bizId, currentState, targetState, operator);
    }
}
```

### 7.2 状态变更日志

```sql
-- 状态变更日志表
CREATE TABLE biz_state_change_log (
    id           BIGINT PRIMARY KEY AUTO_INCREMENT,
    biz_type     VARCHAR(30)  NOT NULL COMMENT '业务类型',
    biz_id       BIGINT       NOT NULL COMMENT '业务单据ID',
    from_state   VARCHAR(30)  COMMENT '原状态',
    to_state     VARCHAR(30)  NOT NULL COMMENT '目标状态',
    operator_id  VARCHAR(64)  COMMENT '操作人ID',
    operator_name VARCHAR(64) COMMENT '操作人',
    change_time  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remark       VARCHAR(500) COMMENT '变更说明',
    INDEX idx_biz (biz_type, biz_id),
    INDEX idx_change_time (change_time)
) ENGINE=InnoDB COMMENT='状态变更日志表';
```

```java
// StateChangeLogService.java
@Service
@RequiredArgsConstructor
@Slf4j
public class StateChangeLogService {

    @Async
    public void log(String bizType, Long bizId, String fromState, 
                    String toState, String operator) {
        StateChangeLog log = StateChangeLog.builder()
            .bizType(bizType)
            .bizId(bizId)
            .fromState(fromState)
            .toState(toState)
            .operator(operator)
            .changeTime(LocalDateTime.now())
            .build();
        logMapper.insert(log);
        
        // 发送状态变更事件（用于MQ通知、审计等）
        eventPublisher.publishEvent(new StateChangeEvent(bizType, bizId, fromState, toState));
    }
}
```

---

## 八、禁止事项

| 序号 | 禁止项 | 正确做法 |
|---|-----|----|
| 1 | 禁止跨状态跳跃 | 必须按状态机定义的路径流转 |
| 2 | 禁止回退已完成状态 | 已完成状态只能取消，不可回退 |
| 3 | 禁止在 Controller 直接修改状态 | 通过状态机统一处理 |
| 4 | 禁止绕过前置条件校验 | 必须执行 validateTransition |
| 5 | 禁止状态变更无日志 | 必须记录 StateChangeLog |
| 6 | 禁止并发修改同一单据 | 使用乐观锁版本号控制 |
| 7 | 禁止事务外变更状态 | 状态变更必须在事务内完成 |
