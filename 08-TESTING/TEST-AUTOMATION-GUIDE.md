# WMS 测试自动化指南

> 版本：V1.0
> 日期：2026-04-04
> 维护人：WMS 开发团队

---

## 一、测试目录结构

```
WMS-backend/                         # 后端
├── pom.xml                           # 父 POM（含 JaCoCo 配置）
├── wms-center-service/
│   └── src/test/java/
│       └── com/abtk/product/
│           ├── BaseServiceTest.java  # Service 测试基类
│           └── service/sys/impl/
│               └── WarehouseReceiverServiceTest.java  # 示例测试
└── wms-center-biz/
    └── src/test/java/
        └── com/abtk/product/
            ├── BaseBizTest.java      # Biz 测试基类
            └── biz/sys/
                └── WarehouseReceiverBizTest.java      # 示例测试

WMS-frontend/                        # 前端
├── playwright.config.ts             # Playwright 配置
├── e2e/
│   ├── setup/
│   │   ├── global-setup.ts         # 全局设置
│   │   └── global-teardown.ts       # 全局清理
│   ├── helpers/
│   │   └── index.ts                # 测试辅助工具
│   ├── login.spec.ts               # 登录测试
│   └── warehouse.spec.ts           # 仓库模块测试
└── .env.test.example               # 测试环境变量示例
```

---

## 二、后端测试

### 2.1 快速开始

```bash
# 进入后端目录
cd WMS-backend

# 运行所有测试
mvn test

# 运行指定模块测试
mvn test -pl wms-center-service

# 运行测试并生成覆盖率报告
mvn test jacoco:report

# 查看覆盖率报告
open wms-center-service/target/site/jacoco/index.html
```

### 2.2 测试基类使用

#### BaseServiceTest

适用于 Service 层的单元测试：

```java
@ExtendWith(MockitoExtension.class)
class WarehouseServiceTest extends BaseServiceTest {

    @Mock
    private WarehouseReceiverMapper mapper;

    @InjectMocks
    private WarehouseReceiverServiceImpl service;

    @Test
    void testCreate() {
        logTestStart("测试新增");

        // given
        WarehouseReceiver receiver = createTestReceiver();
        when(mapper.insert(any())).thenReturn(1);

        // when
        Long id = service.create(receiver);

        // then
        assertNotNull(id);
        verify(mapper).insert(any());

        logTestSuccess("测试新增");
    }
}
```

#### BaseBizTest

适用于 Biz 层的单元测试：

```java
@ExtendWith(MockitoExtension.class)
class WarehouseReceiverBizTest extends BaseBizTest {

    @Mock
    private WarehouseReceiverService warehouseReceiverService;

    @InjectMocks
    private WarehouseReceiverBiz biz;

    @Test
    void testAdd() {
        // given
        WarehouseReceiverRequest request = new WarehouseReceiverRequest();
        request.setConsignee("张三");

        when(warehouseReceiverService.create(any())).thenReturn(1L);

        // when
        R<Long> result = biz.add(request);

        // then
        assertTrue(result.isSuccess());
    }
}
```

### 2.3 测试规范

| 规则 | 说明 |
|------|------|
| 测试类命名 | `XxxServiceTest.java` / `XxxBizTest.java` |
| 测试方法命名 | `test操作_场景()` |
| Mock 对象 | 使用 `@Mock` 注解 |
| 注入对象 | 使用 `@InjectMocks` 注解 |
| 静态方法 Mock | 使用 `mockStatic()` |
| 日志输出 | 使用 `log.info()` 而非 `System.out` |

---

## 三、前端测试

### 3.1 快速开始

```bash
# 进入前端目录
cd WMS-frontend

# 安装依赖（如果 Playwright 未安装）
pnpm exec playwright install --with-deps

# 运行单元测试
pnpm run test:unit

# 运行 E2E 测试
pnpm run test:e2e

# 运行 E2E 测试（UI 模式）
pnpm run test:e2e:ui

# 运行 E2E 测试（调试模式）
pnpm run test:e2e:debug

# 查看 E2E 测试报告
pnpm run test:e2e:report
```

### 3.2 Playwright 配置

主要配置项：

```typescript
// playwright.config.ts
export default defineConfig({
  testDir: './e2e',           // 测试目录
  timeout: 30 * 1000,        // 单个测试超时
  retries: 2,                // CI 环境重试次数
  reporter: 'html',          // 报告格式
  globalSetup: './e2e/setup/global-setup.ts',
  globalTeardown: './e2e/setup/global-teardown.ts',
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
  ],
});
```

### 3.3 测试辅助工具

```typescript
import { createPageHelper, Selectors, TestData } from './helpers';

// 创建辅助对象
const helper = createPageHelper(page);

// 导航
await helper.navigate('/base/warehouse');

// 等待 Toast
await helper.waitForToast('操作成功');

// 等待 Loading
await helper.waitForLoading();

// 填写表单
await helper.fillFormField('仓库编码', 'WH001');

// 等待表格数据
await helper.waitForTableData();

// 获取表格行数
const count = await helper.getTableRowCount();
```

### 3.4 编写 E2E 测试

```typescript
import { test, expect } from '@playwright/test';
import { createPageHelper, Selectors } from './helpers';

test.describe('仓库管理', () => {
  test.beforeEach(async ({ page }) => {
    // 访问页面
    await page.goto('/base/warehouse');
    await page.waitForLoadState('networkidle');
  });

  test('新增仓库', async ({ page }) => {
    const helper = createPageHelper(page);

    // 点击新建
    await page.getByRole('button', { name: /新建/i }).click();

    // 验证弹窗
    await expect(page.locator(Selectors.modal)).toBeVisible();

    // 填写表单
    await helper.fillFormField('仓库编码', 'WH001');
    await helper.fillFormField('仓库名称', '测试仓库');

    // 提交
    await page.click(Selectors.modal + ' button[type="submit"]');

    // 验证结果
    await helper.waitForToast('新增成功');
  });
});
```

---

## 四、CI/CD 集成

### 4.1 GitHub Actions 工作流

| 工作流 | 触发条件 | 任务 |
|-------|---------|------|
| `backend-ci.yml` | push/PR | 单元测试、代码质量、构建 |
| `frontend-ci.yml` | push/PR | 单元测试、类型检查、E2E 测试、构建 |
| `ci.yml` | push/PR | 协调前后端 CI |

### 4.2 查看 CI 结果

1. 进入 GitHub 仓库页面
2. 点击 **Actions** 标签
3. 查看各工作流的运行状态
4. 下载测试报告和覆盖率报告

### 4.3 添加新测试

**后端：**
1. 在对应模块的 `src/test/java` 目录下创建测试类
2. 继承 `BaseServiceTest` 或 `BaseBizTest`
3. 使用 `@Mock` 和 `@InjectMocks` 注入依赖
4. 运行 `mvn test` 验证

**前端：**
1. 在 `e2e/` 目录下创建 `.spec.ts` 文件
2. 使用 `test()` 和 `expect()` 编写测试
3. 运行 `pnpm run test:e2e` 验证

---

## 五、常见问题

### 5.1 后端测试常见问题

| 问题 | 解决方案 |
|------|---------|
| 静态方法无法 Mock | 使用 `mockStatic()` 包装 |
| Mapper 方法不存在 | 在 `WarehouseReceiverMapper` 中添加方法 |
| 覆盖率报告生成失败 | 确保 JaCoCo 插件版本正确 |

### 5.2 前端测试常见问题

| 问题 | 解决方案 |
|------|---------|
| Playwright 找不到浏览器 | 运行 `pnpm exec playwright install` |
| E2E 测试超时 | 增加 `timeout` 配置或检查网络 |
| 全局 setup 登录失败 | 检查 `.env.test` 配置是否正确 |

---

## 六、测试覆盖率目标

| 模块 | 当前覆盖率 | 目标覆盖率 |
|------|----------|-----------|
| Service 层 | < 1% | 60% |
| Biz 层 | 0% | 50% |
| 前端组件 | N/A | 40% |
| 前端 E2E | 0% | 20% |

---

*文档更新时间：2026-04-04*
