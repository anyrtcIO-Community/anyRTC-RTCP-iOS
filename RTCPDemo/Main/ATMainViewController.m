//
//  ATMainViewController.m
//  RTCPDemo
//
//  Created by jh on 2017/10/20.
//  Copyright © 2017年 jh. All rights reserved.
//

#import "ATMainViewController.h"

@interface ATMainViewController ()

//RTCP ID（拉流）
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
//推流
@property (weak, nonatomic) IBOutlet UIButton *pushButton;
//拉流
@property (weak, nonatomic) IBOutlet UIButton *pullButton;

@end

@implementation ATMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.addressTextField.hidden = YES;
    self.pullButton.layer.borderColor = ATBordColor.CGColor;
    [self.addressTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tap];
}

- (IBAction)doSomethingEvents:(UIButton *)sender {
    switch (sender.tag) {
        case 100:
        {
            //推流
            ATLivingViewController *livingVc = [[self storyboard] instantiateViewControllerWithIdentifier:@"LivingView"];
            if (!self.addressTextField.hidden) {
                if (self.addressTextField.text.length ==0) {
                    return;
                }
                //拉流地址（rtcpId为空为推流、反之拉流）
                livingVc.rtcpId = self.addressTextField.text;
                livingVc.isPull = YES;
            }
            
            [self presentViewController:livingVc animated:YES completion:nil];
        }
            break;
        case 101:
        {
            if (self.addressTextField.hidden) {
                //观看直播
                self.addressTextField.hidden = NO;
                [self.addressTextField wzx_addLineWithDirection:WZXLineDirectionBottom type:WZXLineTypeFill lineWidth:1 lineColor:[UIColor whiteColor]];
                
                [self.pushButton setTitle:@"观看直播" forState:UIControlStateNormal];
                [self.pullButton setTitle:@"返回" forState:UIControlStateNormal];
            } else {
                //观看直播
                self.addressTextField.hidden = YES;
                
                [self.pushButton setTitle:@"开启直播" forState:UIControlStateNormal];
                [self.pullButton setTitle:@"观看直播" forState:UIControlStateNormal];
            }
        }
            break;
        case 102:
            //技术支持
            [ATCommon callPhone:@"021-65650071" control:sender];
        default:
            break;
    }
}

- (void)hideKeyBoard{
    [ATCommon hideKeyBoard];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

@end
