//
//  ATMainViewController.m
//  RTCPDemo
//
//  Created by jh on 2017/10/20.
//  Copyright © 2017年 jh. All rights reserved.
//

#import "ATMainViewController.h"

@interface ATMainViewController ()

//推流
@property (weak, nonatomic) IBOutlet UIButton *pushButton;
//拉流
@property (weak, nonatomic) IBOutlet UIButton *pullButton;

@end

@implementation ATMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pullButton.layer.borderColor = ATBordColor.CGColor;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tap];
}

- (IBAction)doSomethingEvents:(UIButton *)sender {
    switch (sender.tag) {
        case 100:
        {
            //推流
            ATLivingViewController *livingVc = [[self storyboard] instantiateViewControllerWithIdentifier:@"LivingView"];
            
            [self presentViewController:livingVc animated:YES completion:nil];
        }
            break;
        case 101:
        {
            ATQRCodeViewController *qrVc = [[self storyboard] instantiateViewControllerWithIdentifier:@"QRViewID"];
            [self.navigationController pushViewController:qrVc animated:YES];
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
