# WMS-Backend 代码索引

> 版本：V1.0
> 日期：2026-04-06

---

## 项目结构

```
WMS-backend/
├── wms-center-api/        # API 层（Request/Response DTO）
├── wms-center-biz/       # 业务逻辑层（Biz）
├── wms-center-common/    # 公共模块
├── wms-center-dao/       # 数据访问层（Entity/Mapper）
├── wms-center-domain/    # 领域模型（Converter）
├── wms-center-service/   # 服务层（Service）
└── wms-center-web/      # Web 层（Controller）
```

---

## 分层说明

| 层级 | 包路径 | 说明 |
|------|--------|------|
| Web | `com.abtk.product.web.controller` | Controller |
| Service | `com.abtk.product.service` | Service 接口和实现 |
| Biz | `com.abtk.product.biz` | 业务编排 |
| Dao | `com.abtk.product.dao` | Mapper + Entity |
| Domain | `com.abtk.product.domain` | Converter 转换器 |
| Common | `com.abtk.product.common` | 工具类、异常、常量 |
| API | `com.abtk.product.api` | Request/Response DTO |

---

## 核心 Entity（DO）

| Entity | 说明 | 路径 |
|---------|------|------|
| Warehouse | 仓库 | `wms-center-dao/.../entity/Warehouse.java` |
| WmsLocation | 库位 | `wms-center-dao/.../entity/WmsLocation.java` |
| Material | 物料 | `wms-center-dao/.../entity/Material.java` |
| ColumnMeta | 字段元数据 | `wms-center-dao/.../entity/ColumnMeta.java` |
| TableMeta | 表元数据 | `wms-center-dao/.../entity/TableMeta.java` |
| WmsTableMeta | 表元数据(新) | `wms-center-dao/.../entity/WmsTableMeta.java` |
| SysUser | 系统用户 | `wms-center-dao/.../entity/SysUser.java` |
| SysRole | 系统角色 | `wms-center-dao/.../entity/SysRole.java` |
| SysMenu | 系统菜单 | `wms-center-dao/.../entity/SysMenu.java` |
| SysDept | 组织机构 | `wms-center-dao/.../entity/SysDept.java` |
| InventoryEntity | 库存 | `wms-center-dao/.../entity/InventoryEntity.java` |

---

## 核心 Mapper

| Mapper | 说明 | 路径 |
|--------|------|------|
| WarehouseMapper | 仓库 | `wms-center-dao/.../mapper/WarehouseMapper.java` |
| WmsLocationMapper | 库位 | `wms-center-dao/.../mapper/WmsLocationMapper.java` |
| MaterialMapper | 物料 | `wms-center-dao/.../mapper/MaterialMapper.java` |
| ColumnMetaMapper | 字段元数据 | `wms-center-dao/.../mapper/ColumnMetaMapper.java` |
| WmsTableMetaMapper | 表元数据 | `wms-center-dao/.../mapper/WmsTableMetaMapper.java` |
| SysUserMapper | 用户 | `wms-center-dao/.../mapper/SysUserMapper.java` |
| SysRoleMapper | 角色 | `wms-center-dao/.../mapper/SysRoleMapper.java` |
| SysMenuMapper | 菜单 | `wms-center-dao/.../mapper/SysMenuMapper.java` |

---

## 核心 Service

| Service | 说明 | 路径 |
|---------|------|------|
| WarehouseService | 仓库服务 | `wms-center-service/.../sys/service/WarehouseService.java` |
| IWmsTableMetaService | 表元数据服务 | `wms-center-service/.../sys/service/IWmsTableMetaService.java` |
| MaterialService | 物料服务 | `wms-center-service/.../sys/service/MaterialService.java` |
| SysUserService | 用户服务 | `wms-center-service/.../system/ISysUserService.java` |
| SysMenuService | 菜单服务 | `wms-center-service/.../system/ISysMenuService.java` |
| TableMetaService | 元数据服务 | `wms-center-service/.../sys/service/TableMetaService.java` |

---

## 核心 Controller

| Controller | 说明 | 路径 |
|------------|------|------|
| WarehouseController | 仓库 | `wms-center-web/.../controller/sys/WarehouseController.java` |
| TableMetaController | 表元数据 | `wms-center-web/.../controller/sys/TableMetaController.java` |
| MaterialController | 物料 | `wms-center-web/.../controller/sys/MaterialController.java` |
| WmsLocationController | 库位 | `wms-center-web/.../controller/location/WmsLocationController.java` |
| SysUserController | 用户 | `wms-center-web/.../controller/system/SysUserController.java` |
| SysMenuController | 菜单 | `wms-center-web/.../controller/system/SysMenuController.java` |
| CrudController | 低代码CRUD | `wms-center-web/.../controller/sys/CrudController.java` |
| LowcodeCrudController | 低代码CRUD | `wms-center-web/.../controller/sys/LowcodeCrudController.java` |

---

## 低代码相关

| 类 | 说明 | 路径 |
|----|------|------|
| LowcodeMapper | 低代码Mapper | `wms-center-dao/.../mapper/LowcodeMapper.java` |
| TableMetaService | 元数据服务 | `wms-center-service/.../sys/service/TableMetaService.java` |
| CrudController | CRUD控制器 | `wms-center-web/.../controller/sys/CrudController.java` |
| MetaController | 元数据控制器 | `wms-center-web/.../controller/sys/MetaController.java` |

---

## 公共组件

| 类 | 说明 | 路径 |
|----|------|------|
| BaseController | 基础控制器 | `wms-center-common/.../web/controller/BaseController.java` |
| TableDataInfo | 分页结果 | `wms-center-common/.../web/page/TableDataInfo.java` |
| R | 统一响应 | `wms-center-common/.../domain/R.java` |
| SecurityUtils | 安全工具 | `wms-center-service/.../security/utils/SecurityUtils.java` |
| TokenService | Token服务 | `wms-center-service/.../security/TokenService.java` |

---

## API 模块路径

| 模块 | Controller路径前缀 |
|------|-------------------|
| system | `/api/system/` |
| sys | `/api/sys/` |
| location | `/api/location/` |
| inv | `/api/inv/` |
| lowcode | `/api/lowcode/` |

---

## 数据库表

| 表名 | 说明 |
|------|------|
| wms_warehouse | 仓库表 |
| wms_location | 库位表 |
| wms_material | 物料表 |
| wms_material_meta_data | 物料元数据 |
| sys_table_meta | 表元数据 |
| sys_column_meta | 字段元数据 |
| sys_user | 用户表 |
| sys_role | 角色表 |
| sys_menu | 菜单表 |
| sys_dept | 部门表 |
| sys_dict_type | 字典类型 |
| sys_dict_data | 字典数据 |

---

## 开发规范

### 新增后端接口步骤

1. **Entity** - 在 `wms-center-dao/.../entity/` 创建 Entity
2. **Mapper** - 在 `wms-center-dao/.../mapper/` 创建 Mapper 接口
3. **Service** - 在 `wms-center-service/.../sys/service/` 创建 Service 接口和实现
4. **Controller** - 在 `wms-center-web/.../controller/` 创建 Controller
5. **Request/Response** - 在 `wms-center-api/.../domain/request/` 和 `response/` 创建 DTO

### 命名规范

- Entity: `WmsXxx.java`（如 `WmsWarehouse`）
- Mapper: `XxxMapper.java`（如 `WarehouseMapper`）
- Service: `IXxxService.java` + `XxxServiceImpl.java`
- Controller: `XxxController.java`（如 `WarehouseController`）
- Request DTO: `XxxRequest.java`
- Response DTO: `XxxResponse.java`
