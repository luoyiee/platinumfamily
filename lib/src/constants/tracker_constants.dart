

/// 没传 none
abstract class  TrackerConstants{

  static const eventParamAction = "action";
  static const eventParamFrom = "from";
  static const eventParamType = "type";

  /// 购买页
  static const eventNamePayShow = "payShow"; // 浏览
  static const eventNamePayClick = "payClick"; // 点击支付
  static const eventNamePayResult = "payResult";  // h5 支付结果
  static const eventNamePayResultDialog = "payResultDialog";  // h5 支付弹窗点击结果

  static const eventValueActionPurchase = "purchase";
  static const eventValueActionUserReport = "userReport";
  static const eventValueActionCheckOut = "checkOut";
  static const eventValueColor = "color"; // 耳机颜色   - color : none (用户未选择), no device ,具体颜色英文名称

  static const eventNameTalkiePodsPlatinumBundleMarketing = "talkiePodsPlatinumBundleMarketing";  // 正式销售介绍页浏览
  static const eventNameTalkiePodsPlatinumBundleMarketingAction = "talkiePodsPlatinumBundleMarketingAction";  // 正式销售介绍页按钮点击

  static const eventValueColorNone = "none";
  static const eventValueColorNoDevice = "no device";
  static const eventValueColorBlue = "Blue";
  static const eventValueColorPurple = "Purple";
  static const eventValueColorNavyRed = "Navy and Red";
  static const eventValueColorRedYellow = "Red and Yellow";
  static const eventValueColorBlackGreen = "Black and Green";
  static const eventValueColorGreen = "Green";
  static const eventValueColorPinkPurple = "Pink and Purple";

  static const eventValuePayResultOk = "ok";
  static const eventValuePayResultCancel = "cancel";
  static const eventValueMembershipPlatinumFamily = "platinumFamily";

  static const eventValuePayResultDialogDone = "已完成支付";
  static const eventValuePayResultDialogUnDone = "未完成支付";
  static const eventValuePayResultDialogContinue = "重新支付";
  static const eventValuePayResultDialogAbandon = "放弃支付";
  static const eventValuePayResultDialogFeedback = "反馈问题";

}