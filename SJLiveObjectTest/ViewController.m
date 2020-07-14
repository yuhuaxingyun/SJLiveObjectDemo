//
//  ViewController.m
//  SJLiveObjectTest
//
//  Created by mac on 2020/7/13.
//  Copyright © 2020 songjiang. All rights reserved.
//

#import "ViewController.h"
#import "SJLiveViewController.h"
#import "SJWatchLiveViewController.h"

@interface ViewController ()

@property (nonatomic,strong) UIButton *liveBtn;
@property (nonatomic,strong) UIButton *watchLiveBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.liveBtn];
    [self.view addSubview:self.watchLiveBtn];
    
    [self.liveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(kScreenHeight/2-60);
        make.size.mas_equalTo(CGSizeMake(100, 50));
        make.centerX.equalTo(self.view);
    }];
    
    [self.watchLiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(kScreenHeight/2+60);
        make.size.mas_equalTo(CGSizeMake(100, 50));
        make.centerX.equalTo(self.view);
    }];
}

- (void)liveBtnClick{
    SJLiveViewController *liveVC = [[SJLiveViewController alloc]init];
    [self presentViewController:liveVC animated:YES completion:nil];
}

- (void)watchLiveBtnClick{
    SJWatchLiveViewController *watchLive = [[SJWatchLiveViewController alloc]init];
    [self presentViewController:watchLive animated:YES completion:nil];
}


- (UIButton *)liveBtn{
    if (!_liveBtn) {
        UIButton *liveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [liveBtn setTitle:@"直播" forState:UIControlStateNormal];
        [liveBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        [liveBtn addTarget:self action:@selector(liveBtnClick)
          forControlEvents:UIControlEventTouchUpInside];
        liveBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        _liveBtn = liveBtn;
    }
    return _liveBtn;
}

- (UIButton *)watchLiveBtn{
    if (!_watchLiveBtn) {
        UIButton *watchLiveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [watchLiveBtn setTitle:@"观看直播" forState:UIControlStateNormal];
        [watchLiveBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        [watchLiveBtn addTarget:self action:@selector(watchLiveBtnClick)
          forControlEvents:UIControlEventTouchUpInside];
        watchLiveBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        _watchLiveBtn = watchLiveBtn;
    }
    return _watchLiveBtn;
}

@end
