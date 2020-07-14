//
//  EnCodeH264.m
//  NewObjectTest
//
//  Created by mac on 2020/7/10.
//  Copyright © 2020 songjiang. All rights reserved.
//

#import "EncodeH264.h"

@interface EncodeH264(){
    dispatch_queue_t encodeQueue;
    long timeStamp;
    VTCompressionSessionRef encodeSession;
}
@property (nonatomic,assign) BOOL isObtainspspps;

@end

/**
 编码回调
 @param userData 回调参考值
 @param sourceFrameRefCon 帧参考值
 @param status noErr代表压缩成功，不成功为错误代码。
 @param infoFlags 编码操作信息
 @param sampleBuffer 包含压缩帧，如果压缩成功且帧未被丢弃，否则NULL。
 */
void outputCallback(void *userData,
                          void *sourceFrameRefCon,
                          OSStatus status,
                          VTEncodeInfoFlags infoFlags,
                          CMSampleBufferRef sampleBuffer)
{
    if (status!=noErr) {
        NSLog(@"压缩失败,status=%d,infoFlags=%d",(int)status,(int)infoFlags);
        return;
    }
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        NSLog(@"sampleBuffer未准备好");
        return;
    }
    EncodeH264 *h264 = (__bridge EncodeH264*)userData;
    //判断当前帧是否为关键帧(i帧)
    bool keyframe = !CFDictionaryContainsKey((CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0)), kCMSampleAttachmentKey_NotSync);//同步
    //获取sps、pps数据，sps、pps只需获取一次，保存在h264开头
    if (keyframe && !h264.isObtainspspps) {
        size_t spsSize, spsCount;
        size_t ppsSize, ppsCount;
        const uint8_t *spsData,*ppsData;
        CMFormatDescriptionRef description = CMSampleBufferGetFormatDescription(sampleBuffer);
        OSStatus err0 = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(description, 0, &spsData, &spsSize, &spsCount, 0);
        OSStatus err1 = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(description, 1, &ppsData, &ppsSize, &ppsCount, 0);
        if (err0==noErr&&err1==noErr) {
            h264.isObtainspspps = YES;
            NSLog(@"获取到sps、pps数据,Length:sps=%zu,pps=%zu",spsSize,ppsSize);
        }
    }
    //获取dataBuffer
    size_t lengthAtOffset,totalLength;
    char *data;
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    OSStatus error = CMBlockBufferGetDataPointer(dataBuffer, 0, &lengthAtOffset, &totalLength, &data);
    if (error==noErr) {
        size_t offset = 0;
        //返回的nalu数据前四个字节不是0001的startcode，而是大端模式的帧长度length
        const int lengthInfoSize = 4;
        //循环获取nalu数据
        while (offset < totalLength-lengthInfoSize) {
            uint32_t naluLength = 0;
            //获取nalu的长度
            memcpy(&naluLength, data+offset, lengthInfoSize);
            //大端模式转化为系统端模式
            naluLength = CFSwapInt32BigToHost(naluLength);
            NSLog(@"获取到nulu数据,length=%d,totalLength=%zu",naluLength,totalLength);
            //读取下一个nalu，一次回调可能包含多个nalu
            offset += lengthInfoSize+naluLength;
        }
    }
}


@implementation EncodeH264
- (instancetype)init {
    if ([super init]) {
        encodeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        timeStamp = 0;
    }
    return self;
}

/**
 创建视频编码session
 @param width 宽度（以像素为单位）
 @param height 高度
 @param fps 帧率
 @param bite 比特率
 @return 是否创建成功
 */
- (BOOL)createEncodeSession:(int)width height:(int)height fps:(int)fps bite:(int)bite {
    OSStatus status;
    //设置回调
    VTCompressionOutputCallback callback = outputCallback;
    //创建session
    status = VTCompressionSessionCreate(kCFAllocatorDefault, width, height, kCMVideoCodecType_H264, NULL, NULL, NULL, callback, (__bridge void *)(self), &encodeSession);
    if (status != noErr) {
        NSLog(@"创建session失败");
        return NO;
    }
    /*设置属性:VTSessionSetProperty()*/
    //提示视频编码器，压缩是否实时执行
    status = VTSessionSetProperty(encodeSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
    NSLog(@"set realtime  return: %d",(int)status);
    //指定编码比特流的配置文件和级别:直播一般使用baseline，可减少由于b帧带来的延时
    status = VTSessionSetProperty(encodeSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Baseline_AutoLevel);
    NSLog(@"set profile   return: %d",(int)status);
    //设置比特率上限:bps
    status  = VTSessionSetProperty(encodeSession, kVTCompressionPropertyKey_AverageBitRate, (__bridge CFTypeRef)@(bite));
    NSLog(@"set bitrate   return: %d",(int)status);
    //设置比特率均值:byte
    NSArray *limit = @[@(bite*2/8),@(1)];
    status = VTSessionSetProperty(encodeSession, kVTCompressionPropertyKey_DataRateLimits, (__bridge CFArrayRef)limit);
    NSLog(@"set limit     return: %d",(int)status);
    // 设置关键帧速率(i帧间隔)
    status = VTSessionSetProperty(encodeSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, (__bridge CFTypeRef)@(fps*2));
    NSLog(@"set KeyFrame  return: %d",(int)status);
    //设置期望帧率
    status = VTSessionSetProperty(encodeSession, kVTCompressionPropertyKey_ExpectedFrameRate, (__bridge CFTypeRef)@(fps));
    NSLog(@"set framerate return: %d",(int)status);
    //开始编码
    status = VTCompressionSessionPrepareToEncodeFrames(encodeSession);
    NSLog(@"start encode  return: %d",(int)status);
    return YES;
}

/**
 编码AVCaptureSession采集的sampleBuffer
 */
- (void)encodeSmapleBuffer:(CMSampleBufferRef)sampleBuffer {
    dispatch_sync(encodeQueue, ^{
        //从sampleBuffer中获取imageBuffer
        CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
        //时间戳
        self->timeStamp ++;
        CMTime pts = CMTimeMake(self->timeStamp, 1000);
        //duration
        CMTime duration = kCMTimeInvalid;
        VTEncodeInfoFlags flags;
        //硬编码
        OSStatus status = VTCompressionSessionEncodeFrame(self->encodeSession,
                                                          imageBuffer,
                                                          pts,
                                                          duration,
                                                          NULL,
                                                          NULL,
                                                          &flags);
        if (status!=noErr) {
            NSLog(@"编码失败,status=%d",(int)status);
            [self stopEncodeSession];
            return;
        }
    });
}

/**
 编码中断
 */
- (void)stopEncodeSession {
    VTCompressionSessionCompleteFrames(encodeSession, kCMTimeInvalid);
    VTCompressionSessionInvalidate(encodeSession);
    CFRelease(encodeSession);
    encodeSession = NULL;
}

@end
