//
//  EnCodeH264.h
//  NewObjectTest
//
//  Created by mac on 2020/7/10.
//  Copyright © 2020 songjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>

@interface EncodeH264 : NSObject

- (BOOL)createEncodeSession:(int)width height:(int)height fps:(int)fps bite:(int)bite;
- (void)encodeSmapleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

