//
//  QRcodeView.m
//  CaputerDemo
//
//  Created by VcaiTech on 16/7/11.
//  Copyright © 2016年 VcaiTech. All rights reserved.
//

#import "QRcodeView.h"
#import <AVFoundation/AVFoundation.h>
#define SCANBOXSIZE 210
#define TOPVIEWHEIGHT 96
#define CORSIZE   20
#define LINEHEIGHT 6
@implementation QRcodeView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self setupCamera];
        [timer fire];
    }
    return self;
}

-(void)setupView{
    
    _maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _maskView.backgroundColor =[UIColor clearColor];
    [self addSubview:_maskView];
    
    
    _leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, (self.frame.size.width-SCANBOXSIZE)*0.5, self.frame.size.height)];
    _leftView.backgroundColor =[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [_maskView addSubview:_leftView];
    
    _rightView = [[UIView alloc]initWithFrame:CGRectMake(self.frame.size.width-(self.frame.size.width-SCANBOXSIZE)*0.5, 0, (self.frame.size.width-SCANBOXSIZE)*0.5, self.frame.size.height)];
    _rightView.backgroundColor =[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [_maskView addSubview:_rightView];
    
    _topView = [[UIView alloc]initWithFrame:CGRectMake((self.frame.size.width-SCANBOXSIZE)*0.5, 0, SCANBOXSIZE, TOPVIEWHEIGHT)];
    _topView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [_maskView addSubview:_topView];
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake((self.frame.size.width-SCANBOXSIZE)*0.5, TOPVIEWHEIGHT+SCANBOXSIZE, SCANBOXSIZE, self.frame.size.height-(TOPVIEWHEIGHT+SCANBOXSIZE))];
    _bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [_maskView addSubview:_bottomView];
    
    UIImageView *topLeftImage =[[UIImageView alloc]initWithFrame:CGRectMake((self.frame.size.width-SCANBOXSIZE)*0.5, TOPVIEWHEIGHT, CORSIZE, CORSIZE)];
    [topLeftImage setImage:[UIImage imageNamed:@"scan_case"]];
    [_maskView addSubview:topLeftImage];
    
    UIImageView *topRightImage =[[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-((self.frame.size.width-SCANBOXSIZE)*0.5+CORSIZE), TOPVIEWHEIGHT, CORSIZE, CORSIZE)];
    [topRightImage setImage:[UIImage imageNamed:@"scan_case"]];
    topRightImage.transform = CGAffineTransformMakeRotation(M_PI_2);
    [self addSubview:topRightImage];
    
    UIImageView *bottomLeftImage =[[UIImageView alloc]initWithFrame:CGRectMake((self.frame.size.width-SCANBOXSIZE)*0.5, TOPVIEWHEIGHT+SCANBOXSIZE-CORSIZE, CORSIZE, CORSIZE)];
    [bottomLeftImage setImage:[UIImage imageNamed:@"scan_case"]];
    bottomLeftImage.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [self addSubview:bottomLeftImage];
    
    UIImageView *bottomRightImage =[[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-((self.frame.size.width-SCANBOXSIZE)*0.5+CORSIZE), TOPVIEWHEIGHT+SCANBOXSIZE-CORSIZE, CORSIZE, CORSIZE)];
    [bottomRightImage setImage:[UIImage imageNamed:@"scan_case"]];
    bottomRightImage.transform = CGAffineTransformMakeRotation(M_PI);
    [_maskView addSubview:bottomRightImage];
    
    _line = [[UIImageView alloc]initWithFrame:CGRectMake((self.frame.size.width-SCANBOXSIZE)*0.5, TOPVIEWHEIGHT, SCANBOXSIZE, LINEHEIGHT)];
    [_line setImage:[UIImage imageNamed:@"scan_line"]];
    [_maskView addSubview:_line];
    _line.alpha = 0;
}

- (void)setupCamera{
    num = 5;
    timer = [NSTimer timerWithTimeInterval:num target:self selector:@selector(animationLoopLines) userInfo:nil repeats:YES];
    [self setupAVComponents];
    [self configureDefaultComponents];
}

-(void)animationLoopLines{
    [_line setFrame:CGRectMake((self.frame.size.width-SCANBOXSIZE)*0.5, TOPVIEWHEIGHT, SCANBOXSIZE, LINEHEIGHT)];
    _line.alpha = 1.0;
    [UIView animateWithDuration:num animations:^{
       [_line setFrame:CGRectMake((self.frame.size.width-SCANBOXSIZE)*0.5, TOPVIEWHEIGHT+SCANBOXSIZE-LINEHEIGHT, SCANBOXSIZE, LINEHEIGHT)];
    } completion:^(BOOL finished) {
        _line.alpha = 0;
        [timer fire];
    }];
}

-(void)startCamera{
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
}

- (void)stopCamera{
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
    _line.alpha = 0;
    [timer invalidate];
}



- (void)setupAVComponents
{
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (_device) {
        self.input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
        self.output     = [[AVCaptureMetadataOutput alloc] init];
        self.session            = [[AVCaptureSession alloc] init];
        self.preview       = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    }
}

- (void)configureDefaultComponents
{
    [_session addOutput:_output];
    
    if (_input) {
        [_session addInput:_input];
    }
    
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    //设置只在小矩形框中获取到图像才有效，否则为无效
    CGSize size = self.bounds.size;
    CGRect cropRect = CGRectMake((self.frame.size.width-SCANBOXSIZE)*0.5, TOPVIEWHEIGHT, SCANBOXSIZE, SCANBOXSIZE);
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用了1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        _output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                                  cropRect.origin.x/size.width,
                                                  cropRect.size.height/fixHeight,
                                                  cropRect.size.width/size.width);
    } else {
        CGFloat fixWidth = size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        _output.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                                  (cropRect.origin.x + fixPadding)/fixWidth,
                                                  cropRect.size.height/size.height,
                                                  cropRect.size.width/fixWidth);
    }
    
    [_preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.layer insertSublayer:_preview atIndex:0];
}


- (BOOL)isTorchAvailable
{
    return _device.hasTorch;
}

- (void)toggleTorch
{
    NSError *error = nil;
    
    [_device lockForConfiguration:&error];
    
    if (error == nil) {
        AVCaptureTorchMode mode = _device.torchMode;
        
        _device.torchMode = mode == AVCaptureTorchModeOn ? AVCaptureTorchModeOff : AVCaptureTorchModeOn;
    }
    
    [_device unlockForConfiguration];
}

#pragma mark - Controlling Reader

- (BOOL)running {
    return self.session.running;
}


#pragma mark - Managing the Orientation

+ (AVCaptureVideoOrientation)videoOrientationFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        default:
            return AVCaptureVideoOrientationPortraitUpsideDown;
    }
}

#pragma mark - Checking the Reader Availabilities

+ (BOOL)isAvailable
{
    @autoreleasepool {
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if (!captureDevice) {
            return NO;
        }
        
        NSError *error;
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        
        if (!deviceInput || error) {
            return NO;
        }
        
        return YES;
    }
}

+ (BOOL)supportsMetadataObjectTypes:(NSArray *)metadataObjectTypes
{
    if (![self isAvailable]) {
        return NO;
    }
    
    @autoreleasepool {
        // Setup components
        AVCaptureDevice *captureDevice    = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
        AVCaptureMetadataOutput *output   = [[AVCaptureMetadataOutput alloc] init];
        AVCaptureSession *session         = [[AVCaptureSession alloc] init];
        
        [session addInput:deviceInput];
        [session addOutput:output];
        
        if (metadataObjectTypes == nil || metadataObjectTypes.count == 0) {
            // Check the QRCode metadata object type by default
            metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        }
        
        for (NSString *metadataObjectType in metadataObjectTypes) {
            if (![output.availableMetadataObjectTypes containsObject:metadataObjectType]) {
                return NO;
            }
        }
        
        return YES;
    }
}

#pragma mark - Managing the Block

- (void)setCompletionWithBlock:(void (^) (NSString *resultAsString))completionBlock
{
    self.completionBlock = completionBlock;
}

#pragma mark - AVCaptureMetadataOutputObjects Delegate Methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *current in metadataObjects) {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]
            && [@[AVMetadataObjectTypeQRCode] containsObject:current.type]) {
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];
            
            if (_completionBlock) {
                _completionBlock(scannedResult);
            }
            
            break;
        }
    }
}

@end
