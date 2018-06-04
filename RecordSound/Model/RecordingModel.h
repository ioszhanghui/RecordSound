//
//  RecordingModel.h
//  RecordSound
//
//  Created by 小飞鸟 on 2018/5/12.
//  Copyright © 2018年 小飞鸟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordingModel : NSObject
/*文件ID*/
@property(nonatomic,assign)NSInteger  ID;
/*文件名字*/
@property(nonatomic,copy)NSString * fileName;
/*录制时间*/
@property(nonatomic,copy)NSString * recordTime;
/*音频时长*/
@property(nonatomic,copy)NSString * duration;
/*音频文件的路径*/
@property(nonatomic,copy)NSString * filePath;

@end
