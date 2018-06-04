//
//  RecordManager.m
//  RecordSound
//
//  Created by 小飞鸟 on 2018/5/12.
//  Copyright © 2018年 小飞鸟. All rights reserved.
//

#import "RecordManager.h"
#import <AVFoundation/AVFoundation.h>
#import "PreHeader.h"
#import "FileHandler.h"
#import "FMDBManager.h"
#import "RecordingModel.h"

@interface RecordManager()<AVAudioRecorderDelegate>
/*音频录制*/
@property(nonatomic,strong)AVAudioRecorder * audioRecorder;
/*当前录制的音频文件*/
@property(nonatomic,copy)NSString * currentFilePath;
/*音频录制时间*/
@property(nonatomic,strong)NSString * recordTime;

@end

// 获取Documents目录路径
#define DocumentDir  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

@implementation RecordManager
/*音频录制按钮*/
+(instancetype)shareRecordManager{
    static RecordManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RecordManager alloc]init];
    });
    return manager;
}

//录音权限
- (BOOL)canRecord{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    return bCanRecord;
}

/*开始录制*/
-(void)beginRecord{
    
    if (![self canRecord]) {
        //没有录音权限
        [AlertViewTool showAlertWithTitle:@"提示" message:@"设置-一键借钱-通讯录”选项中，允许访问您的通讯录" clickAtIndex:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex==1) {
                
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url])
                {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
            
        } cancleButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
        return;
    }
    
    [self initRecorder];
}

/*初始化Recorder*/
-(void)initRecorder{
    
    if (self.currentFilePath&&![self.audioRecorder isRecording]) {
        //暂停录音了 重新开始
        [self.audioRecorder record];
        return;
    }
    
    //设置录音格式
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [setting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [setting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2 声道数 通常为双声道 值2
    [setting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [setting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [setting setValue:[NSNumber numberWithInt:AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryRecord error: nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    self.currentFilePath = self.currentFilePath? self.currentFilePath:[self filePath];
    NSURL *fileUrl=[NSURL fileURLWithPath:self.currentFilePath];
    NSError *error;
    
    self.audioRecorder = [[AVAudioRecorder alloc]initWithURL:fileUrl settings:setting error:&error];
    self.audioRecorder.delegate = self;
    [self.audioRecorder prepareToRecord];
    [self.audioRecorder record];
}

/*文件名*/
-(NSString*)filePath{
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate * date = [NSDate date];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dirPath = [DocumentDir stringByAppendingPathComponent:@"Resource"];
    NSString * filePath = [NSString stringWithFormat:@"%@/%@.wav",dirPath,[dateFormatter stringFromDate:date]];
    NSLog(@"filePath**%@",filePath);
    BOOL isDir = false;
    BOOL isDirExist = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    if(!isDirExist){
        NSLog(@"Resource 文件夹不存在，需要创建文件夹！");
        isDirExist = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
   self.recordTime = [dateFormatter stringFromDate:date];//录制时间
    
    if(isDirExist){
        //  NSLog(@"文件夹之前就存在或者文件夹这次创建成功都会返回文件全路径！");
        return filePath;
    }
    return nil;
}

/*结束录制*/
-(void)endRecord{
    //关闭录制
     [self.audioRecorder stop];
//    self.currentFilePath = nil;
}

/*保存录音*/
-(void)deleteRecord{
    
     [self.audioRecorder stop];
    [self.audioRecorder deleteRecording];
    self.currentFilePath = nil;
}

/*暂停录音*/
-(void)pauseRecord{
    //关闭录制
    [self.audioRecorder pause];
}

#pragma mark AVAudioRecorderDelegate

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
    //音频时长
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath: self.currentFilePath] options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    NSLog(@"%f",audioDurationSeconds);
    
    RecordingModel * model = [RecordingModel new];
    model.recordTime =self.recordTime;
    model.duration = [@(audioDurationSeconds) stringValue];
    model.filePath =self.currentFilePath;
    model.fileName = @"录音文件";
    //保存数据
    [[FMDBManager shareFMDBManager]insertDataIntoTable:model];
    self.currentFilePath = nil;//保存之后 下一次重新录制
    
    //数据删除
    [[FMDBManager shareFMDBManager]deleteFileWithFileTime:@"1"];
    /*修改名字*/
     [[FMDBManager shareFMDBManager]updateFileName:@"test" FileTime:@"3"];
    /*音频文件查询*/
    [[FMDBManager shareFMDBManager]queryFileSuccess:^(NSArray *files) {
        
    } Fail:^{
        
    }];
    NSLog(@"录音完成");  
}
-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    NSLog(@"audioRecorderEncodeErrorDidOccur :%@",[error localizedDescription]);
     NSLog(@"录音编码出错");
}

/*音频录制中断结束*/
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags{
    
    
}
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withFlags:(NSUInteger)flags{
    
}
/*音频录制被打断*/
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
    
    
}

@end
