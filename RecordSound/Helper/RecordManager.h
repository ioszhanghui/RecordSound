//
//  RecordManager.h
//  RecordSound
//
//  Created by 小飞鸟 on 2018/5/12.
//  Copyright © 2018年 小飞鸟. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RecordManager : NSObject

/*音频录制按钮*/
+(instancetype)shareRecordManager;
/*开始录制*/
-(void)beginRecord;
/*结束录制*/
-(void)endRecord;
/*暂停录音*/
-(void)pauseRecord;
/*保存录音*/
-(void)deleteRecord;

@end
