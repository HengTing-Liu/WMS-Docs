# Current State

## 一、当前 Story 基本信息
- Story 名称：物料档案动态表单
- Story 编号：WMS-MATERIAL-001
- 需求来源：用户反馈 /sys/material 页面接入低代码动态表单
- 业务模块：sys - 物料管理
- 当前负责人：
- 当前模式：已完成
- 当前阶段：已完成

## 二、Story 目标
- 业务目标：物料档案页面使用低代码动态表单，实现 CRUD 功能
- 要解决的问题：/sys/material 页面接入低代码动态表单
- 成功标准：物料档案页面可正常搜索、新增、编辑、删除

## 三、范围说明
### 本 Story 包含
- [x] 后端：Material 实体/Mapper/Service/Controller CRUD（基于 sys_material 表）
- [x] 后端：sys_material 表元数据初始化脚本
- [x] 前端：/sys/material 页面接入 LowcodePage 动态表单
- [x] 前端：物料 CRUD API 对接
- [x] 代码推送至 main 分支

### 本 Story 不包含
- [ ] 生产环境回归测试确认

## 四、执行顺序
- [x] 第一步：BE 开发
- [x] 第二步：FE 开发
- [x] 第三步：代码推送
- [x] 第四步：数据库脚本执行（init_material_meta.sql）

## 六、当前阶段状态
- 当前正在做：已全部完成并推送
- 下一阶段：无

## 八、验收标准
1. 物料列表页面正常加载
2. 支持按物料编码、物料名称、规格型号搜索
3. 支持新增物料
4. 支持编辑物料
5. 支持删除物料

## 十一、当前完成情况
### 已完成
- [x] 后端 Material CRUD 完整实现（基于 sys_material 表）
- [x] init_material_meta.sql 元数据脚本
- [x] 前端 /sys/material 页面 LowcodePage 接入
- [x] WMS-backend 推送至 main
- [x] WMS-frontend 推送至 main
- [x] docs 仓库初始化并推送

### 未完成
- [ ] 无

## 十三、本轮修改记录

### 2026-04-05
- 修改人：
- 工作模式：BE + FE
- 本轮目标：物料档案动态表单完整实现并推送
- 实际完成：
  - 后端：Material CRUD（Entity/Mapper/Service/Controller）
  - 后端：sys_material 元数据初始化
  - 前端：/sys/material 接入 LowcodePage
  - 前端：API 对接、多语言配置
  - 三个仓库均推送至 main
- 实际修改文件：
  - 后端：MaterialMapper.java, MaterialService.java, MaterialServiceImpl.java, MaterialController.java, MaterialMapper.xml, init_material_meta.sql 等
  - 前端：LowcodePage.vue, sys/material/index.vue, material.ts 等
  - docs：current-state.md, stories/, epics/ 等
- 验证结果：代码已推送
- 遗留问题：无
- 下一步建议：在测试环境验证 /sys/material 页面功能

---

## 十五、当前结论
- 当前总状态：已完成
- 当前卡点：无
- 需要谁继续处理：无
- 下一步最优动作：在测试环境验证 /sys/material 页面功能

---

## 十七、Story 状态更新记录（2026-04-16）

经完整核对前后端代码与 docs 文档，以下 Story 已实现并投入使用，更新状态为 **已完成**：

### 11-02 字段元数据管理
- **后端**：`MetaController` 已提供字段元数据 CRUD、Schema 查询、批量排序接口
- **前端**：`columnMeta/index.vue` 管理页面已上线，支持拖拽排序、批量新增、从其他表复制、编辑删除
- **状态**：✅ 已完成

### 11-03 操作元数据管理
- **后端**：`MetaController` 已提供操作按钮 CRUD、按表编码获取操作列表、批量排序、批量删除接口
- **前端**：`operationMeta/index.vue` 管理页面已上线，支持增删改查和排序调整
- **状态**：✅ 已完成

### 11-05 低代码引擎接口
- **后端**：`LowcodeCrudController` 已提供通用 CRUD（列表/详情/新增/修改/删除/启用停用/导出/唯一性校验）
- **后端**：`MetaController` 已提供 Schema 获取（字段 + 操作按钮）、表单分组查询
- **状态**：✅ 已完成

### 11-06 前端低代码组件
- **前端**：`LowcodePage.vue`（标准列表页，含搜索/表格/按钮/分页/统计卡片）
- **前端**：`LowcodeDrawer.vue` / `LowcodeFormPage.vue`（动态表单抽屉/页面）
- **前端**：`FieldRenderer.vue`（字段渲染器，支持 text/textarea/number/select/switch/date/datetime）
- **前端**：事件系统（builtin/api/download/redirect）、权限兼容、状态持久化、导出功能均已实现
- **状态**：✅ 已完成

### 当前进行中
- **11-04 字典数据管理**：基础 CRUD 页面与接口已存在，`DictServiceImpl` 中有缓存与集成 TODO 待完善，状态保持 **FE 进行中**

---

## 十八、本轮修改记录（Bool值解析修复）

### 2026-04-10
- 修改人：
- 工作模式：FE
- 本轮目标：修复 sys/warehouse 低代码列表 bool 值判断错误
- 问题描述：
  - 后端返回 `isEnabled: true/false`（Java boolean 经 JSON 序列化）
  - 前端多处用 `=== 1` 判断，`true !== 1` 导致"启用"被误判为"停用"
  - 影响范围：表格列状态标签、行内启用/停用按钮、统计数据、搜索栏过滤
- 实际修改：
  - `LowcodePage.vue`：新增 `isEnabled()` 辅助函数，替换所有 `record.isEnabled === 1` 判断
  - `WmsSearchBar.vue`：`handleSearch` 方法改用 `isEnabledValue()` 兼容处理 bool 和整数
- 验证结果：代码已推送，待前端重新构建后验证
- 遗留问题：无
- 下一步建议：在测试环境刷新 /sys/warehouse 页面，验证「是否启用」列和搜索过滤是否正确
