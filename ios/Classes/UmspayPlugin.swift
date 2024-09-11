import Flutter
import UIKit

var messageChannel: FlutterBasicMessageChannel!

public class UmspayPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        messageChannel = FlutterBasicMessageChannel(name: "com.jajs.umspay.message",
                                                    binaryMessenger: registrar.messenger(),
                                                    codec: FlutterStandardMessageCodec.sharedInstance())
        let channel = FlutterMethodChannel(name: "umspay", binaryMessenger: registrar.messenger())
        let instance = UmspayPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    private func isAppInstalled(urlScheme: String) -> Bool {
        guard let url = URL(string: urlScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
            break
        case "installed":
            // 云闪付app，微信app，支付宝app是否安装
            if let payType = call.arguments as? String {
                switch payType {
                case "uppay":
                    result(isAppInstalled(urlScheme: "uppaywallet://"))
                    break
                case "wechat":
                    result(isAppInstalled(urlScheme: "weixin://"))
                    break
                case "ali":
                    result(isAppInstalled(urlScheme: "alipay://"))
                    break
                default:
                    break
                }
            }
            break
        case "cloundPay":
            // 云闪付
            if let params = call.arguments as? [String: Any] {
                debugPrint(" === 云闪付请求参数:\(params)  === ")
                // urlScheme不能为空
                let urlScheme = params["urlScheme"] as? String
                let payData = params["payData"] as? String
                if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController {
                    debugPrint(" === rootViewController请求参数:\(params)  === ")
                    UMSPPPayUnifyPayPlugin.cloudPay(withURLSchemes: urlScheme,
                                                    payData: payData,
                                                    viewController: rootViewController) { resultCode, resultInfo in
                        debugPrint(" === 云闪付支付 resultCode:\(resultCode ?? "") resultInfo:\(resultInfo ?? "") == ")
                        do {
                            if let resultParams = try! JSONSerialization.jsonObject(with: resultInfo!.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] {
                                let resultMsg = resultParams["resultMsg"]
                                var resultParams: [String: Any] = [:]
                                resultParams["errStr"] = resultMsg
                                resultParams["errCode"] = resultCode
                                messageChannel!.sendMessage(resultParams)
                                if resultCode == "0000" {
                                    // 支付成功
                                } else {

                                }
                            }
                        } catch (_) {
                            var resultParams: [String: Any] = [:]
                            resultParams["errStr"] = "支付失败"
                            resultParams["errCode"] = "1000"
                            messageChannel.sendMessage(resultParams)
                        }
                    }
                }
            }
            break
        case "umsPay":
            // 银联商务支付，天满平台
            if let params = call.arguments as? [String: Any] {
                debugPrint(" === 银联商务支付请求参数:\(params)  === ")
                let channel = params["channel"] as? String
                let payData = params["payData"] as? String
                let wechatAppId = params["wechatAppId"] as? String
                let universalLink = params["universalLink"] as? String
                var channelName = ""
                if channel == "02" {
                    // 支付宝支付
                    channelName = CHANNEL_ALIPAY
                } else if channel == "01" {
                    // 微信支付
                    UMSPPPayUnifyPayPlugin.registerApp(wechatAppId, universalLink: universalLink)
                    channelName = CHANNEL_WEIXIN
                } else if channel == "04" {
                    // 支付宝小程序支付
                    channelName = CHANNEL_ALIMINIPAY
                }
                UMSPPPayUnifyPayPlugin.pay(withPayChannel: channelName, payData: payData) { (resultCode, resultInfo) in
                    debugPrint(" === 银联商务支付 resultCode:\(resultCode ?? "") resultInfo:\(resultInfo ?? "") == ")
                    do {
                        if let resultParams = try! JSONSerialization.jsonObject(with: resultInfo!.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] {
                            let resultMsg = resultParams["resultMsg"]
                            var resultParams: [String: Any] = [:]
                            resultParams["errStr"] = resultMsg
                            resultParams["errCode"] = resultCode
                            messageChannel!.sendMessage(resultParams)
                            if resultCode == "0000" {
                                // 支付成功
                            } else {

                            }
                        }
                    } catch (_) {
                        var resultParams: [String: Any] = [:]
                        resultParams["errStr"] = "支付失败"
                        resultParams["errCode"] = "1000"
                        messageChannel.sendMessage(resultParams)
                    }
                }
            }
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // 银联商务支付中的支付宝支付
        // 充值成功之后要启动充电
        UMSPPPayUnifyPayPlugin.aliMiniPayHandleOpen(url)
        UMSPPPayUnifyPayPlugin.cloudPayHandleOpen(url)
        return true
    }
    
}
