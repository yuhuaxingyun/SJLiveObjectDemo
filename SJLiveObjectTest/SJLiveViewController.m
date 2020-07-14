//
//  SJLiveViewController.m
//  SJLiveObjectTest
//
//  Created by mac on 2020/7/14.
//  Copyright © 2020 songjiang. All rights reserved.
//

#import "SJLiveViewController.h"
#import "SJFilterView.h"

#define localVideoPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/demo.mp4"]
@interface SJLiveViewController ()<LFLiveSessionDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) LFLiveSession *session;

@property (nonatomic,strong) UIButton *circleBtn;
@property (nonatomic,strong) UIButton *cameraPositionBtn;
@property (nonatomic,strong) UIButton *flashBtn;
@property (nonatomic,strong) UILabel *liveStateLabel;
@property (nonatomic, strong) UIImageView* focusImage;

@property (nonatomic, strong) SJFilterView *filterConfigView;

@property (nonatomic,strong) UIButton *backBtn;
@end

@implementation SJLiveViewController
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.session stopLive];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSFileManager defaultManager] removeItemAtPath:localVideoPath error:nil];
    [self.view addSubview:self.circleBtn];
    [self.view addSubview:self.cameraPositionBtn];
    [self.view addSubview:self.flashBtn];
    [self.view addSubview:self.liveStateLabel];
    [self.view addSubview:self.focusImage];
    [self.view addSubview:self.filterConfigView];
    [self.view addSubview:self.backBtn];
    self.focusImage.hidden = YES;
    self.session.running = YES;//开始采集
    [self callBack];
}

-(void)viewWillLayoutSubviews{
    [self.circleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.height.equalTo(@(70));
        make.bottom.equalTo(self.view).offset(-40);
    }];
    
    
    [self.cameraPositionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-22);
        make.width.height.equalTo(@(44));
        make.centerY.equalTo(self->_circleBtn);
    }];
    
    [self.flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(22);
        make.top.equalTo(self.view).offset(24);
        make.width.height.equalTo(@(32));
    }];
    
    [self.liveStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.centerX.equalTo(self.view);
        make.height.equalTo(@(40));
        make.top.equalTo(@(60));
    }];
}

- (void)callBack{
    
    //是否推流
    [[self.circleBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        if (x.isSelected) {
            [self stopLive];
        }else{
            [self startLive];
        }
        [x setBackgroundImage:[UIImage imageNamed: x.isSelected?@"ic_shutter":@"ic_button"] forState:UIControlStateNormal];
        x.selected = !x.selected;
    }];
    
    //前后置切换
    [[self.cameraPositionBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        AVCaptureDevicePosition devicePositon = self.session.captureDevicePosition;
        self.session.captureDevicePosition = (devicePositon == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    }];
    
    //闪光灯切换
    [[self.flashBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        self.session.torch =!self.session.torch;//闪光灯开关
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.delegate = self;
    [[tapGesture rac_gestureSignal] subscribeNext:^(id x) {
        
        //前置不可点
        if (self.session.captureDevicePosition == AVCaptureDevicePositionFront) return;
        
        CGPoint point = [x locationInView:self.view];
        self.focusImage.bounds = CGRectMake(0, 0, 70, 70);
        self.focusImage.center = point;
        self.focusImage.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.focusImage.bounds = CGRectMake(0, 0, 50, 50);
        } completion:^(BOOL finished) {
            self.focusImage.hidden = YES;
//            self.session.focusPoint = point;
        }];
    }];
    [self.view addGestureRecognizer:tapGesture];
    
    UIPinchGestureRecognizer *doubleTapGesture = [[UIPinchGestureRecognizer alloc] init];
    doubleTapGesture.delaysTouchesBegan = YES;
    [[doubleTapGesture rac_gestureSignal] subscribeNext:^(UIPinchGestureRecognizer* x) {
        CGFloat scale = x.scale;
        x.scale = MAX(1.0, scale);
        
        if (scale < 1.0f || scale > 3.0)
            return;
        NSLog(@"捏合%f",scale);
        self.session.zoomScale = scale;
        
    }];
    [self.view addGestureRecognizer:doubleTapGesture];
    
//    //切换滤镜
//    self.filterConfigView.selectBlock = ^(NSInteger index) {
//        self.session.beautyFace = NO;//取消自带美颜
//        self.session.currentFilter =  [self addFilterWithIndex:index];
//    };
}

- (void)backBtnClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 开始直播
- (void)startLive{
    LFLiveStreamInfo *streamInfo = [[LFLiveStreamInfo alloc]init];
    streamInfo.url = rtmpUrl;
    [self.session startLive:streamInfo];
}
#pragma mark - 结束直播
- (void)stopLive{
    [self.session stopLive];
}

#pragma mark - LFLiveSessionDelegate
- (void)liveSession:(LFLiveSession *)session liveStateDidChange:(LFLiveState)state{
    NSString* stateStr;
    switch (state) {
        case LFLiveReady:
            stateStr = @"准备";
            break;
            
        case LFLivePending:
            stateStr = @"连接中";
            break;
            
        case LFLiveStart:
            stateStr = @"已连接";
            break;
            
        case LFLiveStop:
            stateStr = @"已断开";
            break;
            
        case LFLiveError:
            stateStr = @"连接出错";
            break;
            
        case LFLiveRefresh:
            stateStr = @"正在刷新";
            break;
            
        default:
            break;
    }
    
    self.liveStateLabel.text = stateStr;
}

- (void)liveSession:(LFLiveSession *)session debugInfo:(LFLiveDebug *)debugInfo{
    
}

- (void)liveSession:(nullable LFLiveSession*)session errorCode:(LFLiveSocketErrorCode)errorCode{
    switch (errorCode) {
        case LFLiveSocketError_PreView:
             NSLog(@"预览失败");
            break;
        case LFLiveSocketError_GetStreamInfo:
            NSLog(@"获取流媒体信息失败");
            break;
        case LFLiveSocketError_ConnectSocket:
            NSLog(@"连接socket失败");
            break;
        case LFLiveSocketError_Verification:
            NSLog(@"验证服务器失败");
            break;
        case LFLiveSocketError_ReConnectTimeOut:
            NSLog(@"重新连接服务器超时");
            break;
        default:
            break;
    }
}


- (LFLiveSession *)session{
    if (!_session) {
        _session = [[LFLiveSession alloc]initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
        _session.reconnectCount = 5;
        _session.saveLocalVideo = YES;
        _session.saveLocalVideoPath = [NSURL fileURLWithPath:localVideoPath];
        _session.preView = self.view;
        _session.delegate = self;
    }
    return _session;
}

- (UIButton *)circleBtn{
    if (!_circleBtn) {
        _circleBtn = [[UIButton alloc] init];
        [_circleBtn setBackgroundImage:[UIImage imageNamed:@"ic_shutter"] forState:UIControlStateNormal];
    }
    return _circleBtn;
}
- (UIButton *)cameraPositionBtn{
    if (!_cameraPositionBtn) {
        _cameraPositionBtn = [[UIButton alloc] init];
        [_cameraPositionBtn setBackgroundImage:[UIImage imageNamed:@"ic_change"] forState:UIControlStateNormal];
    }
    return _cameraPositionBtn;
}

- (UIButton *)flashBtn{
    if (!_flashBtn) {
        _flashBtn = [[UIButton alloc] init];
        [_flashBtn setBackgroundImage:[UIImage imageNamed:@"ic_iight-close"] forState:UIControlStateNormal];
    }
    return _flashBtn;
}

- (UIImageView *)focusImage{
    if (!_focusImage) {
        _focusImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"对焦"]];
    }
    return _focusImage;
}


- (UILabel *)liveStateLabel{
    if (!_liveStateLabel) {
        _liveStateLabel = [[UILabel alloc] init];
        _liveStateLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
        _liveStateLabel.textColor = [UIColor blackColor];
        _liveStateLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _liveStateLabel;
}

- (SJFilterView *)filterConfigView{
    if (!_filterConfigView) {
        _filterConfigView = [[SJFilterView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 120, 0, 120, 400)];
    }
    return _filterConfigView;
}

//-(FIlterManager *)filterManager{
//    if (!_filterManager) {
//        _filterManager = [[FIlterManager alloc] init];
//    }
//    return _filterManager;
//}

- (UIButton *)backBtn{
    if (!_backBtn) {
        UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 20, 50, 50)];
        [backBtn setTitle:@"返回" forState:UIControlStateNormal];
        [backBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _backBtn = backBtn;
    }
    return _backBtn;
}

@end
