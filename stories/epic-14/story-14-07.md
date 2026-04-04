# Story 14-07 打印模板配置

## 0. 基本信息

- Epic：辅助功能与外部接口
- Story ID：14-07
- 优先级：P2
- 状态：Draft
- 预计工期：1d
- 依赖 Story：无
- 关联迭代：Sprint 4

---

## 1. 目标

实现打印模板配置，支持自定义标签、单据的打印样式。

---

## 2. 业务背景

仓储业务需要打印各类标签（物料标签、库位标签）和单据（入库单、出库单、盘点单），需要支持自定义模板。

---

## 3. 范围

### 3.1 本 Story 包含

- 打印模板列表查询
- 打印模板新增/编辑
- 打印模板启用/禁用
- 打印预览
- 打印服务

### 3.2 本 Story 不包含

- 打印历史记录（后续迭代）

---

## 4. API / 接口契约

### 4.1 接口清单

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/system/print-template/list` | 模板列表 |
| GET | `/api/system/print-template/{id}` | 模板详情 |
| POST | `/api/system/print-template` | 新增模板 |
| PUT | `/api/system/print-template/{id}` | 编辑模板 |
| DELETE | `/api/system/print-template/{id}` | 删除模板 |
| PUT | `/api/system/print-template/{id}/toggle` | 启用/禁用 |
| GET | `/api/system/print-template/preview/{id}` | 打印预览 |
| POST | `/api/system/print/{bizType}` | 打印接口 |

### 4.2 Schema 配置

- **表编码**：WMS0035
- **CRUD前缀**：`/api/system/print-template`

### 4.3 字段定义

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| templateCode | string | 是 | 模板编码 |
| templateName | string | 是 | 模板名称 |
| bizType | string | 是 | 业务类型：LABEL_MATERIAL/LABEL_LOCATION/BILL_IN/BILL_OUT等 |
| templateContent | text | 是 | HTML模板内容 |
| pageWidth | int | 否 | 页面宽度(mm) |
| pageHeight | int | 否 | 页面高度(mm) |
| isDefault | int | 否 | 是否默认模板 |
| isEnabled | int | 是 | 是否启用 |

### 4.4 模板变量

| 变量 | 说明 | 示例 |
|------|------|------|
| ${materialCode} | 物料编码 | MAT001 |
| ${materialName} | 物料名称 | 一次性注射器 |
| ${batchNo} | 批次号 | B20260401 |
| ${warehouseName} | 仓库名称 | 上海仓 |
| ${locationCode} | 库位编码 | A-01-01 |
| ${quantity} | 数量 | 100 |
| ${spec} | 规格 | 5ml |
| ${unit} | 单位 | 支 |
| ${printDate} | 打印日期 | 2026-04-03 |
| ${operator} | 操作人 | 张三 |

### 4.5 打印请求示例

```json
POST /api/system/print/label-material
{
  "templateId": 1,
  "data": {
    "materialCode": "MAT001",
    "materialName": "一次性注射器",
    "batchNo": "B20260401",
    "quantity": 100
  }
}
```

---

## 5. 打印服务

```java
@Component
public class PrintService {

    public byte[] print(Long templateId, Map<String, Object> data) {
        // 1. 获取模板
        PrintTemplate template = getTemplate(templateId);

        // 2. 渲染模板
        String html = renderTemplate(template.getContent(), data);

        // 3. 转换为PDF
        return htmlToPdf(html, template.getPageWidth(), template.getPageHeight());
    }

    private String renderTemplate(String templateContent, Map<String, Object> data) {
        // 使用模板引擎渲染变量
        return engine.render(templateContent, data);
    }
}
```

---

## 6. 验收标准

### 6.1 功能验收

- [ ] 模板 CRUD 功能正常
- [ ] HTML 模板正确渲染
- [ ] 变量替换正确
- [ ] 打印预览正常
- [ ] PDF 生成正常

### 6.2 性能验收

- [ ] 单次打印 < 2s

---

## 7. 交付物清单

- [ ] 后端代码
- [ ] 前端页面
- [ ] 接口文档

---

## 8. 关联文档

- Epic Brief：[epic-14-overview.md](../../epics/epic-14-overview.md)
