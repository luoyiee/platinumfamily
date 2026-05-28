# JUSTALK 字体样式系统使用指南

## 概述

基于设计规范创建的字体样式系统，提供统一的字体样式管理。

## 字体规范

- **字体族**: Roboto
- **经典主题**: Roboto
- **Cute主题**: Roboto

## 样式分类

### 1. Display 样式 (大型标题)
- `displayLarge`: 57px, 64px行高, Bold
- `displayMedium`: 45px, 52px行高, Bold  
- `displaySmall`: 36px, 44px行高, Bold

### 2. Headline 样式 (标题)
- `headlineLarge`: 32px, 40px行高, Bold
- `headlineMedium`: 28px, 36px行高, Bold
- `headlineMedium2`: 28px, 34px行高, Bold
- `headlineSmall`: 24px, 32px行高, Bold
- `headlineSmall2`: 20px, 28px行高, Bold
- `headlineSmall3`: 18px, 26px行高, Bold

### 3. Title 样式 (小标题)
- `titleLarge`: 22px, 28px行高, Bold
- `titleMedium`: 16px, 24px行高, Bold
- `titleSmall`: 14px, 20px行高, Bold

### 4. Label 样式 (标签)
- `labelLarge`: 14px, 20px行高, Bold
- `labelMedium`: 12px, 16px行高, Bold
- `labelSmall`: 11px, 16px行高, Bold

### 5. Body 样式 (正文)
- `bodyLarge2`: 18px, 26px行高, Medium
- `bodyLarge`: 16px, 24px行高, Medium
- `bodyMedium`: 14px, 20px行高, Medium
- `bodySmall`: 12px, 16px行高, Medium

## 使用方法

### 1. 直接使用样式

```dart
import 'package:your_app/constants/text_style.dart';

Text(
  'Hello World',
  style: JustalkTextStyles.headlineLarge,
)
```

### 2. 根据字号获取样式

```dart
Text(
  'Hello World',
  style: JustalkTextStyles.getStyleByFontSize(32),
)
```

### 3. 使用便捷方法

```dart
// Display 样式
Text('Hello', style: JustalkTextStyles.getDisplayStyle(size: 'large'))

// Headline 样式
Text('Hello', style: JustalkTextStyles.getHeadlineStyle(size: 'medium'))

// Title 样式
Text('Hello', style: JustalkTextStyles.getTitleStyle(size: 'small'))

// Label 样式
Text('Hello', style: JustalkTextStyles.getLabelStyle(size: 'medium'))

// Body 样式
Text('Hello', style: JustalkTextStyles.getBodyStyle(size: 'large'))
```

### 4. 样式组合

```dart
Text(
  'Hello World',
  style: JustalkTextStyles.headlineLarge.copyWith(
    color: Colors.blue,
    decoration: TextDecoration.underline,
  ),
)
```

## 实际应用示例

### 主页面标题
```dart
Text(
  'The Best Value Family Offer',
  style: JustalkTextStyles.headlineLarge,
)
```

### 副标题
```dart
Text(
  '1 TalkiePods & 1-Year Platinum Family',
  style: JustalkTextStyles.bodyLarge,
)
```

### 按钮文本
```dart
Text(
  '🔥Buy \$99',
  style: JustalkTextStyles.labelLarge.copyWith(
    color: Colors.white,
  ),
)
```

### 小标签
```dart
Text(
  'Already Got One? Bind My Device',
  style: JustalkTextStyles.bodySmall,
)
```

## 注意事项

1. **行高计算**: 行高 = 字体大小 × height值
2. **字体权重**: Bold = FontWeight.bold, Medium = FontWeight.w500
3. **响应式**: 所有尺寸都是固定的像素值，如需响应式请使用 MediaQuery
4. **主题适配**: 当前使用 Roboto 字体，如需切换主题可修改 `_fontFamily`

## 扩展建议

如需添加新的字体样式，请：

1. 在 `JustalkTextStyles` 类中添加新的静态常量
2. 在 `getStyleByFontSize` 方法中添加对应的 case
3. 在相应的便捷方法中添加新的选项
4. 更新此文档

## 最佳实践

1. **一致性**: 在整个应用中使用统一的字体样式
2. **语义化**: 根据文本的语义选择对应的样式类型
3. **可维护性**: 避免硬编码字体样式，始终使用 `JustalkTextStyles`
4. **性能**: 样式是 const 的，可以安全地在 build 方法中使用 