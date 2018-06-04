//
//  FileHandler.m
//  RecordSound
//
//  Created by 小飞鸟 on 2018/5/12.
//  Copyright © 2018年 小飞鸟. All rights reserved.
//

#import "FileHandler.h"
#import <Speech/SFSpeechRecognizer.h>
#import <Speech/SFSpeechRecognitionRequest.h>
#import <Speech/SFSpeechRecognitionResult.h>
#import <Speech/SFTranscription.h>

@implementation FileHandler
/*语音识别权限访问*/
+(void)requestSpeechRecognizer{
    
    if (@available(iOS 10.0, *)) {
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            switch (status) {
                case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                    NSLog(@"NotDetermined");
                    break;
                case SFSpeechRecognizerAuthorizationStatusDenied:
                    NSLog(@"Denied");
                    break;
                case SFSpeechRecognizerAuthorizationStatusRestricted:
                    NSLog(@"Restricted");
                    break;
                case SFSpeechRecognizerAuthorizationStatusAuthorized:
                    NSLog(@"Authorized");
                    
                    break;
                default:
                    break;
            }
        }];
    } else {
        // Fallback on earlier versions
    }
}
/*音频文件转成文本*/
+(void)changeVoiceToText:(NSString*)filePath Success:(void(^)(NSString * text))success Fail:(void(^)(void))fail{
    
    NSFileManager * manager = [NSFileManager defaultManager];
    
    NSURL * destinationURL = [NSURL fileURLWithPath:filePath];
    NSLocale *local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    if (![manager fileExistsAtPath:filePath]) {
        NSLog(@"语音文件不存在");
        //文件不存在
        fail();
        return;
    }
    
    if (@available(iOS 10.0, *)) {
        
        if ([SFSpeechRecognizer authorizationStatus]==SFSpeechRecognizerAuthorizationStatusAuthorized) {
            //允许音频识别
            [self convertSoundToText:destinationURL Local:local Success:success Fail:fail];
        }else{
            [AlertViewTool showAlertWithTitle:@"提示" message:@"设置-一键借钱-通讯录”选项中，允许访问您的语音识别" clickAtIndex:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex==1) {
                    
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if ([[UIApplication sharedApplication] canOpenURL:url]){
                        [[UIApplication sharedApplication] openURL:url];
                    }
                }
            } cancleButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
        }
        
    } else {
        // Fallback on earlier versions
        fail();
    }
}

/*开始抓化音频文本*/
+(void)convertSoundToText:(NSURL*)url Local:(NSLocale*)local Success:(void(^)(NSString * text))success Fail:(void(^)(void))fail{
    
    if (@available(iOS 10.0, *)) {
        SFSpeechRecognizer *localRecognizer =[[SFSpeechRecognizer alloc] initWithLocale:local];
        SFSpeechURLRecognitionRequest *res =[[SFSpeechURLRecognitionRequest alloc] initWithURL:url];
        [localRecognizer recognitionTaskWithRequest:res resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
            
            if (error) {
                fail();
            }else{
                success(@"");
                success(result.bestTranscription.formattedString);
                NSLog(@"------------------------语音识别解析======成功,%@",result.bestTranscription.formattedString);
            }
        }];
    }
}

@end
