//
//  ArQRCodeViewController.m
//  RTCPDemo
//
//  Created by 余生丶 on 2019/4/10.
//  Copyright © 2019 anyRTC. All rights reserved.
//

#import "ArQRCodeViewController.h"
#import "ArRoomViewController.h"

@interface ArQRCodeViewController ()

@property (nonatomic, strong) SGQRCodeScanView *scanView;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UIView *bottomView;
//辅流id（web端屏幕共享流）
@property (nonatomic, copy) NSString *flowId;

@end

@implementation ArQRCodeViewController {
    SGQRCodeObtain *_obtain;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"扫一扫";
    self.view.backgroundColor = [UIColor blackColor];
    [self setupQRCodeScan];
    [self.view addSubview:self.scanView];
    [self.view addSubview:self.promptLabel];
    [self.view addSubview:self.bottomView];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"image_Exit"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(returnBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
}

- (void)setupQRCodeScan {
    __weak typeof(self) weakSelf = self;
    SGQRCodeObtainConfigure *configure = [SGQRCodeObtainConfigure QRCodeObtainConfigure];
    configure.sampleBufferDelegate = YES;
    _obtain = [SGQRCodeObtain QRCodeObtain];
    [_obtain establishQRCodeObtainScanWithController:self configure:configure];
    [_obtain setBlockWithQRCodeObtainScanResult:^(SGQRCodeObtain *obtain, NSString *result) {
        if (result) {
            [obtain stopRunning];
            [obtain playSoundName:@"SGQRCode.bundle/sound.caf"];
            if (weakSelf.isFlow) {
                [NSNotificationCenter.defaultCenter postNotificationName:ArFlow_Notification object:result];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } else {
                ArRoomViewController *roomVc = [[weakSelf storyboard] instantiateViewControllerWithIdentifier:@"ArMeet_room"];
                roomVc.pubId = result;
                roomVc.isPull = YES;
                [weakSelf.navigationController pushViewController:roomVc animated:YES];
            }
        }
    }];
}

- (void)returnBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.backgroundColor = [UIColor clearColor];
        CGFloat promptLabelX = 0;
        CGFloat promptLabelY = 0.68 * self.view.frame.size.height;
        CGFloat promptLabelW = self.view.frame.size.width;
        CGFloat promptLabelH = 25;
        _promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
        _promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _promptLabel.text = @"将二维码放入框内, 即可自动扫描";
    }
    return _promptLabel;
}

- (SGQRCodeScanView *)scanView {
    if (!_scanView) {
        _scanView = [[SGQRCodeScanView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.9 * self.view.frame.size.height)];
    }
    return _scanView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scanView.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.scanView.frame))];
        _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _bottomView;
}

//MARK: - other
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_obtain startRunningWithBefore:nil completion:nil];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scanView addTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self.scanView removeTimer];
    [_obtain stopRunning];
}

- (void)dealloc {
    [self.scanView removeTimer];
    [self.scanView removeFromSuperview];
    self.scanView = nil;
}

@end
