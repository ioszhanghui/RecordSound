//
//  FMDBManager.h
//  RecordSound
//
//  Created by 小飞鸟 on 2018/5/12.
//  Copyright © 2018年 小飞鸟. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RecordingModel;
@interface FMDBManager : NSObject
/*创建数据库管理者*/
+(instancetype)shareFMDBManager;
/*创建表*/
-(void)createTable;
/*插入数据到表格中*/
-(void)insertDataIntoTable:(RecordingModel*)model;
/*删除某一个录音文件*/
-(void)deleteFileWithFileTime:(NSString*)ID;
/*修改音频文件的名字*/
-(void)updateFileName:(NSString*)newName FileTime:(NSString*)ID;
/*查询该表的所有文件*/
-(void)queryFileSuccess:(void(^)(NSArray *files))success Fail:(void(^)(void))fail;
@end
