//
//  PlayerManager.m
//  RecordSound
//
//  Created by 小飞鸟 on 2018/5/12.
//  Copyright © 2018年 小飞鸟. All rights reserved.
//

#import "PlayerManager.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayerManager ()<AVAudioPlayerDelegate>
/*音频播放*/
@property(nonatomic,strong)AVAudioPlayer * audioPlayer;

@end

@implementation PlayerManager
/*音频播放*/
+(instancetype)sharePlayerManager;{
    static PlayerManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PlayerManager alloc]init];
    });
    return manager;
}

/*播放音频文件*/
-(void)playSound:(NSString*)filePath{
    
    //AVAudioSessionCategoryPlayAndRecord    播放音乐，并录音后台能继续录制
    //AVAudioSessionCategoryAmbient    静音模式或者锁屏下不再播放音乐  和其他app声音混合
    //AVAudioSessionCategoryPlayback 表示对于用户切换静音模式或者锁屏 都不理睬，继续播放音乐。并且不播放来自其他app的音乐
    //AVAudioSessionCategoryRecord    不播放音乐，锁屏状态继续录音
    //AVAudioSessionCategorySoloAmbient    默认模式 静音模式或者锁屏下不再播放音乐，不和其他app声音混合
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [session setActive:YES error:nil];
    NSURL *audioURL = [NSURL fileURLWithPath:filePath];
    NSError * error;
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:audioURL error:&error];
    if (error) {
        NSLog(@"音频播放失败");
    }
    self.audioPlayer.delegate=self;
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer setVolume:1.0];
    [self.audioPlayer play];
}

#pragma mark AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"audioPlayerDidFinishPlaying success playing");
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    self.audioPlayer = nil;
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"audioPlayerDecodeErrorDidOccur :%@",[error localizedDescription]);
    
}

/*播放被打断*/
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    
    
}

@end
