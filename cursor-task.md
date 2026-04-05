# Cursor Task

> 版本：V1.0
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

## 技术要求

### 后端分层

- Controller：`WmsTableMetaController`
- Service：`IWmsTableMetaService` + `WmsTableMetaServiceImpl`
- Mapper：`WmsTableMetaMapper`
- DO 实体：`WmsTableMeta`

### 数据库表

```sql
CREATE TABLE sys_table_meta (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  table_code VARCHAR(50) NOT NULL COMMENT '表编码',
  table_name VARCHAR(100) NOT NULL COMMENT '表名称',
  table_desc VARCHAR(500) COMMENT '表描述',
  module VARCHAR(50) NOT NULL COMMENT '所属模块',
  crud_prefix VARCHAR(100) COMMENT 'CRUD接口前缀',
  is_enabled TINYINT DEFAULT 1 COMMENT '是否启用',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_table_code (table_code)
) COMMENT '表元数据';
```

### 接口清单

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/system/meta/table` | 表元数据列表查询（分页+模糊搜索） |
| GET | `/api/system/meta/table/{id}` | 表元数据详情 |
| GET | `/api/system/meta/table/code/{code}` | 通过编码查询 |
| POST | `/api/system/meta/table` | 创建表元数据 |
| PUT | `/api/system/meta/table/{id}` | 更新表元数据 |
| DELETE | `/api/system/meta/table/{id}` | 删除表元数据（含关联检查） |
| PUT | `/api/system/meta/table/{id}/toggle` | 启用/禁用切换 |

### 业务规则

1. 表编码唯一，重复时报错
2. 删除前检查是否有关联字段
3. 新增/修改/删除记录操作日志

---

## 允许修改

- `WMS-backend/` — 后端代码

---

## 禁止修改

- `WMS-frontend/` — 前端代码
- 其他 Story 相关代码

---

## 完成标准

- [ ] Controller 接口开发完成
- [ ] Service 业务逻辑实现
- [ ] Mapper 数据库操作
- [ ] 表编码唯一性校验
- [ ] 删除关联检查
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
