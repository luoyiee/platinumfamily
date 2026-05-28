import 'package:earlybird/main.dart';
import 'package:earlybird/src/config/price_config.dart';
import 'package:earlybird/src/manager/user_type_manager.dart';

// flutter build web --base-href /talkiepods/v_1.0.6_202512241/    // 正式环境打包
// flutter build web --base-href /testtalkiepods/v_1.0.6_202512241/   // 测试环境打包

class ProductConfig {

  static final int versionCode = 262201;
  static final String versionName = "1.3.1_262201";

  static final int iosMinVersion = 891709150;
  static final int androidMinVersion = 890119380;

  // https://justalk.com/talkiepods/index.html  正式环境
  // https://justalk.com/testtalkiepods/index.html  测试环境
  // https://early-6c554.web.app  firebase 测试环境
  static final String myUrl = 'https://justalk.com/talkiepods/index.html';

  static final bool enableOfficialSale = true;

  // 假设黑五开始于： 2025-11-20 00:00:00 America/New_York (即 UTC 2025-11-20 00:00:00) 时间戳是：1763625600
  static final DateTime blackFridayStartUTC = DateTime.utc(2025, 11, 20, 0, 0, 0);

  // 假设黑五结束于： 2025-12-02 23:59:59 America/New_York (即 UTC 2025-12-02 23:59:59)  时间戳是：1764719999
  static final DateTime blackFridayEndUTC = DateTime.utc(2025, 12, 2, 23, 59, 59);

  /// 预售
  static final String membershipWithHeadphones = isTestMode ? 'price_1RsJEYEQXihmByPwDuUv7TOh' : 'price_1S0dvWEQXihmByPwYgX5hvB7';
  static final String membershipWithoutHeadphones = isTestMode ? 'price_1RswJiEQXihmByPwpg1SLspG' : 'price_1S0drpEQXihmByPwhfi05sbM';

  static final String membershipClaimWithoutHeadphones = isTestMode ? 'price_1RswKVEQXihmByPwdW42cDS2' : 'price_1S4tkyEQXihmByPwJAjhHoPZ';

  /// 正式销售
  static final String officialMembershipWithHeadphones = isTestMode ? 'price_1RswFYEQXihmByPwNH9x8DHb' : 'price_1S7YTIEQXihmByPwK3yQXMgZ';
  static final String officialMembershipWithoutHeadphones = isTestMode ? 'price_1RswK7EQXihmByPwLP9AjUZp' : 'price_1S7YTiEQXihmByPwDEBKkImd';

  // TalkiePods device variants (Stripe Price IDs)
  static final String talkiePodsBlue = isTestMode ? 'price_1RsJDsEQXihmByPwMwZNidlJ' : 'price_1S0de8EQXihmByPwV127hUBo';
  static final String talkiePodsPurple = isTestMode ? 'price_1RxepbEQXihmByPwxalmfxc1' : 'price_1S0dbyEQXihmByPwyyDvDcWF';
  static final String talkiePodsNavyRed = isTestMode ? 'price_1RxeosEQXihmByPwbvxNg0EZ' : 'price_1S0ddqEQXihmByPwbF1RmSUK';
  static final String talkiePodsRedYellow = isTestMode ? 'price_1RxeoNEQXihmByPw1brBpzA6' : 'price_1S0ddwEQXihmByPwWNfuekQG';
  static final String talkiePodsBlackGreen = isTestMode ? 'price_1RxeodEQXihmByPwwXVN0E59' : 'price_1S0dduEQXihmByPwIfWgOGp6';
  static final String talkiePodsGreen = isTestMode ? 'price_1RxepOEQXihmByPwu9NVLnRc' : 'price_1S0ddmEQXihmByPwARx72Qsv';
  static final String talkiePodsPinkPurple = isTestMode ? 'price_1RxenMEQXihmByPwqhAVKhSS' : 'price_1S0ddyEQXihmByPwukQUsQKN';

  static String getCouponId() {
    if (enableOfficialSale) {
      return 'LIMITEDDEAL20';
    }
    return isFamilyMember() ? 'LIMITEDDEAL20' : 'LIMITEDDEAL40';
  }

  /// 优惠券
  static String getOfficialCouponId() {
    return 'LIMITEDDEAL20';
  }


  static String getProductId(bool withHeadphones) {
    if (UserTypeManager().userType == UserType.planPlatinumFamily) {
      return 'noPlatinumFamily';
    }
    return withHeadphones ? ProductConfig.officialMembershipWithHeadphones : ProductConfig.officialMembershipWithoutHeadphones;
  }

}