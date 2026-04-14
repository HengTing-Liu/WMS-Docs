# WMS仓库物流系统 - 数据库设计规范

> 版本：V1.0
> 日期：2026-04-03
> 适用范围：WMS系统数据库设计

---

## 一、数据库设计原则

### 1.1 命名规范

| 对象 | 命名规范 | 示例 |
|------|----------|------|
| 数据库 | 小写下划线 | wms_center |
| 表 | 小写下划线_复数 | wms_warehouse |
| 主键 | id | id |
| 外键 | xxx_id | warehouse_id |
| 普通索引 | idx_字段 | idx_warehouse_code |
| 唯一索引 | uk_字段 | uk_warehouse_code |
| 租户字段 | tenant_id | tenant_id |
| 逻辑删除 | deleted | deleted |
| 创建时间 | created_at | created_at |
| 更新时间 | updated_at | updated_at |
| 创建人 | created_by | created_by |
| 更新人 | updated_by | updated_by |
| 版本号 | version | version |

### 1.2 表设计规范

```sql
CREATE TABLE wms_warehouse (
    id              BIGINT          NOT NULL    AUTO_INCREMENT  COMMENT '主键',
    tenant_id       VARCHAR(64)     NOT NULL                    COMMENT '租户ID',
    warehouse_code   VARCHAR(50)    NOT NULL                    COMMENT '仓库编码',
    warehouse_name   VARCHAR(100)   NOT NULL                    COMMENT '仓库名称',
    warehouse_type   VARCHAR(20)     NULL                        COMMENT '仓库类型',
    company         VARCHAR(100)    NULL                        COMMENT '所属公司',
    temperature_zone VARCHAR(20)    NULL                        COMMENT '温区',
    quality_zone    VARCHAR(20)     NULL                        COMMENT '质检分区',
    manager_id      BIGINT          NULL                        COMMENT '负责人ID',
    manager_name    VARCHAR(50)     NULL                        COMMENT '负责人',
    is_enabled      TINYINT         NOT NULL    DEFAULT 1       COMMENT '状态(1启用/0停用)',
    remark          VARCHAR(500)    NULL                        COMMENT '备注',
    version         BIGINT          NOT NULL    DEFAULT 0       COMMENT '版本号',
    deleted         TINYINT         NOT NULL    DEFAULT 0       COMMENT '逻辑删除',
    created_by      VARCHAR(64)     NULL                        COMMENT '创建人',
    created_at      DATETIME        NOT NULL                    COMMENT '创建时间',
    updated_by      VARCHAR(64)     NULL                        COMMENT '更新人',
    updated_at      DATETIME        NULL                        COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_warehouse_code (warehouse_code),
    KEY idx_tenant_id (tenant_id),
    KEY idx_is_enabled (is_enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仓库表';
```

---

## 二、核心业务表

### 2.1 仓库管理

#### 2.1.1 仓库表 (wms_warehouse)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO | 主键 |
| tenant_id | VARCHAR(64) | NOT NULL | 租户ID |
| warehouse_code | VARCHAR(50) | NOT NULL, UK | 仓库编码 |
| warehouse_name | VARCHAR(100) | NOT NULL | 仓库名称 |
| warehouse_type | VARCHAR(20) | - | 仓库类型 |
| company | VARCHAR(100) | - | 所属公司 |
| temperature_zone | VARCHAR(20) | - | 温区 |
| quality_zone | VARCHAR(20) | - | 质检分区 |
| manager_id | BIGINT | - | 负责人ID |
| manager_name | VARCHAR(50) | - | 负责人 |
| is_enabled | TINYINT | DEFAULT 1 | 状态 |
| remark | VARCHAR(500) | - | 备注 |
| version | BIGINT | DEFAULT 0 | 版本号 |
| deleted | TINYINT | DEFAULT 0 | 逻辑删除 |
| created_by | VARCHAR(64) | - | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_by | VARCHAR(64) | - | 更新人 |
| updated_at | DATETIME | - | 更新时间 |

#### 2.1.2 库位表 (wms_location)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO | 主键 |
| tenant_id | VARCHAR(64) | NOT NULL | 租户ID |
| warehouse_id | BIGINT | NOT NULL, FK | 所属仓库 |
| parent_id | BIGINT | - | 上级库位ID |
| location_code | VARCHAR(50) | NOT NULL, UK | 库位编码 |
| location_name | VARCHAR(100) | NOT NULL | 库位名称 |
| location_type | VARCHAR(20) | NOT NULL | 库位类型 |
| location_level | INT | NOT NULL | 库位层级 |
| capacity | INT | - | 存储容量 |
| occupied_quantity | DECIMAL(18,4) | DEFAULT 0 | 已占用数量 |
| is_enabled | TINYINT | DEFAULT 1 | 状态 |
| storage_mode | VARCHAR(20) | - | 存储模式 |
| spec_row | INT | - | 规格-行 |
| spec_col | INT | - | 规格-列 |
| version | BIGINT | DEFAULT 0 | 版本号 |
| deleted | TINYINT | DEFAULT 0 | 逻辑删除 |
| created_by | VARCHAR(64) | - | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_by | VARCHAR(64) | - | 更新人 |
| updated_at | DATETIME | - | 更新时间 |

#### 2.1.3 库位层级说明

| 层级 | 类型 | location_type | 示例 |
|------|------|---------------|------|
| 1 | 存储类型 | STORAGE_TYPE | 冰箱/货架/地堆/托盘 |
| 2 | 存储分区 | STORAGE_ZONE | 层/架/行/列/格 |
| 3 | 存储容器 | STORAGE_CONTAINER | 盒/箱/笼/抽/屉 |
| 4 | 存储孔位 | STORAGE_HOLE | A01, A02, B01, B02 |

### 2.2 物料管理

#### 2.2.1 物料表 (sys_material)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO | 主键 |
| material_code | VARCHAR(50) | NOT NULL, UK | 物料编码 |
| material_name | VARCHAR(200) | NOT NULL | 物料名称 |
| spec | VARCHAR(200) | - | 规格型号 |
| unit | VARCHAR(20) | - | 单位 |
| category | VARCHAR(100) | - | 物料类别 |
| status | INT | DEFAULT 1 | 状态：0-禁用 1-启用 |
| is_deleted | TINYINT | DEFAULT 0 | 逻辑删除 |
| create_by | VARCHAR(64) | - | 创建人 |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_by | VARCHAR(64) | - | 更新人 |
| update_time | DATETIME | NOT NULL | 更新时间 |
| material_en_name | VARCHAR(200) | - | 物料英文名称 |
| export_name | VARCHAR(200) | - | 出口名称 |
| brand | VARCHAR(100) | - | 品牌 |
| item_no | VARCHAR(50) | - | 货号 |
| package_spec | VARCHAR(100) | - | 包装规格 |
| storage_condition | VARCHAR(200) | - | 存储条件 |
| transport_condition | VARCHAR(200) | - | 运输条件 |
| length | DECIMAL(10,2) | - | 长(cm) |
| width | DECIMAL(10,2) | - | 宽(cm) |
| height | DECIMAL(10,2) | - | 高(cm) |
| logistics_package | VARCHAR(100) | - | 物流包装 |
| box_model | VARCHAR(100) | - | 箱型号 |
| outer_package | VARCHAR(100) | - | 产品外包装 |
| require_qc | TINYINT | DEFAULT 0 | 是否必检 |
| supplier_brand | VARCHAR(100) | - | 供应商品牌 |
| supplier_item_no | VARCHAR(50) | - | 供应商货号 |
| supplier_spec | VARCHAR(200) | - | 供应商规格 |
| erp_sync_remark | VARCHAR(500) | - | ERP同步备注 |
| remark | VARCHAR(500) | - | 备注 |

#### 2.2.2 物料批次表 (wms_batch)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO | 主键 |
| tenant_id | VARCHAR(64) | NOT NULL | 租户ID |
| material_id | BIGINT | NOT NULL, FK | 物料ID |
| batch_no | VARCHAR(50) | NOT NULL, UK | 批次号 |
| supplier_batch_no | VARCHAR(50) | - | 供应商批号 |
| purify_no | VARCHAR(50) | - | 纯化编号 |
| clone_no | VARCHAR(50) | - | 克隆号 |
| concentration | DECIMAL(18,6) | - | 浓度 |
| production_date | DATE | - | 生产日期 |
| expiry_date | DATE | - | 失效日期 |
| qc_status | VARCHAR(20) | DEFAULT 'PENDING' | 质检状态 |
| udi_pi | VARCHAR(100) | - | UDI-PI编码 |
| version | BIGINT | DEFAULT 0 | 版本号 |
| deleted | TINYINT | DEFAULT 0 | 逻辑删除 |
| created_by | VARCHAR(64) | - | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_by | VARCHAR(64) | - | 更新人 |
| updated_at | DATETIME | - | 更新时间 |

### 2.3 库存管理

#### 2.3.1 库存表 (wms_inventory)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO | 主键 |
| tenant_id | VARCHAR(64) | NOT NULL | 租户ID |
| warehouse_id | BIGINT | NOT NULL, FK | 仓库ID |
| location_id | BIGINT | NOT NULL, FK | 库位ID |
| material_id | BIGINT | NOT NULL, FK | 物料ID |
| batch_id | BIGINT | NOT NULL, FK | 批次ID |
| quantity | DECIMAL(18,4) | NOT NULL, DEFAULT 0 | 库存数量 |
| available_quantity | DECIMAL(18,4) | NOT NULL, DEFAULT 0 | 可用数量 |
| locked_quantity | DECIMAL(18,4) | NOT NULL, DEFAULT 0 | 锁定数量 |
| version | BIGINT | DEFAULT 0 | 版本号 |
| deleted | TINYINT | DEFAULT 0 | 逻辑删除 |
| created_by | VARCHAR(64) | - | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_by | VARCHAR(64) | - | 更新人 |
| updated_at | DATETIME | - | 更新时间 |

**唯一索引**: (warehouse_id, location_id, material_id, batch_id)

#### 2.3.2 库存流水表 (wms_inventory_flow)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO | 主键 |
| tenant_id | VARCHAR(64) | NOT NULL | 租户ID |
| flow_no | VARCHAR(50) | NOT NULL, UK | 流水号 |
| flow_type | VARCHAR(20) | NOT NULL | 变更类型 |
| business_type | VARCHAR(20) | NOT NULL | 业务类型 |
| business_no | VARCHAR(50) | - | 业务单号 |
| warehouse_id | BIGINT | NOT NULL, FK | 仓库ID |
| location_id | BIGINT | NOT NULL, FK | 库位ID |
| material_id | BIGINT | NOT NULL, FK | 物料ID |
| batch_id | BIGINT | NOT NULL, FK | 批次ID |
| change_quantity | DECIMAL(18,4) | NOT NULL | 变更数量 |
| before_quantity | DECIMAL(18,4) | NOT NULL | 变更前数量 |
| after_quantity | DECIMAL(18,4) | NOT NULL | 变更后数量 |
| remark | VARCHAR(500) | - | 备注 |
| created_by | VARCHAR(64) | - | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |

### 2.4 业务单据

#### 2.4.1 入库单表头 (wms_inbound_order)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO | 主键 |
| tenant_id | VARCHAR(64) | NOT NULL | 租户ID |
| inbound_no | VARCHAR(50) | NOT NULL, UK | 入库单号 |
| inbound_type | VARCHAR(20) | NOT NULL | 入库类型 |
| warehouse_id | BIGINT | NOT NULL, FK | 仓库ID |
| source_type | VARCHAR(20) | - | 来源类型 |
| source_no | VARCHAR(50) | - | 来源单号 |
| inbound_date | DATE | - | 预计入库日期 |
| status | VARCHAR(20) | NOT NULL | 状态 |
| total_quantity | DECIMAL(18,4) | DEFAULT 0 | 总数量 |
| confirmed_quantity | DECIMAL(18,4) | DEFAULT 0 | 已确认数量 |
| qc_required | TINYINT | DEFAULT 0 | 需质检 |
| remark | VARCHAR(500) | - | 备注 |
| version | BIGINT | DEFAULT 0 | 版本号 |
| deleted | TINYINT | DEFAULT 0 | 逻辑删除 |
| created_by | VARCHAR(64) | - | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_by | VARCHAR(64) | - | 更新人 |
| updated_at | DATETIME | - | 更新时间 |

#### 2.4.2 入库单明细 (wms_inbound_order_item)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO | 主键 |
| tenant_id | VARCHAR(64) | NOT NULL | 租户ID |
| inbound_order_id | BIGINT | NOT NULL, FK | 入库单ID |
| material_id | BIGINT | NOT NULL, FK | 物料ID |
| batch_no | VARCHAR(50) | - | 批次号 |
| material_name | VARCHAR(200) | - | 物料名称 |
| spec | VARCHAR(100) | - | 规格 |
| unit | VARCHAR(20) | - | 单位 |
| expected_quantity | DECIMAL(18,4) | NOT NULL | 预计数量 |
| actual_quantity | DECIMAL(18,4) | DEFAULT 0 | 实际数量 |
| confirmed_quantity | DECIMAL(18,4) | DEFAULT 0 | 已确认数量 |
| location_id | BIGINT | - | 分配库位 |
| qc_status | VARCHAR(20) | - | 质检状态 |
| version | BIGINT | DEFAULT 0 | 版本号 |
| deleted | TINYINT | DEFAULT 0 | 逻辑删除 |
| created_by | VARCHAR(64) | - | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_by | VARCHAR(64) | - | 更新人 |
| updated_at | DATETIME | - | 更新时间 |

---

## 三、系统管理表

### 3.1 用户表 (sys_user)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO | 主键 |
| tenant_id | VARCHAR(64) | NOT NULL | 租户ID |
| username | VARCHAR(50) | NOT NULL, UK | 用户名 |
| password | VARCHAR(200) | NOT NULL | 密码 |
| nickname | VARCHAR(50) | - | 昵称 |
| email | VARCHAR(100) | - | 邮箱 |
| mobile | VARCHAR(20) | - | 手机号 |
| avatar | VARCHAR(500) | - | 头像 |
| dept_id | BIGINT | - | 部门ID |
| is_enabled | TINYINT | DEFAULT 1 | 状态 |
| login_attempts | INT | DEFAULT 0 | 登录尝试 |
| locked_until | DATETIME | - | 锁定截止时间 |
| version | BIGINT | DEFAULT 0 | 版本号 |
| deleted | TINYINT | DEFAULT 0 | 逻辑删除 |
| created_by | VARCHAR(64) | - | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_by | VARCHAR(64) | - | 更新人 |
| updated_at | DATETIME | - | 更新时间 |

### 3.2 角色表 (sys_role)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO | 主键 |
| tenant_id | VARCHAR(64) | NOT NULL | 租户ID |
| role_code | VARCHAR(50) | NOT NULL, UK | 角色编码 |
| role_name | VARCHAR(100) | NOT NULL | 角色名称 |
| role_type | VARCHAR(20) | - | 角色类型 |
| data_scope | VARCHAR(20) | DEFAULT 'SELF' | 数据权限 |
| is_enabled | TINYINT | DEFAULT 1 | 状态 |
| remark | VARCHAR(500) | - | 备注 |
| version | BIGINT | DEFAULT 0 | 版本号 |
| deleted | TINYINT | DEFAULT 0 | 逻辑删除 |
| created_by | VARCHAR(64) | - | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_by | VARCHAR(64) | - | 更新人 |
| updated_at | DATETIME | - | 更新时间 |

### 3.3 菜单表 (sys_menu)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO | 主键 |
| parent_id | BIGINT | DEFAULT 0 | 父菜单ID |
| menu_code | VARCHAR(50) | NOT NULL, UK | 菜单编码 |
| menu_name | VARCHAR(100) | NOT NULL | 菜单名称 |
| menu_type | VARCHAR(20) | NOT NULL | 菜单类型 |
| path | VARCHAR(200) | - | 路由路径 |
| component | VARCHAR(200) | - | 组件路径 |
| icon | VARCHAR(100) | - | 图标 |
| order_num | INT | DEFAULT 0 | 显示顺序 |
| is_visible | TINYINT | DEFAULT 1 | 是否显示 |
| is_cached | TINYINT | DEFAULT 0 | 是否缓存 |
| permission | VARCHAR(100) | - | 权限标识 |
| version | BIGINT | DEFAULT 0 | 版本号 |
| deleted | TINYINT | DEFAULT 0 | 逻辑删除 |
| created_by | VARCHAR(64) | - | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_by | VARCHAR(64) | - | 更新人 |
| updated_at | DATETIME | - | 更新时间 |

### 3.4 用户角色关联表 (sys_user_role)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO | 主键 |
| user_id | BIGINT | NOT NULL | 用户ID |
| role_id | BIGINT | NOT NULL | 角色ID |
| created_by | VARCHAR(64) | - | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |

### 3.5 角色菜单关联表 (sys_role_menu)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO | 主键 |
| role_id | BIGINT | NOT NULL | 角色ID |
| menu_id | BIGINT | NOT NULL | 菜单ID |
| created_by | VARCHAR(64) | - | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |

---

## 四、低代码配置表

### 4.1 表元数据 (sys_table_meta)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO | 主键 |
| table_code | VARCHAR(50) | NOT NULL, UK | 表编码 |
| table_name | VARCHAR(100) | NOT NULL | 表名称 |
| table_desc | VARCHAR(500) | - | 表描述 |
| module | VARCHAR(50) | - | 所属模块 |
| crud_prefix | VARCHAR(100) | - | CRUD接口前缀 |
| is_enabled | TINYINT | DEFAULT 1 | 状态 |
| created_by | VARCHAR(64) | - | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_by | VARCHAR(64) | - | 更新人 |
| updated_at | DATETIME | - | 更新时间 |

### 4.2 字段元数据 (sys_column_meta)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO | 主键 |
| table_id | BIGINT | NOT NULL, FK | 表ID |
| column_code | VARCHAR(50) | NOT NULL | 字段编码 |
| column_name | VARCHAR(100) | NOT NULL | 字段名称 |
| field_type | VARCHAR(20) | NOT NULL | 字段类型 |
| data_type | VARCHAR(20) | - | 数据类型 |
| dict_type | VARCHAR(50) | - | 字典类型 |
| is_required | TINYINT | DEFAULT 0 | 是否必填 |
| is_unique | TINYINT | DEFAULT 0 | 是否唯一 |
| is_show_in_list | TINYINT | DEFAULT 1 | 列表显示 |
| is_show_in_form | TINYINT | DEFAULT 1 | 表单显示 |
| is_sortable | TINYINT | DEFAULT 0 | 是否可排序 |
| list_width | INT | DEFAULT 120 | 列表宽度 |
| form_col_span | INT | DEFAULT 1 | 表单列宽 |
| default_value | VARCHAR(100) | - | 默认值 |
| placeholder | VARCHAR(100) | - | 占位符 |
| valid_rules | VARCHAR(500) | - | 校验规则 |
| sort_order | INT | DEFAULT 0 | 排序 |
| is_enabled | TINYINT | DEFAULT 1 | 状态 |
| created_by | VARCHAR(64) | - | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_by | VARCHAR(64) | - | 更新人 |
| updated_at | DATETIME | - | 更新时间 |

### 4.3 操作元数据 (sys_table_operation)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO | 主键 |
| table_id | BIGINT | NOT NULL, FK | 表ID |
| operation_code | VARCHAR(50) | NOT NULL | 操作编码 |
| operation_name | VARCHAR(50) | NOT NULL | 操作名称 |
| button_type | VARCHAR(20) | - | 按钮类型 |
| icon | VARCHAR(50) | - | 图标 |
| permission | VARCHAR(100) | - | 权限标识 |
| position | VARCHAR(20) | - | 位置 |
| operation_type | VARCHAR(20) | - | 操作类型 |
| confirm_message | VARCHAR(200) | - | 确认提示 |
| sort_order | INT | DEFAULT 0 | 排序 |
| is_enabled | TINYINT | DEFAULT 1 | 状态 |
| created_by | VARCHAR(64) | - | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_by | VARCHAR(64) | - | 更新人 |
| updated_at | DATETIME | - | 更新时间 |

---

## 五、索引设计规范

### 5.1 索引命名

| 索引类型 | 命名规范 | 示例 |
|----------|----------|------|
| 主键索引 | pk_表名_字段 | pk_warehouse_id |
| 唯一索引 | uk_表名_字段 | uk_warehouse_code |
| 普通索引 | idx_表名_字段 | idx_warehouse_tenant |

### 5.2 索引设计原则

1. **高频查询字段必须建索引**
2. **区分度低的字段不建索引**
3. **联合索引遵循最左前缀原则**
4. **避免在索引列上使用函数**
5. **定期分析慢查询日志优化索引**

### 5.3 常用索引示例

```sql
-- 仓库表常用查询索引
KEY idx_warehouse_tenant_enabled (tenant_id, is_enabled)
KEY idx_warehouse_type (warehouse_type)
KEY idx_warehouse_created (created_at)

-- 库位表层级查询索引
KEY idx_location_warehouse (warehouse_id)
KEY idx_location_parent (parent_id)
KEY idx_location_warehouse_parent (warehouse_id, parent_id)
KEY idx_location_code (location_code)

-- 库存表查询索引
KEY idx_inventory_warehouse (warehouse_id)
KEY idx_inventory_location (location_id)
KEY idx_inventory_material (material_id)
KEY idx_inventory_batch (batch_id)
KEY idx_inventory_warehouse_material (warehouse_id, material_id)
KEY idx_inventory_warehouse_material_batch (warehouse_id, material_id, batch_id)

-- 单据表查询索引
KEY idx_order_tenant_status (tenant_id, status)
KEY idx_order_no (inbound_no)
KEY idx_order_source (source_type, source_no)
KEY idx_order_date (inbound_date)
KEY idx_order_created (created_at)
```

---

## 六、SQL开发规范

### 6.1 禁止事项

```sql
-- ❌ 禁止 SELECT *
SELECT * FROM wms_warehouse;

-- ✅ 正确做法：指定字段列表
SELECT id, warehouse_code, warehouse_name, is_enabled
FROM wms_warehouse;

-- ❌ 禁止字符串拼接
WHERE warehouse_code = '" + code + "'";

-- ✅ 正确做法：使用参数绑定
WHERE warehouse_code = #{warehouseCode};

-- ❌ 禁止在索引列上使用函数
WHERE DATE(created_at) = '2024-01-01';

-- ✅ 正确做法：范围查询
WHERE created_at >= '2024-01-01 00:00:00'
  AND created_at < '2024-01-02 00:00:00';
```

### 6.2 分页查询

```sql
-- ✅ 正确分页（使用ID偏移）
SELECT id, warehouse_code, warehouse_name
FROM wms_warehouse
WHERE tenant_id = #{tenantId}
ORDER BY id
LIMIT 20 OFFSET 0;

-- ✅ 优化分页（深度分页使用游标）
SELECT id, warehouse_code, warehouse_name
FROM wms_warehouse
WHERE tenant_id = #{tenantId}
  AND id > #{lastId}
ORDER BY id
LIMIT 20;
```
