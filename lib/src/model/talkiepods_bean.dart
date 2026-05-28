import '../../res/image_library.dart';
import '../../res/string_library.dart';
import '../constants/tracker_constants.dart';
import '../product/product_string.dart';

class TalkiePodsBean {
  final String icon;
  final String image;
  final String imagePad;
  final String priceId;
  final String color;
  final Function(AppLocalizations) name;

  TalkiePodsBean({
    required this.icon,
    required this.image,
    required this.imagePad,
    required this.priceId,
    required this.color,
    required this.name,
  });

  // 单一数据源：颜色/图片/价格ID/本地化名称
  // 索引说明：0=Green，1=Purple，2=Blue，3=Red & Yellow，4=Navy & Red，
  // 5=Pink & Purple，6=Black & Green
  static List<TalkiePodsBean> variants = [
    TalkiePodsBean(
      icon: ImageLibrary.icGreen,
      image: ImageLibrary.imgTalkiepodsGreen,
      imagePad: ImageLibrary.imgTalkiepodsGreenPad,
      priceId: ProductConfig.talkiePodsGreen,
      color: TrackerConstants.eventValueColorGreen,
      name: (loc) => loc.colorGreen,
    ),
    // TalkiePodsBean(
    //   icon: ImageLibrary.icPurple,
    //   image: ImageLibrary.imgTalkiepodsPurple,
    //   imagePad: ImageLibrary.imgTalkiepodsPurplePad,
    //   priceId: ProductConfig.talkiePodsPurple,
    //   color: TrackerConstants.eventValueColorPurple,
    //   name: (loc) => loc.colorPurple,
    // ),
    // TalkiePodsBean(
    //   icon: ImageLibrary.icBlue,
    //   image: ImageLibrary.imgTalkiepodsBlue,
    //   imagePad: ImageLibrary.imgTalkiepodsBluePad,
    //   priceId: ProductConfig.talkiePodsBlue,
    //   color: TrackerConstants.eventValueColorBlue,
    //   name: (loc) => loc.colorBlue,
    // ),
    // TalkiePodsBean(
    //   icon: ImageLibrary.icRedYellow,
    //   image: ImageLibrary.imgTalkiepodsRedYellow,
    //   imagePad: ImageLibrary.imgTalkiepodsRedYellowPad,
    //   priceId: ProductConfig.talkiePodsRedYellow,
    //   color: TrackerConstants.eventValueColorRedYellow,
    //   name: (loc) => loc.colorRedYellow,
    // ),
    // TalkiePodsBean(
    //   icon: ImageLibrary.icNavyRed,
    //   image: ImageLibrary.imgTalkiepodsNavyRed,
    //   imagePad: ImageLibrary.imgTalkiepodsNavyRedPad,
    //   priceId: ProductConfig.talkiePodsNavyRed,
    //   color: TrackerConstants.eventValueColorNavyRed,
    //   name: (loc) => loc.colorNavyRed,
    // ),
    // TalkiePodsBean(
    //   icon: ImageLibrary.icPinkPurple,
    //   image: ImageLibrary.imgTalkiepodsPinkPurple,
    //   imagePad: ImageLibrary.imgTalkiepodsPinkPurplePad,
    //   priceId: ProductConfig.talkiePodsPinkPurple,
    //   color: TrackerConstants.eventValueColorPinkPurple,
    //   name: (loc) => loc.colorPinkPurple,
    // ),
    // TalkiePodsBean(
    //   icon: ImageLibrary.icBlackGreen,
    //   image: ImageLibrary.imgTalkiepodsBlackGreen,
    //   imagePad: ImageLibrary.imgTalkiepodsBlackGreenPad,
    //   priceId: ProductConfig.talkiePodsBlackGreen,
    //   color: TrackerConstants.eventValueColorBlackGreen,
    //   name: (loc) => loc.colorBlackGreen,
    // ),
  ];

  // 模型图列表
  static const List<String> modelImages = [
    ImageLibrary.imgTalkiepods01,
    ImageLibrary.imgTalkiepods02,
  ];
}