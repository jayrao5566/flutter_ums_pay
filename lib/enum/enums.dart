enum UmsPayType {
  weixin("01", "微信支付"),
  alipay("02", "支付宝支付"),
  umspay("03", "云闪付"),
  aliminipay("04", "支付宝小程序支付"),
  weixinminipay("05", "微信小程序支付");

  final String code;
  final String text;

  const UmsPayType(this.code, this.text);
}
