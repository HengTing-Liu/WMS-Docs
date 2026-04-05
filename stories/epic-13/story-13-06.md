# Story 13-06 钉钉通知集成

## 0. 基本信息

- Epic：预警通知管理
- Story ID：13-06
- 优先级：P1
- 状态：Draft
- 预计工期：1d
- 依赖 Story：13-01（预警规则配置）
- 关联迭代：Sprint 6

---

## 1. 目标

实现钉钉通知集成，支持通过钉钉机器人发送预警通知。

---

## 2. 业务背景

钉钉是企业常用的沟通工具，通过钉钉机器人可以及时将预警信息推送给相关人员。

---

## 3. 范围

### 3.1 本 Story 包含

- 钉钉配置管理
- 钉钉机器人 Webhook 集成
- 钉钉消息发送服务
- 消息发送状态跟踪

### 3.2 本 Story 不包含

- 钉钉企业应用集成（后续迭代）
- 邮件/短信通知（后续迭代）

---

## 4. API / 接口契约

### 4.1 钉钉配置接口

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/system/dingtalk/config` | 获取钉钉配置 |
| PUT | `/api/system/dingtalk/config` | 更新钉钉配置 |

### 4.2 配置字段

| 字段 | 类型 | 必填 | 说明 |
|------|------|---:|------|
| webhookUrl | string | 是 | 钉钉机器人 Webhook 地址 |
| secret | string | 否 | 加签密钥 |
| enabled | boolean | 是 | 是否启用 |
| mentionList | array | 否 | 默认@人员 |

### 4.3 消息发送接口

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/warning/notify/dingtalk` | 发送钉钉通知 |
| POST | `/api/warning/notify/batch` | 批量发送通知 |

### 4.4 发送请求示例

```json
POST /api/warning/notify/dingtalk
{
  "title": "库存预警",
  "content": "物料【一次性注射器】库存不足，当前库存8，最低库存10",
  "warningLevel": "WARNING",
  "mentionUsers": ["13800138000"],
  "jumpUrl": "http://wms.xxx.com/warning/message/123"
}
```

### 4.5 发送响应示例

```json
{
  "code": 200,
  "data": {
    "messageId": "msg123",
    "sendStatus": "SUCCESS",
    "sendTime": "2026-04-03 08:00:00"
  }
}
```

---

## 5. 技术实现

### 5.1 钉钉消息类型

使用钉钉自定义机器人，支持以下消息类型：
- 文本消息（text）
- 链接消息（link）- 推荐
- Markdown 消息（markdown）- 推荐

### 5.2 消息签名

```java
@Component
public class DingtalkClient {

    public void send(DingtalkMessage message) {
        // 1. 签名计算
        long timestamp = System.currentTimeMillis();
        String sign = computeSign(timestamp, secret);

        // 2. 构建请求URL
        String url = webhookUrl + "&timestamp=" + timestamp + "&sign=" + sign;

        // 3. 发送请求
        HttpUtil.post(url, JSON.toJSONString(message));
    }

    private String computeSign(long timestamp, String secret) {
        String stringToSign = timestamp + "\n" + secret;
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(secret.getBytes(), "HmacSHA256"));
        return Base64.encode(mac.doFinal(stringToSign.getBytes()));
    }
}
```

### 5.3 Markdown 消息模板

```json
{
  "msgtype": "markdown",
  "markdown": {
    "title": "库存预警",
    "text": "### 🔔 【库存预警】\n\n" +
            "**物料**：一次性注射器 5ml\n\n" +
            "**仓库**：上海仓\n\n" +
            "**当前库存**：8\n\n" +
            "**最低库存**：10\n\n" +
            "**时间**：2026-04-03 08:00:00"
  },
  "at": {
    "atMobiles": ["13800138000"],
    "isAtAll": false
  }
}
```

---

## 6. 数据库设计

### 6.1 钉钉配置表

```sql
CREATE TABLE sys_dingtalk_config (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  webhook_url VARCHAR(500) NOT NULL COMMENT 'Webhook地址',
  secret VARCHAR(100) COMMENT '加签密钥',
  enabled TINYINT DEFAULT 1 COMMENT '是否启用',
  mention_list VARCHAR(500) COMMENT '默认@人员',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT '钉钉配置';
```

### 6.2 通知记录表

```sql
CREATE TABLE wms_notification_log (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  message_id VARCHAR(50) NOT NULL COMMENT '消息ID',
  warning_id BIGINT COMMENT '预警消息ID',
  channel VARCHAR(20) NOT NULL COMMENT '通知渠道',
  recipient VARCHAR(100) COMMENT '接收人',
  content TEXT COMMENT '消息内容',
  send_status VARCHAR(20) NOT NULL COMMENT '发送状态',
  send_time DATETIME COMMENT '发送时间',
  error_message VARCHAR(500) COMMENT '错误信息',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT '通知记录';
```

---

## 7. 验收标准

### 7.1 功能验收

- [ ] 钉钉配置保存正常
- [ ] Webhook 连接测试正常
- [ ] 消息发送成功
- [ ] 签名验证通过
- [ ] 发送状态跟踪正常

### 7.2 性能验收

- [ ] 单条消息发送 < 500ms

### 7.3 可靠性验收

- [ ] 发送失败时记录错误日志
- [ ] 支持重试机制

---

## 8. 交付物清单

- [ ] 后端代码（钉钉客户端）
- [ ] 配置管理页面
- [ ] 接口文档
- [ ] 测试用例

---

## 9. 关联文档

- Epic Brief：[epic-13-overview.md](../../epics/epic-13-overview.md)
- 钉钉开发文档：https://open.dingtalk.com/document/robots/customize-robot-security-settings
