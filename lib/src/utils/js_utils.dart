import 'dart:convert';
import 'dart:js_interop';

@JS('console.log')
external void _consoleLogJs(JSString message);
void consoleLog(String message) => _consoleLogJs(message.toJS);

/// 将JSAny转换为String
String? jsAnyToString(JSAny? data) {
  if (data == null) return null;
  if (data.isA<JSString>()) return (data as JSString).toDart;
  return data.toString();
}

/// 将JSAny转换为 Map<String, dynamic>
Map<String, dynamic>? jsAnyToMap(JSAny? data) {
  if (data == null) return null;
  if (data.isA<JSObject>()) {
    final obj = (data as JSObject).dartify();
    if (obj is Map<String, dynamic>) return obj;
  }
  if (data.isA<JSString>()) {
    try {
      return jsonDecode((data as JSString).toDart);
    } catch (_) {}
  }
  return null;
} 