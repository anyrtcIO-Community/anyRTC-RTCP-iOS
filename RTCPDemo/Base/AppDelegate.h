//
//  AppDelegate.h
//  RTCPDemo
//
//  Created by jh on 2017/10/20.
//  Copyright © 2017年 jh. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *developerID = @"XXX";
static NSString *token = @"XXX";
static NSString *key = @"XXX";
static NSString *appID = @"XXX";

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//是都允许横屏
@property (nonatomic,assign)BOOL allowRotation;

@end

