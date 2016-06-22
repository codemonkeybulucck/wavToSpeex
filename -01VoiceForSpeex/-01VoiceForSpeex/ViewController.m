//
//  ViewController.m
//  -01VoiceForSpeex
//
//  Created by 势必可赢 on 16/6/13.
//  Copyright © 2016年 势必可赢. All rights reserved.
//

#import "ViewController.h"
#import "OggSpx_AQRecorder.h"
#import "AudioRecord.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *originFile;
@property (weak, nonatomic) IBOutlet UILabel *speexFile;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (strong,nonatomic) OggSpx_AQRecorder *speexRecorder;
@property (strong,nonatomic) AudioRecord *originRecorder;
@property (nonatomic,assign) BOOL isRecording;
@property (nonatomic,assign) int index;
- (IBAction)startOrStopRecording;
@end

@implementation ViewController

- (OggSpx_AQRecorder *)speexRecorder
{
    if (_speexRecorder == nil)
    {
        _speexRecorder = [[OggSpx_AQRecorder alloc]init];
    }
    return  _speexRecorder;
}

- (AudioRecord *)originRecorder
{
    if (_originRecorder == nil)
    {
        _originRecorder = [[AudioRecord alloc]init];
    }
    return  _originRecorder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startOrStopRecording {
    if (self.isRecording)
    {
        self.isRecording = NO;
        [self.recordBtn setTitle:@"开始录音" forState:UIControlStateNormal];
        [self.speexRecorder stopRecording:^(NSString *speexFilePath, NSString *wavFilePath) {
           dispatch_sync(dispatch_get_main_queue(), ^{
               NSLog(@"speexFilePath : %@",speexFilePath);
               NSLog(@"wavFilePath: %@",wavFilePath);
               //分别将speex和wav文件写到统一的文件夹里面
               NSString *speexFilePath1 = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"speexFile"];
               if (![[NSFileManager defaultManager] fileExistsAtPath:speexFilePath1])
               {
                   [[NSFileManager defaultManager] createDirectoryAtPath:speexFilePath1 withIntermediateDirectories:YES attributes:nil error:nil];
               }
               NSString *wavFilePath1 = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"wavFile"];
               if (![[NSFileManager defaultManager] fileExistsAtPath:wavFilePath1])
               {
                   [[NSFileManager defaultManager] createDirectoryAtPath:wavFilePath1 withIntermediateDirectories:YES attributes:nil error:nil];
               }
               NSString *speexFileName = [NSString stringWithFormat:@"speexVoice_%d.spx",self.index];
               NSString *speexFinalPath = [speexFilePath1 stringByAppendingPathComponent:speexFileName];
               NSString *wavFileName = [NSString stringWithFormat:@"wavVoice_%d.wav",self.index];
               NSString *wavFinalPath = [wavFilePath1 stringByAppendingPathComponent:wavFileName];
               BOOL sp = [self writeDataFormPath:speexFilePath toPath:speexFinalPath];
             BOOL wv =  [self writeDataFormPath:wavFilePath toPath:wavFinalPath];
               if (sp)
               {
                     NSLog(@"文件写入成功，文件路径是:%@\n",[NSString stringWithFormat:@"%@/speexVoice_%d.spx",speexFilePath,self.index]);
               }
               if (wv)
               {
                     NSLog(@"文件写入成功，文件路径是:%@\n",[NSString stringWithFormat:@"%@/wavVoice_%d.wav",wavFilePath,self.index]);
               }
           });
        }];
        NSString *originPath = [self.originRecorder stopRecording];
        //        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = PATH_OF_DOCUMENT;
        NSString *voiceDirectory = [docsDir stringByAppendingPathComponent:@"originFile"];
        if ( ! [[NSFileManager defaultManager] fileExistsAtPath:voiceDirectory])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:voiceDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        NSString *fileName = [NSString stringWithFormat:@"originVoice_%d.wav",self.index];
        NSString *finalPath = [voiceDirectory stringByAppendingPathComponent:fileName];
        BOOL succeed = [self writeDataFormPath:originPath toPath:finalPath];
        if (succeed)
        {
            NSLog(@"文件写入成功，文件路径是:%@\n",finalPath);
        }
        self.index ++ ;
    }else
    {
        self.isRecording = YES;
       [self.recordBtn setTitle:@"正在录音" forState:UIControlStateNormal];
        [self.originRecorder startRecording];
        [self.speexRecorder startRecording];
    }
}

- (BOOL)writeDataFormPath:(NSString *)filePath toPath:(NSString *)fileDir
{
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    return [fileData writeToFile:fileDir atomically:YES];
}


@end
