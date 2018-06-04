//
//  FMDBManager.m
//  RecordSound
//
//  Created by 小飞鸟 on 2018/5/12.
//  Copyright © 2018年 小飞鸟. All rights reserved.
//

#import "FMDBManager.h"
#import "FMDatabase.h"
#import "RecordingModel.h"

#define FMDBFilePath [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]

@interface FMDBManager()
/*数据库的管理者*/
@property(nonatomic,strong)FMDatabase * dataBase;

@end

@implementation FMDBManager
/*创建数据库管理者*/
+(instancetype)shareFMDBManager{
    static FMDBManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FMDBManager alloc]init];
    });
    return manager;
}

-(instancetype)init{
    if (self=[super init]) {
        NSString * dataBaseFile = [FMDBFilePath stringByAppendingPathComponent:@"Sound.sqlite"];
        _dataBase = [[FMDatabase alloc]initWithPath:dataBaseFile];
        if ([_dataBase open]) {
            NSLog(@"数据库打开成功");
            [self createTable];
        }else{
            NSLog(@"数据库打开失败");
        }
    }
    return self;
}

/*创建表*/
-(void)createTable{
    
    NSString * sql = @"create table if not exists Recording(id integer primary key,filename varchar(255) not NULL,recordTime varchar(125) not NULL,duration varchar(255) not NULL,filePath varchar(255) not NULL)";
      BOOL success = [_dataBase executeUpdate:sql];
        if (success) {
            NSLog(@"创建表成功");
        }else{
            NSLog(@"创建表失败");
        }
}

/*插入数据到表格中*/
-(void)insertDataIntoTable:(RecordingModel*)model{
 
   BOOL success = [_dataBase executeUpdate:@"insert into Recording(filename,recordTime,duration,filePath) values(?,?,?,?)",model.fileName,model.recordTime,model.duration,model.filePath];
    if (success) {
        NSLog(@"数据插入成功");
    }
}
/*删除某一个录音文件*/
-(void)deleteFileWithFileTime:(NSString*)ID{
   BOOL success = [_dataBase executeUpdate:@"delete from Recording where id=(?)",ID];
    if (success) {
        NSLog(@"删除成功");
    }
}
/*修改音频文件的名字*/
-(void)updateFileName:(NSString*)newName FileTime:(NSString*)ID{
    BOOL success = [_dataBase executeUpdate:@"update Recording set filename=(?) where id=(?)",newName,ID];
    if (success) {
        NSLog(@"修改名字成功");
    }
}

/*查询该表的所有文件*/
-(void)queryFileSuccess:(void(^)(NSArray *files))success Fail:(void(^)(void))fail;{
    
    NSMutableArray * files = [NSMutableArray array];
    FMResultSet * resultSet = [_dataBase executeQuery:@"select * from Recording"];
    while ([resultSet next]) {
        RecordingModel * model = [RecordingModel new];
        NSInteger IDs = [resultSet intForColumn:@"id"];
        model.ID = IDs;
        NSString * filename = [resultSet stringForColumn:@"filename"];
        model.fileName = filename;
        NSString * recordTime =[resultSet stringForColumn:@"recordTime"];
        model.recordTime = recordTime;
        NSString * duration = [resultSet stringForColumn:@"duration"];
        model.duration = duration;
        NSString * filePath = [resultSet stringForColumn:@"filePath"];
        model.filePath=filePath;
        [files addObject:model];
    }
    success(files);
}

@end
