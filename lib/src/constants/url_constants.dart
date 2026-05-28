

import '../../main.dart';
import '../../res/static_string_library.dart';

abstract class  UrlConstants{


  /// 带 label 用户反馈页面地址
  static final feedbackUrlWithLabel = "https://justalk.com/openApp?action=feedback&label=${loc.labelFeedback}&label_cn=${StaticStringLibrary.labelFeedbackCn}";

  /// app 更新地址
  static const updateUrl = "https://www.justalk.com/dl";

}