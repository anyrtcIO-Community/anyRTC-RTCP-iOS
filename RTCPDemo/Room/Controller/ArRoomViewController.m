//
//  ArRoomViewController.m
//  RTCPDemo
//
//  Created by 余生丶 on 2019/4/9.
//  Copyright © 2019 anyRTC. All rights reserved.
//

#import "ArRoomViewController.h"
#import "ArQRCodeViewController.h"
#import "ArLogView.h"

@interface ArRoomViewController ()<ARRtcpKitDelegate>

@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UILabel *roomIdLabel;
@property (weak, nonatomic) IBOutlet UIView *qrCodeView;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
/** 实时直播对象 */
@property (nonatomic, strong) ARRtcpKit *rtcpKit;
/** 辅流id */
@property (nonatomic, copy) NSString *flowId;
@property (nonatomic, strong) UIView *flowView;
@property (nonatomic, strong) NSMutableArray *logArr;

@end

@implementation ArRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.logArr = [NSMutableArray array];
    [self addObserver:self forKeyPath:@"logArr" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    self.qrCodeView.hidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideQrView)];
    [self.qrCodeView addGestureRecognizer:tap];
    
    self.qrCodeImageView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(saveImage:)];
    [self.qrCodeImageView addGestureRecognizer:longTap];
    [self itializationRTCPKit];
    //监听辅流(屏幕共享)
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(addFlow:) name:ArFlow_Notification object:nil];
}

- (void)itializationRTCPKit {
    //配置信息
    ARRtcpOption *option = [ARRtcpOption defaultOption];
    ARVideoConfig *config = [[ARVideoConfig alloc] init];
    config.videoProfile = ARVideoProfile360x640;
    config.cameraOrientation = ARCameraAuto;
    option.videoConfig = config;
    
    //实例化实时直播对象
    self.rtcpKit = [[ARRtcpKit alloc] initWithDelegate:self userId:[NSString stringWithFormat:@"%d",arc4random() % 100000] userData:@""];
    if (self.isPull) {
        //观看直播（订阅）
        [self.rtcpKit subscribeByToken:nil pubId:self.pubId];
        [self.rtcpKit updateRTCVideoRenderModel:ARVideoRenderScaleAspectFit];
        self.videoButton.hidden = YES;
        self.audioButton.hidden = YES;
        self.roomIdLabel.text = [NSString stringWithFormat:@"  房间号：%@  ",self.pubId];
        
        ArMethodText(@"subscribeByToken:");
        ArMethodText(@"updateRTCVideoRenderModel:");
    } else {
        //开启直播（发布）
        [self.rtcpKit publishByToken:nil mediaType:0];
        [self.rtcpKit updateLocalVideoRenderModel:ARVideoRenderScaleAspectFill];
        [self.rtcpKit setLocalVideoCapturer:self.view option:option];
        
        ArMethodText(@"publishByToken:");
        ArMethodText(@"updateLocalVideoRenderModel:");
        ArMethodText(@"setLocalVideoCapturer:");
    }
    [self.rtcpKit setAudioActiveCheck:YES];
    
    [self.stackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = (UIButton *)obj;
        if (self.isPull) {
            button.hidden = !(BOOL)(button.tag == 103 || button.tag == 104);
        } else {
            button.hidden = !(BOOL)(button.tag != 103);
        }
    }];
}

- (IBAction)handleSomethingEvent:(UIButton *)sender {
    switch (sender.tag) {
        case 50:
            //本地音频
            sender.selected = !sender.selected;
            [self.rtcpKit setLocalAudioEnable:!sender.selected];
            ArMethodText(@"setLocalAudioEnable:");
            break;
        case 51:
            //挂断
            [self.rtcpKit close];
            ArMethodText(@"close");
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
        case 52:
            //本地视频
            sender.selected = !sender.selected;
            [self.rtcpKit setLocalVideoEnable:!sender.selected];
            ArMethodText(@"setLocalVideoEnable:");
            break;
        case 100:
            //旋转摄像头
            [self.rtcpKit switchCamera];
            ArMethodText(@"switchCamera");
            break;
        case 101:
            //复制id
        {
            if (self.pubId.length != 0) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = self.pubId;
                [SVProgressHUD showSuccessWithStatus:@"房间号复制成功"];
                [SVProgressHUD dismissWithDelay:0.8];
            }
        }
            break;
        case 102:
            //二维码
            if (self.pubId.length > 0) {
                self.qrCodeView.hidden = NO;
                UIImage *qrImage = [SGQRCodeObtain generateQRCodeWithData:self.pubId size:220 logoImage:[UIImage imageNamed:@""] ratio:0.2];
                self.qrCodeImageView.image = qrImage;
            } else {
                [SVProgressHUD showErrorWithStatus:@"正在连接，请等待..."];
                [SVProgressHUD dismissWithDelay:1.0];
            }
            break;
        case 103:
            //添加辅流
        {
            if (self.flowId.length != 0) {
                [SVProgressHUD showWithStatus:@"只可订阅一路屏幕共享流"];
                [SVProgressHUD dismissWithDelay:1.5];
            } else {
                ArQRCodeViewController *qrCodeVc = [[self storyboard] instantiateViewControllerWithIdentifier:@"ArQrCodeID"];
                qrCodeVc.isFlow = YES;
                [self.navigationController pushViewController:qrCodeVc animated:YES];
            }
        }
            break;
        case 104:
            //日志
        {
            ArLogView *logView = [[ArLogView alloc] initWithFrame:self.view.bounds];
            [logView refreshLogText:self.logArr];
            UIWindow *window = UIApplication.sharedApplication.delegate.window;
            [window addSubview:logView];
        }
            break;
        default:
            break;
    }
}

- (void)addFlow:(NSNotification *)notifi {
    //订阅辅流
    self.flowId = (NSString *)notifi.object;
    [self.rtcpKit subscribeByToken:nil pubId:self.flowId];
    ArMethodText(@"subscribeByToken:");
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

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        [SVProgressHUD showSuccessWithStatus:@"保存到相册成功"];
        [SVProgressHUD dismissWithDelay:0.8];
        self.qrCodeView.hidden = YES;
    }
}

//MARK: - ARRtcpKitDelegate

- (void)onRTCPublishOK:(NSString *)pubId liveInfo:(NSString *)liveInfo {
    //发布媒体成功回调
    self.pubId = pubId;
    self.roomIdLabel.text = [NSString stringWithFormat:@"  房间号：%@  ",pubId];
    ArCallbackLog;
}

- (void)onRTCPublishFailed:(ARRtcpCode)code reason:(NSString *)reason {
    //发布媒体失败回调
    [SVProgressHUD showErrorWithStatus:@"发布媒体失败"];
    [SVProgressHUD dismissWithDelay:0.8];
    ArCallbackLog;
}

- (void)onRTCSubscribeOK:(NSString *)pubId {
    //订阅频道成功的回调
    ArCallbackLog;
}

- (void)onRTCSubscribeFailed:(NSString *)pubId code:(ARRtcpCode)code reason:(NSString *)reason {
    //订阅频道失败的回调
    [SVProgressHUD showErrorWithStatus:@"订阅媒体失败"];
    [SVProgressHUD dismissWithDelay:0.8];
    ArCallbackLog;
}

- (void)onRTCOpenRemoteVideoRender:(NSString *)pubId {
    //订阅后视频即将显示的回调
    if (![self.flowId isEqualToString:pubId]) {
        [self.rtcpKit setRemoteVideoRender:self.view pubId:pubId];
    } else {
        //辅流
        self.flowView = [[UIView alloc] init];
        self.flowView.backgroundColor = [UIColor blackColor];
        [self.view insertSubview:self.flowView aboveSubview:self.videoButton];
        [self.flowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(self.videoButton.mas_top).offset(-20);
            make.width.equalTo(self.view.mas_width).multipliedBy(0.5);
            make.height.equalTo(self.flowView.mas_width).multipliedBy(0.75);
        }];
        [self.rtcpKit setRemoteVideoRender:self.flowView pubId:pubId];
    }
    ArCallbackLog;
}

- (void)onRTCCloseRemoteVideoRender:(NSString *)pubId {
    //订阅的音视频离开的回调
    if (![self.flowId isEqualToString:pubId]) {
        [self.rtcpKit close];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.flowView removeFromSuperview];
        self.flowView = nil;
    }
    ArCallbackLog;
}

- (void)onRTCOpenRemoteAudioTrack:(NSString *)pubId {
    //订阅音频后成功的回调
    ArCallbackLog;
}

- (void)onRTCCloseRemoteAudioTrack:(NSString *)pubId {
    //订阅的音频离开的回调
    ArCallbackLog;
}

- (void)onRTCFirstLocalVideoFrame:(CGSize)size {
    //本地视频第一帧
    ArCallbackLog;
}

- (void)onRTCFirstRemoteVideoFrame:(CGSize)size pubId:(NSString *)pubId {
    //远程视频第一帧
    ArCallbackLog;
}

- (void)onRTCLocalVideoViewChanged:(CGSize)size {
    //本地视频窗口大小的回调
    ArCallbackLog;
}

- (void)onRTCRemoteVideoViewChanged:(CGSize)size pubId:(NSString *)pubId {
    //远程窗口大小的回调
    ArCallbackLog;
}

- (void)onRTCRemoteAudioActive:(NSString *)pubId audioLevel:(int)level showTime:(int)time {
    //其他发布者的音频检测回调
    ArCallbackLog;
}

- (void)onRTCLocalAudioActive:(int)level showTime:(int)time {
    //本地音频检测回调
    ArCallbackLog;
}

- (void)onRTCRemoteNetworkStatus:(NSString *)pubId netSpeed:(int)netSpeed packetLost:(int)packetLost netQuality:(ARNetQuality)netQuality {
    //其他发布者的网络质量回调
    ArCallbackLog;
}

- (void)onRTCLocalNetworkStatus:(int)netSpeed packetLost:(int)packetLost netQuality:(ARNetQuality)netQuality {
    //本地网络质量回调
    ArCallbackLog;
}

//MARK: - other

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"logArr"]) {
        for (UIView *subView in UIApplication.sharedApplication.keyWindow.subviews) {
            if ([subView isKindOfClass:[ArLogView class]]) {
                ArLogView *logView = (ArLogView *)subView;
                [logView refreshLogText:self.logArr];
                break;
            }
        }
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"logArr"];
    [NSNotificationCenter.defaultCenter removeObserver:self name:ArFlow_Notification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

@end
