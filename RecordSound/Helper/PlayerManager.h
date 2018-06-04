//
//  PlayerManager.h
//  RecordSound
//
//  Created by 小飞鸟 on 2018/5/12.
//  Copyright © 2018年 小飞鸟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayerManager : NSObject
/*音频播放*/
+(instancetype)sharePlayerManager;
/*播放音频文件*/
-(void)playSound:(NSString*)filePath;

@end
