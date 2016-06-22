//
//  AudioRecord.h
//  SpeakinVoice
//
//  Created by 势必可赢 on 15/11/9.
//  Copyright © 2015年 势必可赢. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>


@interface AudioRecord : NSObject

/**
 *  开始记录
 */
- (void) startRecording;

/**
 *  取消录音
 */
- (void)cancelRecording;

/**
 *  停止记录
 *
 */
- (NSString *)stopRecording;
/**
 *  播放录音
 *
 *  @param soundFilePath1 录音路径
 */

- (void)playRecording:(NSString *)soundFilePath1;
/**
 *  停止播放
 */
- (void) stopPlaying;


//停止噪音检测
- (NSString *)stopAqRecording;


@end


#pragma mark - 通知名称
extern NSString *const AudioRecordLitmitVolNotification;