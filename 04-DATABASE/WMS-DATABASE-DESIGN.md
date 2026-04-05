# WMS仓库物流系统 - 数据库设计文档

> 版本：V1.0
> 日期：2026-04-03
> 状态：整理中

---

## 一、概述

本文档汇总了WMS仓库物流系统的完整数据库设计，包含：
1. **现有数据库表** - 后端代码中已实现的表结构
2. **需求规划表** - 需求说明书中规划但尚未实现的表

---

## 二、现有数据库表（已实现）

### 2.1 系统设置模块 (sys_ / wms_ 前缀)

#### 2.1.1 用户权限相关表

| 序号 | 表名 | 说明 | 实体类 |
|-----|------|------|--------|
| 1 | **sys_user** | 用户信息表 | SysUser.java |
| 2 | **sys_role** | 角色表 | SysRole.java |
| 3 | **sys_menu** | 菜单权限表 | SysMenu.java |
| 4 | **sys_dept** | 部门表 | SysDept.java |
| 5 | **sys_user_role** | 用户角色关联表 | SysUserRole.java |
| 6 | **sys_role_menu** | 角色菜单关联表 | SysRoleMenu.java |
| 7 | **sys_role_dept** | 角色部门关联表 | SysRoleDept.java |
| 8 | **sys_user_post** | 用户岗位关联表 | SysUserPost.java |
| 9 | **sys_post** | 岗位表 | SysPost.java |
| 10 | **sys_user_warehouse** | 用户仓库权限表 | SysUserWarehouse.java |
| 11 | **sys_role_warehouse** | 角色仓库权限表 | SysRoleWarehouse.java |

#### 2.1.2 系统配置表

| 序号 | 表名 | 说明 | 实体类 |
|-----|------|------|--------|
| 12 | **sys_dict_type** | 字典类型表 | SysDictType.java |
| 13 | **sys_dict_data** | 字典数据表 | SysDictData.java |
| 14 | **sys_config** | 参数配置表 | SysConfig.java |
| 15 | **sys_oper_log** | 操作日志表 | SysOperLog.java |
| 16 | **sys_logininfor** | 登录日志表 | SysLogininfor.java |
| 17 | **sys_file** | 文件表 | SysFile.java |
| 18 | **sys_notice** | 通知公告表 | SysNotice.java |
| 19 | **sys_serial_number** | 流水号规则表 | SysSerialNumber.java |

#### 2.1.3 枚举管理表

| 序号 | 表名 | 说明 | 实体类 |
|-----|------|------|--------|
| 20 | **sys_enum_define** | 枚举定义表 | SysEnumDefine.java |
| 21 | **sys_enum_item** | 枚举明细表 | SysEnumItem.java |

#### 2.1.4 数据权限表

| 序号 | 表名 | 说明 |
|-----|------|------|
| 22 | **user_data_permission** | 用户数据权限表 |
| 23 | **role_data_permission** | 角色数据权限表 |
| 24 | **dept_data_permission** | 部门数据权限表 |
| 25 | **company_data_permission** | 公司数据权限表 |
| 26 | **sys_data_permission_field** | 数据权限字段表 |
| 27 | **permission_rule_log** | 权限规则日志表 |

---

### 2.2 WMS业务表 (wms_ / inv_ / sys_warehouse 前缀)

#### 2.2.1 基础档案表

| 序号 | 表名 | 说明 | 实体类 |
|-----|------|------|--------|
| 28 | **sys_warehouse** | 仓库档案表 | Warehouse.java |
| 29 | **sys_warehouse_receiver** | 仓库收货人表 | WarehouseReceiver.java |
| 30 | **wms_location** | 库位档案表 | WmsLocation.java |
| 31 | **material** | 物料档案表 | Material.java |
| 32 | **inv_qrcode** | 二维码表 | QrCodeEntity.java |

---

## 三、现有表详细结构

### 3.1 sys_user（用户表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| user_id | BIGINT | 用户ID（主键） |
| dept_id | BIGINT | 部门ID |
| user_name | VARCHAR(30) | 用户账号 |
| nick_name | VARCHAR(30) | 用户昵称 |
| email | VARCHAR(50) | 用户邮箱 |
| phonenumber | VARCHAR(11) | 手机号码 |
| sex | CHAR(1) | 用户性别 |
| avatar | VARCHAR(100) | 用户头像 |
| password | VARCHAR(100) | 密码 |
| status | CHAR(1) | 账号状态（0正常 1停用） |
| del_flag | CHAR(1) | 删除标志（0存在 2删除） |
| login_ip | VARCHAR(128) | 最后登录IP |
| login_date | DATETIME | 最后登录时间 |
| pwd_update_date | DATETIME | 密码最后更新时间 |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

---

### 3.2 sys_role（角色表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| role_id | BIGINT | 角色ID（主键） |
| role_name | VARCHAR(30) | 角色名称 |
| role_key | VARCHAR(100) | 角色权限字符串 |
| role_sort | INT | 显示顺序 |
| data_scope | CHAR(1) | 数据范围 |
| menu_check_strictly | TINYINT(1) | 菜单树选择关联 |
| dept_check_strictly | TINYINT(1) | 部门树选择关联 |
| status | CHAR(1) | 角色状态（0正常 1停用） |
| del_flag | CHAR(1) | 删除标志（0存在 2删除） |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

---

### 3.3 sys_menu（菜单权限表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| menu_id | BIGINT | 菜单ID（主键） |
| menu_name | VARCHAR(50) | 菜单名称 |
| parent_id | BIGINT | 父菜单ID |
| order_num | INT | 显示顺序 |
| path | VARCHAR(200) | 路由地址 |
| component | VARCHAR(255) | 组件路径 |
| query | VARCHAR(255) | 路由参数 |
| route_name | VARCHAR(255) | 路由名称 |
| is_frame | CHAR(1) | 是否外链（0是 1否） |
| is_cache | CHAR(1) | 是否缓存（0缓存 1不缓存） |
| menu_type | CHAR(1) | 菜单类型（M目录 C菜单 F按钮） |
| visible | CHAR(1) | 显示状态（0显示 1隐藏） |
| status | CHAR(1) | 菜单状态（0正常 1停用） |
| perms | VARCHAR(100) | 权限字符串 |
| icon | VARCHAR(100) | 菜单图标 |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

---

### 3.4 sys_dept（部门表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| dept_id | BIGINT | 部门id（主键） |
| parent_id | BIGINT | 父部门id |
| ancestors | VARCHAR(50) | 祖级列表 |
| dept_name | VARCHAR(30) | 部门名称 |
| order_num | INT | 显示顺序 |
| leader | VARCHAR(20) | 负责人 |
| phone | VARCHAR(11) | 联系电话 |
| email | VARCHAR(50) | 邮箱 |
| status | CHAR(1) | 部门状态（0正常 1停用） |
| del_flag | CHAR(1) | 删除标志（0存在 2删除） |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |

---

### 3.5 sys_warehouse（仓库档案表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| warehouse_code | VARCHAR(50) | 仓库编码 |
| warehouse_name | VARCHAR(100) | 仓库名称 |
| temperature_zone | VARCHAR(50) | 温度分区 |
| quality_zone | VARCHAR(50) | 质量分区 |
| employee_code | VARCHAR(50) | 责任人工号 |
| employee_name | VARCHAR(50) | 责任人 |
| dept_code | VARCHAR(50) | 责任部门编号 |
| dept_name_full_path | VARCHAR(200) | 责任部门全路径 |
| company | VARCHAR(100) | 所属公司 |
| is_enabled | INT | 是否启用（0-禁用 1-启用） |
| is_deleted | INT | 逻辑删除（0-未删除 1-已删除） |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

---

### 3.6 wms_location（库位档案表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| parent_id | BIGINT | 上级ID（根节点为NULL） |
| location_grade | VARCHAR(50) | 库位等级编码 |
| location_type | VARCHAR(50) | 库位类型名称 |
| location_level | INT | 层级深度 |
| location_level_count | INT | 总层数 |
| internal_serial_no | INT | 同级内部序号 |
| internal_quantity | INT | 同级总数量 |
| location_no | VARCHAR(100) | 库位编号（业务编码） |
| location_name | VARCHAR(100) | 库位名称 |
| warehouse_code | VARCHAR(50) | 仓库编码 |
| parent_name | VARCHAR(100) | 上级名称 |
| storage_mode | VARCHAR(20) | 存储模式（Exclusive/Shared） |
| specification | VARCHAR(50) | 规格（如4x4、1x1） |
| grid_config | VARCHAR(50) | 网格配置 |
| is_use | INT | 是否使用（0=空闲，1=占用） |
| location_sort_no | VARCHAR(100) | 排序号 |
| location_fullpath_name | VARCHAR(500) | 全路径名称 |
| capacity_total | INT | 总容量 |
| capacity_used | INT | 已用容量 |
| is_deleted | INT | 是否删除（0=正常，1=已删除） |
| remarks | VARCHAR(500) | 备注 |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |

---

### 3.7 material（物料档案表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| material_code | VARCHAR(50) | 物料编码 |
| material_name | VARCHAR(100) | 物料名称 |
| spec | VARCHAR(100) | 规格 |
| unit | VARCHAR(20) | 单位 |
| category | VARCHAR(50) | 类别 |
| status | INT | 状态 |
| del_flag | INT | 删除标志 |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |

---

### 3.8 inv_qrcode（二维码表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| qrcode | VARCHAR(100) | 二维码值 |
| catalogno | VARCHAR(50) | 目录号 |
| productname | VARCHAR(100) | 产品名称 |
| batchid | VARCHAR(50) | 批次ID |
| size | VARCHAR(50) | 尺寸 |
| unit | VARCHAR(20) | 单位 |
| is_deleted | TINYINT | 是否删除 |
| remark | VARCHAR(500) | 备注 |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |

---

### 3.9 sys_warehouse_receiver（仓库收货人表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| warehouse_code | VARCHAR(50) | 仓库编码 |
| consignee | VARCHAR(50) | 收货人姓名 |
| phone_number | VARCHAR(20) | 手机号码 |
| country | VARCHAR(50) | 国家 |
| province | VARCHAR(50) | 省份 |
| city | VARCHAR(50) | 城市 |
| district | VARCHAR(50) | 区县 |
| detailed_address | VARCHAR(200) | 详细地址 |
| postal_code | VARCHAR(20) | 邮政编码 |
| is_default | INT | 是否默认（0-否 1-是） |
| is_deleted | INT | 逻辑删除（0-未删除 1-已删除） |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

---

### 3.10 sys_serial_number（流水号规则表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| name | VARCHAR(100) | 名称 |
| prefix | VARCHAR(50) | 前缀 |
| number_type | INT | 数字规则（0-无，1-年，2-年月，3-年月日） |
| digit_length | INT | 位数 |
| suffix | VARCHAR(50) | 后缀 |
| start_value | BIGINT | 起始值 |
| reset_rule | VARCHAR(20) | 重置规则 |
| current_value | BIGINT | 当前值 |
| last_reset_key | VARCHAR(50) | 上次重置周期标识 |
| is_enabled | INT | 是否启用（0-禁用，1-启用） |
| usage_scope | VARCHAR(100) | 使用范围 |
| is_deleted | VARCHAR(1) | 删除标志 |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

---

### 3.11 sys_enum_define（枚举定义表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| enum_code | VARCHAR(50) | 枚举编码 |
| enum_name | VARCHAR(100) | 枚举名称 |
| enum_desc | VARCHAR(200) | 枚举描述 |
| category_code | VARCHAR(50) | 分类编码 |
| category_name | VARCHAR(100) | 分类名称 |
| is_enabled | INT | 是否启用 |
| sort_order | INT | 排序 |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

---

### 3.12 sys_enum_item（枚举明细表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| enum_code | VARCHAR(50) | 所属枚举编码 |
| item_key | VARCHAR(50) | 枚举项键值 |
| item_value | VARCHAR(100) | 枚举项显示值 |
| item_desc | VARCHAR(200) | 枚举项描述 |
| sort_order | INT | 排序顺序 |
| is_default | INT | 是否默认值 |
| is_enabled | INT | 是否启用 |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

---

### 3.13 batch（批次档案表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| material_id | BIGINT | 物料ID |
| material_code | VARCHAR(50) | 物料编码 |
| batch_no | VARCHAR(50) | 批次号 |
| supplier_batch_no | VARCHAR(50) | 供应商批号 |
| purify_no | VARCHAR(50) | 纯化编号 |
| clone_no | VARCHAR(50) | 克隆号 |
| concentration | VARCHAR(50) | 浓度 |
| concentration_update_time | DATETIME | 浓度更新时间 |
| expire_date | DATE | 失效期 |
| qc_data | TEXT | 质检数据 |
| coa_link | VARCHAR(500) | COA链接 |
| inbound_date | DATE | 入库日期 |
| production_date | DATE | 生产日期 |
| project_no | VARCHAR(50) | 项目编号 |
| naked_finish_code | VARCHAR(50) | 裸成品物料编码 |
| naked_finish_batch | VARCHAR(50) | 裸成品批次 |
| buffer_solution | VARCHAR(200) | 缓冲液 |
| erp_sync_remark | VARCHAR(500) | ERP同步备注 |
| is_deleted | TINYINT | 是否删除（0-正常，1-删除） |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

### 3.14 inv_inventory（库存余量表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| material_id | BIGINT | 物料ID |
| material_code | VARCHAR(50) | 物料编码 |
| batch_id | BIGINT | 批次ID |
| batch_no | VARCHAR(50) | 批次号 |
| warehouse_code | VARCHAR(50) | 仓库编码 |
| location_id | BIGINT | 库位ID |
| location_sort_no | VARCHAR(100) | 库位排序号 |
| location_fullpath_name | VARCHAR(500) | 库位全路径名称 |
| quantity | INT | 数量 |
| remaining_quantity | INT | 剩余量 |
| in_transit_quantity | INT | 出库在途量 |
| freeze_quantity | INT | 冻结数量 |
| status | VARCHAR(20) | 状态 |
| qc_status | VARCHAR(20) | 质检状态 |
| is_generate_qrcode | TINYINT | 是否生成二维码 |
| is_deleted | TINYINT | 是否删除（0-正常，1-删除） |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

### 3.15 inv_inventory_change（库存变更明细表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| inventory_id | BIGINT | 库存ID |
| change_type | VARCHAR(20) | 变更类型 |
| change_date | DATE | 发生日期 |
| source_no | VARCHAR(50) | 来源单号 |
| source_detail_id | BIGINT | 来源明细ID |
| change_quantity | INT | 变更数量 |
| quantity_before | INT | 变更前数量 |
| quantity_after | INT | 变更后数量 |
| location_id | BIGINT | 库位ID |
| location_sort_no | VARCHAR(100) | 库位排序号 |
| location_path | VARCHAR(500) | 库位路径 |
| is_deleted | TINYINT | 是否删除（0-正常，1-删除） |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

### 3.16 qc_standard（质检标准表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| standard_code | VARCHAR(50) | 标准编号 |
| standard_name | VARCHAR(100) | 标准名称 |
| company_code | VARCHAR(50) | 公司编码 |
| material_category_large | VARCHAR(50) | 物料大类 |
| material_category_middle | VARCHAR(50) | 物料中类 |
| material_category_small | VARCHAR(50) | 物料小类 |
| material_id | BIGINT | 物料ID |
| material_code | VARCHAR(50) | 物料编码 |
| material_name | VARCHAR(100) | 物料名称 |
| brand | VARCHAR(50) | 品牌 |
| product_no | VARCHAR(50) | 货号 |
| batch_no | VARCHAR(50) | 批次号 |
| supplier_batch_no | VARCHAR(50) | 供应商批次号 |
| qc_suggestion | VARCHAR(50) | 质检建议 |
| wait_hours | INT | 参考等待小时数 |
| qc_days | INT | 参考质检天数 |
| executor_id | BIGINT | 执行人ID |
| executor_name | VARCHAR(50) | 执行人 |
| dept_id | BIGINT | 负责部门ID |
| dept_name | VARCHAR(100) | 负责部门 |
| status | TINYINT | 状态（0-停用，1-启用） |
| is_deleted | TINYINT | 是否删除（0-正常，1-删除） |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

### 3.17 qc_record（质量记录表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| record_no | VARCHAR(50) | 检验单号 |
| apply_date | DATE | 申请日期 |
| applicant_id | BIGINT | 申请人ID |
| applicant_name | VARCHAR(50) | 申请人 |
| apply_dept_id | BIGINT | 申请部门ID |
| apply_dept_name | VARCHAR(100) | 申请部门 |
| source_type | VARCHAR(30) | 来源单据类型 |
| source_no | VARCHAR(50) | 来源单据号 |
| source_detail_id | BIGINT | 来源单据明细行ID |
| material_id | BIGINT | 物料ID |
| material_code | VARCHAR(50) | 物料编码 |
| material_name | VARCHAR(100) | 物料名称 |
| batch_id | BIGINT | 批次ID |
| batch_no | VARCHAR(50) | 批次号 |
| purify_no | VARCHAR(50) | 纯化编号 |
| quantity | INT | 数量 |
| qc_standard_id | BIGINT | 质检标准ID |
| qc_executor_id | BIGINT | 检验执行人ID |
| qc_executor_name | VARCHAR(50) | 检验执行人 |
| qc_dept_id | BIGINT | 检验部门ID |
| qc_dept_name | VARCHAR(100) | 检验部门 |
| status | VARCHAR(20) | 状态 |
| has_coa | TINYINT | 是否有COA |
| qc_group | VARCHAR(50) | 检验组别 |
| qc_loss_quantity | INT | 质检损耗量 |
| finish_date | DATE | 完工日期 |
| finish_operator_id | BIGINT | 完工操作员ID |
| finish_operator_name | VARCHAR(50) | 完工操作员 |
| special_remark | VARCHAR(500) | 其他特殊情况备注 |
| release_conclusion | VARCHAR(50) | 放行结论 |
| overdue_days | INT | 逾期天数 |
| is_deleted | TINYINT | 是否删除（0-正常，1-删除） |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

### 3.18 st_stocktake（库存盘点主表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| stocktake_no | VARCHAR(50) | 盘点单号 |
| stocktake_name | VARCHAR(100) | 盘点名称 |
| apply_date | DATE | 申请日期 |
| apply_dept_id | BIGINT | 申请部门ID |
| apply_dept_name | VARCHAR(100) | 申请部门 |
| applicant_id | BIGINT | 申请人ID |
| applicant_name | VARCHAR(50) | 申请人 |
| company_code | VARCHAR(50) | 公司编码 |
| warehouse_code | VARCHAR(50) | 仓库编码 |
| warehouse_name | VARCHAR(100) | 仓库名称 |
| stocktake_type | VARCHAR(20) | 盘点类型 |
| stocktake_scope | VARCHAR(50) | 盘点范围 |
| approval_time | DATETIME | 审批时间 |
| approval_user_id | BIGINT | 审批人ID |
| approval_user_name | VARCHAR(50) | 审批人 |
| approval_conclusion | VARCHAR(50) | 审批结论 |
| status | VARCHAR(20) | 状态 |
| total_materials | INT | 物料总数 |
| checked_count | INT | 已盘数量 |
| unchecked_count | INT | 未盘数量 |
| finish_time | DATETIME | 完成时间 |
| is_deleted | TINYINT | 是否删除（0-正常，1-删除） |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

### 3.19 st_stocktake_location（库存盘点库位计划表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| stocktake_id | BIGINT | 盘点ID |
| location_id | BIGINT | 库位ID |
| location_grade | VARCHAR(50) | 库位等级 |
| location_type | VARCHAR(50) | 库位类型 |
| location_fullpath_name | VARCHAR(500) | 库位全路径名称 |
| plan_start_time | DATETIME | 计划开始时间 |
| plan_finish_time | DATETIME | 计划完成时间 |
| actual_start_time | DATETIME | 实际开始时间 |
| actual_finish_time | DATETIME | 实际完成时间 |
| operator_id | BIGINT | 完工操作员ID |
| operator_name | VARCHAR(50) | 完工操作员 |
| status | VARCHAR(20) | 状态 |
| is_deleted | TINYINT | 是否删除（0-正常，1-删除） |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

### 3.20 st_stocktake_item（库存盘点物料清单表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| stocktake_id | BIGINT | 盘点ID |
| stocktake_location_id | BIGINT | 盘点库位ID |
| inventory_id | BIGINT | 库存ID |
| location_id | BIGINT | 库位ID |
| location_fullpath_name | VARCHAR(500) | 库位全路径名称 |
| material_id | BIGINT | 物料ID |
| material_code | VARCHAR(50) | 物料编码 |
| material_name | VARCHAR(100) | 物料名称 |
| batch_id | BIGINT | 批次ID |
| batch_no | VARCHAR(50) | 批次号 |
| purify_no | VARCHAR(50) | 纯化编号 |
| expire_date | DATE | 失效期 |
| system_quantity | INT | 账面数量 |
| actual_quantity | INT | 实际盘点数量 |
| diff_quantity | INT | 差异数量 |
| diff_rate | DECIMAL(10,4) | 差异率 |
| adjust_status | VARCHAR(20) | 调整状态 |
| adjust_time | DATETIME | 调整时间 |
| is_deleted | TINYINT | 是否删除（0-正常，1-删除） |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

### 3.21 adj_location（库位调整表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| adjust_no | VARCHAR(50) | 调整单号 |
| adjust_name | VARCHAR(100) | 调整名称 |
| apply_date | DATE | 申请日期 |
| apply_dept_id | BIGINT | 申请部门ID |
| apply_dept_name | VARCHAR(100) | 申请部门 |
| applicant_id | BIGINT | 申请人ID |
| applicant_name | VARCHAR(50) | 申请人 |
| warehouse_code | VARCHAR(50) | 仓库编码 |
| warehouse_name | VARCHAR(100) | 仓库名称 |
| out_inventory_id | BIGINT | 调出库存ID |
| out_location_id | BIGINT | 调出库位ID |
| out_location_fullpath | VARCHAR(500) | 调出库位全路径 |
| in_location_id | BIGINT | 调入库位ID |
| in_location_fullpath | VARCHAR(500) | 调入库位全路径 |
| material_id | BIGINT | 物料ID |
| material_code | VARCHAR(50) | 物料编码 |
| material_name | VARCHAR(100) | 物料名称 |
| batch_id | BIGINT | 批次ID |
| batch_no | VARCHAR(50) | 批次号 |
| adjust_quantity | INT | 调整数量 |
| status | VARCHAR(20) | 状态 |
| finish_date | DATE | 完工日期 |
| finish_operator_id | BIGINT | 完工操作员ID |
| finish_operator_name | VARCHAR(50) | 完工操作员 |
| is_deleted | TINYINT | 是否删除（0-正常，1-删除） |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

### 3.22 sync_log（同步日志表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| interface_code | VARCHAR(50) | 接口编号 |
| interface_name | VARCHAR(100) | 接口名称 |
| interface_type | VARCHAR(20) | 接口方式 |
| source_system | VARCHAR(50) | 发起系统 |
| target_system | VARCHAR(50) | 接收系统 |
| start_time | DATETIME | 开始时间 |
| end_time | DATETIME | 结束时间 |
| data_type | VARCHAR(50) | 数据类型 |
| title | VARCHAR(200) | 标题 |
| biz_no | VARCHAR(50) | 单据编号 |
| operation_type | VARCHAR(20) | 操作类型 |
| request_data | TEXT | 请求数据 |
| response_data | TEXT | 响应数据 |
| apply_status | VARCHAR(20) | 申方状态 |
| consume_status | VARCHAR(20) | 消方状态 |
| error_message | TEXT | 错误信息 |
| retry_count | INT | 重试次数 |
| is_deleted | TINYINT | 是否删除（0-正常，1-删除） |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

---

## 四、需求规划表（待实现）

以下表来自需求说明书，尚未在后端代码中实现：

### 4.1 批次管理

| 序号 | 表名 | 说明 |
|-----|------|------|
| 1 | **batch** | 批次档案表 |
| 2 | **batch_ext** | 批次扩展表 |

### 4.2 库存管理

| 序号 | 表名 | 说明 |
|-----|------|------|
| 3 | **inv_inventory** | 库存余量表 |
| 4 | **inv_inventory_change** | 库存变更明细表 |
| 5 | **inv_inventory_detail** | 库存出入台账表 |
| 6 | **inv_inventory_item** | 库存出入物料明细表 |

### 4.3 二维码管理

| 序号 | 表名 | 说明 |
|-----|------|------|
| 7 | **inv_qrcode_detail** | 二维码变更明细表 |

### 4.4 质检管理

| 序号 | 表名 | 说明 |
|-----|------|------|
| 8 | **qc_standard** | 质检标准表 |
| 9 | **qc_record** | 质量记录表 |

### 4.5 入库/出库管理（库存出入台账）

| 序号 | 表名 | 说明 |
|-----|------|------|
| 10 | **io_inventory_account** | 库存出入台账表 |
| 11 | **io_inventory_item** | 库存出入物料明细表 |

#### 4.5.1 io_inventory_account（库存出入台账表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| account_no | VARCHAR(50) | 单据号 |
| apply_date | DATE | 申请日期 |
| apply_dept_id | BIGINT | 申请部门ID |
| apply_dept_name | VARCHAR(100) | 申请部门 |
| applicant_id | BIGINT | 申请人ID |
| applicant_name | VARCHAR(50) | 申请人 |
| io_type | VARCHAR(20) | 收发类型（入库/出库） |
| biz_type | VARCHAR(30) | 业务类型 |
| out_company_code | VARCHAR(50) | 出库公司编码 |
| out_warehouse_code | VARCHAR(50) | 出库仓库编码 |
| in_company_code | VARCHAR(50) | 入库公司编码 |
| in_warehouse_code | VARCHAR(50) | 入库仓库编码 |
| approval_time | DATETIME | 审批时间 |
| approval_user_id | BIGINT | 审批人ID |
| approval_user_name | VARCHAR(50) | 审批人 |
| approval_conclusion | VARCHAR(50) | 审批结论 |
| need_express | TINYINT(1) | 是否需要快递（0-否，1-是） |
| consignee | VARCHAR(50) | 收货人 |
| phone | VARCHAR(20) | 手机号码 |
| country | VARCHAR(50) | 国家 |
| province | VARCHAR(50) | 省份 |
| city | VARCHAR(50) | 城市 |
| district | VARCHAR(50) | 区街 |
| address | VARCHAR(200) | 详细地址 |
| is_special_require | TINYINT(1) | 是否特殊要求（0-否，1-是） |
| require_delivery_time | DATETIME | 要求发货时间 |
| other_require | VARCHAR(500) | 其他发货要求 |
| source_type | VARCHAR(30) | 来源类型 |
| source_no | VARCHAR(50) | 来源单据号 |
| source_id | BIGINT | 来源单据ID |
| status | VARCHAR(20) | 状态 |
| out_finish_date | DATE | 出库完成日期 |
| out_operator_id | BIGINT | 出库操作员ID |
| out_operator_name | VARCHAR(50) | 出库操作员 |
| in_finish_date | DATE | 入库完成日期 |
| in_operator_id | BIGINT | 入库操作员ID |
| in_operator_name | VARCHAR(50) | 入库操作员 |
| erp_sync_remark | VARCHAR(500) | ERP同步备注 |
| is_deleted | TINYINT(1) | 是否删除（0-正常，1-删除） |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

#### 4.5.2 io_inventory_item（库存出入物料明细表）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键ID |
| account_id | BIGINT | 台账ID |
| seq_no | INT | 序号 |
| material_id | BIGINT | 物料ID |
| material_code | VARCHAR(50) | 物料编码 |
| material_name | VARCHAR(100) | 物料名称 |
| brand | VARCHAR(50) | 品牌 |
| product_no | VARCHAR(50) | 货号 |
| category | VARCHAR(50) | 产品类别 |
| spec | VARCHAR(100) | 规格 |
| unit | VARCHAR(20) | 计量单位 |
| batch_id | BIGINT | 批次ID |
| batch_no | VARCHAR(50) | 批次号 |
| purify_no | VARCHAR(50) | 纯化编号 |
| concentration | VARCHAR(50) | 浓度 |
| expire_date | DATE | 失效期 |
| quantity | INT | 数量 |
| is_qc_required | TINYINT(1) | 是否必检（0-否，1-是） |
| recommend_box_no | VARCHAR(50) | 推荐盒号 |
| recommend_hole_no | VARCHAR(50) | 推荐孔号 |
| location_selection_id | BIGINT | 库位选择ID |
| location_fullpath_name | VARCHAR(500) | 库位全路径名称 |
| price | DECIMAL(18,2) | 单价 |
| freight | DECIMAL(18,2) | 运保费 |
| total_amount | DECIMAL(18,2) | 合计金额 |
| is_deleted | TINYINT(1) | 是否删除（0-正常，1-删除） |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

### 4.6 出库管理

| 序号 | 表名 | 说明 |
|-----|------|------|
| 12 | **io_location_selection** | 多库位选择表 |

### 4.7 提货单管理

| 序号 | 表名 | 说明 |
|-----|------|------|
| 13 | **io_pick_order_sale** | 销售提货单主表 |
| 14 | **io_pick_order_sale_item** | 销售提货单物料明细表 |
| 15 | **io_pick_order_transfer** | 调拨提货单主表 |
| 16 | **io_pick_order_consume** | 领用提货单主表 |
| 17 | **io_pick_order_cro** | CRO提货单主表 |
| 18 | **io_goods_with** | 随货物品清单表 |

### 4.8 盘点管理

| 序号 | 表名 | 说明 |
|-----|------|------|
| 21 | **st_stocktake** | 库存盘点表 |
| 22 | **st_stocktake_location** | 库存盘点库位计划表 |
| 23 | **st_stocktake_item** | 库存盘点物料清单表 |

### 4.9 库位调整

| 序号 | 表名 | 说明 |
|-----|------|------|
| 24 | **adj_location** | 库位调整表 |

### 4.10 同步日志

| 序号 | 表名 | 说明 |
|-----|------|------|
| 25 | **sync_log** | 同步日志表 |

---

## 五、表关系图

### 5.1 权限体系关系

```
sys_user ── sys_user_role ── sys_role
    │                              │
    │                              ├── sys_role_menu ── sys_menu
    │                              │
    │                              └── sys_role_dept ── sys_dept
    │
    ├── sys_user_post ── sys_post
    │
    ├── sys_user_warehouse ── sys_warehouse
    │
    └── user_data_permission
            │
            ├── dept_data_permission ── sys_dept
            └── company_data_permission
```

### 5.2 WMS业务关系

```
sys_warehouse ──┬── sys_warehouse_receiver
                │
                └── wms_location (树形结构，自关联)
                        │
                        │
                        └── inv_inventory ── material
                                │              │
                                │              └── batch
                                │
                                ├── inv_inventory_change
                                │
                                └── inv_qrcode ── inv_qrcode_detail
```

---

## 六、索引设计

### 6.1 唯一索引

| 表名 | 字段 | 说明 |
|-----|------|------|
| sys_user | user_name | 用户账号唯一 |
| sys_role | role_key | 角色权限唯一 |
| sys_warehouse | warehouse_code | 仓库编码唯一 |
| sys_warehouse | warehouse_name | 仓库名称唯一 |
| wms_location | location_no | 库位编号唯一 |
| material | material_code | 物料编码唯一 |
| sys_enum_define | enum_code | 枚举编码唯一 |
| sys_enum_item | enum_code + item_key | 枚举明细唯一 |
| inv_qrcode | qrcode | 二维码值唯一 |

### 6.2 业务索引

| 表名 | 字段 | 说明 |
|-----|------|------|
| sys_user | dept_id | 按部门查询用户 |
| sys_user | status, del_flag | 用户状态查询 |
| sys_dept | parent_id | 查询子部门 |
| wms_location | parent_id | 查询子库位 |
| wms_location | warehouse_code | 按仓库查询库位 |
| material | category | 按类别查询物料 |
| inv_inventory | warehouse_code | 按仓库查询库存 |
| inv_inventory | material_code | 按物料查询库存 |

---

## 七、字段规范

### 7.1 主键命名

| 类型 | 命名规则 | 示例 |
|-----|---------|------|
| ID主键 | id / {table}_id | id, user_id, role_id |
| 外键 | {ref_table}_id | dept_id, warehouse_id |

### 7.2 状态字段

| 类型 | 字段名 | 值说明 |
|-----|-------|-------|
| 删除标志 | is_deleted / del_flag | 0-正常, 1-删除 |
| 启用状态 | is_enabled / status | 0-禁用, 1-启用 |
| 业务状态 | status | 按业务定义 |

### 7.3 审计字段

| 字段名 | 类型 | 说明 |
|-------|------|------|
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |
| remark | VARCHAR(500) | 备注 |

---

## 八、待完善事项

- [x] inv_inventory 库存表实体类 - 已补全 InvInventory.java
- [x] inv_inventory_change 库存变更明细表 - 已补全 InvInventoryChange.java
- [x] batch 批次档案表 - 已补全 Batch.java
- [x] qc_standard 质检标准表 - 已补全 QcStandard.java
- [x] qc_record 质量记录表 - 已补全 QcRecord.java
- [x] st_stocktake 盘点表 - 已补全 StStocktake.java
- [x] st_stocktake_location 盘点库位表 - 已补全 StStocktakeLocation.java
- [x] st_stocktake_item 盘点物料表 - 已补全 StStocktakeItem.java
- [x] adj_location 库位调整表 - 已补全 AdjLocation.java
- [x] sync_log 同步日志表 - 已补全 SyncLog.java
- [x] inv_qrcode_detail 二维码变更明细表 - 已补全 InvQrcodeDetail.java
- [x] io_inventory_account 库存出入台账表 - 已补全 IoInventoryAccount.java
- [x] io_inventory_item 库存出入物料明细表 - 已补全 IoInventoryItem.java
- [x] io_pick_order_sale 销售提货单主表 - 已补全 IoPickOrderSale.java
- [x] io_pick_order_sale_item 销售提货单物料明细表 - 已补全 IoPickOrderSaleItem.java
- [x] io_pick_order_transfer 调拨提货单主表 - 已补全 IoPickOrderTransfer.java
- [x] io_pick_order_consume 领用提货单主表 - 已补全 IoPickOrderConsume.java
- [x] io_pick_order_cro CRO提货单主表 - 已补全 IoPickOrderCro.java
- [x] io_goods_with 随货物品清单表 - 已补全 IoGoodsWith.java
- [x] io_location_selection 多库位选择表 - 已补全 IoLocationSelection.java
- [ ] wms_location_grid_config 库位网格配置表 - 待实现
- [ ] customer 客户档案表 - 待实现
- [ ] supplier 供应商档案表 - 待实现
- [ ] storage 储位配置表 - 待实现
- [ ] wms_user WMS用户扩展表 - 待实现

---

## 附录：数据库连接信息

```yaml
数据库地址: 10.201.0.34:3306
数据库名称: wms
用户名: test
密码: Test123!@#
```

---

*文档更新时间：2026-04-03*
