//
//  CaptureSession.h
//  NewObjectTest
//
//  Created by mac on 2020/7/10.
//  Copyright © 2020 songjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger,CaptureSessionPreset) {
    CaptureSessionPreset640x480,
    CaptureSessionPresetiFrame960x540,
    CaptureSessionPreset1280x720,
};

@protocol CaptureSessionDelegate <NSObject>

- (void)videoWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

@interface CaptureSession : NSObject
@property (nonatomic,strong)id<CaptureSessionDelegate> delegate;
@property (nonatomic,strong) AVCaptureSession *session;

- (instancetype)initWithCaptureSessionPreset:(CaptureSessionPreset)preset;
- (void)start;
- (void)stop;

@end

