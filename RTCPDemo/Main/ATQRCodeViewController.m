//
//  ATQRCodeViewController.m
//  DollMachine
//
//  Created by jh on 2017/11/29.
//  Copyright © 2017年 jh. All rights reserved.
//

#import "ATQRCodeViewController.h"

@interface ATQRCodeViewController ()<SGQRCodeScanManagerDelegate>

@property (nonatomic, strong) SGQRCodeScanManager *manager;

@property (nonatomic, strong) SGQRCodeScanningView *scanningView;

@property (nonatomic, strong) UILabel *promptLabel;

@end

@implementation ATQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.promptLabel];
    [self.view addSubview:self.scanningView];
    [self setNavBar];
    [self setupQRCodeScanning];
}

- (void)setNavBar{
    self.navigationItem.title = @"扫码观看";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [ATCommon getColor:@"#145eee"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    UIButton *leftBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setImage:[UIImage imageNamed:@"image_Exit"] forState:UIControlStateNormal];
    [leftBtn setTitle:@"返回" forState:UIControlStateNormal];
    leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    leftBtn.titleLabel.font=[UIFont systemFontOfSize:17];
    leftBtn.frame=CGRectMake(0, 0, 70, 30);
    [leftBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
}

//扫描
- (void)setupQRCodeScanning {
    self.manager = [SGQRCodeScanManager sharedManager];
    NSArray *arr = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    [_manager setupSessionPreset:AVCaptureSessionPreset1920x1080 metadataObjectTypes:arr currentController:self];
    _manager.delegate = self;
}

- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - - - SGQRCodeScanManagerDelegate
- (void)QRCodeScanManager:(SGQRCodeScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects {
    if (metadataObjects != nil && metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        NSString *resultStr = [obj stringValue];
        ATLivingViewController *livingVc = [[self storyboard] instantiateViewControllerWithIdentifier:@"LivingView"];
        livingVc.isPull = YES;
        livingVc.rtcpId = resultStr;
        [self.navigationController pushViewController:livingVc animated:YES];
        
        [scanManager stopRunning];
        [scanManager videoPreviewLayerRemoveFromSuperlayer];
    } else {
        [XHToast showCenterWithText:@"暂未识别出扫描的二维码"];
    }
}

- (void)QRCodeScanManager:(SGQRCodeScanManager *)scanManager brightnessValue:(CGFloat)brightnessValue {
    
}

- (SGQRCodeScanningView *)scanningView {
    if (!_scanningView) {
        _scanningView = [[SGQRCodeScanningView alloc] initWithFrame:self.view.bounds];
        _scanningView.scanningImageName = @"QRCodeScanningLine";
    }
    return _scanningView;
}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.backgroundColor = [UIColor clearColor];
        _promptLabel.frame = CGRectMake(0, 0.73 * self.view.frame.size.height, self.view.frame.size.width, 25);
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
        _promptLabel.textColor = [UIColor whiteColor];
        _promptLabel.text = @"将二维码放入框内, 即可自动扫描";
    }
    return _promptLabel;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.scanningView addTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.scanningView removeTimer];
    [_manager cancelSampleBufferDelegate];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

@end
