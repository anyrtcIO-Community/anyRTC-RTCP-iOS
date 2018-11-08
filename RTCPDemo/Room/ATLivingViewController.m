//
//  ATLivingViewController.m
//  RTCPDemo
//
//  Created by jh on 2017/10/24.
//  Copyright © 2017年 jh. All rights reserved.
//

#import "ATLivingViewController.h"

@interface ATLivingViewController ()<RTCPKitDelegate>

//频道id
@property (weak, nonatomic) IBOutlet UILabel *rtcpIdLabel;
//状态
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
//切换摄像头
@property (weak, nonatomic) IBOutlet UIButton *switchButton;

@property (weak, nonatomic) IBOutlet UIView *qrCodeView;
//二维码
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;

//视频显示窗口
@property (nonatomic, strong) UIView *localView;

@property (nonatomic, assign) CGFloat videoScale;

@property (nonatomic, strong)RTCPKit *rtcpKit;

@end

@implementation ATLivingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
    [self.view insertSubview:self.localView atIndex:0];
    self.qrCodeView.hidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideQrView)];
    [self.qrCodeView addGestureRecognizer:tap];
    
    self.qrCodeImageView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(saveImage:)];
    [self.qrCodeImageView addGestureRecognizer:longTap];
    
    [self itializationRTCPKit];
}

- (void)itializationRTCPKit{
    //配置信息
    RTCPOption *option = [RTCPOption defaultOption];
    option.videoMode = AnyRTCVideoQuality_Medium1;
    option.orientation = RTC_SCRN_Auto;
    
    //初始化会议工具类
    self.rtcpKit = [[RTCPKit alloc]initWithDelegate:self withOption:option];
    if (self.isPull) {
        //观看直播
        [self.rtcpKit subscribe:self.rtcpId];
        [self.switchButton setHidden:YES];
        self.rtcpIdLabel.text = self.rtcpId;
    } else {
        //开启直播
        [self.rtcpKit publish:0 withAnyRtcId:[ATCommon randomString:6]];
        [self.rtcpKit updateLocalVideoRenderModel:AnyRTCVideoRenderScaleAspectFill];
        //设置本地视频窗口
        [self.rtcpKit setLocalVideoCapturer:self.localView];
    }
}

- (void)hideQrView{
    self.qrCodeView.hidden = YES;
}

- (void)saveImage:(UILongPressGestureRecognizer *)longTap{
    if (longTap.state == UIGestureRecognizerStateBegan) {
        //保存到相册
        UIImageWriteToSavedPhotosAlbum(self.qrCodeImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        [XHToast showCenterWithText:@"添加图片成功"];
    }
}

#pragma mark - RTCPKitDelegate
- (void)onPublishOK:(NSString *)strRtcpId withLiveInfo:(NSString*)strLiveInfo{
    //发布媒体成功回调
    self.rtcpId = strRtcpId;
    self.rtcpIdLabel.text = strRtcpId;
    self.tipsLabel.text = @"发布媒体成功...";
}

- (void)onPublishFailed:(int)nCode{
    //发布媒体失败回调
    self.tipsLabel.text = @"发布媒体失败...";
    if (nCode == 100) {
        [XHToast showCenterWithText:@"网络异常"];
    }
}

- (void)onSubscribeOK:(NSString*)strRtcpId{
    //订阅频道成功的回调
    self.tipsLabel.text = @"订阅频道成功...";
}

- (void)onSubscribeFailed:(NSString*)strRtcpId intCode:(int)nCode{
    //订阅频道失败的回调
    self.tipsLabel.text = @"订阅频道失败...";
    if (nCode == 100) {
        [XHToast showCenterWithText:@"网络异常"];
    }
}

- (void)onRTCOpenVideoRender:(NSString*)strRtcpId{
    //订阅后视频即将显示的回调
    [self.rtcpKit setRTCVideoRender:strRtcpId andRender:self.localView];
}

- (void)onRTCCloseVideoRender:(NSString*)strRtcpId{
    //订阅的视频离开的回调
    [self.rtcpKit close];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRTCVideoViewChanged:(UIView*)videoView didChangeVideoSize:(CGSize)size{
    //视频窗口大小的回调
    if (self.isPull && size.height > 0) {
        //拉
        self.videoScale = size.width / size.height;
        [self layOut];
    } else {
        //推
        [self.localView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    }
}

-(void)onRTCFirstLocalVideoFrame:(UIView*)videoView videoSize:(CGSize)size{
    //本地视频第一针
}

-(void)onRTCFirstRemoteVideoFrame:(UIView*)videoView videoSize:(CGSize)size{
    //远程视频第一针
}

- (void)layOut{
    if (SCREEN_WIDTH > SCREEN_HEIGHT) {
        //横屏
        self.localView.frame = CGRectMake(0, 0, SCREEN_HEIGHT * self.videoScale, SCREEN_HEIGHT);
    } else {
        //竖屏
        self.localView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/self.videoScale);
    }
    self.localView.center = self.view.center;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (self.isPull) {
            [self layOut];
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}

#pragma mark -event
- (IBAction)doSomethingEvents:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    
    switch (sender.tag) {
        case 100:
            [self.rtcpKit switchCamera];
            break;
        case 101:
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = self.rtcpIdLabel.text;
            [XHToast showCenterWithText:@"rtcpId复制成功"];
        }
            break;
        case 102:
        {
            [self.rtcpKit close];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.allowRotation = NO;
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
            break;
        case 103://二维码
        {
            if (self.rtcpId.length > 0) {
                self.qrCodeView.hidden = NO;
                UIImage *qrImage = [SGQRCodeGenerateManager generateWithLogoQRCodeData:self.rtcpId logoImageName:@"ios-template-1024" logoScaleToSuperView:0.2];
                
                self.qrCodeImageView.image = qrImage;
            } else {
                [XHToast showCenterWithText:@"rtcpId为空"];
            }
        }
            break;
        default:
            break;
    }
}

- (UIView *)localView{
    if (!_localView) {
        _localView = [[UIView alloc]initWithFrame:self.view.bounds];
    }
    return _localView;
}

@end
