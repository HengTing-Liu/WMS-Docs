# WMS 技术标准规范

> 版本：V1.0
> 日期：2026-04-03

---

## 文档索引

| 序号 | 文档 | 说明 | 优先级 |
|-----|------|------|-------|
| 1 | [01-transaction-design.md](01-transaction-design.md) | 库存一致性保障设计 | **P0** |
| 2 | [02-state-machine-design.md](02-state-machine-design.md) | 状态机流转设计 | **P0** |
| 3 | [03-job-scheduler-design.md](03-job-scheduler-design.md) | 任务调度设计 | **P1** |
| 4 | [04-permission-design.md](04-permission-design.md) | 权限设计（功能/数据/字段） | **P0** |
| 5 | [05-elk-log-design.md](05-elk-log-design.md) | ELK 日志埋点规范 | **P1** |
| 6 | [06-idempotent-design.md](06-idempotent-design.md) | 接口幂等设计 | **P0** |

---

## 优先级说明

| 优先级 | 说明 | 文档 |
|-------|------|------|
| **P0** | 核心设计，上线前必须完成 | 库存一致性、状态机、权限、幂等 |
| **P1** | 重要规范，上线后逐步完善 | 任务调度、日志埋点 |

---

## 快速导航

### 库存一致性
- 分层锁策略（乐观锁 → 分布式锁 → 本地锁）
- 死锁预防（锁排序规则、超时设置）
- 补偿机制（失败重试、对账任务）
- 详见：[01-transaction-design.md](01-transaction-design.md)

### 状态机
- 入库单状态流转（DRAFT → PENDING → IN_PROGRESS → COMPLETED）
- 出库单状态流转（PENDING → ALLOCATED → PRINTED → PICKING → SHIPPED）
- 质检单状态流转（PENDING → IN_PROGRESS → QUALIFIED/UNQUALIFIED）
- 详见：[02-state-machine-design.md](02-state-machine-design.md)

### 任务调度
- XXL-Job 任务清单（数据同步、业务处理、批量任务）
- 任务分片、失败重试、任务依赖
- 详见：[03-job-scheduler-design.md](03-job-scheduler-design.md)

### 权限设计
- 功能权限（菜单/按钮权限注解）
- 数据权限（租户/仓库/部门/用户级）
- 字段权限（隐藏/只读/脱敏）
- 详见：[04-permission-design.md](04-permission-design.md)

### 日志规范
- MDC 字段（traceId、tenantId、userId、problemCategory）
- 问题分类（BUSINESS/SYSTEM/SECURITY）
- 敏感数据脱敏
- 详见：[05-elk-log-design.md](05-elk-log-design.md)

### 接口幂等
- Token 机制（前端防重复提交）
- 幂等表（通用幂等方案）
- 外部接口幂等（ERP/LIMS）
- 详见：[06-idempotent-design.md](06-idempotent-design.md)
