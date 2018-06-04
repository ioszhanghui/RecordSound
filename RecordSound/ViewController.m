//
//  ViewController.m
//  RecordSound
//
//  Created by 小飞鸟 on 2018/5/12.
//  Copyright © 2018年 小飞鸟. All rights reserved.
//

#import "ViewController.h"
#import "PreHeader.h"
#import "RecordManager.h"

@interface ViewController ()
/*计时时间*/
@property(nonatomic,strong)UILabel *timeLabel;
/*播放按钮*/
@property(nonatomic,strong)UIButton *playBtn;

@end

@implementation ViewController{
    /*定时器*/
    dispatch_source_t _timer;
    /*秒数*/
    NSInteger second;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configUI];
}

#pragma mark 布局UI
-(void)configUI{
    
    self.title = @"录音";
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"bg"].CGImage);
    
    //设置按钮
    self.navigationItem.leftBarButtonItem = [self createBarItem:[UIImage imageNamed:@"设置"] Tag:1000];
    //记录按钮
     self.navigationItem.rightBarButtonItem = [self createBarItem:[UIImage imageNamed:@"icon_record"] Tag:1000];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:18]};
    
    //时间
    UIImageView * timeLogo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"circle"]];
    [self.view addSubview:timeLogo];
    
    [timeLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.equalTo(self.view).mas_offset(142);
    }];
    
    self.timeLabel = [[UILabel alloc]init];
    self.timeLabel.textAlignment =NSTextAlignmentCenter;
    self.timeLabel.frame = timeLogo.bounds;
    self.timeLabel.text = @"00 : 00";
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = [UIFont fontWithName:@"impact" size:55];
    [timeLogo addSubview:self.timeLabel];
    
    //录音和暂停
    UIButton * playBtn = [[UIButton alloc]init];
    [playBtn setImage:[UIImage imageNamed:@"play_button"] forState:UIControlStateNormal];
    [playBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    [playBtn sizeToFit];
    [playBtn addTarget:self action:@selector(recordSound:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:playBtn];
    self.playBtn =playBtn;
    
    [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeLogo.mas_bottom).offset(88);
        make.centerX.equalTo(self.view);
    }];
    
    
    //删除按钮
    UIButton * deleteBtn = [[UIButton alloc]init];
    [deleteBtn setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
    [deleteBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    [deleteBtn sizeToFit];
    [deleteBtn addTarget:self action:@selector(recordDelete:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:deleteBtn];
    
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(playBtn.mas_left).offset(-38);
        make.centerY.equalTo(playBtn);
    }];
    
    
    //保存按钮
    UIButton * saveBtn = [[UIButton alloc]init];
    [saveBtn setImage:[UIImage imageNamed:@"icon_complete"] forState:UIControlStateNormal];
    [saveBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    [saveBtn sizeToFit];
    [saveBtn addTarget:self action:@selector(recordSave:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:saveBtn];
    
    [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(playBtn.mas_right).offset(38);
        make.centerY.equalTo(playBtn);
    }];
    
}

#pragma mar 创建定时器
-(void)startGCDTimer{
    
    NSTimeInterval period = 1.0; //设置时间间隔
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        
        second++;
        //在这里执行事件
        dispatch_async(dispatch_get_main_queue(), ^{
            self.timeLabel.text = [self getMMSSFromSS:second];
        });
    });
    
    dispatch_resume(_timer);
}

#pragma mark 时间转化成分秒
-(NSString *)getMMSSFromSS:(NSInteger)seconds{
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%02ld : %02ld",seconds/60,seconds%60];
    return format_time;
}

#pragma mark暂停定时器
-(void) pauseTimer{
    if(_timer){
        dispatch_suspend(_timer);
    }
}

#pragma mark 重新执行定时器
-(void) resumeTimer{
    if(_timer){
        dispatch_resume(_timer);
    }
}
#pragma mark 关闭定时器
-(void) stopTimer{
    if(_timer){
        dispatch_source_cancel(_timer);
//        _timer = nil;
    }
}

#pragma mark 音频录制
-(void)recordSound:(UIButton*)btn{
    
    btn.selected = !btn.selected;
    btn.selected? (second==0? [self startGCDTimer]:[self resumeTimer]):[self pauseTimer];
    btn.selected? [[RecordManager shareRecordManager]beginRecord]:[[RecordManager shareRecordManager]pauseRecord];
}

#pragma mark 音频删除
-(void)recordDelete:(UIButton*)btn{
    [self rsetData];
    [[RecordManager shareRecordManager]endRecord];
}

#pragma mark 重置数据
-(void)rsetData{
    [self stopTimer];
    second = 0;
    self.timeLabel.text = @"00 : 00";
    self.playBtn.selected = !self.playBtn.selected;
}

#pragma mark 音频保存
-(void)recordSave:(UIButton*)btn{
     [self rsetData];
     [[RecordManager shareRecordManager]endRecord];
    
}

+(UIImage*) createImageWithColor:(UIColor*) color{
    CGRect rect=CGRectMake(0.0f, 0.0f, WIDTH, 0.5f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)viewWillAppear:(BOOL)animated{
    
    //设置导航栏背景图片为一个空的image，这样就透明了
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    //去掉透明后导航栏下边的黑边
    [self.navigationController.navigationBar setShadowImage:[[self class] createImageWithColor:[UIColor whiteColor]]];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    //    如果不想让其他页面的导航栏变为透明 需要重置
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

#pragma mark 创建设置 和记录按钮
-(UIBarButtonItem*)createBarItem:(UIImage*)image Tag:(NSInteger)tag{
    
    UIButton * btn = [[UIButton alloc]init];
    [btn setImage:image forState:UIControlStateNormal];
    [btn sizeToFit];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
    return item;
    
}

#pragma mark 按钮点击
-(void)btnClick:(NSInteger)index{
    
    
}

@end
