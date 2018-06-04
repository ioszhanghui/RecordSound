//
//  FileHandler.h
//  RecordSound
//
//  Created by 小飞鸟 on 2018/5/12.
//  Copyright © 2018年 小飞鸟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlertViewTool.h"

@interface FileHandler : NSObject

/*语音识别权限访问*/
+(void)requestSpeechRecognizer;
/*音频文件转成文本*/
+(void)changeVoiceToText:(NSString*)filePath Success:(void(^)(NSString * text))success Fail:(void(^)(void))fail;

@end
