# WMS仓库物流系统 - 页面开发指南

> 版本：V1.0
> 日期：2026-04-03
> 适用范围：WMS低代码页面开发

---

## 一、页面分类与开发策略

### 1.1 页面分类

| 类别 | 特征 | 开发方式 | 示例 |
|------|------|----------|------|
| A类 | 纯档案页面 | 低代码 | 仓库档案、物料档案 |
| B类 | 简单单据 | 低代码+扩展 | 采购入库、销售出库 |
| C类 | 复杂业务 | 定制开发 | 质检放行、出库准备 |

### 1.2 选择策略

```
┌─────────────────────────────────────────────────────────────┐
│                     页面开发决策树                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  页面类型？                                                  │
│    │                                                        │
│    ├── 纯档案页面（增删改查） → 选择A类（低代码）            │
│    │                                                        │
│    ├── 单表+状态机 → 选择B类（低代码+扩展）                  │
│    │                                                        │
│    └── 复杂业务                    → 选择C类（定制开发）      │
│            │                                                │
│            ├── 多行明细？                                    │
│            ├── 多阶段流程？                                  │
│            ├── 特殊交互（扫码等）？                          │
│            └── 外部系统对接？                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 二、A类页面开发（低代码）

### 2.1 适用场景

- 纯档案页面（增删改查、启用停用）
- 列表+表单结构
- 简单的业务校验
- 标准的CRUD操作

### 2.2 已实现页面清单

| 页面 | 表编码 | 说明 | 状态 |
|------|--------|------|------|
| 仓库档案 | WMS0010 | 仓库管理 | ✅ 已实现 |
| 库位档案 | WMS0020 | 库位层级 | 🔄 开发中 |
| 物料档案 | WMS0030 | 物料管理 | 🔄 开发中 |
| 基础数据 | WMS0040 | 枚举/字典 | 🔄 开发中 |
| 查询物料 | WMS0050 | 库存查询 | 🔄 开发中 |
| 查询库位 | WMS0060 | 库位查询 | 🔄 开发中 |
| 质检标准 | WMS0215 | 质检标准 | 🔄 开发中 |

### 2.3 开发流程

**Step 1: 后端配置Meta数据**

```sql
-- 1. 插入表元数据
INSERT INTO sys_table_meta (
  table_code, table_name, module, crud_prefix, is_enabled, created_at
) VALUES (
  'WMS0090', '生产入库', 'inbound', '/api/inbound/production', 1, NOW()
);

-- 2. 获取表ID并插入字段元数据
SET @table_id = LAST_INSERT_ID();

INSERT INTO sys_column_meta (
  table_id, column_code, column_name, field_type, data_type,
  is_required, is_show_in_list, is_show_in_form, list_width, sort_order
) VALUES
  (@table_id, 'inbound_no', '入库单号', 'text', 'string', 1, 1, 1, 120, 1),
  (@table_id, 'warehouse_id', '仓库', 'select', 'number', 1, 1, 1, 100, 2),
  (@table_id, 'inbound_date', '入库日期', 'date', 'date', 1, 1, 1, 120, 3),
  (@table_id, 'total_quantity', '总数量', 'number', 'decimal', 0, 1, 1, 100, 4),
  (@table_id, 'status', '状态', 'select', 'string', 1, 1, 1, 100, 5),
  (@table_id, 'remark', '备注', 'textarea', 'string', 0, 0, 1, 24, 6),
  (@table_id, 'is_enabled', '启用', 'switch', 'number', 1, 1, 0, 80, 7);

-- 3. 插入操作元数据
INSERT INTO sys_table_operation (
  table_id, operation_code, operation_name, button_type, position, permission
) VALUES
  (@table_id, 'create', '新建', 'primary', 'toolbar', 'wms:inbound:add'),
  (@table_id, 'edit', '编辑', 'default', 'row', 'wms:inbound:edit'),
  (@table_id, 'delete', '删除', 'danger', 'row', 'wms:inbound:remove'),
  (@table_id, 'toggle', '启用/停用', 'default', 'row', 'wms:inbound:toggle'),
  (@table_id, 'export', '导出', 'default', 'toolbar', 'wms:inbound:export');
```

**Step 2: 前端创建页面**

```vue
<!-- views/lowcode/wms0090/index.vue -->
<template>
  <LowcodePage
    table-code="WMS0090"
    page-title="生产入库"
    page-desc="管理生产入库单据"
    crud-prefix="/api/inbound/production"
    :show-stats="true"
    :stats-config="statsConfig"
    :enable-selection="true"
  />
</template>

<script setup lang="ts">
import LowcodePage from '#/lowcode/LowcodePage.vue';
import type { StatsCardConfig } from '#/lowcode/types';

const statsConfig: StatsCardConfig[] = [
  { key: 'total', label: '总单数', icon: 'material-symbols:receipt', color: '#1677ff', field: 'total' },
  { key: 'pending', label: '待入库', icon: 'material-symbols:pending', color: '#faad14', field: 'pending' },
  { key: 'completed', label: '已入库', icon: 'material-symbols:check-circle', color: '#52c41a', field: 'completed' },
];
</script>
```

**Step 3: 配置路由**

```typescript
// 在路由配置文件中添加
{
  path: '/lowcode/wms0090',
  name: 'Wms0090',
  component: () => import('#/views/lowcode/wms0090/index.vue'),
  meta: {
    title: '生产入库',
    icon: 'material-symbols:inventory',
    permission: ['wms:inbound:view'],
  },
}
```

**Step 4: 配置菜单**

在系统管理的菜单管理中添加菜单记录：
- 菜单编码：wms0090
- 菜单名称：生产入库
- 路由路径：/lowcode/wms0090
- 组件路径：/views/lowcode/wms0090/index.vue

---

## 三、B类页面开发（低代码+扩展）

### 3.1 适用场景

- 单表+状态机
- 简单的业务操作
- 部分字段需要自定义渲染
- 需要扩展统计卡片

### 3.2 开发流程

**Step 1: 基础配置（同A类）**

**Step 2: 创建扩展页面**

```vue
<!-- views/lowcode/wms0140-custom/index.vue -->
<template>
  <div>
    <!-- 统计卡片 -->
    <div class="mb-6 grid grid-cols-4 gap-4">
      <Card v-for="stat in statsConfig" :key="stat.key" class="stat-card">
        <div class="flex items-center">
          <div class="mr-4 flex h-12 w-12 items-center justify-center rounded-full"
               :style="{ backgroundColor: `${stat.color}20` }">
            <IconifyIcon :icon="stat.icon" class="text-xl" :style="{ color: stat.color }" />
          </div>
          <div>
            <div class="text-sm text-gray-500">{{ stat.label }}</div>
            <div class="text-2xl font-bold">{{ stats[stat.key] }}</div>
          </div>
        </div>
      </Card>
    </div>

    <!-- 低代码列表 -->
    <LowcodePage
      ref="lowcodeRef"
      table-code="WMS0140"
      page-title="销售出库"
      page-desc="管理销售出库单据"
      crud-prefix="/api/outbound/sales"
      :show-stats="false"
      @edit="handleEdit"
      @formSuccess="handleFormSuccess"
    >
      <!-- 自定义列插槽 -->
      <template #bodyCell="{ column, record }">
        <!-- 状态列自定义 -->
        <template v-if="column.key === 'status'">
          <Tag :color="getStatusColor(record.status)">
            {{ getStatusLabel(record.status) }}
          </Tag>
        </template>

        <!-- 操作列扩展 -->
        <template v-else-if="column.key === 'action'">
          <div class="flex items-center gap-2">
            <template v-if="record.status === 'PENDING'">
              <Button type="link" size="small" @click="handleAllocate(record)">
                库位分配
              </Button>
            </template>
            <Button type="link" size="small" @click="handlePrint(record)">
              打印
            </Button>
          </div>
        </template>
      </template>
    </LowcodePage>

    <!-- 自定义表单 -->
    <SalesOutboundDrawer
      v-model:open="drawerVisible"
      :record="currentRecord"
      @success="handleFormSuccess"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { Card, Tag, Button } from 'ant-design-vue';
import { IconifyIcon } from '@vben/icons';
import LowcodePage from '#/lowcode/LowcodePage.vue';
import SalesOutboundDrawer from './modules/SalesOutboundDrawer.vue';
import { outboundApi } from '#/api/modules/outbound-api';
import type { StatsCardConfig } from '#/lowcode/types';

const lowcodeRef = ref();
const statsConfig: StatsCardConfig[] = [
  { key: 'total', label: '总单数', icon: 'material-symbols:receipt', color: '#1677ff', field: 'total' },
  { key: 'pending', label: '待出库', icon: 'material-symbols:pending', color: '#faad14', field: 'pending' },
  { key: 'allocated', label: '已分配', icon: 'material-symbols:inventory', color: '#1890ff', field: 'allocated' },
  { key: 'completed', label: '已出库', icon: 'material-symbols:check-circle', color: '#52c41a', field: 'completed' },
];

const stats = reactive({ total: 0, pending: 0, allocated: 0, completed: 0 });

const drawerVisible = ref(false);
const currentRecord = ref<any>(null);

function getStatusColor(status: string) {
  const map: Record<string, string> = {
    PENDING: 'default',
    ALLOCATED: 'processing',
    PRINTED: 'warning',
    COMPLETED: 'success',
  };
  return map[status] || 'default';
}

function getStatusLabel(status: string) {
  const map: Record<string, string> = {
    PENDING: '待出库',
    ALLOCATED: '已分配',
    PRINTED: '已打印',
    COMPLETED: '已完成',
  };
  return map[status] || status;
}

function handleEdit(record: any) {
  currentRecord.value = record;
  drawerVisible.value = true;
}

function handleAllocate(record: any) {
  // 库位分配逻辑
  console.log('库位分配', record);
}

function handlePrint(record: any) {
  // 打印逻辑
  console.log('打印', record);
}

function handleFormSuccess() {
  lowcodeRef.value?.reload();
}

onMounted(async () => {
  // 加载统计数据
  // const res = await outboundApi.getStats();
  // Object.assign(stats, res);
});
</script>
```

**Step 3: 后端实现业务接口**

```java
// 库位分配接口
@RestController
@RequestMapping("/api/outbound/sales")
@RequiredArgsConstructor
public class SalesOutboundController {
    
    private final SalesOutboundService salesOutboundService;
    
    @PostMapping("/{id}/allocate")
    @RequiresPermissions("wms:outbound:allocate")
    public Result<Void> allocate(
            @PathVariable Long id,
            @RequestBody AllocateRequest request) {
        salesOutboundService.allocateLocation(id, request);
        return Result.success();
    }
    
    @PostMapping("/{id}/print")
    @RequiresPermissions("wms:outbound:print")
    public Result<String> print(@PathVariable Long id) {
        String url = salesOutboundService.printLabel(id);
        return Result.success(url);
    }
}
```

---

## 四、C类页面开发（定制开发）

### 4.1 适用场景

- 多行明细表
- 复杂状态机
- 特殊交互（扫码、打印等）
- 外部系统对接
- 非标准表单布局

### 4.2 开发流程

**Step 1: 创建页面目录**

```
views/wms/outbound-order/
├── index.vue                 # 主页面
└── modules/
    ├── PrepareForm.vue       # 出库准备表单
    ├── OutboundDetail.vue    # 出库明细组件
    └── PrintPreview.vue      # 打印预览组件
```

**Step 2: 开发主页面**

```vue
<!-- views/wms/outbound-order/index.vue -->
<template>
  <Page auto-content-height>
    <div class="outbound-order p-4">
      <div class="mb-6 flex items-center justify-between">
        <h1 class="text-2xl font-bold">出库准备</h1>
        <div class="flex gap-2">
          <Button @click="handleBatchAllocate">批量分配</Button>
          <Button @click="handleBatchPrint">批量打印</Button>
          <Button type="primary" @click="handleCreate">新建</Button>
        </div>
      </div>

      <!-- 搜索区域 -->
      <Card class="mb-4">
        <Form layout="inline" :model="searchForm">
          <FormItem label="出库单号">
            <Input v-model:value="searchForm.orderNo" placeholder="请输入单号" />
          </FormItem>
          <FormItem label="状态">
            <Select v-model:value="searchForm.status" placeholder="请选择状态">
              <SelectOption value="PENDING">待分配</SelectOption>
              <SelectOption value="ALLOCATED">已分配</SelectOption>
              <SelectOption value="PRINTED">已打印</SelectOption>
            </Select>
          </FormItem>
          <FormItem>
            <Space>
              <Button type="primary" @click="handleSearch">查询</Button>
              <Button @click="handleReset">重置</Button>
            </Space>
          </FormItem>
        </Form>
      </Card>

      <!-- 数据表格 -->
      <Table
        :columns="columns"
        :data-source="dataList"
        :loading="loading"
        :pagination="pagination"
        :row-selection="rowSelection"
        row-key="id"
        @change="handleTableChange"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <StatusTag :status="record.status" />
          </template>
          <template v-else-if="column.key === 'action'">
            <Space>
              <Button type="link" size="small" @click="handleAllocate(record)">分配</Button>
              <Button type="link" size="small" @click="handlePreview(record)">预览</Button>
              <Button type="link" size="small" @click="handleScan(record)">扫码</Button>
            </Space>
          </template>
        </template>
      </Table>

      <!-- 出库准备弹窗 -->
      <PrepareModal
        v-model:open="prepareVisible"
        :record="currentRecord"
        @success="handlePrepareSuccess"
      />

      <!-- 扫码弹窗 -->
      <ScanModal
        v-model:open="scanVisible"
        :record="currentRecord"
        @success="handleScanSuccess"
      />

      <!-- 打印预览 -->
      <PrintPreview
        v-model:open="printVisible"
        :record="currentRecord"
      />
    </div>
  </Page>
</template>
```

**Step 3: 开发业务组件**

```vue
<!-- modules/PrepareModal.vue -->
<template>
  <Modal
    v-model:open="internalOpen"
    title="出库准备"
    width="900px"
    @ok="handleSubmit"
  >
    <Form :model="formData" :label-col="{ span: 6 }">
      <Row :gutter="16">
        <Col :span="12">
          <FormItem label="出库单号">
            <Input :value="currentRecord?.orderNo" disabled />
          </FormItem>
        </Col>
        <Col :span="12">
          <FormItem label="客户名称">
            <Input :value="currentRecord?.customerName" disabled />
          </FormItem>
        </Col>
      </Row>

      <!-- 明细表格 -->
      <Table
        :columns="detailColumns"
        :data-source="formData.details"
        :pagination="false"
        size="small"
      >
        <template #bodyCell="{ column, record, index }">
          <template v-if="column.key === 'locationId'">
            <Select
              v-model:value="record.locationId"
              placeholder="请选择库位"
              @change="handleLocationChange(record)"
            >
              <SelectOption
                v-for="loc in availableLocations"
                :key="loc.id"
                :value="loc.id"
              >
                {{ loc.locationCode }} ({{ loc.availableQty }})
              </SelectOption>
            </Select>
          </template>
          <template v-else-if="column.key === 'quantity'">
            <InputNumber
              v-model:value="record.quantity"
              :min="0"
              :max="record.availableQty"
              @change="handleQuantityChange(record)"
            />
          </template>
        </template>
      </Table>
    </Form>
  </Modal>
</template>
```

---

## 五、通用页面模板

### 5.1 标准页面结构

```
页面/
├── index.vue              # 主页面（必须）
├── components/
│   ├── SearchBar.vue       # 搜索栏组件（可选）
│   ├── DataTable.vue       # 数据表格组件（可选）
│   └── DetailDrawer.vue    # 详情抽屉（可选）
├── hooks/
│   ├── usePage.ts         # 页面逻辑Hook（可选）
│   └── useForm.ts          # 表单逻辑Hook（可选）
└── types/
    └── index.ts           # 类型定义（可选）
```

### 5.2 页面开发自检清单

- [ ] 页面加载显示loading
- [ ] 空数据状态处理
- [ ] 分页组件正确使用
- [ ] 搜索/重置功能完整
- [ ] 新增/编辑/删除功能完整
- [ ] 状态转换正确
- [ ] 错误提示友好
- [ ] 权限控制正确
- [ ] 国际化文本处理
- [ ] 响应式布局适配

---

## 六、后端接口开发

### 6.1 CRUD接口实现

```java
// 1. Mapper
@Mapper
public interface OutboundPrepareMapper extends BaseMapper<OutboundPrepareDO> {
    Page<OutboundPrepareDO> selectPageList(
        @Param("params") OutboundPrepareRequest params,
        Page<OutboundPrepareDO> page);
}

// 2. Service
public interface OutboundPrepareService {
    PageResult<OutboundPrepareVO> pagePrepare(OutboundPrepareRequest params, String tenantId);
    void allocateLocation(Long id, AllocateRequest request, String userId);
}

@Service
@RequiredArgsConstructor
@Transactional
public class OutboundPrepareServiceImpl implements OutboundPrepareService {
    
    private final OutboundPrepareMapper mapper;
    private final InventoryService inventoryService;
    
    @Override
    @Transactional(readOnly = true)
    public PageResult<OutboundPrepareVO> pagePrepare(OutboundPrepareRequest params, String tenantId) {
        Page<OutboundPrepareDO> page = Page.of(params.getPageNum(), params.getPageSize());
        Page<OutboundPrepareDO> result = mapper.selectPageList(params, page);
        return PageResult.of(
            result.getRecords().stream()
                .map(this::convertToVO)
                .collect(Collectors.toList()),
            result.getTotal()
        );
    }
    
    @Override
    public void allocateLocation(Long id, AllocateRequest request, String userId) {
        OutboundPrepareDO prepare = mapper.selectById(id);
        if (prepare == null) {
            throw new BusinessException("PREPARE_NOT_FOUND", "出库准备单不存在");
        }
        
        // 校验状态
        if (!"PENDING".equals(prepare.getStatus())) {
            throw new BusinessException("STATUS_NOT_ALLOWED", "当前状态不允许分配");
        }
        
        // 分配库位
        for (AllocateItem item : request.getItems()) {
            inventoryService.lockQuantity(
                item.getLocationId(),
                item.getMaterialId(),
                item.getBatchId(),
                item.getQuantity()
            );
        }
        
        // 更新状态
        prepare.setStatus("ALLOCATED");
        prepare.setUpdatedBy(userId);
        prepare.setUpdatedAt(LocalDateTime.now());
        mapper.updateById(prepare);
        
        log.info("Outbound prepare allocated: id={}, operator={}", id, userId);
    }
}

// 3. Controller
@RestController
@RequestMapping("/api/outbound-order/prepare")
@RequiredArgsConstructor
public class OutboundPrepareController {
    
    private final OutboundPrepareService service;
    
    @GetMapping
    public Result<PageResult<OutboundPrepareVO>> list(
            OutboundPrepareRequest params,
            @RequestHeader("X-Tenant-Id") String tenantId) {
        return Result.success(service.pagePrepare(params, tenantId));
    }
    
    @PostMapping("/{id}/allocate")
    @RequiresPermissions("wms:outbound:allocate")
    public Result<Void> allocate(
            @PathVariable Long id,
            @RequestBody AllocateRequest request,
            @RequestHeader("X-Tenant-Id") String tenantId,
            @RequestHeader("X-User-Id") String userId) {
        service.allocateLocation(id, request, userId);
        return Result.success();
    }
}
```

---

## 七、测试要点

### 7.1 功能测试

- [ ] 列表查询功能正常
- [ ] 新增数据正确
- [ ] 编辑数据正确
- [ ] 删除数据正确
- [ ] 状态转换正确
- [ ] 权限控制正确
- [ ] 分页功能正常
- [ ] 搜索功能正常
- [ ] 导出功能正常

### 7.2 边界测试

- [ ] 空数据列表展示
- [ ] 超长文本处理
- [ ] 特殊字符处理
- [ ] 并发操作处理
- [ ] 网络异常处理
- [ ] 数据校验正确提示
