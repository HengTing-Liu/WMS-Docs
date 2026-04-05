# WMS 仓库物流系统 - 文档中心

> 版本：V1.0
> 日期：2026-04-03
> 维护人：WMS 开发团队

---

## 一、文档目录

```
docs/
│
├── 01-OVERVIEW/                    # 系统总览
│   ├── README.md                   # 文档索引（本文件）
│   ├── SYSTEM-ARCHITECTURE.md      # 系统架构文档
│   └── WMS-PRD-FULL.md            # WMS完整产品需求文档
│
├── 02-FUNCTIONAL/                  # 功能需求
│   ├── 01-basic-archive.md         # 基础档案（仓库/库位/物料）
│   ├── 02-inventory-query.md      # 库存查询
│   ├── 03-inbound.md              # 入库操作
│   ├── 04-outbound.md             # 出库操作
│   ├── 05-inventory-adjust.md     # 库存调整
│   ├── 06-quality-control.md     # 质量控制
│   ├── 07-pick-order.md          # 提货单管理
│   ├── 08-outbound-order.md      # 出库单管理
│   ├── 09-transit-warehouse.md   # 中转仓管理
│   ├── 10-foreign-trade.md        # 外贸发货
│   ├── 11-delivery.md            # 运单配送
│   └── 12-system-mgmt.md         # 系统管理
│
├── 03-NON-FUNCTIONAL/             # 非功能需求
│   ├── 01-performance.md         # 性能需求
│   ├── 02-security.md             # 安全需求
│   ├── 03-compatibility.md       # 兼容性需求
│   ├── 04-data-quality.md         # 数据质量需求
│   ├── 05-maintainability.md      # 可维护性需求
│   └── 06-interface-req.md        # 系统集成需求
│
├── 04-DESIGN/                     # 技术设计文档
│   ├── 01-api-spec.md            # API接口规范
│   ├── 02-database-design.md     # 数据库设计
│   ├── 03-lowcode-design.md      # 低代码架构设计
│   ├── 04-integration-design.md  # 外部系统集成设计
│   └── 05-workflow-design.md     # 业务流程设计
│
├── 05-DEV-GUIDE/                  # 开发指南
│   ├── 01-backend-dev-guide.md   # 后端开发规范
│   ├── 02-frontend-dev-guide.md  # 前端开发规范
│   └── 03-page-impl-guide.md     # 页面开发指南
│
├── 06-DICTIONARY/                 # 数据字典
│   ├── 01-status-codes.md        # 状态码定义
│   └── 02-dict-types.md         # 字典类型定义
│
└── 07-INTERFACE/                  # 接口文档
    ├── 01-erp-interface.md       # ERP系统接口
    └── 02-lims-interface.md      # LIMS系统接口
```

---

## 二、文档版本历史

| 版本 | 日期 | 变更内容 | 维护人 |
|------|------|----------|--------|
| V1.0 | 2026-04-03 | 初始版本，建立文档结构 | WMS开发团队 |

---

## 三、快速链接

### 产品需求
- [WMS完整PRD](./01-OVERVIEW/WMS-PRD-FULL.md) - 完整产品需求文档
- [系统架构](./01-OVERVIEW/SYSTEM-ARCHITECTURE.md) - 系统架构总览

### 功能模块
- [基础档案](./02-FUNCTIONAL/01-basic-archive.md) - 仓库、库位、物料管理
- [库存查询](./02-FUNCTIONAL/02-inventory-query.md) - 物料/库位/流水/二维码
- [入库操作](./02-FUNCTIONAL/03-inbound.md) - 生产/采购/调拨入库
- [出库操作](./02-FUNCTIONAL/04-outbound.md) - 销售/调拨/领用出库
- [库存调整](./02-FUNCTIONAL/05-inventory-adjust.md) - 盘点/报废/库位调整
- [质量控制](./02-FUNCTIONAL/06-quality-control.md) - 质检标准/放行

### 技术设计
- [API规范](./04-DESIGN/01-api-spec.md) - RESTful API设计规范
- [数据库设计](./04-DESIGN/02-database-design.md) - 表结构设计
- [低代码设计](./04-DESIGN/03-lowcode-design.md) - 低代码架构方案

### 开发指南
- [后端开发](./05-DEV-GUIDE/01-backend-dev-guide.md) - Java后端开发规范
- [前端开发](./05-DEV-GUIDE/02-frontend-dev-guide.md) - Vue3前端开发规范
- [页面开发](./05-DEV-GUIDE/03-page-impl-guide.md) - 低代码页面开发指南

---

## 四、相关资源

- **需求文档**: `docs/WMS需求说明书 20260331 完成3.1-3.6.md`
- **后端代码**: `WMS-backend/`
- **前端代码**: `WMS-frontend/`
- **低代码配置**: `WMS-backend/wms-center-web/` (sys_table_meta, sys_column_meta)
