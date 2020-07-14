//
//  Common.h
//  NewObjectTest
//
//  Created by mac on 2020/6/10.
//  Copyright © 2020 songjiang. All rights reserved.
//

#ifndef Common_h
#define Common_h

//#import <QiniuSDK.h>
#import <IJKMediaFramework/IJKMediaFramework.h>
#import <LFLiveKit/LFLiveKit.h>
#import <CocoaAsyncSocket/CocoaAsyncSocket-umbrella.h>
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

//直播服务器地址
#define rtmpUrl @"rtmp://192.168.124.30:1935/rtmplive/room"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

// 弱引用
#define SJWeakSelf __weak typeof(self) weakSelf = self;

#endif /* Common_h */
