import Flutter
import UIKit

#if UMSPAY_SPM
import UMSPosPayOnlyShim
#endif

var messageChannel: FlutterBasicMessageChannel!

public class UmspayPlugin: NSObject, FlutterPlugin, FlutterSceneLifeCycleDelegate {
    public static func register(with registrar: FlutterPluginRegistrar) {
        messageChannel = FlutterBasicMessageChannel(
            name: "com.jajs.umspay.message",
            binaryMessenger: registrar.messenger(),
            codec: FlutterStandardMessageCodec.sharedInstance()
        )
        let channel = FlutterMethodChannel(name: "umspay", binaryMessenger: registrar.messenger())
        let instance = UmspayPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
        if #available(iOS 13.0, *) {
            registrar.addSceneDelegate(instance)
        }
    }

    @available(iOS 13.0, *)
    private func activeRootViewController() -> UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first {
                $0.activationState == .foregroundActive ||
                $0.activationState == .foregroundInactive
            }
        let window = windowScene?.windows.first(where: \.isKeyWindow)
            ?? windowScene?.windows.first

        return window?.rootViewController
            ?? UIApplication.shared.delegate?.window??.rootViewController
    }

    private func handleOpenURL(_ url: URL) -> Bool {
        // 银联商务支付中的支付宝支付
        // 充值成功之后要启动充电
        UMSPPPayUnifyPayPlugin.aliMiniPayHandleOpen(url)
        return UMSPPPayUnifyPayPlugin.cloudPayHandleOpen(url)
    }

    private func sendPayResult(resultCode: String?, resultInfo: String?) {
        var resultParams: [String: Any] = [
            "errStr": "支付失败",
            "errCode": "1000",
        ]
        if let resultInfo,
           let data = resultInfo.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data),
           let params = json as? [String: Any] {
            resultParams["errStr"] = params["resultMsg"]
            resultParams["errCode"] = resultCode
        }
        messageChannel?.sendMessage(resultParams)
    }

    private func isAppInstalled(urlScheme: String) -> Bool {
        guard let url = URL(string: urlScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "installed":
            if let payType = call.arguments as? String {
                switch payType {
                case "uppay":
                    result(isAppInstalled(urlScheme: "uppaywallet://"))
                case "wechat":
                    result(isAppInstalled(urlScheme: "weixin://"))
                case "ali":
                    result(isAppInstalled(urlScheme: "alipay://"))
                default:
                    break
                }
            }
        case "cloundPay":
            if let params = call.arguments as? [String: Any] {
                debugPrint(" === 云闪付请求参数:\(params)  === ")
                let urlScheme = params["urlScheme"] as? String
                let payData = params["payData"] as? String
                let rootViewController: UIViewController?
                if #available(iOS 13.0, *) {
                    rootViewController = activeRootViewController()
                } else {
                    rootViewController = UIApplication.shared.delegate?.window??.rootViewController
                }
                if let rootViewController = rootViewController {
                    debugPrint(" === rootViewController请求参数:\(params)  === ")
                    UMSPPPayUnifyPayPlugin.cloudPay(
                        withURLSchemes: urlScheme,
                        payData: payData,
                        viewController: rootViewController
                    ) { resultCode, resultInfo in
                        debugPrint(" === 云闪付支付 resultCode:\(resultCode ?? "") resultInfo:\(resultInfo ?? "") == ")
                        self.sendPayResult(resultCode: resultCode, resultInfo: resultInfo)
                    }
                }
            }
        case "umsPay":
            if let params = call.arguments as? [String: Any] {
                debugPrint(" === 银联商务支付请求参数:\(params)  === ")
                let channel = params["channel"] as? String
                let payData = params["payData"] as? String
                let wechatAppId = params["wechatAppId"] as? String
                let universalLink = params["universalLink"] as? String
                var channelName = ""
                if channel == "02" {
                    channelName = CHANNEL_ALIPAY
                } else if channel == "01" {
                    UMSPPPayUnifyPayPlugin.registerApp(wechatAppId, universalLink: universalLink)
                    channelName = CHANNEL_WEIXIN
                } else if channel == "04" {
                    channelName = CHANNEL_ALIMINIPAY
                }
                UMSPPPayUnifyPayPlugin.pay(withPayChannel: channelName, payData: payData) {
                    resultCode,
                    resultInfo in
                    debugPrint(" === 银联商务支付 resultCode:\(resultCode ?? "") resultInfo:\(resultInfo ?? "") == ")
                    self.sendPayResult(resultCode: resultCode, resultInfo: resultInfo)
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        handleOpenURL(url)
    }

    @available(iOS 13.0, *)
    public func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions?
    ) -> Bool {
        guard let connectionOptions = connectionOptions else { return false }
        var handled = false
        for context in connectionOptions.urlContexts {
            handled = handleOpenURL(context.url) || handled
        }
        return handled
    }

    @available(iOS 13.0, *)
    public func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) -> Bool {
        var handled = false
        for context in URLContexts {
            handled = handleOpenURL(context.url) || handled
        }
        return handled
    }
}
