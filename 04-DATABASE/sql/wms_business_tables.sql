-- =============================================
-- WMS仓库物流系统 - 数据库建表脚本
-- 版本: V1.0
-- 日期: 2026-04-03
-- 说明: 包含所有待实现的业务表
-- =============================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 1. 批次档案表 (batch)
-- ----------------------------
DROP TABLE IF EXISTS `batch`;
CREATE TABLE `batch` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `material_id` bigint NOT NULL COMMENT '物料ID',
  `material_code` varchar(50) NOT NULL COMMENT '物料编码',
  `batch_no` varchar(50) NOT NULL COMMENT '批次号',
  `supplier_batch_no` varchar(50) DEFAULT NULL COMMENT '供应商批号',
  `purify_no` varchar(50) DEFAULT NULL COMMENT '纯化编号',
  `clone_no` varchar(50) DEFAULT NULL COMMENT '克隆号',
  `concentration` varchar(50) DEFAULT NULL COMMENT '浓度',
  `concentration_update_time` datetime DEFAULT NULL COMMENT '浓度更新时间',
  `expire_date` date DEFAULT NULL COMMENT '失效期',
  `qc_data` text COMMENT '质检数据',
  `coa_link` varchar(500) DEFAULT NULL COMMENT 'COA链接',
  `inbound_date` date DEFAULT NULL COMMENT '入库日期',
  `production_date` date DEFAULT NULL COMMENT '生产日期',
  `project_no` varchar(50) DEFAULT NULL COMMENT '项目编号',
  `naked_finish_code` varchar(50) DEFAULT NULL COMMENT '裸成品物料编码',
  `naked_finish_batch` varchar(50) DEFAULT NULL COMMENT '裸成品批次',
  `buffer_solution` varchar(200) DEFAULT NULL COMMENT '缓冲液',
  `erp_sync_remark` varchar(500) DEFAULT NULL COMMENT 'ERP同步备注',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_batch_no` (`batch_no`, `is_deleted`),
  KEY `idx_material_id` (`material_id`),
  KEY `idx_expire_date` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='批次档案表';

-- ----------------------------
-- 2. 库存余量表 (inv_inventory)
-- ----------------------------
DROP TABLE IF EXISTS `inv_inventory`;
CREATE TABLE `inv_inventory` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `material_id` bigint NOT NULL COMMENT '物料ID',
  `material_code` varchar(50) NOT NULL COMMENT '物料编码',
  `batch_id` bigint NOT NULL COMMENT '批次ID',
  `batch_no` varchar(50) NOT NULL COMMENT '批次号',
  `warehouse_code` varchar(50) NOT NULL COMMENT '仓库编码',
  `location_id` bigint DEFAULT NULL COMMENT '库位ID',
  `location_sort_no` varchar(100) DEFAULT NULL COMMENT '库位排序号',
  `location_fullpath_name` varchar(500) DEFAULT NULL COMMENT '库位全路径名称',
  `quantity` int NOT NULL DEFAULT '0' COMMENT '数量',
  `remaining_quantity` int NOT NULL DEFAULT '0' COMMENT '剩余量',
  `in_transit_quantity` int NOT NULL DEFAULT '0' COMMENT '出库在途量',
  `freeze_quantity` int NOT NULL DEFAULT '0' COMMENT '冻结数量',
  `status` varchar(20) DEFAULT NULL COMMENT '状态（待检验/检验中/正常/盘库中/库位调整中）',
  `qc_status` varchar(20) DEFAULT NULL COMMENT '质检状态',
  `is_generate_qrcode` tinyint(1) DEFAULT '0' COMMENT '是否生成二维码（0-否，1-是）',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_material_batch` (`material_id`, `batch_id`),
  KEY `idx_warehouse` (`warehouse_code`),
  KEY `idx_location` (`location_id`),
  KEY `idx_batch_no` (`batch_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存余量表';

-- ----------------------------
-- 3. 库存变更明细表 (inv_inventory_change)
-- ----------------------------
DROP TABLE IF EXISTS `inv_inventory_change`;
CREATE TABLE `inv_inventory_change` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `inventory_id` bigint NOT NULL COMMENT '库存ID',
  `change_type` varchar(20) NOT NULL COMMENT '变更类型（入库/出库/调拨/盘点调整/库位调整）',
  `change_date` date NOT NULL COMMENT '发生日期',
  `source_no` varchar(50) DEFAULT NULL COMMENT '来源单号',
  `source_detail_id` bigint DEFAULT NULL COMMENT '来源明细ID',
  `change_quantity` int NOT NULL COMMENT '变更数量（正数入库，负数出库）',
  `quantity_before` int NOT NULL COMMENT '变更前数量',
  `quantity_after` int NOT NULL COMMENT '变更后数量',
  `location_id` bigint DEFAULT NULL COMMENT '库位ID',
  `location_sort_no` varchar(100) DEFAULT NULL COMMENT '库位排序号',
  `location_path` varchar(500) DEFAULT NULL COMMENT '库位路径',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_inventory_id` (`inventory_id`),
  KEY `idx_change_type` (`change_type`),
  KEY `idx_change_date` (`change_date`),
  KEY `idx_source_no` (`source_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存变更明细表';

-- ----------------------------
-- 4. 二维码变更明细表 (inv_qrcode_detail)
-- ----------------------------
DROP TABLE IF EXISTS `inv_qrcode_detail`;
CREATE TABLE `inv_qrcode_detail` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `qrcode_id` bigint NOT NULL COMMENT '二维码ID',
  `qrcode_value` varchar(100) NOT NULL COMMENT '二维码值',
  `apply_type` varchar(20) NOT NULL COMMENT '请码库存类型',
  `apply_source_table` varchar(50) NOT NULL COMMENT '请码数据源表',
  `apply_source_id` bigint NOT NULL COMMENT '请码数据来源ID',
  `use_type` varchar(20) DEFAULT NULL COMMENT '用码变更类型',
  `use_source_table` varchar(50) DEFAULT NULL COMMENT '用码数据源表',
  `use_source_id` bigint DEFAULT NULL COMMENT '用码数据来源ID',
  `is_valid` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否有效（0-无效，1-有效）',
  `code_b` varchar(100) DEFAULT NULL COMMENT 'B码值',
  `code_c` varchar(100) DEFAULT NULL COMMENT 'C码值',
  `sync_result` varchar(50) DEFAULT NULL COMMENT '同步结果',
  `is_scan` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否扫码（0-否，1-是）',
  `is_print_label` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否打印标签（0-否，1-是）',
  `is_arrive_scan` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否到货扫码（0-否，1-是）',
  `is_delivery_scan` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否送货扫码（0-否，1-是）',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_qrcode_id` (`qrcode_id`),
  KEY `idx_qrcode_value` (`qrcode_value`),
  KEY `idx_apply_source` (`apply_source_table`, `apply_source_id`),
  KEY `idx_use_source` (`use_source_table`, `use_source_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='二维码变更明细表';

-- ----------------------------
-- 5. 质检标准表 (qc_standard)
-- ----------------------------
DROP TABLE IF EXISTS `qc_standard`;
CREATE TABLE `qc_standard` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `standard_code` varchar(50) NOT NULL COMMENT '标准编号',
  `standard_name` varchar(100) NOT NULL COMMENT '标准名称',
  `company_code` varchar(50) DEFAULT NULL COMMENT '公司编码',
  `material_category_large` varchar(50) DEFAULT NULL COMMENT '物料大类',
  `material_category_middle` varchar(50) DEFAULT NULL COMMENT '物料中类',
  `material_category_small` varchar(50) DEFAULT NULL COMMENT '物料小类',
  `material_id` bigint DEFAULT NULL COMMENT '物料ID',
  `material_code` varchar(50) DEFAULT NULL COMMENT '物料编码',
  `material_name` varchar(100) DEFAULT NULL COMMENT '物料名称',
  `brand` varchar(50) DEFAULT NULL COMMENT '品牌',
  `product_no` varchar(50) DEFAULT NULL COMMENT '货号',
  `batch_no` varchar(50) DEFAULT NULL COMMENT '批次号',
  `supplier_batch_no` varchar(50) DEFAULT NULL COMMENT '供应商批次号',
  `qc_suggestion` varchar(50) DEFAULT NULL COMMENT '质检建议（如：快递放行）',
  `wait_hours` int DEFAULT NULL COMMENT '参考等待小时数',
  `qc_days` int DEFAULT NULL COMMENT '参考质检天数',
  `executor_id` bigint DEFAULT NULL COMMENT '执行人ID',
  `executor_name` varchar(50) DEFAULT NULL COMMENT '执行人',
  `dept_id` bigint DEFAULT NULL COMMENT '负责部门ID',
  `dept_name` varchar(100) DEFAULT NULL COMMENT '负责部门',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态（0-停用，1-启用）',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_standard_code` (`standard_code`, `is_deleted`),
  KEY `idx_material` (`material_id`),
  KEY `idx_material_code` (`material_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='质检标准表';

-- ----------------------------
-- 6. 质量记录表 (qc_record)
-- ----------------------------
DROP TABLE IF EXISTS `qc_record`;
CREATE TABLE `qc_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `record_no` varchar(50) NOT NULL COMMENT '检验单号',
  `apply_date` date NOT NULL COMMENT '申请日期',
  `applicant_id` bigint DEFAULT NULL COMMENT '申请人ID',
  `applicant_name` varchar(50) DEFAULT NULL COMMENT '申请人',
  `apply_dept_id` bigint DEFAULT NULL COMMENT '申请部门ID',
  `apply_dept_name` varchar(100) DEFAULT NULL COMMENT '申请部门',
  `source_type` varchar(30) NOT NULL COMMENT '来源单据类型',
  `source_no` varchar(50) NOT NULL COMMENT '来源单据号',
  `source_detail_id` bigint DEFAULT NULL COMMENT '来源单据明细行ID',
  `material_id` bigint NOT NULL COMMENT '物料ID',
  `material_code` varchar(50) NOT NULL COMMENT '物料编码',
  `material_name` varchar(100) DEFAULT NULL COMMENT '物料名称',
  `batch_id` bigint NOT NULL COMMENT '批次ID',
  `batch_no` varchar(50) NOT NULL COMMENT '批次号',
  `purify_no` varchar(50) DEFAULT NULL COMMENT '纯化编号',
  `quantity` int NOT NULL COMMENT '数量',
  `qc_standard_id` bigint DEFAULT NULL COMMENT '质检标准ID',
  `qc_executor_id` bigint DEFAULT NULL COMMENT '检验执行人ID',
  `qc_executor_name` varchar(50) DEFAULT NULL COMMENT '检验执行人',
  `qc_dept_id` bigint DEFAULT NULL COMMENT '检验部门ID',
  `qc_dept_name` varchar(100) DEFAULT NULL COMMENT '检验部门',
  `status` varchar(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态（未开始/质检中/已完成）',
  `has_coa` tinyint(1) DEFAULT '0' COMMENT '是否有COA（0-否，1-是）',
  `qc_group` varchar(50) DEFAULT NULL COMMENT '检验组别',
  `qc_loss_quantity` int DEFAULT '0' COMMENT '质检损耗量',
  `finish_date` date DEFAULT NULL COMMENT '完工日期',
  `finish_operator_id` bigint DEFAULT NULL COMMENT '完工操作员ID',
  `finish_operator_name` varchar(50) DEFAULT NULL COMMENT '完工操作员',
  `special_remark` varchar(500) DEFAULT NULL COMMENT '其他特殊情况备注',
  `release_conclusion` varchar(50) DEFAULT NULL COMMENT '放行结论（合格/不合格）',
  `overdue_days` int DEFAULT '0' COMMENT '逾期天数',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_record_no` (`record_no`, `is_deleted`),
  KEY `idx_source_no` (`source_no`),
  KEY `idx_material_batch` (`material_id`, `batch_id`),
  KEY `idx_status` (`status`),
  KEY `idx_apply_date` (`apply_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='质量记录表';

-- ----------------------------
-- 7. 库存盘点主表 (st_stocktake)
-- ----------------------------
DROP TABLE IF EXISTS `st_stocktake`;
CREATE TABLE `st_stocktake` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `stocktake_no` varchar(50) NOT NULL COMMENT '盘点单号',
  `stocktake_name` varchar(100) DEFAULT NULL COMMENT '盘点名称',
  `apply_date` date NOT NULL COMMENT '申请日期',
  `apply_dept_id` bigint DEFAULT NULL COMMENT '申请部门ID',
  `apply_dept_name` varchar(100) DEFAULT NULL COMMENT '申请部门',
  `applicant_id` bigint DEFAULT NULL COMMENT '申请人ID',
  `applicant_name` varchar(50) DEFAULT NULL COMMENT '申请人',
  `company_code` varchar(50) NOT NULL COMMENT '公司编码',
  `warehouse_code` varchar(50) NOT NULL COMMENT '仓库编码',
  `warehouse_name` varchar(100) NOT NULL COMMENT '仓库名称',
  `stocktake_type` varchar(20) NOT NULL COMMENT '盘点类型（全盘/抽盘/周期盘）',
  `stocktake_scope` varchar(50) DEFAULT NULL COMMENT '盘点范围（全仓库/指定库区/指定库位）',
  `approval_time` datetime DEFAULT NULL COMMENT '审批时间',
  `approval_user_id` bigint DEFAULT NULL COMMENT '审批人ID',
  `approval_user_name` varchar(50) DEFAULT NULL COMMENT '审批人',
  `approval_conclusion` varchar(50) DEFAULT NULL COMMENT '审批结论',
  `status` varchar(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态',
  `total_materials` int DEFAULT '0' COMMENT '物料总数',
  `checked_count` int DEFAULT '0' COMMENT '已盘数量',
  `unchecked_count` int DEFAULT '0' COMMENT '未盘数量',
  `finish_time` datetime DEFAULT NULL COMMENT '完成时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_stocktake_no` (`stocktake_no`, `is_deleted`),
  KEY `idx_warehouse` (`warehouse_code`),
  KEY `idx_status` (`status`),
  KEY `idx_apply_date` (`apply_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存盘点主表';

-- ----------------------------
-- 8. 库存盘点库位计划表 (st_stocktake_location)
-- ----------------------------
DROP TABLE IF EXISTS `st_stocktake_location`;
CREATE TABLE `st_stocktake_location` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `stocktake_id` bigint NOT NULL COMMENT '盘点ID',
  `location_id` bigint NOT NULL COMMENT '库位ID',
  `location_grade` varchar(50) DEFAULT NULL COMMENT '库位等级',
  `location_type` varchar(50) DEFAULT NULL COMMENT '库位类型',
  `location_fullpath_name` varchar(500) DEFAULT NULL COMMENT '库位全路径名称',
  `plan_start_time` datetime DEFAULT NULL COMMENT '计划开始时间',
  `plan_finish_time` datetime DEFAULT NULL COMMENT '计划完成时间',
  `actual_start_time` datetime DEFAULT NULL COMMENT '实际开始时间',
  `actual_finish_time` datetime DEFAULT NULL COMMENT '实际完成时间',
  `operator_id` bigint DEFAULT NULL COMMENT '完工操作员ID',
  `operator_name` varchar(50) DEFAULT NULL COMMENT '完工操作员',
  `status` varchar(20) DEFAULT NULL COMMENT '状态',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_stocktake_id` (`stocktake_id`),
  KEY `idx_location_id` (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存盘点库位计划表';

-- ----------------------------
-- 9. 库存盘点物料清单表 (st_stocktake_item)
-- ----------------------------
DROP TABLE IF EXISTS `st_stocktake_item`;
CREATE TABLE `st_stocktake_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `stocktake_id` bigint NOT NULL COMMENT '盘点ID',
  `stocktake_location_id` bigint DEFAULT NULL COMMENT '盘点库位ID',
  `inventory_id` bigint NOT NULL COMMENT '库存ID',
  `location_id` bigint DEFAULT NULL COMMENT '库位ID',
  `location_fullpath_name` varchar(500) DEFAULT NULL COMMENT '库位全路径名称',
  `material_id` bigint NOT NULL COMMENT '物料ID',
  `material_code` varchar(50) NOT NULL COMMENT '物料编码',
  `material_name` varchar(100) DEFAULT NULL COMMENT '物料名称',
  `batch_id` bigint DEFAULT NULL COMMENT '批次ID',
  `batch_no` varchar(50) DEFAULT NULL COMMENT '批次号',
  `purify_no` varchar(50) DEFAULT NULL COMMENT '纯化编号',
  `expire_date` date DEFAULT NULL COMMENT '失效期',
  `system_quantity` int NOT NULL COMMENT '账面数量（系统数量）',
  `actual_quantity` int DEFAULT NULL COMMENT '实际盘点数量',
  `diff_quantity` int DEFAULT NULL COMMENT '差异数量',
  `diff_rate` decimal(10,4) DEFAULT NULL COMMENT '差异率',
  `adjust_status` varchar(20) DEFAULT NULL COMMENT '调整状态',
  `adjust_time` datetime DEFAULT NULL COMMENT '调整时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_stocktake_id` (`stocktake_id`),
  KEY `idx_inventory_id` (`inventory_id`),
  KEY `idx_material_batch` (`material_id`, `batch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存盘点物料清单表';

-- ----------------------------
-- 10. 库位调整表 (adj_location)
-- ----------------------------
DROP TABLE IF EXISTS `adj_location`;
CREATE TABLE `adj_location` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `adjust_no` varchar(50) NOT NULL COMMENT '调整单号',
  `adjust_name` varchar(100) DEFAULT NULL COMMENT '调整名称',
  `apply_date` date NOT NULL COMMENT '申请日期',
  `apply_dept_id` bigint DEFAULT NULL COMMENT '申请部门ID',
  `apply_dept_name` varchar(100) DEFAULT NULL COMMENT '申请部门',
  `applicant_id` bigint DEFAULT NULL COMMENT '申请人ID',
  `applicant_name` varchar(50) DEFAULT NULL COMMENT '申请人',
  `warehouse_code` varchar(50) NOT NULL COMMENT '仓库编码',
  `warehouse_name` varchar(100) DEFAULT NULL COMMENT '仓库名称',
  `out_inventory_id` bigint NOT NULL COMMENT '调出库存ID',
  `out_location_id` bigint NOT NULL COMMENT '调出库位ID',
  `out_location_fullpath` varchar(500) DEFAULT NULL COMMENT '调出库位全路径',
  `in_location_id` bigint DEFAULT NULL COMMENT '调入库位ID',
  `in_location_fullpath` varchar(500) DEFAULT NULL COMMENT '调入库位全路径',
  `material_id` bigint NOT NULL COMMENT '物料ID',
  `material_code` varchar(50) NOT NULL COMMENT '物料编码',
  `material_name` varchar(100) DEFAULT NULL COMMENT '物料名称',
  `batch_id` bigint NOT NULL COMMENT '批次ID',
  `batch_no` varchar(50) NOT NULL COMMENT '批次号',
  `adjust_quantity` int NOT NULL COMMENT '调整数量',
  `status` varchar(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态',
  `finish_date` date DEFAULT NULL COMMENT '完工日期',
  `finish_operator_id` bigint DEFAULT NULL COMMENT '完工操作员ID',
  `finish_operator_name` varchar(50) DEFAULT NULL COMMENT '完工操作员',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_adjust_no` (`adjust_no`, `is_deleted`),
  KEY `idx_warehouse` (`warehouse_code`),
  KEY `idx_status` (`status`),
  KEY `idx_material` (`material_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库位调整表';

-- ----------------------------
-- 11. 同步日志表 (sync_log)
-- ----------------------------
DROP TABLE IF EXISTS `sync_log`;
CREATE TABLE `sync_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `interface_code` varchar(50) NOT NULL COMMENT '接口编号',
  `interface_name` varchar(100) NOT NULL COMMENT '接口名称',
  `interface_type` varchar(20) NOT NULL COMMENT '接口方式（HTTP/MQ/API）',
  `source_system` varchar(50) NOT NULL COMMENT '接口发起系统',
  `target_system` varchar(50) NOT NULL COMMENT '接口接收系统',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `data_type` varchar(50) DEFAULT NULL COMMENT '数据类型',
  `title` varchar(200) DEFAULT NULL COMMENT '标题',
  `biz_no` varchar(50) DEFAULT NULL COMMENT '单据编号',
  `operation_type` varchar(20) DEFAULT NULL COMMENT '操作类型（新增/更新/删除）',
  `request_data` text COMMENT '请求数据',
  `response_data` text COMMENT '响应数据',
  `apply_status` varchar(20) DEFAULT NULL COMMENT '申方状态',
  `consume_status` varchar(20) DEFAULT NULL COMMENT '消方状态',
  `error_message` text COMMENT '错误信息',
  `retry_count` int DEFAULT '0' COMMENT '重试次数',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_interface_code` (`interface_code`),
  KEY `idx_biz_no` (`biz_no`),
  KEY `idx_start_time` (`start_time`),
  KEY `idx_apply_status` (`apply_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='同步日志表';

SET FOREIGN_KEY_CHECKS = 1;
