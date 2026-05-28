# Earlybird

A Flutter project for TalkiePods.

## 项目概述

这是一个 Flutter 多平台应用，支持 Web、iOS 和 Android。

## 开发环境

- Flutter SDK: ^3.7.2
- Dart SDK: ^3.7.2

## 本地运行

### 移动端
```bash
flutter run
```

### Web 端
```bash
flutter run -d chrome
# 或指定端口
flutter run -d web-server --web-port=8080
```

## Web 部署

### 1. 本地 HTTP 服务器（局域网访问）

适合本地测试，手机和电脑在同一 WiFi 下也可访问。

```bash
# 构建项目
flutter build web --release

# 启动本地服务器
cd build/web
npx http-server -p 8000 -a 0.0.0.0
```

访问地址：
- 电脑访问: http://localhost:8000
- 手机访问: http://你的局域网IP:8000 (例如: http://172.10.0.86:8000)

查看本地 IP 地址：
```bash
ipconfig getifaddr en0  # macOS
ipconfig               # Windows
```

### 2. Firebase 部署
```bash
 firebase deploy
```
### 3. 测试环境 打包
```bash
flutter build web --base-href /testtalkiepods/v_1.0.3_202509291/
```

#### 正式环境 打包
```bash
flutter build web --base-href /talkiepods/v_1.0.3_202509291/
```

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── res/
│   └── lang/                # 多语言支持
│       ├── en.dart
│       ├── zh.dart
│       └── zh_tw.dart
├── src/
│   ├── constants/           # 常量定义
│   ├── manager/             # 管理器类
│   ├── pages/               # 页面
│   │   ├── membership_claim_page.dart
│   │   └── talkiepods/      # TalkiePods 相关页面
│   ├── product/             # 产品相关
│   ├── utils/               # 工具类
│   └── view/                # 自定义组件
└── assets/
    ├── config/              # 配置文件
    ├── images/              # 图片资源
    ├── videos/              # 视频资源
    └── svg/                 # SVG 图标
```


## 版本管理

当前版本: 1.0.0+27

更新版本号:
```bash
# 在 pubspec.yaml 中修改 version 字段
version: 1.0.0+27
```

## Git 工作流

当前分支: main

```bash
# 查看状态
git status

# 提交更改
git add .
git commit -m "描述信息"
git push

# 切换分支
git checkout dev_1.0.5
```

## 常见问题

### 修改版本号后如何更新部署路径？

正式环境：
```bash
flutter build web --base-href /talkiepods/v_新版本号/
```

测试环境：
```bash
flutter build web --base-href /testtalkiepods/v_新版本号/
```



