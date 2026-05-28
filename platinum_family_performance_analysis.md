# Platinum Family 页面加载性能问题分析

## 背景

基于 Grafana 看板数据：

| 指标 | Platinum Family | 全局 H5 均值 | 差距 |
|------|----------------|-------------|------|
| 页面加载成功率 | ~60% | ~84% | **-24pp** |
| 加载成功耗时 P90 | ~10s | ~6s | **+4s (+67%)** |

---

## 问题一：本地资源体积过大

**根本原因：assets 总体积 109MB，其中视频资源占 63MB，是首屏加载耗时高的主要贡献来源。**

### 1.1 视频资源是最大瓶颈

| 文件 | 大小 |
|------|------|
| `assets/videos/official_home.mp4` | 24MB |
| `assets/videos/official_home_tablet.mp4` | 24MB |
| `assets/videos/home_top.mp4` | 15MB |

视频资源打包在 assets 里，WebView 首次加载时需要完整传输，单视频文件就占绝大部分耗时。建议将视频迁移至 CDN，改用网络流式加载，彻底移出主包体积。

此外，`home_top_video.dart:25` 在 `initState` 中立即触发初始化，**同步阻塞首帧渲染**，迁移 CDN 后同步改为 `VideoPlayerController.networkUrl()`：

```dart
// 当前：从本地 assets 加载，阻塞首帧
_controller = VideoPlayerController.asset(widget.video)

// 建议：走 CDN 网络加载
_controller = VideoPlayerController.networkUrl(Uri.parse(cdnVideoUrl))
```

### 1.2 大量图片未转 WebP

images 目录下共 **189 个 PNG，仅 42 个 webp**，webp 占比不足 20%。3.0x 尺寸下单张 PNG 最高达 1MB，转 webp 后通常可压缩 40～60%。

| 目录 | PNG 数量 | webp 数量 |
|------|---------|---------|
| images/（1x，根目录） | 63 | 14 |
| images/2.0x/ | 63 | 14 |
| images/3.0x/ | 63 | 14 |
| **合计** | **189** | **42** |

### 1.3 与 Poll 页面的本质差异

Poll 页面几乎没有重型本地资源（无视频、图片少），Platinum Family 有视频 + 大量耳机颜色图，本地资源体积差距悬殊，直接反映在耗时差距上。

---

## 问题二：`checkPurchaseHistory` 阻塞了不必要的关键路径

### 2.1 当前加载链路（完整串行路径）

```
App 打开 WebView
    ↓
[1] JsBridgeManager.setup() — 等待 Bridge 注入完成
    ↓
[2] initWeb() — Bridge 调用，等待 App 返回初始化数据
    ↓
[3] _initWebCallback() — 解析 version/userType/traceData 等
    ↓
[4] freeTrialDay() — 异步查询用户会员类型（不阻塞主流程）
    ↓
[5] checkPurchaseHistory() — Bridge 调用，等待 App 查询 Stripe 历史订单
    ↓（等待 App 侧网络请求返回）
[6] loadingSuccess() 上报 ← 此处才算"加载成功"
    ↓
[7] PriceConfigManager.loadConfig() — 读取本地 JSON 资源
    ↓
[8] 路由跳转 → TalkiePodsHomePage 渲染
```

每一步均为串行等待，P90 达到 10s 是上述多个 IPC + 网络等待叠加的结果。

### 2.2 `checkPurchaseHistory` 不需要阻塞关键路径

`checkPurchaseHistory` 的目的是查询 Stripe 历史订单，检测是否存在 `acknowledged=false` 的未激活订单。该场景属于**极低频兜底逻辑**（绝大多数用户订单均已激活），却被放在关键路径上阻塞了所有用户的首屏渲染和 `loadingSuccess` 上报。

当前代码中还存在一个直接 bug：回调返回 `null` 时直接 `return`，导致 `loadingSuccess` 和 `initPage` 均不会执行：

```dart
webViewJavascriptBridge.callHandler('jtJsToApp'.toJS, paramsJson.toJS, (JSAny? responseData) {
    if (responseData == null) {
      consoleLog('purchaseHistory callback is null');
      return;  // ⚠️ 直接 return，loadingSuccess 和 initPage 均不会执行
    }
    JsBridgeManager.loadingSuccess();
    ...
    initPage();
});
```

回调为 `null` 并非偶发——查看 App 侧 Android 实现，错误路径会**显式回调 null**：

```java
private void handlePurchaseHistory(CallBackFunction callBack, String platform) {
    ApiClientHelper.getOrderHistory(platform)
            .compose(RxUtilsKt.ioTransformer())
            .doOnNext(callBack::onCallBack)
            .doOnError(throwable -> LogUtils.e(getClassName(), "purchaseHistory error", throwable))
            .doOnError(throwable -> callBack.onCallBack(null))  // ⚠️ 任何网络/接口异常 → 主动回调 null
            .onErrorResumeNext(Observable.empty())
            .compose(bindUntilEvent(ActivityEvent.DESTROY))
            .subscribe();
}
```

两条路径对应关系明确：

- **成功**：`doOnNext` 回调真实数据
- **任何异常**（网络超时、接口报错等）：`doOnError` 主动调用 `callBack.onCallBack(null)`

即**线上每一次网络波动都会稳定触发这条失败链路**。网络越差的用户，命中概率越高，60% 成功率完全可以解释。

### 2.3 正确做法：将 `checkPurchaseHistory` 移出关键路径

`checkPurchaseHistory` 本质上是一个补救检查，应后台静默执行，不阻塞首屏渲染：

```
_initWebCallback() 完成
    ↓
立即调用 loadingSuccess() + initPage()    ← 不再等待
    ↓（并行）
_checkPurchaseHistoryInBackground()        ← 后台静默执行
    ↓
若发现 acknowledged=false 的订单 → 从已渲染页面内跳转激活页（体验可接受）
```

对应代码改动：

```dart
// 当前：阻塞等待 purchaseHistory 回调
checkPurchaseHistory();

// 建议：立即上报成功并渲染，purchaseHistory 后台查
JsBridgeManager.loadingSuccess();
Future.delayed(Duration(milliseconds: 500), () {
  setState(() { loadingSuccess = true; });
});
initPage();
_checkPurchaseHistoryInBackground(); // 后台静默，发现未激活订单再跳转
```

`_checkPurchaseHistoryInBackground` 中只保留跳转逻辑，不再调用 `loadingSuccess`：

```dart
void _checkPurchaseHistoryInBackground() {
  final paramsJson = jsonEncode({'action': 'purchaseHistory', 'platform': 'stripe'});
  webViewJavascriptBridge.callHandler('jtJsToApp'.toJS, paramsJson.toJS, (JSAny? responseData) {
    if (responseData == null) return; // 静默忽略，不影响已渲染的页面
    // ...解析，发现 acknowledged=false 时跳转激活页
  }.toJS);
}
```

---

## 综合结论

| 问题 | 影响维度 | 严重程度 |
|------|---------|---------|
| `checkPurchaseHistory` 阻塞关键路径（含 null 时漏报 `loadingSuccess`） | 成功率 + 耗时 | P0 |
| 视频资源 63MB 打包在 assets，同步阻塞首帧 | 耗时 | P0 |
| 新增耳机 PNG 未转 WebP | 耗时 | P1 |
| `purchaseHistory` 缺少超时兜底（后台化后降级） | 体验兜底 | P1 |

**耗时高**的根因是视频资源 + 串行接口链路叠加；**成功率低**的根因是 `checkPurchaseHistory` 不必要地阻塞了关键路径，且 null 回调时漏报 `loadingSuccess`。两个方向独立，需分别修复。

## 优化方案

| 问题 | 优化方案 | 优先级 |
|------|---------|--------|
| `checkPurchaseHistory` 阻塞关键路径 | 将其移出关键路径，改为后台静默执行；`loadingSuccess` 和 `initPage` 在 `_initWebCallback` 完成后立即调用 | P0 |
| 视频资源 63MB 打包在 assets | 视频迁移至 CDN，改用 `VideoPlayerController.networkUrl()` 加载 | P0 |
| 大量图片未转 WebP | 存量 PNG 批量转换为 WebP，预计可压缩 40～60% 体积 | P1 |
| `purchaseHistory` 缺少超时兜底 | 后台化后不再白屏，但仍建议加超时（8s）以便回收后台任务，避免用户已离开后仍触发跳转 | P1 |

---

## 后续方向：技术栈迁移至 Vue

当前项目基于 Flutter Web 构建 H5，Flutter Web 的产物是编译后的 Wasm/JS，所有 assets 随包分发，**天然不适合 H5 轻量加载场景**，也是本次资源体积问题的结构性根因。

后续若迁移至 Vue（或其他原生 Web 框架），可获得：

- 图片/视频走 CDN 按需加载，不打入主包
- 首屏 JS bundle 可做代码分割，按路由懒加载
- 浏览器原生缓存策略（ETag/Cache-Control）生效，二次访问极快
- 构建产物可控，便于持续优化

该方向为中长期规划，短期优先修复上述 P0 问题。
