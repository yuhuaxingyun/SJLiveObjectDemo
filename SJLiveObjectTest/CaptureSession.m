//
//  CaptureSession.m
//  NewObjectTest
//
//  Created by mac on 2020/7/10.
//  Copyright © 2020 songjiang. All rights reserved.
//

#import "CaptureSession.h"

@interface CaptureSession()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic,strong) AVCaptureDevice *videoDevice;
@property (nonatomic,strong) AVCaptureInput *videoInput;
@property (nonatomic,strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic,assign) CaptureSessionPreset definePreset;
@property (nonatomic,strong) NSString *realPreset;
@end

@implementation CaptureSession
- (instancetype)initWithCaptureSessionPreset:(CaptureSessionPreset)preset{
    self = [super init];
    if (self) {
        [self initAVCaptureSession];
        _definePreset = preset;
    }
    return self;
}

- (void)initAVCaptureSession{
    //初始化AVCaptureSession
    _session = [[AVCaptureSession alloc]init];
    //设置分辨率
    if (![self.session canSetSessionPreset:self.realPreset]) {
        if (![self.session canSetSessionPreset:AVCaptureSessionPresetiFrame960x540]) {
            if (![self.session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
                
            }
        }
    }
    
    //开始配置
    [_session beginConfiguration];
    //获取视频设备对象
    self.videoDevice = [self cameraWithPosition:AVCaptureDevicePositionBack];
    
    //初始化视频捕获输入对象
    NSError *error;
    self.videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:self.videoDevice error:&error];
    if (error) {
        NSLog(@"摄像头错误");
        return;
    }
    
    //将输入对象添加到Session
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    
    //初始化视频输出对象
    self.videoOutput = [[AVCaptureVideoDataOutput alloc]init];
    //是否卡顿时丢帧
    self.videoOutput.alwaysDiscardsLateVideoFrames = NO;
    //设置像素格式:kCVPixelFormatType_{长度|序列}{颜色空间}{Planar|BiPlanar}{VideoRange|FullRange}
    [self.videoOutput setVideoSettings:@{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)}];
    
    //设置代理并添加到队列
    dispatch_queue_t captureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self.videoOutput setSampleBufferDelegate:self queue:captureQueue];
    //将输出对象添加到Session
    if ([self.session canAddOutput:self.videoOutput]) {
        [self.session addOutput:self.videoOutput];
    }
    
    //创建连接AVCaptureConnection输入对象和捕获输出对象之间建立连接
    AVCaptureConnection *connection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    //设置视频方向
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    //设置稳定性，判断connection是否支持视频稳定
    if ([connection isVideoStabilizationSupported]) {
        //这个稳定模式最适合连接
        connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    
    //缩放裁剪系数
    connection.videoScaleAndCropFactor = connection.videoMaxScaleAndCropFactor;
    //提交配置
    [self.session commitConfiguration];
}

- (NSString *)realPreset{
    switch (_definePreset) {
        case CaptureSessionPreset640x480:
            _realPreset = AVCaptureSessionPreset640x480;
            break;
        case CaptureSessionPresetiFrame960x540:
            _realPreset = AVCaptureSessionPresetiFrame960x540;
            break;
        case CaptureSessionPreset1280x720:
            _realPreset = AVCaptureSessionPreset1280x720;
            break;
        default:
            _realPreset = AVCaptureSessionPreset640x480;
            break;
    }
    return _realPreset;
}

- (void)start{
    [self.session startRunning];
}

- (void)stop{
    [self.session stopRunning];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer fromConnection:(nonnull AVCaptureConnection *)connection{
    [self.delegate videoWithSampleBuffer:sampleBuffer];
}

@end
