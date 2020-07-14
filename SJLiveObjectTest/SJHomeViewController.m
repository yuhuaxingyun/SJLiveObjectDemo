//
//  ViewController.m
//  NewObjectTest
//
//  Created by mac on 2020/6/10.
//  Copyright © 2020 songjiang. All rights reserved.
//

#import "SJHomeViewController.h"
#import "SJWatchLiveViewController.h"
#import "CaptureSession.h"
#import "EncodeH264.h"

@interface SJHomeViewController ()<CaptureSessionDelegate>
@property (nonatomic,strong) CaptureSession *captureSession;
@property (nonatomic,strong) UIButton *pauseButton;
@property (nonatomic,strong) EncodeH264 *h264;
@end


@implementation SJHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createEncodeH264];
    [self createCaptureSession];
    [self.view addSubview:self.pauseButton];
   
}

- (void)createEncodeH264{
    //创建编码对象
    _h264 = [[EncodeH264 alloc] init];
    //创建视频编码会话
    [_h264 createEncodeSession:480 height:640 fps:25 bite:640*1000];
}
- (void)createCaptureSession{
    //创建视频采集会话
    _captureSession = [[CaptureSession alloc]initWithCaptureSessionPreset:CaptureSessionPreset1280x720];
    //设置代理
    _captureSession.delegate = self;
    //创建预览层
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:_captureSession.session];
    //设置frame
    previewLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    //设置方向
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill; //填充且不拉伸
    [self.view.layer addSublayer:previewLayer];
}
#pragma mark - CaptureSessionDelegate
- (void)videoWithSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    NSLog(@"实时采集回调得到sampleBuffer");
    [_h264 encodeSmapleBuffer:sampleBuffer];
}

#pragma mark - Event
- (void)pauseButtonClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [_captureSession start];
    }else{
        [_captureSession stop];
        SJWatchLiveViewController*showTimeVC = [[SJWatchLiveViewController alloc]init];
        [self presentViewController:showTimeVC animated:YES completion:nil];
    }
}

#pragma mark - getter
- (UIButton *)pauseButton{
    if (!_pauseButton) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((kScreenWidth - 50)/2, kScreenHeight-150, 50, 50)];
        [button addTarget:self action:@selector(pauseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor purpleColor];
        button.layer.cornerRadius = 25;
        button.layer.masksToBounds = YES;
        _pauseButton = button;
    }
    return _pauseButton;
}
@end
