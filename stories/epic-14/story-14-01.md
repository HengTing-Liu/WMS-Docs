# Story 14-01 系统登录认证

## 0. 基本信息

- Epic：辅助功能与外部接口
- Story ID：14-01
- 优先级：P0
- 状态：Draft
- 预计工期：1d
- 依赖 Story：无
- 关联迭代：Sprint 1

---

## 1. 目标

实现系统登录认证功能，包括用户名密码登录、Token认证、登录日志记录。

---

## 2. 业务背景

系统登录是用户使用系统的前提，需要支持安全的认证机制和会话管理。

---

## 3. 范围

### 3.1 本 Story 包含

- 用户名密码登录
- JWT Token 认证
- Token 刷新
- 登录日志记录
- 退出登录

### 3.2 本 Story 不包含

- SSO 单点登录（后续迭代）
- 验证码登录（后续迭代）

---

## 4. API / 接口契约

### 4.1 接口清单

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/auth/login` | 用户登录 |
| POST | `/api/auth/logout` | 退出登录 |
| POST | `/api/auth/refresh` | 刷新Token |
| GET | `/api/auth/current-user` | 获取当前用户信息 |

### 4.2 登录请求示例

```json
POST /api/auth/login
{
  "username": "admin",
  "password": "xxx",
  "captcha": "1234",
  "captchaKey": "uuid"
}
```

### 4.3 登录响应示例

```json
{
  "code": 200,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 7200,
    "user": {
      "id": 1,
      "username": "admin",
      "nickname": "管理员",
      "avatar": "https://xxx/avatar.png"
    }
  }
}
```

---

## 5. 登录日志

| 字段 | 类型 | 说明 |
|------|------|------|
| id | long | 主键 |
| userId | long | 用户ID |
| username | string | 用户名 |
| loginTime | datetime | 登录时间 |
| loginIp | string | 登录IP |
| loginLocation | string | 登录地点 |
| loginDevice | string | 登录设备 |
| loginBrowser | string | 浏览器 |
| loginOs | string | 操作系统 |
| loginStatus | string | 登录状态：SUCCESS/FAIL |
| failReason | string | 失败原因 |

---

## 6. 验收标准

### 6.1 功能验收

- [ ] 用户名密码登录正常
- [ ] 登录成功返回 Token
- [ ] Token 认证生效
- [ ] Token 刷新正常
- [ ] 退出登录正常
- [ ] 登录日志记录完整

### 6.2 安全验收

- [ ] 密码加密存储
- [ ] Token 防伪造验证
- [ ] 登录失败锁定（5次失败锁定30分钟）

---

## 7. 交付物清单

- [ ] 后端代码（认证服务）
- [ ] 前端登录页面
- [ ] 接口文档

---

## 8. 关联文档

- Epic Brief：[epic-14-overview.md](../../epics/epic-14-overview.md)
