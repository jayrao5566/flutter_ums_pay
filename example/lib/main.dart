import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:umspay/enum/enums.dart';
import 'package:umspay/umspay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _umspayPlugin = Umspay();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _umspayPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void _showTips(
    BuildContext context, {
    String? tips,
  }) {
    debugPrint(" === 弹窗tips:$tips ===");
    showCupertinoDialog<bool>(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return Material(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: Colors.greenAccent,
                  height: 100,
                  width: 200,
                  child: Text(
                    tips ?? "",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  iconSize: 60,
                  color: Colors.blueAccent,
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.close_outlined),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Builder(builder: (context) {
          return Center(
            child: Column(
              children: [
                Text('Running on: $_platformVersion\n'),
                const SizedBox(
                  height: 40,
                ),
                GestureDetector(
                  onTap: () {
                    // showTips(context, tips: "1111");
                    // return;
                    const payData = """
{\"miniuser\":\"2019010762862511\",\"msgType\":\"trade.appPreOrder\",\"package\":\"Sign=ALI\",\"minipath\":\"pages/appPay/index/index\",\"appScheme\":\"cdyncharge\",\"sign\":\"CGZcmxXdkgsGqayBGSnauksyWNGBkrdIWdHtzykzFWuWIthcfFzCnpMjtluPScRb\",\"prepayid\":\"ori=35UTT24091058984840309\",\"noncestr\":\"MDRTxmVNBThajyVbyElWSpJJtLDesoJY\",\"timestamp\":\"20240910184446\"}
                        """;
                    try {
                      debugPrint(" === error:${"No"} === ");
                      _umspayPlugin.umsPay(
                        type: UmsPayType.aliminipay,
                        payData: payData,
                        onSuccess: () {
                          _showTips(context, tips: "成功");
                        },
                        onFailure: (err) {
                          debugPrint(" === error is : 失败 aaaaaaa:$err === ");
                          _showTips(context, tips: err.toString());
                        },
                      );
                    } catch (e) {
                      debugPrint(" === error:${e.toString()} === ");
                    }
                  },
                  child: const Text("跳转到支付宝小程序支付"),
                ),
                const SizedBox(
                  height: 40,
                ),
                GestureDetector(
                  onTap: () {
                    const payData = """
{"tn": "760304680402643789213"}
                        """;
                    try {
                      debugPrint(" === error:${"No"} === ");
                      _umspayPlugin.cloundPay(
                        urlScheme: "cdyncharge",
                        payData: payData,
                        env: "00",
                        onSuccess: () {
                          _showTips(context, tips: "成功");
                        },
                        onFailure: (err) {
                          debugPrint(" === error is : 失败 aaaaaaa:$err === ");
                          _showTips(context, tips: err.toString());
                        },
                      );
                    } catch (e) {
                      debugPrint(" === error:${e.toString()} === ");
                    }
                  },
                  child: const Text("跳转到云闪付支付"),
                ),
                const SizedBox(
                  height: 40,
                ),
                GestureDetector(
                  onTap: () async {
                    try {
                      const payMode = AppPayMode.uppay;
                      final installed = await _umspayPlugin.installed(
                        payMode: payMode,
                      );
                      debugPrint(" === 支付${payMode.code}是否安装:$installed === ");
                      if (context.mounted) {
                        _showTips(
                          context,
                          tips: installed == true ? "安装" : "没有安装",
                        );
                      }
                    } catch (e) {
                      debugPrint(" === error:${e.toString()} === ");
                    }
                  },
                  child: const Text("支付app是否安装"),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
