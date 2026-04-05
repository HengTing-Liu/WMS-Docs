# WMS仓库物流系统 - 任务调度设计

> 版本：V1.0
> 日期：2026-04-03
> 适用范围：WMS 所有定时任务设计
> 技术选型：XXL-Job（分布式任务调度平台）
> 核心目标：规范化任务开发、配置与监控

---

## 一、概述

### 1.1 技术选型

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                            XXL-Job 架构                                      │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│                         ┌─────────────────┐                                  │
│                         │   XXL-Job       │                                  │
│                         │   Admin         │                                  │
│                         │   (调度中心)     │                                  │
│                         └────────┬────────┘                                  │
│                                  │                                            │
│                       ┌──────────┼──────────┐                               │
│                       │          │          │                                │
│                       ▼          ▼          ▼                                │
│                  ┌────────┐ ┌────────┐ ┌────────┐                          │
│                  │ 执行器  │ │ 执行器  │ │ 执行器  │                          │
│                  │(WMS-1) │ │(WMS-2) │ │(WMS-3) │                          │
│                  └────────┘ └────────┘ └────────┘                          │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 XXL-Job 核心优势

| 优势 | 说明 |
|------|------|
| 分布式调度 | 任务分发至多个执行器节点 |
| 任务分片 | 支持大文件/批量任务并行处理 |
| 失败重试 | 失败自动重试，支持配置重试次数 |
| 任务依赖 | 支持任务编排，DAG 依赖 |
| 监控告警 | 实时任务状态监控 |
| 弹性扩容 | 执行器可随时增加/减少 |

---

## 二、任务分类

### 2.1 任务类型

| 类型 | 触发方式 | 说明 | 示例 |
|------|---------|------|------|
| 定时任务 | Cron 表达式 | 按固定周期执行 | 每日库存对账 |
| 异步任务 | 手动触发 | 用户操作触发 | 批量导入 |
| 广播任务 | 触发 | 通知所有执行器 | 配置刷新 |
| 分片任务 | 手动触发 | 并行处理大数据 | 批量导出 |

### 2.2 任务分层

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                            任务分层                                          │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  L1  数据同步任务（低频、高可靠）                                             │
│  ├─ ERP 数据同步（每5分钟）                                                  │
│  ├─ LIMS 数据同步（每5分钟）                                                 │
│  └─ 定时对账（每日）                                                         │
│                                                                              │
│  L2  业务处理任务（中频、定时）                                              │
│  ├─ 库存对账（每日凌晨）                                                     │
│  ├─ 批次效期检查（每日凌晨）                                                 │
│  ├─ 库存预警（每日早8点）                                                    │
│  └─ 补偿任务（每5分钟）                                                      │
│                                                                              │
│  L3  批量处理任务（按需、耗时）                                               │
│  ├─ 批量导入（用户触发）                                                      │
│  ├─ 批量导出（用户触发）                                                      │
│  └─ 报表生成（用户触发）                                                      │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 三、任务清单

### 3.1 库存管理任务

| 任务名 | JobHandler | Cron | 说明 |
|--------|-----------|------|------|
| 库存一致性对账 | `inventoryReconciliationJob` | `0 0 2 * * ?` | 每日凌晨2点对账 |
| 库存补偿 | `inventoryCompensationJob` | `0 0/5 * * * ?` | 每5分钟补偿失败操作 |
| 批次效期检查 | `batchExpireCheckJob` | `0 0 1 * * ?` | 每日凌晨1点检查效期 |
| 冻结库存清理 | `frozenInventoryCleanJob` | `0 0 3 * * ?` | 每日凌晨3点清理异常冻结 |

### 3.2 数据同步任务

| 任务名 | JobHandler | Cron | 说明 |
|--------|-----------|------|------|
| ERP采购入库同步 | `erpInboundSyncJob` | `0 0/5 * * * ?` | 每5分钟同步ERP采购入库 |
| ERP销售出库同步 | `erpOutboundSyncJob` | `0 0/5 * * * ?` | 每5分钟同步ERP销售出库 |
| ERP库存同步 | `erpInventorySyncJob` | `0 0/10 * * * ?` | 每10分钟同步ERP库存 |
| LIMS质检同步 | `limsQcSyncJob` | `0 0/5 * * * ?` | 每5分钟同步LIMS质检结果 |
| 同步失败重试 | `syncFailRetryJob` | `0 0/10 * * * ?` | 每10分钟重试同步失败记录 |

### 3.3 预警通知任务

| 任务名 | JobHandler | Cron | 说明 |
|--------|-----------|------|------|
| 效期预警 | `expireWarningJob` | `0 0 8 * * ?` | 每日早8点提醒效期临近 |
| 库存预警 | `inventoryWarningJob` | `0 0 8 * * ?` | 每日早8点提醒库存不足 |
| 盘点超时预警 | `stocktakeTimeoutJob` | `0 30 9 * * ?` | 每日早9:30提醒盘点超时 |
| 异常告警 | `alertMonitorJob` | `0 0/30 * * * ?` | 每30分钟检查异常并告警 |

### 3.4 数据清理任务

| 任务名 | JobHandler | Cron | 说明 |
|--------|-----------|------|------|
| 操作日志清理 | `operLogCleanJob` | `0 0 4 * * ?` | 每日凌晨4点清理90天前日志 |
| 登录日志清理 | `loginLogCleanJob` | `0 0 4 * * ?` | 每日凌晨4点清理180天前日志 |
| 临时文件清理 | `tempFileCleanJob` | `0 0 5 * * ?` | 每日凌晨5点清理临时文件 |

### 3.5 报表任务

| 任务名 | JobHandler | Cron | 说明 |
|--------|-----------|------|------|
| 库存月报生成 | `inventoryMonthlyReportJob` | `0 0 0 1 * ?` | 每月1号凌晨生成月报 |
| 库存周报生成 | `inventoryWeeklyReportJob` | `0 0 6 ? * MON` | 每周一凌晨6点生成周报 |
| 库位使用率统计 | `locationUsageStatJob` | `0 0 7 * * ?` | 每日早7点统计库位使用率 |

---

## 四、任务开发规范

### 4.1 任务注册

```java
// 方式一：基于 @XxlJob 注解（推荐）
@Component
@Slf4j
public class InventoryJobs {

    @XxlJob("inventoryReconciliationJob")
    public ReturnT<String> inventoryReconciliation() {
        log.info("开始库存一致性对账...");
        
        // 1. 初始化上下文
        XxlJobHelper.log("库存一致性对账任务开始执行");
        
        try {
            // 2. 执行业务逻辑
            doReconciliation();
            
            // 3. 返回成功
            XxlJobHelper.log("库存一致性对账任务执行完成");
            return ReturnT.SUCCESS;
        } catch (Exception e) {
            log.error("库存一致性对账任务执行失败", e);
            XxlJobHelper.log("库存一致性对账任务执行失败: " + e.getMessage());
            return ReturnT.FAIL;
        }
    }

    /**
     * 分片任务示例
     */
    @XxlJob("batchExportJob")
    public ReturnT<String> batchExport() {
        // 获取分片参数
        ShardingUtil.ShardingVO shardingVO = ShardingUtil.getSharding();
        int shardingIndex = shardingVO.getIndex(); // 当前分片序号
        int shardingTotal = shardingVO.getTotal();  //总分片数
        
        log.info("开始分片任务, index={}, total={}", shardingIndex, shardingTotal);
        
        // 按分片处理数据
        List<Long> ids = queryDataByShard(shardingIndex, shardingTotal);
        for (Long id : ids) {
            processData(id);
        }
        
        return ReturnT.SUCCESS;
    }

    /**
     * 任务编排示例（子任务）
     */
    @XxlJob("parentTaskJob")
    public ReturnT<String> parentTask() {
        // 1. 执行父任务
        doParentTask();
        
        // 2. 触发子任务
        int childJobId1 = 1; // 库存报表任务ID
        int childJobId2 = 2; // 库位报表任务ID
        
        XxlJobHelper.trigger(shardingIndex, childJobId1);
        XxlJobHelper.trigger(shardingIndex, childJobId2);
        
        return ReturnT.SUCCESS;
    }
}
```

### 4.2 任务配置

| 配置项 | 说明 | 示例 |
|-------|------|------|
| 任务名称 | 任务唯一标识 | 库存一致性对账 |
| JobHandler | 代码中的处理器名 | inventoryReconciliationJob |
| 任务类型 | BEAN / GLUE | BEAN |
| Cron | Cron 表达式 | `0 0 2 * * ?` |
| 分片数 | 并行执行节点数 | 4 |
| 运行模式 | 阻塞策略 | 单机串行 |
| 超时时间 | 任务最大执行时间 | 3600秒 |
| 失败重试 | 失败重试次数 | 3次 |
| 任务依赖 | 上游任务 | - |
| 告警方式 | 失败告警方式 | 邮件/钉钉 |

### 4.3 阻塞策略

| 策略 | 说明 | 适用场景 |
|------|------|---------|
| 单机串行 | 同一任务串行执行 | 数据对账、补偿任务 |
| 丢弃后续调度 | 新任务替换旧任务 | 状态推送、通知 |
| 覆盖之前调度 | 丢弃并执行新任务 | 报表生成 |
| 阻塞调度 | 队列满了就等待 | 低频重要任务 |

### 4.4 失败重试策略

```java
// 配置：失败重试次数 = 3，间隔 = 1000ms
@XxlJob(value = "syncJob", init = "initHandler", destroy = "destroyHandler")
public ReturnT<String> execute() {
    try {
        // 业务逻辑
        return ReturnT.SUCCESS;
    } catch (Exception e) {
        // 主动记录失败原因
        XxlJobHelper.handleFail("同步失败: " + e.getMessage());
        return ReturnT.FAIL;
    }
}

// 初始化/销毁钩子
public void initHandler() {
    log.info("任务初始化");
}

public void destroyHandler() {
    log.info("任务销毁");
}
```

---

## 五、任务分片设计

### 5.1 分片场景

| 场景 | 数据量 | 分片数 | 预估耗时 |
|------|--------|--------|---------|
| 批量导出 | 10万条 | 4 | 5分钟 |
| 批量导入 | 10万条 | 4 | 10分钟 |
| 库存对账 | 100万条 | 8 | 30分钟 |
| 报表生成 | 100万条 | 4 | 20分钟 |

### 5.2 分片实现

```java
@XxlJob("batchImportJob")
public ReturnT<String> batchImport() {
    // 1. 获取分片参数
    ShardingUtil.ShardingVO sharding = ShardingUtil.getSharding();
    int index = sharding.getIndex(); // 0,1,2,3
    int total = sharding.getTotal(); // 4
    
    log.info("分片任务开始, index={}, total={}", index, total);

    // 2. 查询待处理数据（按分片分配）
    List<ImportTask> tasks = importTaskMapper.selectPending(index, total);
    log.info("分片 {} 分配到 {} 条任务", index, tasks.size());

    // 3. 分片执行
    int success = 0, fail = 0;
    for (ImportTask task : tasks) {
        try {
            processImport(task);
            success++;
        } catch (Exception e) {
            fail++;
            log.error("导入失败, taskId={}", task.getId(), e);
            importTaskMapper.updateStatus(task.getId(), "FAILED", e.getMessage());
        }
    }

    // 4. 汇总结果（仅分片0汇总）
    if (index == 0) {
        summaryImportResult();
    }

    log.info("分片任务完成, index={}, success={}, fail={}", index, success, fail);
    
    // 5. 失败率过高则标记任务失败
    if (fail > 0 && (double) fail / tasks.size() > 0.1) {
        return XxlJobHelper.handleFail("失败率超过10%");
    }
    
    return ReturnT.SUCCESS;
}
```

---

## 六、任务依赖设计

### 6.1 依赖配置

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          任务依赖关系（DAG）                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                           库存日结                                          │
│                         (inventoryDailyJob)                                │
│                                │                                            │
│           ┌───────────────────┼───────────────────┐                       │
│           │                   │                   │                        │
│           ▼                   ▼                   ▼                        │
│   ┌───────────────┐  ┌───────────────┐  ┌───────────────┐                  │
│   │ 库存月报生成  │  │ 库存对账     │  │ 库位使用率   │                  │
│   │ (monthlyJob)  │  │ (reconcileJob)│ │ (usageJob)   │                  │
│   └───────────────┘  └───────────────┘  └───────────────┘                  │
│                                                                             │
│  配置方式：在 XXL-Job Admin 中设置 parentJobId                            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.2 依赖执行

```java
@XxlJob("inventoryDailyJob")
public ReturnT<String> inventoryDaily() {
    // 1. 执行日结
    doDailySettlement();
    
    // 2. 触发下游任务（手动触发方式）
    // 库存月报（月末日执行）
    if (isMonthEnd()) {
        XxlJobHelper.trigger(1, "inventoryMonthlyReportJob");
    }
    
    // 库存对账
    XxlJobHelper.trigger(0, "inventoryReconciliationJob");
    
    // 库位使用率
    XxlJobHelper.trigger(0, "locationUsageStatJob");
    
    return ReturnT.SUCCESS;
}
```

---

## 七、监控与告警

### 7.1 监控指标

| 指标 | 描述 | 告警阈值 |
|------|------|---------|
| 任务执行成功率 | 成功次数/总次数 | < 99% |
| 任务执行耗时 | 任务执行时间 | > 预期耗时 * 2 |
| 任务失败数 | 失败任务数 | > 0 |
| 任务堆积数 | 等待执行任务数 | > 100 |
| 任务超时数 | 超过超时时间任务数 | > 0 |

### 7.2 告警配置

```yaml
# application.yml
xxl:
  job:
    admin:
      addresses: http://xxl-job-admin:8080/xxl-job-admin
    executor:
      appname: wms-center-service
      port: 9999
    accessToken: your-token
    alert:
      emails: ops@company.com
      dingtalk: https://oapi.dingtalk.com/robot/send?access_token=xxx
```

### 7.3 告警实现

```java
@Component
@Slf4j
public class JobAlertService {

    /**
     * 发送告警通知
     */
    public void sendAlert(JobAlert alert) {
        switch (alert.getLevel()) {
            case CRITICAL:
                sendDingTalk(alert);
                sendEmail(alert);
                sendSms(alert);
                break;
            case WARNING:
                sendDingTalk(alert);
                sendEmail(alert);
                break;
            case INFO:
                sendEmail(alert);
                break;
        }
    }
}
```

---

## 八、任务执行日志

### 8.1 日志规范

```java
@XxlJob("exampleJob")
public ReturnT<String> example() {
    // 1. 开始日志
    XxlJobHelper.log("任务开始执行, 参数={}", param);
    log.info("任务开始执行, 参数={}", param);
    
    try {
        // 2. 进度日志（大批量时记录）
        for (int i = 0; i < total; i++) {
            process(i);
            if (i % 1000 == 0) {
                XxlJobHelper.log("进度: {}/{}", i, total);
            }
        }
        
        // 3. 完成日志
        XxlJobHelper.log("任务执行完成, 处理数量={}", total);
        return ReturnT.SUCCESS;
        
    } catch (Exception e) {
        // 4. 失败日志
        XxlJobHelper.handleFail("任务执行失败: " + e.getMessage());
        log.error("任务执行失败", e);
        return ReturnT.FAIL;
    }
}
```

### 8.2 日志查询

| 字段 | 说明 |
|------|------|
| jobId | 任务ID |
| jobGroup | 任务组 |
| executorAddress | 执行器地址 |
| triggerTime | 触发时间 |
| triggerCode | 触发结果码（200=成功） |
| triggerMsg | 触发信息 |
| handleTime | 执行完成时间 |
| handleCode | 执行结果码 |
| handleMsg | 执行信息 |

---

## 九、禁止事项

| 序号 | 禁止项 | 正确做法 |
|---|-----|----|
| 1 | 禁止在任务中执行耗时 > 1小时 | 拆分成分片任务 |
| 2 | 禁止任务间强耦合 | 使用 MQ 异步解耦 |
| 3 | 禁止任务无限重试 | 设置最大重试次数 |
| 4 | 禁止任务无超时配置 | 必须设置超时时间 |
| 5 | 禁止任务无监控告警 | 必须配置失败告警 |
| 6 | 禁止硬编码 Cron | 使用配置中心管理 |
| 7 | 禁止任务内嵌套事务过长 | 拆分为小事务批次处理 |
| 8 | 禁止任务日志写入数据库 | 使用 ELK 或文件日志 |
