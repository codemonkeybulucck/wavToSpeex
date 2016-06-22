//
//  OggSpx_AQRecorder.h
//  SpeakIn
//
//  Created by 势必可赢 on 15/12/4.
//  Copyright © 2015年 势必可赢. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OggSpx_AQRecorder : NSObject


@property (nonatomic,strong) void (^completionBlock)(NSString * spxFileName,NSString * wavFileName);
@property (nonatomic, assign) float volAVG;
- (void) startRecording;
- (void)stopRecording:(void (^)(NSString *,NSString *))completionBlock;
- (void)playRecording:(NSString *)soundFilePath1;
- (void) stopPlaying;
@end
