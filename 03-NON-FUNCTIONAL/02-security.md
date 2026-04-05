# WMS仓库物流系统 - 安全性需求

> 版本：V1.0
> 日期：2026-04-03
> 适用范围：系统安全设计

---

## 一、认证授权

### 1.1 认证机制

| 认证项 | 实现方案 | 说明 |
|--------|----------|------|
| 登录认证 | JWT Token | 无状态认证 |
| Token有效期 | 2小时 | Access Token |
| Refresh Token | 7天 | 续期使用 |
| 单点登录 | CAS/OAuth2 | 集成企业SSO |

### 1.2 授权机制

| 授权项 | 实现方案 | 说明 |
|--------|----------|------|
| 权限模型 | RBAC | 基于角色的访问控制 |
| 数据权限 | 行级权限 | 租户隔离 + 仓库权限 |
| 接口权限 | 注解拦截 | @RequiresPermissions |
| 菜单权限 | 前端路由守卫 | 根据用户角色动态渲染 |

### 1.3 权限控制示例

```java
// 接口权限控制
@RequiresPermissions("wms:warehouse:add")
public Result<Void> addWarehouse(@RequestBody WarehouseRequest request) {
    return Result.success(warehouseService.add(request));
}

// 数据权限示例（SQL层面）
SELECT * FROM wms_warehouse
WHERE tenant_id = #{tenantId}
  AND warehouse_id IN (
    SELECT warehouse_id FROM sys_user_warehouse
    WHERE user_id = #{userId}
  )
```

---

## 二、安全防护

### 2.1 SQL注入防护

| 防护措施 | 实现方案 |
|----------|----------|
| 参数绑定 | MyBatis #{} 自动转义 |
| 禁止字符串拼接 | 严格审查SQL |
| 白名单校验 | 限制输入格式 |

```java
// ✅ 正确示例
@Select("SELECT * FROM wms_warehouse WHERE warehouse_code = #{code}")
Warehouse selectByCode(@Param("code") String code);

// ❌ 错误示例
@Select("SELECT * FROM wms_warehouse WHERE warehouse_code = '" + code + "'")
Warehouse selectByCodeDangerous(@Param("code") String code);
```

### 2.2 XSS防护

| 防护措施 | 实现方案 |
|----------|----------|
| 输入校验 | 白名单校验 |
| 输出编码 | HTML转义 |
| 富文本处理 | XSS过滤器 |

```java
// Spring Boot配置
@Configuration
public class XssConfig {
    @Bean
    public FilterRegistrationBean<XssFilter> xssFilter() {
        FilterRegistrationBean<XssFilter> bean = new FilterRegistrationBean<>();
        bean.setFilter(new XssFilter());
        return bean;
    }
}
```

### 2.3 CSRF防护

| 防护措施 | 实现方案 |
|----------|----------|
| Token校验 | Spring Security CSRF |
| 请求来源校验 | Referer/Origin校验 |
| CORS配置 | 限制跨域请求 |

### 2.4 接口限流

| 限流策略 | 配置 |
|----------|------|
| 全局限流 | 1000QPS |
| 登录接口 | 10QPS/人 |
| 敏感接口 | 100QPS/人 |
| 导出接口 | 1QPS/人 |

```java
@RateLimiter(value = 10, timeout = 1)
public Result<Void> login(@RequestBody LoginRequest request) {
    return authService.login(request);
}
```

---

## 三、敏感数据保护

### 3.1 敏感字段

| 字段类型 | 保护措施 |
|----------|----------|
| 密码 | BCrypt加密 |
| 手机号 | 脱敏展示（138****5678） |
| 身份证 | 加密存储，脱敏展示 |
| 银行卡 | 加密存储 |
| 密钥 | 加密存储 |

### 3.2 加密实现

```java
// AES加密示例
@Service
public class EncryptionService {
    
    @Value("${encryption.secret}")
    private String secretKey;
    
    public String encrypt(String plaintext) {
        Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
        SecretKeySpec keySpec = new SecretKeySpec(secretKey.getBytes(), "AES");
        cipher.init(Cipher.ENCRYPT_MODE, keySpec);
        byte[] encrypted = cipher.doFinal(plaintext.getBytes());
        return Base64.encodeBase64String(encrypted);
    }
    
    public String decrypt(String ciphertext) {
        // 解密实现...
        return plaintext;
    }
}
```

### 3.3 脱敏规则

| 数据类型 | 脱敏规则 | 示例 |
|----------|----------|------|
| 手机号 | 中间4位脱敏 | 138****5678 |
| 身份证 | 出生日期脱敏 | 310***********1234 |
| 银行卡 | 仅显示后4位 | ************1234 |
| 姓名 | 仅显示姓 | 张* |
| 地址 | 仅显示省市区 | 上海市浦东新区*** |

---

## 四、日志审计

### 4.1 审计日志内容

| 审计项 | 记录内容 |
|----------|----------|
| 登录日志 | 用户、时间、IP、设备 |
| 操作日志 | 用户、时间、操作、对象、结果 |
| 数据变更 | 用户、时间、变更前后值 |
| 异常日志 | 时间、异常类型、堆栈 |

### 4.2 操作日志示例

```java
@Log(title = "仓库管理", businessType = BusinessType.INSERT)
@RequiresPermissions("wms:warehouse:add")
public Result<Long> add(@RequestBody WarehouseRequest request) {
    return Result.success(warehouseService.add(request));
}
```

### 4.3 日志规范

```java
// ✅ 正确日志
log.info("Warehouse created: id={}, code={}, operator={}", 
    warehouse.getId(), warehouse.getCode(), getCurrentUser());

// ❌ 禁止日志
log.info("仓库创建成功");
log.error("出错了: " + e.getMessage());
```

---

## 五、数据安全

### 5.1 数据备份

| 备份类型 | 频率 | 保存时间 |
|----------|------|----------|
| 全量备份 | 每日 | 30天 |
| 增量备份 | 每小时 | 7天 |
| 异地备份 | 每周 | 90天 |

### 5.2 数据加密存储

| 数据类型 | 存储方式 |
|----------|----------|
| 核心业务数据 | 明文存储 |
| 用户密码 | BCrypt加密 |
| 敏感字段 | AES加密 |
| 传输通道 | HTTPS |
| 日志文件 | 加密存储 |

### 5.3 数据权限控制

```java
// 数据权限注解
@DataScope(scopeType = DataScopeType.WAREHOUSE)
public interface WarehouseMapper {
    List<Warehouse> selectWarehouseList(Warehouse warehouse);
}
```

---

## 六、安全配置

### 6.1 Spring Security配置

```java
@Configuration
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()
            .sessionManagement()
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/swagger-ui/**").permitAll()
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }
}
```

### 6.2 CORS配置

```java
@Configuration
public class CorsConfig {
    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(Arrays.asList("https://wms.company.com"));
        config.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE"));
        config.setAllowedHeaders(Arrays.asList("*"));
        config.setAllowCredentials(true);
        config.setMaxAge(3600L);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return new CorsFilter(source);
    }
}
```

---

## 七、安全检查清单

- [ ] 所有接口必须认证
- [ ] 敏感数据必须加密
- [ ] 密码必须加密存储
- [ ] 日志必须脱敏
- [ ] SQL必须参数绑定
- [ ] 输入必须校验
- [ ] 输出必须编码
- [ ] 接口必须限流
- [ ] 越权必须拦截
- [ ] 异常必须捕获
- [ ] 操作必须审计
