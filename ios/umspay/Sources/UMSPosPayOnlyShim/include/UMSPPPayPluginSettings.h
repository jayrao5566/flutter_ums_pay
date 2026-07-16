//
//  UMSPluginSettings.h
//  UMSPosPay
//
//  Created by chinaums on 15/10/19.
//  Copyright © 2015年 ChinaUMS. All rights reserved.
//

//  sdk_version = 3.1.6

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UMSPluginEnvironment) {
    UMSP_PROD,
    UMSP_TEST
};

typedef NS_ENUM(NSInteger, UMSPluginEnterType) {
    UMSPluginEnterType_Default,
    UMSPluginEnterType_ScanCode
};

@interface UMSPPPayPluginSettings : NSObject

+ (UMSPPPayPluginSettings *)sharedInstance;

@property (nonatomic, assign) UMSPluginEnvironment umspEnviroment;
@property (nonatomic, assign) UMSPluginEnterType umspEnterType;
@property (nonatomic, assign) BOOL umspSplash;

@end
