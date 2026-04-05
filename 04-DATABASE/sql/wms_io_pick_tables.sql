-- =============================================
-- WMS仓库物流系统 - 业务单据建表脚本
-- 版本: V1.0
-- 日期: 2026-04-03
-- 说明: 包含入库单、出库单、提货单相关表
-- =============================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 1. 库存出入台账表 (io_inventory_account)
-- ----------------------------
DROP TABLE IF EXISTS `io_inventory_account`;
CREATE TABLE `io_inventory_account` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `account_no` varchar(50) NOT NULL COMMENT '单据号',
  `apply_date` date NOT NULL COMMENT '申请日期',
  `apply_dept_id` bigint DEFAULT NULL COMMENT '申请部门ID',
  `apply_dept_name` varchar(100) DEFAULT NULL COMMENT '申请部门',
  `applicant_id` bigint DEFAULT NULL COMMENT '申请人ID',
  `applicant_name` varchar(50) DEFAULT NULL COMMENT '申请人',
  `io_type` varchar(20) NOT NULL COMMENT '收发类型（入库/出库）',
  `biz_type` varchar(30) NOT NULL COMMENT '业务类型（生产入库/采购入库/调拨入库/销售出库/调拨出库/领用出库等）',
  `out_company_code` varchar(50) DEFAULT NULL COMMENT '出库公司编码',
  `out_warehouse_code` varchar(50) DEFAULT NULL COMMENT '出库仓库编码',
  `in_company_code` varchar(50) DEFAULT NULL COMMENT '入库公司编码',
  `in_warehouse_code` varchar(50) DEFAULT NULL COMMENT '入库仓库编码',
  `approval_time` datetime DEFAULT NULL COMMENT '审批时间',
  `approval_user_id` bigint DEFAULT NULL COMMENT '审批人ID',
  `approval_user_name` varchar(50) DEFAULT NULL COMMENT '审批人',
  `approval_conclusion` varchar(50) DEFAULT NULL COMMENT '审批结论',
  `need_express` tinyint(1) DEFAULT '0' COMMENT '是否需要快递（0-否，1-是）',
  `consignee` varchar(50) DEFAULT NULL COMMENT '收货人',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号码',
  `country` varchar(50) DEFAULT NULL COMMENT '国家',
  `province` varchar(50) DEFAULT NULL COMMENT '省份',
  `city` varchar(50) DEFAULT NULL COMMENT '城市',
  `district` varchar(50) DEFAULT NULL COMMENT '区街',
  `address` varchar(200) DEFAULT NULL COMMENT '详细地址',
  `is_special_require` tinyint(1) DEFAULT '0' COMMENT '是否特殊要求（0-否，1-是）',
  `require_delivery_time` datetime DEFAULT NULL COMMENT '要求发货时间',
  `other_require` varchar(500) DEFAULT NULL COMMENT '其他发货要求',
  `source_type` varchar(30) DEFAULT NULL COMMENT '来源类型',
  `source_no` varchar(50) DEFAULT NULL COMMENT '来源单据号',
  `source_id` bigint DEFAULT NULL COMMENT '来源单据ID',
  `status` varchar(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态',
  `out_finish_date` date DEFAULT NULL COMMENT '出库完成日期',
  `out_operator_id` bigint DEFAULT NULL COMMENT '出库操作员ID',
  `out_operator_name` varchar(50) DEFAULT NULL COMMENT '出库操作员',
  `in_finish_date` date DEFAULT NULL COMMENT '入库完成日期',
  `in_operator_id` bigint DEFAULT NULL COMMENT '入库操作员ID',
  `in_operator_name` varchar(50) DEFAULT NULL COMMENT '入库操作员',
  `erp_sync_remark` varchar(500) DEFAULT NULL COMMENT 'ERP同步备注',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_account_no` (`account_no`, `is_deleted`),
  KEY `idx_io_type` (`io_type`),
  KEY `idx_biz_type` (`biz_type`),
  KEY `idx_status` (`status`),
  KEY `idx_source_no` (`source_no`),
  KEY `idx_apply_date` (`apply_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存出入台账表';

-- ----------------------------
-- 2. 库存出入物料明细表 (io_inventory_item)
-- ----------------------------
DROP TABLE IF EXISTS `io_inventory_item`;
CREATE TABLE `io_inventory_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `account_id` bigint NOT NULL COMMENT '台账ID',
  `seq_no` int NOT NULL COMMENT '序号',
  `material_id` bigint NOT NULL COMMENT '物料ID',
  `material_code` varchar(50) NOT NULL COMMENT '物料编码',
  `material_name` varchar(100) DEFAULT NULL COMMENT '物料名称',
  `brand` varchar(50) DEFAULT NULL COMMENT '品牌',
  `product_no` varchar(50) DEFAULT NULL COMMENT '货号',
  `category` varchar(50) DEFAULT NULL COMMENT '产品类别',
  `spec` varchar(100) DEFAULT NULL COMMENT '规格',
  `unit` varchar(20) DEFAULT NULL COMMENT '计量单位',
  `batch_id` bigint NOT NULL COMMENT '批次ID',
  `batch_no` varchar(50) NOT NULL COMMENT '批次号',
  `purify_no` varchar(50) DEFAULT NULL COMMENT '纯化编号',
  `concentration` varchar(50) DEFAULT NULL COMMENT '浓度',
  `expire_date` date DEFAULT NULL COMMENT '失效期',
  `quantity` int NOT NULL DEFAULT '0' COMMENT '数量',
  `is_qc_required` tinyint(1) DEFAULT '0' COMMENT '是否必检（0-否，1-是）',
  `recommend_box_no` varchar(50) DEFAULT NULL COMMENT '推荐盒号',
  `recommend_hole_no` varchar(50) DEFAULT NULL COMMENT '推荐孔号',
  `location_selection_id` bigint DEFAULT NULL COMMENT '库位选择ID',
  `location_fullpath_name` varchar(500) DEFAULT NULL COMMENT '库位全路径名称',
  `price` decimal(18,2) DEFAULT NULL COMMENT '单价',
  `freight` decimal(18,2) DEFAULT NULL COMMENT '运保费',
  `total_amount` decimal(18,2) DEFAULT NULL COMMENT '合计金额',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_account_id` (`account_id`),
  KEY `idx_material` (`material_id`),
  KEY `idx_batch` (`batch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存出入物料明细表';

-- ----------------------------
-- 3. 销售提货单主表 (io_pick_order_sale)
-- ----------------------------
DROP TABLE IF EXISTS `io_pick_order_sale`;
CREATE TABLE `io_pick_order_sale` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `pick_no` varchar(50) NOT NULL COMMENT '提货单号',
  `order_no` varchar(50) NOT NULL COMMENT '订单号',
  `require_delivery_time` datetime DEFAULT NULL COMMENT '要求发货时间',
  `order_date` date DEFAULT NULL COMMENT '订单日期',
  `out_company_code` varchar(50) DEFAULT NULL COMMENT '发货公司编码',
  `out_warehouse_code` varchar(50) DEFAULT NULL COMMENT '发货仓库编码',
  `sales_user_code` varchar(50) DEFAULT NULL COMMENT '销售员工号',
  `sales_user_name` varchar(50) DEFAULT NULL COMMENT '销售员姓名',
  `sales_dept_code` varchar(50) DEFAULT NULL COMMENT '销售部门编号',
  `sales_dept_name` varchar(100) DEFAULT NULL COMMENT '销售部门名称',
  `sales_dept_seq` varchar(50) DEFAULT NULL COMMENT '销售部门序号',
  `customer_code` varchar(50) DEFAULT NULL COMMENT '客户编号',
  `customer_name` varchar(100) DEFAULT NULL COMMENT '客户名称',
  `customer_type` varchar(50) DEFAULT NULL COMMENT '客户类型',
  `order_org_code` varchar(50) DEFAULT NULL COMMENT '订单机构编号',
  `order_org_name` varchar(100) DEFAULT NULL COMMENT '订单机构名称',
  `order_org_u8c_code` varchar(50) DEFAULT NULL COMMENT '订单机构U8c编码',
  `is_special_require` tinyint(1) DEFAULT '0' COMMENT '是否特殊要求（0-否，1-是）',
  `delivery_require_summary` varchar(500) DEFAULT NULL COMMENT '发货要求汇总',
  `delivery_hub` varchar(100) DEFAULT NULL COMMENT '发货集散点',
  `consignee` varchar(50) DEFAULT NULL COMMENT '收货人',
  `phone` varchar(20) DEFAULT NULL COMMENT '收货电话',
  `mobile` varchar(20) DEFAULT NULL COMMENT '收货手机',
  `country` varchar(50) DEFAULT NULL COMMENT '国家',
  `province` varchar(50) DEFAULT NULL COMMENT '省份',
  `city` varchar(50) DEFAULT NULL COMMENT '城市',
  `address` varchar(200) DEFAULT NULL COMMENT '收货地址',
  `settlement_currency` varchar(20) DEFAULT NULL COMMENT '结算货币',
  `status` varchar(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态（待处理/已处理/待退回）',
  `erp_sync_remark` varchar(500) DEFAULT NULL COMMENT 'ERP同步备注',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_pick_no` (`pick_no`, `is_deleted`),
  KEY `idx_order_no` (`order_no`),
  KEY `idx_customer` (`customer_code`),
  KEY `idx_status` (`status`),
  KEY `idx_require_time` (`require_delivery_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='销售提货单主表';

-- ----------------------------
-- 4. 销售提货单物料明细表 (io_pick_order_sale_item)
-- ----------------------------
DROP TABLE IF EXISTS `io_pick_order_sale_item`;
CREATE TABLE `io_pick_order_sale_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `pick_id` bigint NOT NULL COMMENT '提货单ID',
  `outbound_id` bigint DEFAULT NULL COMMENT '出库单ID',
  `qc_record_id` bigint DEFAULT NULL COMMENT '检验单ID',
  `order_no` varchar(50) DEFAULT NULL COMMENT '订单号',
  `sales_user_name` varchar(50) DEFAULT NULL COMMENT '业务员',
  `dept_fullpath_name` varchar(200) DEFAULT NULL COMMENT '部门全路径名称',
  `order_detail_id` bigint DEFAULT NULL COMMENT '订单明细ID',
  `line_no` int DEFAULT NULL COMMENT '行号',
  `material_id` bigint NOT NULL COMMENT '物料ID',
  `material_code` varchar(50) NOT NULL COMMENT '物料编码',
  `material_name` varchar(100) DEFAULT NULL COMMENT '物料名称',
  `export_name` varchar(100) DEFAULT NULL COMMENT '出口名称',
  `brand` varchar(50) DEFAULT NULL COMMENT '品牌',
  `product_no` varchar(50) DEFAULT NULL COMMENT '货号',
  `category` varchar(50) DEFAULT NULL COMMENT '产品类别',
  `spec` varchar(100) DEFAULT NULL COMMENT '规格',
  `unit` varchar(20) DEFAULT NULL COMMENT '计量单位',
  `batch_id` bigint NOT NULL COMMENT '批次ID',
  `batch_no` varchar(50) NOT NULL COMMENT '批次号',
  `purify_no` varchar(50) DEFAULT NULL COMMENT '纯化编号',
  `concentration` varchar(50) DEFAULT NULL COMMENT '浓度',
  `expire_date` date DEFAULT NULL COMMENT '失效期',
  `po_no` varchar(50) DEFAULT NULL COMMENT 'PoNo',
  `quantity` int DEFAULT '0' COMMENT '数量',
  `price` decimal(18,2) DEFAULT NULL COMMENT '单价',
  `freight` decimal(18,2) DEFAULT NULL COMMENT '运保费',
  `total_amount` decimal(18,2) DEFAULT NULL COMMENT '合计金额',
  `order_remark` varchar(500) DEFAULT NULL COMMENT '订单明细备注',
  `status` varchar(20) DEFAULT NULL COMMENT '状态',
  `out_confirm_time` datetime DEFAULT NULL COMMENT '出库确认时间',
  `label_print_count` int DEFAULT '0' COMMENT '标签打印次数',
  `manual_print_count` int DEFAULT '0' COMMENT '说明书打印次数',
  `list_print_count` int DEFAULT '0' COMMENT '清单打印次数',
  `ac_link_count` int DEFAULT '0' COMMENT 'AC关联数量',
  `out_scan_quantity` int DEFAULT '0' COMMENT '出库扫码数量',
  `out_scan_volume` decimal(18,4) DEFAULT NULL COMMENT '出库扫码体积',
  `arrive_scan_quantity` int DEFAULT '0' COMMENT '到货扫码数量',
  `arrive_scan_volume` decimal(18,4) DEFAULT NULL COMMENT '到货扫码体积',
  `delivery_scan_quantity` int DEFAULT '0' COMMENT '送货扫码数量',
  `delivery_scan_volume` decimal(18,4) DEFAULT NULL COMMENT '送货扫码体积',
  `express_input_count` int DEFAULT '0' COMMENT '快递录入次数',
  `express_id` bigint DEFAULT NULL COMMENT '快递ID',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_pick_id` (`pick_id`),
  KEY `idx_outbound_id` (`outbound_id`),
  KEY `idx_material` (`material_id`),
  KEY `idx_batch` (`batch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='销售提货单物料明细表';

-- ----------------------------
-- 5. 多库位选择表 (io_location_selection)
-- ----------------------------
DROP TABLE IF EXISTS `io_location_selection`;
CREATE TABLE `io_location_selection` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `source_table` varchar(50) NOT NULL COMMENT '来源单据表名',
  `source_id` bigint NOT NULL COMMENT '来源单据ID',
  `inventory_id` bigint NOT NULL COMMENT '库存ID',
  `company_code` varchar(50) DEFAULT NULL COMMENT '公司编码',
  `warehouse_code` varchar(50) DEFAULT NULL COMMENT '仓库编码',
  `location_id` bigint NOT NULL COMMENT '库位ID',
  `location_fullpath_name` varchar(500) DEFAULT NULL COMMENT '库位全路径名称',
  `occupy_quantity` int NOT NULL DEFAULT '0' COMMENT '占用数量',
  `scan_quantity` int DEFAULT '0' COMMENT '扫码数量',
  `operator_id` bigint DEFAULT NULL COMMENT '操作员ID',
  `operator_name` varchar(50) DEFAULT NULL COMMENT '操作员',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_source` (`source_table`, `source_id`),
  KEY `idx_inventory_id` (`inventory_id`),
  KEY `idx_location_id` (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='多库位选择表';

-- ----------------------------
-- 6. 随货物品清单表 (io_goods_with)
-- ----------------------------
DROP TABLE IF EXISTS `io_goods_with`;
CREATE TABLE `io_goods_with` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `pick_no` varchar(50) NOT NULL COMMENT '订单号（关联销售提货单）',
  `customer_code` varchar(50) DEFAULT NULL COMMENT '客户编号',
  `customer_name` varchar(100) DEFAULT NULL COMMENT '客户名称',
  `consignee` varchar(50) DEFAULT NULL COMMENT '收货人',
  `phone` varchar(20) DEFAULT NULL COMMENT '收货电话',
  `mobile` varchar(20) DEFAULT NULL COMMENT '收货手机',
  `country` varchar(50) DEFAULT NULL COMMENT '国家',
  `province` varchar(50) DEFAULT NULL COMMENT '省份',
  `city` varchar(50) DEFAULT NULL COMMENT '城市',
  `address` varchar(200) DEFAULT NULL COMMENT '收货地址',
  `goods_content` varchar(500) DEFAULT NULL COMMENT '随货内容',
  `outbound_id` bigint DEFAULT NULL COMMENT '出库单ID',
  `is_special_require` tinyint(1) DEFAULT '0' COMMENT '是否特殊要求（0-否，1-是）',
  `require_delivery_time` datetime DEFAULT NULL COMMENT '要求发货时间',
  `other_require` varchar(500) DEFAULT NULL COMMENT '其他发货要求',
  `status` varchar(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_pick_no` (`pick_no`),
  KEY `idx_customer` (`customer_code`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='随货物品清单表';

-- ----------------------------
-- 7. 调拨提货单主表 (io_pick_order_transfer)
-- ----------------------------
DROP TABLE IF EXISTS `io_pick_order_transfer`;
CREATE TABLE `io_pick_order_transfer` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `pick_no` varchar(50) NOT NULL COMMENT '提货单号',
  `transfer_no` varchar(50) NOT NULL COMMENT '调拨单号',
  `out_company_code` varchar(50) DEFAULT NULL COMMENT '调出公司编码',
  `out_warehouse_code` varchar(50) DEFAULT NULL COMMENT '调出仓库编码',
  `in_company_code` varchar(50) DEFAULT NULL COMMENT '调入公司编码',
  `in_warehouse_code` varchar(50) DEFAULT NULL COMMENT '调入仓库编码',
  `apply_dept_id` bigint DEFAULT NULL COMMENT '申请部门ID',
  `apply_dept_name` varchar(100) DEFAULT NULL COMMENT '申请部门',
  `applicant_id` bigint DEFAULT NULL COMMENT '申请人ID',
  `applicant_name` varchar(50) DEFAULT NULL COMMENT '申请人',
  `apply_date` date DEFAULT NULL COMMENT '申请日期',
  `require_delivery_time` datetime DEFAULT NULL COMMENT '要求发货时间',
  `need_express` tinyint(1) DEFAULT '0' COMMENT '是否需要快递（0-否，1-是）',
  `consignee` varchar(50) DEFAULT NULL COMMENT '收货人',
  `phone` varchar(20) DEFAULT NULL COMMENT '收货电话',
  `mobile` varchar(20) DEFAULT NULL COMMENT '收货手机',
  `country` varchar(50) DEFAULT NULL COMMENT '国家',
  `province` varchar(50) DEFAULT NULL COMMENT '省份',
  `city` varchar(50) DEFAULT NULL COMMENT '城市',
  `address` varchar(200) DEFAULT NULL COMMENT '收货地址',
  `is_special_require` tinyint(1) DEFAULT '0' COMMENT '是否特殊要求（0-否，1-是）',
  `other_require` varchar(500) DEFAULT NULL COMMENT '其他发货要求',
  `status` varchar(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态（待处理/已处理/已完成）',
  `erp_sync_remark` varchar(500) DEFAULT NULL COMMENT 'ERP同步备注',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_pick_no` (`pick_no`, `is_deleted`),
  KEY `idx_transfer_no` (`transfer_no`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='调拨提货单主表';

-- ----------------------------
-- 8. 调拨提货单物料明细表 (io_pick_order_transfer_item)
-- ----------------------------
DROP TABLE IF EXISTS `io_pick_order_transfer_item`;
CREATE TABLE `io_pick_order_transfer_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `pick_id` bigint NOT NULL COMMENT '提货单ID',
  `outbound_id` bigint DEFAULT NULL COMMENT '出库单ID',
  `material_id` bigint NOT NULL COMMENT '物料ID',
  `material_code` varchar(50) NOT NULL COMMENT '物料编码',
  `material_name` varchar(100) DEFAULT NULL COMMENT '物料名称',
  `spec` varchar(100) DEFAULT NULL COMMENT '规格',
  `unit` varchar(20) DEFAULT NULL COMMENT '计量单位',
  `batch_id` bigint NOT NULL COMMENT '批次ID',
  `batch_no` varchar(50) NOT NULL COMMENT '批次号',
  `purify_no` varchar(50) DEFAULT NULL COMMENT '纯化编号',
  `quantity` int DEFAULT '0' COMMENT '数量',
  `status` varchar(20) DEFAULT NULL COMMENT '状态',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_pick_id` (`pick_id`),
  KEY `idx_material` (`material_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='调拨提货单物料明细表';

-- ----------------------------
-- 9. 领用提货单主表 (io_pick_order_consume)
-- ----------------------------
DROP TABLE IF EXISTS `io_pick_order_consume`;
CREATE TABLE `io_pick_order_consume` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `pick_no` varchar(50) NOT NULL COMMENT '提货单号',
  `consume_no` varchar(50) NOT NULL COMMENT '领用单号',
  `out_company_code` varchar(50) DEFAULT NULL COMMENT '领用公司编码',
  `out_warehouse_code` varchar(50) DEFAULT NULL COMMENT '领用仓库编码',
  `apply_dept_id` bigint DEFAULT NULL COMMENT '申请部门ID',
  `apply_dept_name` varchar(100) DEFAULT NULL COMMENT '申请部门',
  `applicant_id` bigint DEFAULT NULL COMMENT '申请人ID',
  `applicant_name` varchar(50) DEFAULT NULL COMMENT '申请人',
  `apply_date` date DEFAULT NULL COMMENT '申请日期',
  `require_delivery_time` datetime DEFAULT NULL COMMENT '要求发货时间',
  `need_express` tinyint(1) DEFAULT '0' COMMENT '是否需要快递（0-否，1-是）',
  `consignee` varchar(50) DEFAULT NULL COMMENT '收货人',
  `phone` varchar(20) DEFAULT NULL COMMENT '收货电话',
  `mobile` varchar(20) DEFAULT NULL COMMENT '收货手机',
  `country` varchar(50) DEFAULT NULL COMMENT '国家',
  `province` varchar(50) DEFAULT NULL COMMENT '省份',
  `city` varchar(50) DEFAULT NULL COMMENT '城市',
  `address` varchar(200) DEFAULT NULL COMMENT '收货地址',
  `is_special_require` tinyint(1) DEFAULT '0' COMMENT '是否特殊要求（0-否，1-是）',
  `other_require` varchar(500) DEFAULT NULL COMMENT '其他发货要求',
  `status` varchar(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态',
  `erp_sync_remark` varchar(500) DEFAULT NULL COMMENT 'ERP同步备注',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_pick_no` (`pick_no`, `is_deleted`),
  KEY `idx_consume_no` (`consume_no`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='领用提货单主表';

-- ----------------------------
-- 10. 领用提货单物料明细表 (io_pick_order_consume_item)
-- ----------------------------
DROP TABLE IF EXISTS `io_pick_order_consume_item`;
CREATE TABLE `io_pick_order_consume_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `pick_id` bigint NOT NULL COMMENT '提货单ID',
  `outbound_id` bigint DEFAULT NULL COMMENT '出库单ID',
  `material_id` bigint NOT NULL COMMENT '物料ID',
  `material_code` varchar(50) NOT NULL COMMENT '物料编码',
  `material_name` varchar(100) DEFAULT NULL COMMENT '物料名称',
  `spec` varchar(100) DEFAULT NULL COMMENT '规格',
  `unit` varchar(20) DEFAULT NULL COMMENT '计量单位',
  `batch_id` bigint NOT NULL COMMENT '批次ID',
  `batch_no` varchar(50) NOT NULL COMMENT '批次号',
  `purify_no` varchar(50) DEFAULT NULL COMMENT '纯化编号',
  `quantity` int DEFAULT '0' COMMENT '数量',
  `status` varchar(20) DEFAULT NULL COMMENT '状态',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_pick_id` (`pick_id`),
  KEY `idx_material` (`material_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='领用提货单物料明细表';

-- ----------------------------
-- 11. CRO提货单主表 (io_pick_order_cro)
-- ----------------------------
DROP TABLE IF EXISTS `io_pick_order_cro`;
CREATE TABLE `io_pick_order_cro` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `pick_no` varchar(50) NOT NULL COMMENT '提货单号',
  `project_no` varchar(50) NOT NULL COMMENT '项目号',
  `out_company_code` varchar(50) DEFAULT NULL COMMENT '发货公司编码',
  `out_warehouse_code` varchar(50) DEFAULT NULL COMMENT '发货仓库编码',
  `apply_dept_id` bigint DEFAULT NULL COMMENT '申请部门ID',
  `apply_dept_name` varchar(100) DEFAULT NULL COMMENT '申请部门',
  `applicant_id` bigint DEFAULT NULL COMMENT '申请人ID',
  `applicant_name` varchar(50) DEFAULT NULL COMMENT '申请人',
  `apply_date` date DEFAULT NULL COMMENT '申请日期',
  `require_delivery_time` datetime DEFAULT NULL COMMENT '要求发货时间',
  `need_express` tinyint(1) DEFAULT '0' COMMENT '是否需要快递（0-否，1-是）',
  `consignee` varchar(50) DEFAULT NULL COMMENT '收货人',
  `phone` varchar(20) DEFAULT NULL COMMENT '收货电话',
  `mobile` varchar(20) DEFAULT NULL COMMENT '收货手机',
  `country` varchar(50) DEFAULT NULL COMMENT '国家',
  `province` varchar(50) DEFAULT NULL COMMENT '省份',
  `city` varchar(50) DEFAULT NULL COMMENT '城市',
  `address` varchar(200) DEFAULT NULL COMMENT '收货地址',
  `is_special_require` tinyint(1) DEFAULT '0' COMMENT '是否特殊要求（0-否，1-是）',
  `other_require` varchar(500) DEFAULT NULL COMMENT '其他发货要求',
  `status` varchar(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态',
  `erp_sync_remark` varchar(500) DEFAULT NULL COMMENT 'ERP同步备注',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_pick_no` (`pick_no`, `is_deleted`),
  KEY `idx_project_no` (`project_no`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='CRO提货单主表';

-- ----------------------------
-- 12. CRO提货单物料明细表 (io_pick_order_cro_item)
-- ----------------------------
DROP TABLE IF EXISTS `io_pick_order_cro_item`;
CREATE TABLE `io_pick_order_cro_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `pick_id` bigint NOT NULL COMMENT '提货单ID',
  `outbound_id` bigint DEFAULT NULL COMMENT '出库单ID',
  `material_id` bigint NOT NULL COMMENT '物料ID',
  `material_code` varchar(50) NOT NULL COMMENT '物料编码',
  `material_name` varchar(100) DEFAULT NULL COMMENT '物料名称',
  `spec` varchar(100) DEFAULT NULL COMMENT '规格',
  `unit` varchar(20) DEFAULT NULL COMMENT '计量单位',
  `batch_id` bigint NOT NULL COMMENT '批次ID',
  `batch_no` varchar(50) NOT NULL COMMENT '批次号',
  `purify_no` varchar(50) DEFAULT NULL COMMENT '纯化编号',
  `quantity` int DEFAULT '0' COMMENT '数量',
  `status` varchar(20) DEFAULT NULL COMMENT '状态',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除（0-正常，1-删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_pick_id` (`pick_id`),
  KEY `idx_material` (`material_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='CRO提货单物料明细表';

SET FOREIGN_KEY_CHECKS = 1;
