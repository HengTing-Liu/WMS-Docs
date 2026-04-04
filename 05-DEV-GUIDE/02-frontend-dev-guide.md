# WMS仓库物流系统 - 前端开发规范

> 版本：V1.0
> 日期：2026-04-03
> 适用范围：WMS前端Vue3开发

---

## 一、项目结构

### 1.1 前端目录结构

```
WMS-frontend/
├── apps/
│   └── web-antd/          # 主应用
│       └── src/
│           ├── views/      # 页面
│           │   ├── lowcode/        # 低代码页面
│           │   ├── base/           # 基础档案
│           │   ├── system/         # 系统管理
│           │   └── wms/            # WMS业务
│           ├── components/  # 组件
│           │   ├── common/        # 通用组件
│           │   └── business/     # 业务组件
│           ├── lowcode/    # 低代码引擎
│           ├── api/        # API层
│           │   ├── core/         # 核心API
│           │   ├── modules/       # 分模块API
│           │   └── request.ts      # Axios封装
│           ├── layouts/    # 布局
│           ├── router/     # 路由
│           ├── store/       # 状态管理
│           ├── locales/     # 国际化
│           ├── styles/      # 样式
│           └── utils/       # 工具
│
└── packages/              # 共享包
    ├── @core/             # 核心包
    ├── effects/           # 效果包
    ├── constants/         # 常量
    ├── icons/             # 图标
    ├── styles/            # 样式
    ├── types/             # 类型
    └── utils/             # 工具
```

### 1.2 页面目录结构

```
views/
├── lowcode/                      # 低代码页面
│   ├── wms0010/                  # 仓库档案
│   │   └── index.vue
│   └── wms0020/                  # 库位档案
│       └── index.vue
│
├── base/                         # 基础档案
│   ├── warehouse/                 # 仓库
│   │   ├── index.vue
│   │   └── modules/
│   │       └── warehouseModal.vue
│   ├── material/                # 物料
│   │   └── index.vue
│   └── location/                 # 库位
│       └── index.vue
│
├── system/                       # 系统管理
│   ├── user/                    # 用户管理
│   │   ├── index.vue
│   │   └── modules/
│   ├── roleManager/            # 角色管理
│   │   └── index.vue
│   └── menu/                    # 菜单管理
│       └── index.vue
│
└── wms/                         # WMS业务
    ├── inbound/                 # 入库
    │   ├── production/         # 生产入库
    │   └── purchase/           # 采购入库
    └── outbound/                # 出库
        └── sales/              # 销售出库
```

---

## 二、命名规范

### 2.1 文件命名

| 类型 | 规范 | 示例 |
|------|------|------|
| Vue文件 | PascalCase | WarehouseList.vue |
| 组件目录 | kebab-case | warehouse-list/ |
| 组件文件 | PascalCase | WarehouseForm.vue |
| API文件 | kebab-case | warehouse-api.ts |
| 类型文件 | kebab-case | warehouse-type.ts |
| 工具文件 | kebab-case | format-date.ts |

### 2.2 变量命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 普通变量 | camelCase | warehouseList |
| 常量 | UPPER_SNAKE | MAX_RETRY_COUNT |
| 组件引用 | PascalCase | WarehouseForm |
| Props | camelCase | pageTitle |
| Emits | camelCase | formSuccess |
| 计算属性 | camelCase | computedName |
| 方法 | camelCase/动词 | handleSubmit |

### 2.3 API命名

| 类型 | 规范 | 示例 |
|------|------|------|
| API模块 | xxxApi | warehouseApi |
| 获取列表 | getXxxList | getWarehouseList |
| 获取详情 | getXxxById | getWarehouseById |
| 新增 | createXxx | createWarehouse |
| 修改 | updateXxx | updateWarehouse |
| 删除 | deleteXxx | deleteWarehouse |
| 导出 | exportXxx | exportWarehouse |
| 导入 | importXxx | importWarehouse |

---

## 三、API层规范

### 3.1 Axios封装

```typescript
// api/request.ts
import axios, { AxiosInstance, AxiosResponse } from 'axios';
import { ElMessage } from 'element-plus';
import { useUserStore } from '@/store/modules/user';

const request: AxiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE,
  timeout: 15000,
  headers: { 'Content-Type': 'application/json' },
});

// 请求拦截器
request.interceptors.request.use((config) => {
  const token = localStorage.getItem('wms_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  config.headers['X-Tenant-Id'] = localStorage.getItem('wms_tenant_id') || 'default';
  config.headers['X-Request-Id'] = crypto.randomUUID();
  return config;
});

// 响应拦截器
request.interceptors.response.use(
  (response: AxiosResponse) => {
    const res = response.data;
    if (res.code === 200) return res.data;
    ElMessage.error(res.message || '请求失败');
    return Promise.reject(new Error(res.message));
  },
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('wms_token');
      window.location.href = '/login';
    }
    ElMessage.error(error.response?.data?.message || '请求失败');
    return Promise.reject(error);
  }
);

export default request;
```

### 3.2 API模块定义

```typescript
// api/modules/warehouse-api.ts
import request from '../request';
import type { WarehouseDTO, WarehouseRequest, WarehouseCreateRequest } from '@/types';

export const warehouseApi = {
  /**
   * 获取仓库列表
   */
  getList(params: WarehouseRequest) {
    return request.get<{ rows: WarehouseDTO[]; total: number }>('/api/base/warehouse', { params });
  },

  /**
   * 获取仓库详情
   */
  getById(id: number) {
    return request.get<WarehouseDTO>(`/api/base/warehouse/${id}`);
  },

  /**
   * 新增仓库
   */
  create(data: WarehouseCreateRequest) {
    return request.post<{ id: number }>('/api/base/warehouse', data);
  },

  /**
   * 修改仓库
   */
  update(id: number, data: WarehouseCreateRequest) {
    return request.put<void>(`/api/base/warehouse/${id}`, data);
  },

  /**
   * 删除仓库
   */
  delete(id: number) {
    return request.delete<void>(`/api/base/warehouse/${id}`);
  },

  /**
   * 启用/停用仓库
   */
  toggle(id: number, isEnabled: number) {
    return request.put<void>(`/api/base/warehouse/${id}/toggle`, { isEnabled });
  },

  /**
   * 导出仓库
   */
  export(params: WarehouseRequest) {
    return request.get('/api/base/warehouse/export', { params, responseType: 'blob' });
  },
};
```

---

## 四、页面代码示例

### 4.1 标准列表页

```vue
<template>
  <Page auto-content-height>
    <div class="warehouse-list p-4">
      <!-- 页面标题 -->
      <div class="mb-6 flex items-center justify-between">
        <div>
          <h1 class="text-2xl font-bold text-gray-800">仓库档案</h1>
          <p class="mt-1 text-sm text-gray-500">管理仓库基本信息、温区、质检分区等</p>
        </div>
        <div class="flex gap-2">
          <a-button @click="handleExport">
            <IconifyIcon icon="material-symbols:file-download" class="mr-1" />
            导出
          </a-button>
          <a-button type="primary" @click="handleCreate">
            <IconifyIcon icon="material-symbols:add" class="mr-1" />
            新增
          </a-button>
        </div>
      </div>

      <!-- 搜索栏 -->
      <Card class="mb-4">
        <WmsSearchBar
          v-model="searchForm"
          :remote-fields-url="searchFieldsUrl"
          cache-key="warehouse-fields-cache"
          @search="handleSearch"
          @reset="handleReset"
        />
      </Card>

      <!-- 统计卡片 -->
      <div class="mb-6 grid grid-cols-4 gap-4">
        <Card v-for="stat in statsConfig" :key="stat.key" class="stat-card">
          <div class="flex items-center">
            <div class="mr-4 flex h-12 w-12 items-center justify-center rounded-full" :style="{ backgroundColor: `${stat.color}20` }">
              <IconifyIcon :icon="stat.icon" class="text-xl" :style="{ color: stat.color }" />
            </div>
            <div>
              <div class="text-sm text-gray-500">{{ stat.label }}</div>
              <div class="text-2xl font-bold">{{ stats[stat.key] }}</div>
            </div>
          </div>
        </Card>
      </div>

      <!-- 数据表格 -->
      <WmsDataTable
        :columns="columns"
        :data-source="dataList"
        :loading="loading"
        :pagination="paginationConfig"
        row-key="id"
        @page-change="onPageChange"
        @selection-change="onSelectionChange"
      >
        <template #bodyCell="{ column, record, index }">
          <!-- 序号 -->
          <template v-if="column.key === 'seq'">
            {{ (pagination.current - 1) * pagination.pageSize + index + 1 }}
          </template>

          <!-- 状态 -->
          <template v-else-if="column.key === 'isEnabled'">
            <Tag :color="record.isEnabled === 1 ? 'success' : 'default'">
              {{ record.isEnabled === 1 ? '启用' : '停用' }}
            </Tag>
          </template>

          <!-- 操作 -->
          <template v-else-if="column.key === 'action'">
            <div class="flex items-center gap-2">
              <Tooltip title="编辑">
                <Button type="link" size="small" @click="handleEdit(record)">
                  <IconifyIcon icon="material-symbols:edit" class="text-lg" />
                </Button>
              </Tooltip>
              <Tooltip :title="record.isEnabled === 1 ? '停用' : '启用'">
                <Button type="link" size="small" @click="handleToggle(record)">
                  <IconifyIcon
                    :icon="record.isEnabled === 1 ? 'material-symbols:toggle-on' : 'material-symbols:toggle-off'"
                    :class="record.isEnabled === 1 ? 'text-green-500 text-2xl' : 'text-gray-400 text-2xl'"
                  />
                </Button>
              </Tooltip>
              <Popconfirm title="是否确认删除?" @confirm="handleDelete(record.id)">
                <Button type="link" size="small" danger>
                  <IconifyIcon icon="material-symbols:delete" class="text-lg" />
                </Button>
              </Popconfirm>
            </div>
          </template>
        </template>
      </WmsDataTable>
    </div>

    <!-- 新增/编辑弹窗 -->
    <WarehouseModal
      v-model:open="modalVisible"
      :record="currentRecord"
      @success="handleFormSuccess"
    />
  </Page>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue';
import { message } from 'ant-design-vue';
import { Button, Card, Tag, Tooltip, Popconfirm } from 'ant-design-vue';
import { IconifyIcon } from '@vben/icons';
import { Page } from '@vben/common-ui';

import { warehouseApi } from '#/api/modules/warehouse-api';
import WmsSearchBar from '#/components/common/WmsSearchBar.vue';
import WmsDataTable from '#/components/common/WmsDataTable.vue';
import WarehouseModal from './modules/WarehouseModal.vue';
import type { StatsCardConfig } from '#/lowcode/types';

// 搜索字段URL
const searchFieldsUrl = '/api/system/meta/column/schema?tableCode=WMS0010';

// 统计配置
const statsConfig: StatsCardConfig[] = [
  { key: 'total', label: '总仓库数', icon: 'material-symbols:warehouse', color: '#1677ff', field: 'total' },
  { key: 'enabled', label: '已启用', icon: 'material-symbols:check-circle', color: '#52c41a', field: 'enabled' },
  { key: 'disabled', label: '已停用', icon: 'material-symbols:cancel', color: '#ff4d4f', field: 'disabled' },
];

// 状态
const loading = ref(false);
const dataList = ref<any[]>([]);
const searchForm = reactive<Record<string, any>>({});
const stats = reactive({ total: 0, enabled: 0, disabled: 0 });

// 弹窗
const modalVisible = ref(false);
const currentRecord = ref<any>(null);

// 分页
const pagination = reactive({ current: 1, pageSize: 20, total: 0 });
const paginationConfig = computed(() => ({
  current: pagination.current,
  pageSize: pagination.pageSize,
  total: pagination.total,
  showSizeChanger: true,
  showTotal: (total: number) => `共 ${total} 条`,
}));

// 表格列
const columns = [
  { title: '序号', key: 'seq', width: 60, align: 'center' },
  { title: '仓库编码', dataIndex: 'warehouseCode', width: 120, align: 'center' },
  { title: '仓库名称', dataIndex: 'warehouseName', width: 180 },
  { title: '仓库类型', dataIndex: 'warehouseType', width: 100, align: 'center' },
  { title: '温区', dataIndex: 'temperatureZone', width: 100, align: 'center' },
  { title: '状态', key: 'isEnabled', width: 80, align: 'center' },
  { title: '操作', key: 'action', width: 150, align: 'center', fixed: 'right' },
];

// 加载数据
async function loadData() {
  loading.value = true;
  try {
    const params = {
      pageNum: pagination.current,
      pageSize: pagination.pageSize,
      ...searchForm,
    };
    const res = await warehouseApi.getList(params);
    dataList.value = res.rows;
    pagination.total = res.total;
    
    // 更新统计
    stats.total = res.total;
    stats.enabled = res.rows.filter((r: any) => r.isEnabled === 1).length;
    stats.disabled = stats.total - stats.enabled;
  } catch (e) {
    message.error('加载失败');
  } finally {
    loading.value = false;
  }
}

// 搜索
function handleSearch() {
  pagination.current = 1;
  loadData();
}

// 重置
function handleReset() {
  Object.keys(searchForm).forEach((key) => delete searchForm[key]);
  pagination.current = 1;
  loadData();
}

// 分页
function onPageChange({ page, pageSize }: { page: number; pageSize: number }) {
  pagination.current = page;
  pagination.pageSize = pageSize;
  loadData();
}

// 新增
function handleCreate() {
  currentRecord.value = null;
  modalVisible.value = true;
}

// 编辑
function handleEdit(record: any) {
  currentRecord.value = record;
  modalVisible.value = true;
}

// 启用/停用
async function handleToggle(record: any) {
  try {
    await warehouseApi.toggle(record.id, record.isEnabled === 1 ? 0 : 1);
    message.success(record.isEnabled === 1 ? '停用成功' : '启用成功');
    loadData();
  } catch (e) {
    message.error('操作失败');
  }
}

// 删除
async function handleDelete(id: number) {
  try {
    await warehouseApi.delete(id);
    message.success('删除成功');
    loadData();
  } catch (e) {
    message.error('删除失败');
  }
}

// 导出
function handleExport() {
  message.info('导出功能开发中...');
}

// 表单成功
function handleFormSuccess() {
  loadData();
}

// 初始化
onMounted(() => {
  loadData();
});
</script>

<style scoped>
.stat-card {
  transition: box-shadow 0.2s;
}
.stat-card:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.09);
}
</style>
```

### 4.2 表单弹窗

```vue
<template>
  <Modal
    v-model:open="internalOpen"
    :title="isEdit ? '编辑仓库' : '新增仓库'"
    width="600px"
    @ok="handleSubmit"
    @cancel="handleClose"
  >
    <Form
      ref="formRef"
      :model="formData"
      :label-col="{ span: 6 }"
      :rules="rules"
    >
      <FormItem label="仓库编码" name="warehouseCode">
        <Input v-model:value="formData.warehouseCode" placeholder="请输入仓库编码" />
      </FormItem>
      <FormItem label="仓库名称" name="warehouseName">
        <Input v-model:value="formData.warehouseName" placeholder="请输入仓库名称" />
      </FormItem>
      <FormItem label="仓库类型" name="warehouseType">
        <Select v-model:value="formData.warehouseType" placeholder="请选择仓库类型">
          <SelectOption value="SALES">销售仓</SelectOption>
          <SelectOption value="ISOLATION">隔离仓</SelectOption>
          <SelectOption value="FRONT">前置仓</SelectOption>
          <SelectOption value="TRANSIT">中转仓</SelectOption>
        </Select>
      </FormItem>
      <FormItem label="温区" name="temperatureZone">
        <Select v-model:value="formData.temperatureZone" placeholder="请选择温区">
          <SelectOption value="NORMAL">常温</SelectOption>
          <SelectOption value="COLD">冷藏</SelectOption>
          <SelectOption value="FROZEN">-18℃冷冻</SelectOption>
          <SelectOption value="ULTRA_COLD">-40℃超低温</SelectOption>
        </Select>
      </FormItem>
      <FormItem label="状态" name="isEnabled">
        <Switch
          v-model:checked="formData.isEnabled"
          checked-children="启用"
          un-checked-children="停用"
        />
      </FormItem>
      <FormItem label="备注" name="remark">
        <Textarea v-model:value="formData.remark" placeholder="请输入备注" :rows="3" />
      </FormItem>
    </Form>
  </Modal>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch } from 'vue';
import { message } from 'ant-design-vue';
import { Modal, Form, FormItem, Input, Select, SelectOption, Switch, Textarea } from 'ant-design-vue';
import type { FormInstance, Rule } from 'ant-design-vue/es/form';

import { warehouseApi } from '#/api/modules/warehouse-api';

interface Props {
  open: boolean;
  record?: Record<string, any> | null;
}

const props = withDefaults(defineProps<Props>(), {
  open: false,
  record: null,
});

const emit = defineEmits<{
  (e: 'update:open', value: boolean): void;
  (e: 'success', record: any): void;
  (e: 'close'): void;
}>();

const internalOpen = computed({
  get: () => props.open,
  set: (val) => emit('update:open', val),
});

const isEdit = computed(() => !!props.record?.id);

const formRef = ref<FormInstance>();
const formData = reactive({
  warehouseCode: '',
  warehouseName: '',
  warehouseType: undefined as string | undefined,
  temperatureZone: undefined as string | undefined,
  isEnabled: true,
  remark: '',
});

const rules: Record<string, Rule[]> = {
  warehouseCode: [{ required: true, message: '请输入仓库编码', trigger: 'blur' }],
  warehouseName: [{ required: true, message: '请输入仓库名称', trigger: 'blur' }],
};

// 监听record变化，填充表单
watch(
  () => props.record,
  (record) => {
    if (record) {
      Object.assign(formData, {
        ...record,
        isEnabled: record.isEnabled === 1,
      });
    } else {
      Object.assign(formData, {
        warehouseCode: '',
        warehouseName: '',
        warehouseType: undefined,
        temperatureZone: undefined,
        isEnabled: true,
        remark: '',
      });
    }
  },
  { immediate: true }
);

// 提交
async function handleSubmit() {
  try {
    await formRef.value?.validate();
    const data = {
      ...formData,
      isEnabled: formData.isEnabled ? 1 : 0,
    };
    if (isEdit.value) {
      await warehouseApi.update(props.record.id, data);
      message.success('修改成功');
    } else {
      await warehouseApi.create(data);
      message.success('新增成功');
    }
    emit('success', data);
    handleClose();
  } catch (e) {
    // 校验失败
  }
}

// 关闭
function handleClose() {
  internalOpen.value = false;
  emit('close');
}
</script>
```

---

## 五、类型定义

### 5.1 类型文件

```typescript
// types/warehouse-type.ts
export interface WarehouseDTO {
  id: number;
  warehouseCode: string;
  warehouseName: string;
  warehouseType: string;
  company?: string;
  temperatureZone?: string;
  qualityZone?: string;
  managerId?: number;
  managerName?: string;
  isEnabled: number;
  remark?: string;
  createdAt: string;
  updatedAt: string;
}

export interface WarehouseRequest {
  pageNum?: number;
  pageSize?: number;
  warehouseCode?: string;
  warehouseName?: string;
  warehouseType?: string;
  isEnabled?: number;
}

export interface WarehouseCreateRequest {
  warehouseCode: string;
  warehouseName: string;
  warehouseType: string;
  company?: string;
  temperatureZone?: string;
  qualityZone?: string;
  managerId?: number;
  managerName?: string;
  isEnabled?: number;
  remark?: string;
}
```

---

## 六、低代码页面开发

### 6.1 新增低代码页面

```vue
<!-- views/lowcode/wms0100/index.vue -->
<template>
  <LowcodePage
    table-code="WMS0100"
    page-title="库位档案"
    page-desc="管理仓库内的库位层级结构"
    crud-prefix="/api/base/location"
    :show-stats="false"
  />
</template>

<script setup lang="ts">
import LowcodePage from '#/lowcode/LowcodePage.vue';
</script>
```

### 6.2 扩展低代码页面

```vue
<!-- views/lowcode/wms0100-custom/index.vue -->
<template>
  <LowcodePage
    ref="lowcodeRef"
    table-code="WMS0100"
    page-title="库位档案"
    page-desc="管理仓库内的库位层级结构"
    crud-prefix="/api/base/location"
    :show-stats="false"
    @formSuccess="handleFormSuccess"
  >
    <!-- 自定义列插槽 -->
    <template #bodyCell="{ column, record }">
      <!-- 自定义库位类型列 -->
      <template v-if="column.key === 'locationType'">
        <Tag :color="getLocationTypeColor(record.locationType)">
          {{ getLocationTypeLabel(record.locationType) }}
        </Tag>
      </template>
    </template>
  </LowcodePage>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { Tag } from 'ant-design-vue';
import LowcodePage from '#/lowcode/LowcodePage.vue';

const lowcodeRef = ref<InstanceType<typeof LowcodePage>>();

function getLocationTypeColor(type: string) {
  const map: Record<string, string> = {
    STORAGE_TYPE: 'blue',
    STORAGE_ZONE: 'green',
    STORAGE_CONTAINER: 'orange',
    STORAGE_HOLE: 'purple',
  };
  return map[type] || 'default';
}

function getLocationTypeLabel(type: string) {
  const map: Record<string, string> = {
    STORAGE_TYPE: '存储类型',
    STORAGE_ZONE: '存储分区',
    STORAGE_CONTAINER: '存储容器',
    STORAGE_HOLE: '存储孔位',
  };
  return map[type] || type;
}

function handleFormSuccess() {
  console.log('表单提交成功');
}
</script>
```

---

## 七、组件使用规范

### 7.1 通用组件

| 组件 | 说明 | 使用场景 |
|------|------|----------|
| WmsSearchBar | 搜索栏 | 列表页搜索条件 |
| WmsDataTable | 数据表格 | 列表页数据展示 |
| LowcodePage | 低代码列表页 | 档案页面快速开发 |
| LowcodeDrawer | 低代码表单抽屉 | 表单弹窗 |

### 7.2 组件引入

```vue
<script setup lang="ts">
// ✅ 正确：按需引入
import { Button, Table, Modal } from 'ant-design-vue';

// ❌ 错误：全量引入
import { Button } from 'ant-design-vue';
import Table from 'ant-design-vue/es/table';
</script>
```

---

## 八、代码自检清单

- [ ] 代码符合命名规范
- [ ] TypeScript类型完整
- [ ] Props有默认值
- [ ] Emits定义正确
- [ ] 无any类型
- [ ] 错误处理完整
- [ ] 加载状态显示
- [ ] 空状态处理
- [ ] 权限控制正确
- [ ] 国际化处理
