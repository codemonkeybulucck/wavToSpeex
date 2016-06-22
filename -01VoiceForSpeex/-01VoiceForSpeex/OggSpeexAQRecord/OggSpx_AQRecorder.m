//
//  OggSpx_AQRecorder.m
//  SpeakIn
//
//  Created by 势必可赢 on 15/12/4.
//  Copyright © 2015年 势必可赢. All rights reserved.
//

#import "OggSpx_AQRecorder.h"
#import "RecorderManager.h"
#import "PlayerManager.h"

@interface OggSpx_AQRecorder () <RecordingDelegate, PlayingDelegate>
{
    NSMutableArray *volArr;
}


@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, copy) NSString *filename;





@end

@implementation OggSpx_AQRecorder

//-(id)init{
//    self = [super init];
//    if (self) {
//        // Initialization code
//        [self addObserver:self forKeyPath:@"isRecording" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
//        [self addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
//    }
//    return self;
//}

- (void) startRecording
{
    self.volAVG = 0.0;
    volArr = [[NSMutableArray alloc]init];
    
    if (self.isPlaying) {
        return;
    }
    if (!self.isRecording) {
        self.isRecording = YES;
        [RecorderManager sharedManager].delegate = self;
        [[RecorderManager sharedManager] startRecording];
    }
}

- (void)stopRecording:(void (^)(NSString *,NSString *))completionBlock
{
    self.completionBlock = completionBlock;
    if (self.isPlaying) {
        return ;
    }
    if (self.isRecording) {
        self.isRecording = NO;
        [[RecorderManager sharedManager] stopRecording];

        //NSLog(@"filename: \n->%@",self.filename);
    }
}

- (void)playRecording:(NSString *)soundFilePath1
{
    if (self.isRecording) {
        return;
    }
    if (!self.isPlaying) {
        [PlayerManager sharedManager].delegate = nil;
        self.isPlaying = YES;
        
        NSLog(@"soundFilePath1:\n%@",soundFilePath1);
//        [[PlayerManager sharedManager] playAudioWithFileName:self.filename delegate:self];
        [[PlayerManager sharedManager] playAudioWithFileName:soundFilePath1 delegate:self];
    }
}

- (void) stopPlaying
{
    if (self.isRecording) {
        return;
    }
    if (self.isPlaying) {
        self.isPlaying = NO;
        [[PlayerManager sharedManager] stopPlaying];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isRecording"]) {

        
    }
    else if ([keyPath isEqualToString:@"isPlaying"]) {

        
    }
}
//
//
//- (void)dealloc {
//    [self removeObserver:self forKeyPath:@"isRecording"];
//    [self removeObserver:self forKeyPath:@"isPlaying"];
//}

#pragma mark - Recording & Playing Delegate

- (void)recordingFinishedWithFileName:(NSString *)filePath wavPath:(NSString *)wavPath time:(NSTimeInterval)interval
{
    self.isRecording = NO;
    self.filename = filePath;
    
    NSLog(@"\n录音完成: \nspx->%@\nwav->%@",self.filename,wavPath);
    
    self.volAVG = [[volArr valueForKeyPath:@"@avg.floatValue"] floatValue];
    
    if (self.completionBlock){
        self.completionBlock(self.filename,wavPath);
    }
}

- (void)recordingTimeout {

    self.isRecording = NO;
    NSLog(@"录音超时");
}

- (void)recordingStopped {
    self.isRecording = NO;
    NSLog(@"录音结束");
}

- (void)recordingFailed:(NSString *)failureInfoString {

    self.isRecording = NO;
    NSLog(@"录音失败");
}

- (void)levelMeterChanged:(float)levelMeter {

//    NSLog(@"音量:%f",levelMeter);
    
//    double volume = log10f(levelMeter)*20.f;
//    NSLog(@"volume%f",volume);
//    NSLog(@"%f实时音量: %1.2f dB",levelMeter, 20*log10f(levelMeter));
    
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
    NSLog(@"实时音量: %1.2f dB", level*100);
    if (level*100<1||level*100>99) {
        NSLog(@"排除，%1.2f dB", level*100);
        return;
    }
    [volArr addObject:[NSNumber numberWithFloat:level*100]];
}

- (void)playingStoped {
    self.isPlaying = NO;
    NSLog(@"播放结束");
}

@end
