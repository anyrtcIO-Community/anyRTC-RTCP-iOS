//
//  ArRoomViewController.h
//  RTCPDemo
//
//  Created by 余生丶 on 2019/4/9.
//  Copyright © 2019 anyRTC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ArRoomViewController : UIViewController
/** YES推流、NO拉流 */
@property (nonatomic, assign) BOOL isPull;
@property (nonatomic, copy) NSString *pubId;

@end

NS_ASSUME_NONNULL_END
