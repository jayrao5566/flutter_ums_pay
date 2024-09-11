enum UmsPayType {
  weixin("01", "微信支付"),
  alipay("02", "支付宝支付"),
  uppay("03", "云闪付"),
  aliminipay("04", "支付宝小程序支付"),
  weixinminipay("05", "微信小程序支付");

  final String code;
  final String text;

  const UmsPayType(this.code, this.text);
}

enum AppPayMode {
  /// 云闪付APP
  uppay("uppay", "云闪付APP"),

  /// 微信APP
  wechat("wechat", "微信APP"),

  /// 支付宝APP
  ali("ali", "支付宝APP");

  final String code;
  final String text;

  const AppPayMode(this.code, this.text);
}
