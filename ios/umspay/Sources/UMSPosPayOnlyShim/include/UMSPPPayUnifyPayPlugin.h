//
//  UMSPPPayUnifyPayPlugin.h
//  UMSPosPay
//
//  Created by SunXP on 17/4/25.
//  Copyright © 2017年 ChinaUMS. All rights reserved.
//

//  sdk_version = 3.1.6

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WechatOpenSDK/WXApi.h>

FOUNDATION_EXTERN NSString *const CHANNEL_WEIXIN;
FOUNDATION_EXTERN NSString *const CHANNEL_ALIPAY;
FOUNDATION_EXTERN NSString *const CHANNEL_ALIMINIPAY;
FOUNDATION_EXTERN NSString *const CHANNEL_WEIXINMINI;

typedef void(^TransactionResultBlock)(NSString *resultCode, NSString *resultInfo);

@interface UMSPPPayUnifyPayPlugin : NSObject

+ (void)payWithPayChannel:(NSString *)payChannel
                  payData:(NSString *)payData
            callbackBlock:(TransactionResultBlock)callbackBlock;

+ (void)cloudPayWithURLSchemes:(NSString *)schemes
                       payData:(NSString *)payData
                viewController:(UIViewController *)viewController
                 callbackBlock:(TransactionResultBlock)callbackBlock;

+ (void)aliSafePayWithURLSchemes:(NSString *)schemes
                         payData:(NSString *)payData
                   callbackBlock:(TransactionResultBlock)callbackBlock;

+ (BOOL)registerApp:(NSString *)appId universalLink:(NSString *)universalLink;

+ (BOOL)handleOpenURL:(NSURL *)url otherDelegate:(id<WXApiDelegate>)otherDelegate;

+ (BOOL)handleOpenUniversalLink:(NSUserActivity *)userActivity
                  otherDelegate:(id<WXApiDelegate>)otherDelegate API_AVAILABLE(ios(8.0));

+ (BOOL)cloudPayHandleOpenURL:(NSURL *)url;
+ (void)aliMiniPayHandleOpenURL:(NSURL *)url;
+ (void)aliSafePayHandleOpenURL:(NSURL *)url;

@end
