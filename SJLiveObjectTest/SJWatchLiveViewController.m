//
//  SJShowTimeViewController.m
//  NewObjectTest
//
//  Created by mac on 2020/7/10.
//  Copyright © 2020 songjiang. All rights reserved.
//

#import "SJWatchLiveViewController.h"
#import <UIKit/UIKit.h>

//#define PLAY_URL @"http://ivi.bupt.edu.cn/hls/cctv1hd.m3u8"
//#define PLAY_URL @"rtmp://58.200.131.2:1935/livetv/hunantv"
@interface SJWatchLiveViewController ()
@property (nonatomic,strong) IJKFFMoviePlayerController *moviePlayer;
@property (nonatomic,strong) UIImageView *placeHolderView;
@property (nonatomic,strong) UIActivityIndicatorView *activity;
@property (nonatomic,strong) UIButton *backBtn;
@end

@implementation SJWatchLiveViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.moviePlayer prepareToPlay];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.moviePlayer shutdown];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.placeHolderView];
    [self showActivityView];
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    [options setPlayerOptionIntValue:1  forKey:@"videotoolbox"];

    // 帧速率(fps) （可以改，确认非标准桢率会导致音画不同步，所以只能设定为15或者29.97）
    [options setPlayerOptionIntValue:29.97 forKey:@"r"];
    // -vol——设置音量大小，256为标准音量。（要设置成两倍音量时则输入512，依此类推
    [options setPlayerOptionIntValue:512 forKey:@"vol"];

    IJKFFMoviePlayerController *moviePlayer = [[IJKFFMoviePlayerController alloc] initWithContentURLString:rtmpUrl withOptions:options];
    moviePlayer.view.frame = self.view.bounds;

    moviePlayer.scalingMode = IJKMPMovieScalingModeAspectFill;
    // 设置自动播放(必须设置为NO, 防止自动播放, 才能更好的控制直播的状态)
    moviePlayer.shouldAutoplay = NO;
    // 默认不显示
    moviePlayer.shouldShowHudView = NO;
    [self.view insertSubview:moviePlayer.view atIndex:0];

    self.moviePlayer = moviePlayer;
    // 设置监听
    [self addObserver];
    
    [self.view addSubview:self.backBtn];
}

- (void)backBtnClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addObserver
{
    //监听加载状态改变通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateDidChange:) name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.moviePlayer];
}

- (void)loadStateDidChange:(NSNotification *) notification{
    //状态为缓冲几乎完成，可以连续播放
    if ((self.moviePlayer.loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        if (!self.moviePlayer.isPlaying) {
            //开始播放
            [self.moviePlayer play];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self->_placeHolderView) {
                    [self->_placeHolderView removeFromSuperview];
                    self->_placeHolderView = nil;
                }
                [self stopActivityView];
            });
        }else{
            // 如果是网络状态不好, 断开后恢复, 也需要去掉加载
            if ([_activity isAnimating]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self stopActivityView];
                });
            }
        }
    }
    //缓冲中
    else if (self.moviePlayer.loadState & IJKMPMovieLoadStateStalled){
        [self showActivityView];
        /*
            这里主播可能已经结束直播了。我们需要请求服务器查看主播是否已经结束直播。
            方法：
            1、从服务器获取主播是否已经关闭直播。
                优点：能够正确的获取主播端是否正在直播。
                缺点：主播端异常crash的情况下是没有办法通知服务器该直播关闭的。
            2、用户http请求该地址，若请求成功表示直播未结束，否则结束
                优点：能够真实的获取主播端是否有推流数据
                缺点：如果主播端丢包率太低，但是能够恢复的情况下，数据请求同样是失败的。
         */
    }
}

- (void)dealloc{
    if (_moviePlayer) {
        [_moviePlayer shutdown];
        [_moviePlayer.view removeFromSuperview];
        _moviePlayer = nil;
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

//直播前的占位图片
- (UIImageView *)placeHolderView
{
    if (!_placeHolderView) {
        _placeHolderView = [[UIImageView alloc] init];
        _placeHolderView.frame = self.view.bounds;
        _placeHolderView.image = [UIImage imageNamed:@"profile_user_414x414"];
        // 强制布局
        [_placeHolderView layoutIfNeeded];
    }
    return _placeHolderView;
}
//卡顿占位动效
- (void)showActivityView{
    if (!_activity) {
        _activity= [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activity.frame = CGRectMake((kScreenWidth-100)*0.5, (kScreenHeight-100)*0.5, 100, 100);
    }
    [self.activity startAnimating];
    [self.view addSubview:self.activity];
}
//关闭卡顿占位动效
- (void)stopActivityView{
    if ([_activity isAnimating]) {
        [_activity startAnimating];
    }
    [_activity removeFromSuperview];
    _activity = nil;
}

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
