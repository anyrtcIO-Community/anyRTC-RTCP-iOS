//
//  ATLivingViewController.h
//  RTCPDemo
//
//  Created by jh on 2017/10/24.
//  Copyright © 2017年 jh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATLivingViewController : UIViewController

@property (nonatomic, copy) NSString *rtcpId;

//yes拉流 no推流
@property (nonatomic, assign) BOOL isPull;

@end
