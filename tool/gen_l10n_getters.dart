import 'dart:io';

void main() {
  final file = File('lib/l10n/en.dart');
  final content = file.readAsStringSync();

  // 提取所有 key
  final keyReg = RegExp(r"'([^']+)':");
  final keys = keyReg.allMatches(content).map((m) => m.group(1)!).toList();

  // 生成 getter
  final getters = keys.map((k) {
    // 驼峰命名
    final camel = k.replaceAllMapped(RegExp(r'_([a-z])'), (m) => m.group(1)!.toUpperCase());
    return "  String get $camel => _get('$k');";
  }).join('\n');

  print('// --- 自动生成的 getter ---');
  print(getters);
} 