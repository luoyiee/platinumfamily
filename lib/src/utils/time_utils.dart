import 'package:intl/intl.dart';

String formatTimestamp(int timestamp) {
  // 1. 将时间戳（毫秒）转换为 DateTime 对象
  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

  // 2. 创建一个 DateFormat 实例，指定你想要的格式
  // 'MMM' 代表月份的缩写 (e.g., Jul)
  // 'd' 代表日期 (e.g., 10)
  // 'yyyy' 代表四位数的年份 (e.g., 2025)
  final formatter = DateFormat('MMM d, yyyy');

  // 3. 使用 formatter 来格式化 DateTime 对象，并返回结果
  return formatter.format(dateTime);
}