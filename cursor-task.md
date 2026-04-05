# Cursor Task

> 版本：V1.1
> 日期：2026-04-06
> 子任务：11-01-BE

---

## 执行 Agent

**使用 Cursor BE（后端）执行开发任务**

---

## 当前子任务

- **编号**：11-01-BE
- **名称**：表元数据管理-后端开发
- **所属 Story**：11-01 表元数据管理
- **所属 Epic**：Epic-11 低代码配置管理
- **串行顺序**：第 2 个子任务
- **前置任务**：11-01-PM ✅ 已完成

---

## 本轮只处理

完成表元数据管理的后端接口开发，包括 Controller/Service/Mapper。

---

## 需求依据

已确认的需求见：`WMS-Docs/stories/epic-11/story-11-01-pm-confirm.md`

---

## 实际数据库表结构

```sql
sys_table_meta (
  id BIGINT PRIMARY KEY,
  table_code VARCHAR(100) NOT NULL UNIQUE,
  table_name VARCHAR(200) NOT NULL,
  module VARCHAR(50),
  entity_class VARCHAR(200),
  service_class VARCHAR(200),
  permission_code VARCHAR(100),
  page_size INT DEFAULT 20,
  is_tree TINYINT DEFAULT 0,
  status TINYINT DEFAULT 1,
  remark VARCHAR(500),
  create_by VARCHAR(64),
  create_time DATETIME,
  update_by VARCHAR(64),
  update_time DATETIME,
  is_deleted_column VARCHAR(50),
  has_data_permission TINYINT DEFAULT 0,
  permission_field VARCHAR(64),
  permission_scope VARCHAR(32)
)
```

---

## 后端分层

- Controller：`WmsTableMetaController`
- Service：`IWmsTableMetaService` + `WmsTableMetaServiceImpl`
- Mapper：`WmsTableMetaMapper`
- DO 实体：`WmsTableMeta`

---

## 接口清单

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/system/meta/table` | 表元数据列表查询（分页+模糊搜索） |
| GET | `/api/system/meta/table/{id}` | 表元数据详情 |
| GET | `/api/system/meta/table/code/{code}` | 通过编码查询 |
| POST | `/api/system/meta/table` | 创建表元数据 |
| PUT | `/api/system/meta/table/{id}` | 更新表元数据 |
| DELETE | `/api/system/meta/table/{id}` | 删除表元数据（逻辑删除） |
| PUT | `/api/system/meta/table/{id}/toggle` | 启用/禁用切换 |

---

## 业务规则

1. 表编码唯一，重复时报错
2. 删除使用逻辑删除（is_deleted_column）
3. 新增/修改/删除记录操作日志
4. 自动填充 create_by, create_time, update_by, update_time

---

## 允许修改

- `WMS-backend/` — 后端代码

---

## 禁止修改

- `WMS-frontend/` — 前端代码
- 数据库表结构

---

## 完成标准

- [ ] Controller 接口开发完成
- [ ] Service 业务逻辑实现
- [ ] Mapper 数据库操作
- [ ] 表编码唯一性校验
- [ ] 逻辑删除支持
- [ ] 操作日志记录
- [ ] 自测通过

---

## 输出要求

完成后必须输出到 `cursor-result.md`：

1. 实际开发文件列表
2. 接口实现清单
3. 自测结果
4. 遗留问题（无或列出）

---

## Git 提交

```bash
git add .
git commit -m "feat(backend): 11-01-BE 表元数据管理后端开发完成"
git push
```

---

## 下一步

完成后通知 OpenClaw，等待 11-01-FE 前端任务。
