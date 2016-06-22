//
//  AudioRecord.m
//  SpeakinVoice
//
//  Created by 势必可赢 on 15/11/9.
//  Copyright © 2015年 势必可赢. All rights reserved.
//

#import "AudioRecord.h"
#import <UIKit/UIKit.h>

@interface AudioRecord ()
@property (nonatomic, strong) NSMutableArray *volArr;
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
@property (nonatomic,strong) AVAudioRecorder *audioRecorder;
@property (nonatomic,assign) int recordEncoding;
@property (nonatomic,copy) NSString *soundFilePath;
@property (nonatomic,strong) NSTimer *timerForPitch;
@end

@implementation AudioRecord
//{
//    AVAudioPlayer *audioPlayer;
//    AVAudioRecorder *audioRecorder;
//    int recordEncoding;
//    NSString *soundFilePath;
//    
//    NSTimer *timerForPitch;
//}

- (NSMutableArray *)volArr
{
    if (_volArr == nil)
    {
        _volArr = [[NSMutableArray alloc]init];
    }
    return  _volArr;
}

- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                } else {
                    bCanRecord = NO;
                }
            }];
        }
    }
    
    return bCanRecord;
}

#pragma mark - Audio Recorder √


- (void)startRecording
{

    if (![self canRecord]) {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:[NSString stringWithFormat:@"我们需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风"]
                                   delegate:nil
                          cancelButtonTitle:@"好"
                          otherButtonTitles:nil] show];
        return;
    }

//    NSLog(@"-------------开始录音-----------------");
    self.soundFilePath = @"";
    self.audioRecorder = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    
    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];

        [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:[SAMPLE_RATE integerValue]/*44100.0*/] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:[CHANNEL integerValue]/*1*/] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:[BIT_DEPTH integerValue]/*16*/] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    NSString *docsDir = PATH_OF_DOCUMENT;
//    NSString *voiceDirectory = [docsDir stringByAppendingPathComponent:@"originFile"];
//    if ( ! [[NSFileManager defaultManager] fileExistsAtPath:voiceDirectory])
//    {
//        [[NSFileManager defaultManager] createDirectoryAtPath:voiceDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
//    }
    self.soundFilePath = [docsDir stringByAppendingPathComponent:@"origin.wav"];
    NSURL *url = [NSURL fileURLWithPath:self.soundFilePath];
    NSError *error = nil;
    self.audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    self.audioRecorder.meteringEnabled = YES;
    if ([self.audioRecorder prepareToRecord] == YES){
        self.audioRecorder.meteringEnabled = YES;
        [self.audioRecorder record];
        self.timerForPitch =[NSTimer scheduledTimerWithTimeInterval: 0.01 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];

    }else {
        int errorCode = CFSwapInt32HostToBig ([error code]);
        NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
        
    }
    
}



- (void)levelTimerCallback:(NSTimer *)timer
{
    [self.audioRecorder updateMeters];
    [self levelMeterChanged:[self.audioRecorder peakPowerForChannel:0]];
    [self levelMeterChanged:[self.audioRecorder averagePowerForChannel:0]];
}


- (void)levelMeterChanged:(float)levelMeter {
    
    float   level;
    // The linear 0.0 .. 1.0 value we need.
    float   minDecibels = -80.0f;
    // Or use -60dB, which I measured in a silent room.
    float   decibels    = levelMeter/*20*log10f(levelMeter)*/;
    if (decibels < minDecibels)
    {
        level = 0.0f;
    }
    else if (decibels >= 0.0f)
    {
        level = 1.0f;
    }
    else
    {
        float   root            = 2.0f;
        float   minAmp          = powf(10.0f, 0.05f * minDecibels);
        float   inverseAmpRange = 1.0f / (1.0f - minAmp);
        float   amp             = powf(10.0f, 0.05f * decibels);
        float   adjAmp          = (amp - minAmp) * inverseAmpRange;
        level = powf(adjAmp, 1.0f / root);
    }        /* level 范围[0 ~ 1], 转为[0 ~120] 之间 */
    
    //    NSLog(@"level:%f",level*120);
//    NSLog(@"实时音量: %1.2f dB", level*100);
    if (level*100<1||level*100>99) {
//        NSLog(@"排除，%1.2f dB", level*100);
        return;
    }
    
    [self.volArr addObject:[NSNumber numberWithFloat:level*100]];
}


- (NSString *)stopAqRecording
{
    [self.audioRecorder stop];
    self.audioPlayer = nil;
    self.audioRecorder = nil;
    [self.timerForPitch invalidate];
    CGFloat avgVol = [[self.volArr valueForKeyPath:@"@avg.floatValue"] floatValue];
    NSLog(@"平均音量: %1.2f dB", avgVol);
    //发送平均音量的通知，那么就发送通知,把平均音量传过去
    NSDictionary *dict = @{@"avgVol":@(avgVol)};
    [[NSNotificationCenter defaultCenter]postNotificationName:AudioRecordLitmitVolNotification object:nil userInfo:dict];
    [self.volArr removeAllObjects];
    return self.soundFilePath;
}

- (NSString *)stopRecording
{
    [self.audioRecorder stop];
    self.audioPlayer = nil;
    self.audioRecorder = nil;
    [self.timerForPitch invalidate];
    CGFloat avgVol = [[self.volArr valueForKeyPath:@"@avg.floatValue"] floatValue];
    NSLog(@"平均音量: %1.2f dB", avgVol);
    return self.soundFilePath;
   
}

//取消录音
- (void)cancelRecording
{
    [self.audioRecorder stop];
    self.audioPlayer = nil;
    self.audioRecorder = nil;
    [self.timerForPitch invalidate];
}

- (void)playRecording:(NSString *)soundFilePath1
{
   
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSURL *url = [NSURL fileURLWithPath:soundFilePath1];
    
   
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.audioPlayer.numberOfLoops = 0;
    [self.audioPlayer play];
    //NSLog(@"playing");
}

- (void)stopPlaying
{
    //NSLog(@"stopPlaying");
    [self.audioPlayer stop];
    //NSLog(@"stopped");
    
}

NSString *const AudioRecordLitmitVolNotification = @"AudioRecordLitmitVolNotification";

@end
