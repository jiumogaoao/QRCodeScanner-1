//
//  ViewController.m
//  CaputerDemo
//
//  Created by VcaiTech on 16/7/8.
//  Copyright © 2016年 VcaiTech. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ScanQRViewController.h"

@interface ViewController ()<QRResultDelegate>
{
    BOOL torchIsOn;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self turnTorchOn:YES];
    // Do any additional setup after loading the view, typically from a nib.
    
    //页面动画的实现方案
//    CATransition *animation = [CATransition animation];
//    [animation setDuration:0.35f];
//    [animation setFillMode:kCAFillModeForwards];
//    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
//    [animation setType:kCATransitionPush];
//    [animation setSubtype:kCATransitionFromRight];
//    [self.view.layer addAnimation:animation forKey:nil];
    
    
    
    
}

-(IBAction)doScan:(id)sender{
    ScanQRViewController *scanViewController =[[ScanQRViewController alloc]init];
    scanViewController.delegate = self;
    [self presentViewController:scanViewController animated:YES completion:nil];
}

-(void)qrDelegateResult:(NSString *)resultStr{
    
    UIAlertView *qrAlert  = [[UIAlertView alloc]initWithTitle:@"QR" message:resultStr delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles: nil];
    [qrAlert show];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//打开/关闭手电的功能实现
-(void)turnTorchOn: (bool) on {
    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                torchIsOn = YES;
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                torchIsOn = NO;
            }
            [device unlockForConfiguration];
        }
    }
}

@end
