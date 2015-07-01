//
//  ViewController.m
//  RUN13
//
//  Created by 刘洋 on 6/11/15.
//  Copyright (c) 2015 css. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "historyTableViewController.h"
//#import <SBJson/SBJson4Writer.h>
#import "CircleProgressView.h"
#import "Session.h"
#import "AppDelegate.h"
#import "TrainResult.h"

#define SET_MINITE_TIME 6

@interface ViewController (){
    BOOL ifStarted;
    BOOL ifPauseed;
}

@end

@implementation ViewController
@synthesize numberOfMenuIetm;
@synthesize navMenu;
@synthesize popupController;
@synthesize showData;
@synthesize showStatusString;
@synthesize startButton;
//@synthesize pauseButton;
//@synthesize stopButton;
@synthesize showStartTime;
@synthesize timer;
//@synthesize realTime;
@synthesize avAudioPlayer;
//@synthesize cancelTrainButton;
@synthesize planPliatDictionary;
@synthesize plistTableView;
@synthesize progressTimer;
@synthesize ifWalking;
@synthesize startDate;
@synthesize endDate;
@synthesize startDateString;
@synthesize endDateString;
@synthesize trainingSchedule;
@synthesize trainTypeStr;

int vibratenumber = 0;
int doneWalknumber = 0;
int doneRunnumber = 0;
int pausetimes = 0;
float walkSetNum;
float runSetNum;
int countSetNum;
float totalSetTime;

NSCalendar *cal;
unsigned int unitFlags;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor grayColor];

    self.session = [[Session alloc] init];
    self.progressTimer = nil;
    

    self.circleProgressView = [[CircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 230, 230)];
    self.circleProgressView.center = CGPointMake(self.view.frame.size.width/2, 80+self.circleProgressView.frame.size.height/2);
    [self.view addSubview:self.circleProgressView];
    self.circleProgressView.status = NSLocalizedString(@"等待开始", nil);
    self.circleProgressView.tintColor = [UIColor blackColor];
    self.circleProgressView.elapsedTime = 0;

    
    
    self.showData = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    self.showData.center = CGPointMake(self.view.frame.size.width/2, self.circleProgressView.frame.size.height + 80 + 40);
    self.showData.font = [UIFont boldSystemFontOfSize:12];
    self.showData.numberOfLines = 2;
    self.showData.text = [NSString stringWithFormat:NSLocalizedString(@"请先设置运动计划", @"")];
    self.showData.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.showData];
    
    self.showStartTime = [[UILabel alloc] initWithFrame:CGRectMake(20, self.circleProgressView.frame.size.height + 150, self.view.frame.size.width - 40, 40)];
    self.showStartTime.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:self.showStartTime];
    
    
    self.startButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-20, self.circleProgressView.frame.size.height + 220, 40, 40)];
//    [self.startButton setTitle:NSLocalizedString(@"开始", @"") forState:UIControlStateNormal];
    [self.startButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
//    self.startButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [self.startButton addTarget:self action:@selector(startRun:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startButton];
    
//    self.pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(125, self.circleProgressView.frame.size.height + 220, 60, 30)];
//    [self.pauseButton setTitle:NSLocalizedString(@"暂停", @"") forState:UIControlStateNormal];
//    self.pauseButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
//    [self.pauseButton addTarget:self action:@selector(pauseRun:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.pauseButton];
    
//    self.stopButton = [[UIButton alloc] initWithFrame:CGRectMake(250, self.circleProgressView.frame.size.height + 220, 30, 30)];
////    [self.stopButton setTitle:NSLocalizedString(@"结束", @"") forState:UIControlStateNormal];
//    [self.stopButton setImage:[UIImage imageNamed:@"Delete"] forState:UIControlStateNormal];
//
////    self.stopButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
//    [self.stopButton addTarget:self action:@selector(stopRun:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.stopButton];

    NSString *hist = [[NSUserDefaults standardUserDefaults] objectForKey:@"historyTimes"];
    NSLog(@"cancel -- self history times = %d",hist.intValue);
    if (showStatusString == nil) {
        showStatusString = [[UILabel alloc] initWithFrame:CGRectMake(20, self.circleProgressView.frame.size.height + 300, self.view.frame.size.width-20, 20)];
    }
    showStatusString.text = [NSString stringWithFormat:NSLocalizedString(@"已进行 %d 次训练", @""),hist.intValue];
    showStatusString.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:self.showStatusString];
    
//    self.trainingSchedule = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    
    
    self.numberOfMenuIetm = 4;  //每行显示ietm数目
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"功能" style:UIBarButtonItemStylePlain target:self action:@selector(openMenu:)];
    
    
//    if (showData == nil) {
//        showData = [[UILabel alloc] init];
//        showData.text = [NSString stringWithFormat:@"请首先设置训练计划"];
//    }
    
    
//    stopButton.enabled = NO;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    
    cal = [NSCalendar currentCalendar];
    unitFlags = kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay | kCFCalendarUnitHour | kCFCalendarUnitMinute |kCFCalendarUnitSecond;

    ifStarted = NO;
    ifPauseed = NO;
    
    
    
    // 从应用程序包中加载模型文件
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    // 传入模型对象，初始化NSPersistentStoreCoordinator
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    // 构建SQLite数据库文件的路径
    NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *url = [NSURL fileURLWithPath:[docs stringByAppendingPathComponent:@"trainresult.data"]];
    // 添加持久化存储库，这里使用SQLite作为存储库
    NSError *error = nil;
    NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error];
    if (store == nil) { // 直接抛异常
        [NSException raise:@"添加数据库错误" format:@"%@", [error localizedDescription]];
    }
    // 初始化上下文，设置persistentStoreCoordinator属性
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = psc;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"didRecieceMemoryWarning");
}

- (void) viewDidDisappear:(BOOL)animated{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    [self.timer invalidate];
    self.timer = nil;
    
    self.circleProgressView = nil;
    self.showData = nil;
    self.showStartTime = nil;
    self.startDate = nil;
    self.endDate = nil;
    self.endDateString = nil;
    self.startDateString = nil;
    self.trainingSchedule = nil;
}
#pragma mark - NAV MEN
- (DOPNavbarMenu *)menu {
    if (self.navMenu == nil) {
        DOPNavbarMenuItem *item0 = [DOPNavbarMenuItem ItemWithTitle:@"10公里计划" icon:[UIImage imageNamed:@"Image"]];
        DOPNavbarMenuItem *item1 = [DOPNavbarMenuItem ItemWithTitle:@"自定义" icon:[UIImage imageNamed:@"Image"]];
        DOPNavbarMenuItem *item2 = [DOPNavbarMenuItem ItemWithTitle:@"历史记录" icon:[UIImage imageNamed:@"Image"]];
        DOPNavbarMenuItem *item3 = [DOPNavbarMenuItem ItemWithTitle:@"设置" icon:[UIImage imageNamed:@"Image"]];

        self.navMenu = [[DOPNavbarMenu alloc] initWithItems:@[item0,item1,item2,item3] width:self.view.dop_width maximumNumberInRow:self.numberOfMenuIetm];
        self.navMenu.backgroundColor = [UIColor lightGrayColor];
        self.navMenu.separatarColor = [UIColor whiteColor];
        self.navMenu.delegate = self;
    }
    return self.navMenu;
}

- (void)openMenu:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (self.menu.isOpen) {
        [self.menu dismissWithAnimation:YES];
    } else {
        [self.menu showInNavigationController:self.navigationController];
    }
}

- (void)didShowMenu:(DOPNavbarMenu *)menu {
    [self.navigationItem.rightBarButtonItem setTitle:@"完毕"];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didDismissMenu:(DOPNavbarMenu *)menu {
    [self.navigationItem.rightBarButtonItem setTitle:@"功能"];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    if (index == 0) {
        NSLog(@"10 miles");
        [self showPlistPlanPopupWithFullScreenStyle];
    }else if (index == 1){
        NSLog(@"auto");
        [self showCustomizePopupWithStyle:CNPPopupStyleCentered];
    }else if (index == 2){
        NSLog(@"history list");
        historyTableViewController *historylist = [[historyTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        historylist.title = @"history";
        [self.navigationController pushViewController:historylist animated:YES];

    }else if (index == 3){
        NSLog(@"settings");
    }
}

#pragma mark - 读取plist存储计划
- (void)showPlistPlanPopupWithFullScreenStyle{
    NSString *planPlistPath = [[NSBundle mainBundle] pathForResource:@"13PlanList.plist" ofType:nil];
//    NSString *ppp = [[NSBundle mainBundle]pathForResource:@"13PlanList.plist" ofType:nil];

    planPliatDictionary = [NSDictionary dictionaryWithContentsOfFile:planPlistPath];
    
    if (plistTableView == NULL) {
        plistTableView = [[UITableView alloc] initWithFrame:CGRectMake(15, 40,self.view.frame.size.width-30 , self.view.frame.size.height - 70) style:UITableViewStyleGrouped];
    }
    plistTableView.tag = 101;
    plistTableView.delegate = self;
    plistTableView.dataSource = self;
    
    CNPPopupButton *button = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
    button.layer.cornerRadius = 4;
    button.selectionHandler = ^(CNPPopupButton *button){
        NSLog(@"Block for button: %@", button.titleLabel.text);
        [self.popupController dismissPopupControllerAnimated:YES];
    };

    self.popupController = [[CNPPopupController alloc] initWithContents:@[plistTableView, button]];
    self.popupController.theme = [CNPPopupTheme defaultTheme];
    self.popupController.theme.popupStyle = CNPPopupStyleFullscreen;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
}


#pragma mark - 自定义
- (void)showCustomizePopupWithStyle:(CNPPopupStyle)popupStyle {
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"自定义你今天的跑步计划" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 0;
    titleLabel.attributedText = title;
    
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 125)];
    customView.backgroundColor = [UIColor lightGrayColor];
    
    UITextField *walkTextFied = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, 230, 35)];
    walkTextFied.borderStyle = UITextBorderStyleBezel;
    walkTextFied.placeholder = @"走路分钟数";
    walkTextFied.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [customView addSubview:walkTextFied];
    UITextField *runTextFied = [[UITextField alloc] initWithFrame:CGRectMake(10, 45, 230, 35)];
    runTextFied.borderStyle = UITextBorderStyleBezel;
    runTextFied.placeholder = @"跑步分钟数";
    runTextFied.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [customView addSubview:runTextFied];
    UITextField *countTextFied = [[UITextField alloc] initWithFrame:CGRectMake(10, 85, 230, 35)];
    countTextFied.borderStyle = UITextBorderStyleBezel;
    countTextFied.placeholder = @"循环次数";
    countTextFied.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [customView addSubview:countTextFied];

    CNPPopupButton *button = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
    button.layer.cornerRadius = 4;
    
    CNPPopupButton *cancelPopbutton = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    cancelPopbutton.titleLabel.textColor = [UIColor whiteColor];
    cancelPopbutton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [cancelPopbutton setTitle:@"取消" forState:UIControlStateNormal];
    cancelPopbutton.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
    cancelPopbutton.layer.cornerRadius = 4;

    //??
    button.selectionHandler = ^(CNPPopupButton *button){
        NSLog(@"Block for button: %@", button.titleLabel.text);
        //输入数据符合要求后，才能保存并推出popview
        if (walkTextFied.text.length == 0 || runTextFied.text.length == 0 || countTextFied.text.length == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"warning" message:@"有的值没填啊" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alert show];
        }else{
            [self showSetPlanDataWithWalk:walkTextFied.text.floatValue Run:runTextFied.text.floatValue Count:countTextFied.text.intValue];
            self.trainTypeStr = [NSString stringWithFormat:@"自定义"];
            [self.popupController dismissPopupControllerAnimated:YES];
        }
    };

     cancelPopbutton.selectionHandler = ^(CNPPopupButton *button){
         [self.popupController dismissPopupControllerAnimated:YES];
     };
    
    self.popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel, customView, button,cancelPopbutton]];
    self.popupController.theme = [CNPPopupTheme defaultTheme];
    self.popupController.theme.popupStyle = popupStyle;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];

}

#pragma mark - CNPPopupController Delegate

- (void)popupController:(CNPPopupController *)controller didDismissWithButtonTitle:(NSString *)title {
    NSLog(@"Dismissed with button title: %@", title);
}

- (void)popupControllerDidPresent:(CNPPopupController *)controller {
    NSLog(@"Popup controller presented.");
}


//设置完本次训练计划后，在主界面显示设置数据
- (void)showSetPlanDataWithWalk:(float)walkTime Run:(float)runTime Count:(int)countNum{
    
    walkSetNum = walkTime;
    runSetNum = runTime;
    countSetNum = countNum;
    totalSetTime =( walkTime + runTime ) * countNum;
    
    showData.text = [NSString stringWithFormat:@"本次运动设置：行走 %.1f 分钟，慢跑 %.1f 分钟，共 %d 次。预计时长：%.1f 分钟",walkSetNum,runSetNum,countSetNum,totalSetTime];
    
//    NSString *kaishiSound = [[NSBundle mainBundle]pathForResource:@"zbkaishi" ofType:@"mp3"];
//    NSURL *kaishiSoundURL = [NSURL URLWithString:kaishiSound];
//    avAudioPlayer = nil;
//    avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:kaishiSoundURL error:nil];
//    [avAudioPlayer play];
//    [self startVideo:@"zbkaishi" type:@"mp3"];

}

- (void) startVideo:(NSString *)videoname type:(NSString *)typename{
    NSString *videoSound = [[NSBundle mainBundle]pathForResource:videoname ofType:typename];
    NSURL *videoSoundURL = [NSURL URLWithString:videoSound];
    avAudioPlayer = nil;
    avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:videoSoundURL error:nil];
    [avAudioPlayer play];
}
#pragma mark button

- (IBAction)startRun:(id)sender {
//    NSLog(@"start");
    if (ifStarted == NO) {
        if (totalSetTime != 0.0) {
            NSLog(@"start");
            ifStarted = YES;
            
//            stopButton.enabled = YES;
//            self.startButton.titleLabel.text = [NSString stringWithFormat:@"暂停"];
//            [self.startButton setTitle:[NSString stringWithFormat:@"暂停"] forState:UIControlStateNormal];
            [self.startButton setImage:[UIImage imageNamed:@"Pause"] forState:UIControlStateNormal];

            doneRunnumber = 0;
            doneWalknumber = 0;
            pausetimes = 0;
            
            self.session.state = kSessionStateStop;
            [self startTimer];
            
            [self walkTimerSetting:timer];
            
            self.startDate = [NSDate date];
            NSDateComponents *showdt = [cal components:unitFlags fromDate:self.startDate];
            self.startDateString = [NSString stringWithFormat:@"%ld-%ld-%ld   %ld:%ld:%ld",(long)showdt.year,(long)showdt.month,(long)showdt.day,(long)showdt.hour,(long)showdt.minute,(long)showdt.second];
            showStartTime.text = self.startDateString;
            
            self.showStatusString.text = [NSString stringWithFormat:NSLocalizedString(@"正在进行训练循环第 1 次", @"")];
            
        }else{
            UIAlertView *cannotStartAlert = [[UIAlertView alloc] initWithTitle:@"warning" message:@"请先进行训练设置" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [cannotStartAlert show];
        }
    }else if(ifStarted == YES){
        if (ifPauseed == NO) {
            NSLog(@"pause");
            ifPauseed = YES;
            
//            self.startButton.titleLabel.text = [NSString stringWithFormat:@"继续"];
//            [self.startButton setTitle:[NSString stringWithFormat:@"继续"] forState:UIControlStateNormal];
            [self.startButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];

            [self stopProgress];
            //暂停惩罚，总循环训练计数 +1
            [timer setFireDate:[NSDate distantFuture]];
            countSetNum ++;
            pausetimes ++;
            
            totalSetTime =( walkSetNum + runSetNum ) * countSetNum;
            showData.text = [NSString stringWithFormat:@"本次运动设置：行走 %.1f 分钟，慢跑 %.1f 分钟，共 %d 次。预计时长：%.1f 分钟",walkSetNum,runSetNum,countSetNum,totalSetTime];
            
            self.showStatusString.text = [NSString stringWithFormat:@"再次开始将进行下一阶段练习，同时练习总循环数+1"];

        } else {
            UIActionSheet *resumeOrDeleteSheet = [[UIActionSheet alloc] initWithTitle:@"操作控制选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"继续训练" otherButtonTitles:@"结束训练", nil];
            [resumeOrDeleteSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
            [resumeOrDeleteSheet showInView:self.view];
        }
    }
}

//- (IBAction)pauseRun:(id)sender {
//    if(![timer isValid]){
//        UIAlertView *pauseErrorAlert = [[UIAlertView alloc] initWithTitle:@"warning" message:@"都没开始呢。。。" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
//        [pauseErrorAlert show];
//    }else{
//        if (pauseButton.selected == YES) {
//            self.pauseButton.titleLabel.text = [NSString stringWithFormat:@"暂停"];
//
//            if (self.ifWalking == YES) {
//                [self startProgressWithStatus:@"跑步"];
//            }else if(self.ifWalking == NO){
//                [self startProgressWithStatus:@"行走"];
//            }
//
//            NSLog(@"resume");
//            pauseButton.selected = NO;
//            [timer setFireDate:[NSDate distantPast]];
//        }else{
//            [self stopProgress];
////            [self.pauseButton setTitle:@"继续" forState:UIControlStateHighlighted];
////            self.pauseButton.tintColor = [UIColor redColor];
//            NSLog(@"pause");//暂停惩罚，总循环训练计数 +1
//            pauseButton.selected = YES;
//            [timer setFireDate:[NSDate distantFuture]];
////            doneWalknumber --;
////            doneRunnumber --;
//            countSetNum ++;
//            pausetimes ++;
//            
//            totalSetTime =( walkSetNum + runSetNum ) * countSetNum;
//            showData.text = [NSString stringWithFormat:@"本次运动设置：行走 %.1f 分钟，慢跑 %.1f 分钟，共 %d 次。预计时长：%.1f 分钟",walkSetNum,runSetNum,countSetNum,totalSetTime];
//
//        }
//    }
//}

- (void)stopRun{
    NSLog(@"stop");
    if ([self.timer isValid]) {
        NSLog(@"timer is valid can not stop");
        UIAlertView *cancelRunAlert = [[UIAlertView alloc] initWithTitle:@"warning" message:@"运动计划还没完呢，取消就白跑了！" delegate:self cancelButtonTitle:@"再想想" otherButtonTitles:@"不跑了！", nil];
        [cancelRunAlert show];
        cancelRunAlert.tag = 101;

    }
}

- (void)saveTrainResultDataWithStartTime:(NSString *)startTimeString EndTime:(NSString *)endTimeString TrainType:(NSString *)trainTypeString TrainDetail:(NSString *)trainDetailString PauseTimes:(NSString *)pauseTimesString AddTime:(NSString *)addTimeString{
    
    // 传入上下文，创建一个Person实体对象
//    NSManagedObjectContext *context;
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context=[appdelegate managedObjectContext];
    
//    NSManagedObject *person = [NSEntityDescription insertNewObjectForEntityForName:@"TrainResult" inManagedObjectContext:context];
//    // 设置Person的简单属性
//    [person setValue:startTime forKey:@"startTime"];
//    [person setValue:endTime forKey:@"endTime"];
//    // 利用上下文对象，将数据同步到持久化存储库
    
    TrainResult *trainResultInsert = [NSEntityDescription insertNewObjectForEntityForName:@"TrainResult" inManagedObjectContext:context];
    trainResultInsert.startTime = startTimeString;
    trainResultInsert.endTime = endTimeString;
    trainResultInsert.trainType = trainTypeString;
    trainResultInsert.pauseTimes = pauseTimesString;
    trainResultInsert.trainDetail = trainDetailString;
    trainResultInsert.addTime = addTimeString;
    
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"booki insert Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    
    
    // 初始化一个查询请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    // 设置要查询的实体
    request.entity = [NSEntityDescription entityForName:@"TrainResult" inManagedObjectContext:context];
    // 设置排序（按照age降序）
//    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:NO];
//    request.sortDescriptors = [NSArray arrayWithObject:sort];
//    // 设置条件过滤(搜索name中包含字符串"Itcast-1"的记录，注意：设置条件过滤时，数据库SQL语句中的%要用*来代替，所以%Itcast-1%应该写成*Itcast-1*)
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@", @"*Itcast-1*"];
//    request.predicate = predicate;
//    // 执行请求
//    NSError *error = nil;
    NSArray *objs = [context executeFetchRequest:request error:&error];
    if (error) {
        [NSException raise:@"查询错误" format:@"%@", [error localizedDescription]];
    }
    // 遍历数据
    for (NSManagedObject *obj in objs) {
        NSLog(@"start=%@", [obj valueForKey:@"startTime"]);
        NSLog(@"end=%@", [obj valueForKey:@"endTime"]);
        NSLog(@"type=%@", [obj valueForKey:@"trainType"]);
        NSLog(@"pause=%@", [obj valueForKey:@"pauseTimes"]);
        NSLog(@"add time=%@", [obj valueForKey:@"addTime"]);
    }
}

#pragma mark walk and run timer logic
//使用定时器控制跑步和走路的时间，初始定义都是先开始走路，后跑步。每一次次数加1，当走路次数查过定义循环数时，标示已完成训练。
- (void)walkTimerSetting:(NSTimer *)timer{
    float progressv = (float)doneWalknumber/(float)countSetNum;
    [self.trainingSchedule setProgress:progressv animated:YES];
    
    doneWalknumber ++;
    NSLog(@"walk number = %d == %d",doneWalknumber,countSetNum);
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    if (doneWalknumber <= countSetNum) {
        self.showStatusString.text = [NSString stringWithFormat:NSLocalizedString(@"正在进行训练循环第 %d 次", @""),doneWalknumber];
        
        self.ifWalking = YES;
        [self vibratePlayNum:1];
        
        //+ video 这里是行走训练
//        NSString *xingzouSound = [[NSBundle mainBundle]pathForResource:@"xingzou" ofType:@"wav"];
//        NSURL *xingzouSoundURL = [NSURL URLWithString:xingzouSound];
//        avAudioPlayer = nil;
//        avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:xingzouSoundURL error:nil];
//        [avAudioPlayer play];
//        [self startVideo:@"xingzou" type:@"wav"];

        self.timer = [NSTimer scheduledTimerWithTimeInterval:(walkSetNum * SET_MINITE_TIME) target:self selector:@selector(runTimerSetting:) userInfo:nil repeats:YES];
        
        self.circleProgressView.timeLimit = walkSetNum * SET_MINITE_TIME;
        [self stopProgress];
        [self startProgressWithStatus:@"行走"];

    }
    else{
        //这里就本次结束训练了
        NSLog(@"end");
        [self vibratePlayNum:3];

//        NSString *jieshuSound = [[NSBundle mainBundle]pathForResource:@"jieshu" ofType:@"wav"];
//        NSURL *jieshuSoundURL = [NSURL URLWithString:jieshuSound];
//        avAudioPlayer = nil;
//        avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:jieshuSoundURL error:nil];
//        [avAudioPlayer play];
//        [self startVideo:@"jieshu" type:@"wav"];
        
        self.endDate = [NSDate date];
        NSDateComponents *showet = [cal components:unitFlags fromDate:endDate];
        
        self.endDateString = [NSString stringWithFormat:@"%ld:%ld:%ld",(long)showet.hour,(long)showet.minute,(long)showet.second];
        
        self.showStartTime.text = [NSString stringWithFormat:@"%@------%@",self.startDateString,self.endDateString];
        
        
        [self.progressTimer invalidate];
        self.progressTimer = nil;
        [self.timer invalidate];
        self.timer = nil;
        self.circleProgressView.status = NSLocalizedString(@"训练结束", nil);
        self.circleProgressView.tintColor = [UIColor whiteColor];
        self.circleProgressView.elapsedTime = 0;
        
        self.showStatusString.text = [NSString stringWithFormat:NSLocalizedString(@"恭喜你，本次训练结束，将自动保存记录。", @""),doneWalknumber];
        
        NSString *hist = [[NSUserDefaults standardUserDefaults] objectForKey:@"historyTimes"];
        if (hist.length == 0) {
            self.historyTimes = 1;
        }
        else{
            self.historyTimes = hist.intValue +1 ;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",self.historyTimes] forKey:@"historyTimes"];
        
        NSLog(@"self history times = %d",self.historyTimes);
        
        if (pausetimes == 0) {
            self.showStatusString.text = [NSString stringWithFormat:NSLocalizedString(@"顺利完成本次训练", @"")];
        }else{
            self.showStatusString.text = [NSString stringWithFormat:NSLocalizedString(@"完成训练，中途暂停 %d 次，训练循环 +%d次", @""),pausetimes,pausetimes];
        }
        startButton.enabled = YES;

        ifStarted = NO;
        [self.startButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
        
//        [self saveTrainResultDataWithStartTime:self.startDateString endTime:self.endDateString];
        [self saveTrainResultDataWithStartTime:self.startDateString EndTime:self.endDateString TrainType:self.trainTypeStr TrainDetail:showData.text PauseTimes:[NSString stringWithFormat:@"%d",pausetimes] AddTime:nil];
    }
}

- (void)runTimerSetting:(NSTimer *)timer{
    
    doneRunnumber ++;
    NSLog(@"done run times = %d",doneRunnumber);
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.ifWalking = NO;
    [self vibratePlayNum:2];
//    //+ video 这里跑步训练
//    NSString *paobuSound = [[NSBundle mainBundle]pathForResource:@"paubu" ofType:@"wav"];
//    NSURL *paobuSoundURL = [NSURL URLWithString:paobuSound];
//    avAudioPlayer = nil;
//    avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:paobuSoundURL error:nil];
//    [avAudioPlayer play];
//    [self startVideo:@"paubu" type:@"wav"];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(runSetNum * SET_MINITE_TIME) target:self selector:@selector(walkTimerSetting:) userInfo:nil repeats:YES];

    self.circleProgressView.timeLimit = runSetNum * SET_MINITE_TIME;
    [self stopProgress];
    [self startProgressWithStatus:@"慢跑"];

}


#pragma mark progerss timer
- (void) startProgressWithStatus:(NSString *)statusString{
    if (self.session.state == kSessionStateStop) {
        
        self.session.startDate = [NSDate date];
        self.session.finishDate = nil;
        self.session.state = kSessionStateStart;
        
        UIColor *tintColor = [UIColor colorWithRed:184/255.0 green:233/255.0 blue:134/255.0 alpha:1.0];
        self.circleProgressView.status = [NSString stringWithFormat:@"%@训练",statusString];
        self.circleProgressView.tintColor = tintColor;
        self.circleProgressView.elapsedTime = 0;
        
    }
}

- (void) stopProgress{
    self.session.finishDate = [NSDate date];
    self.session.state = kSessionStateStop;
    
    self.circleProgressView.status = NSLocalizedString(@"计时停止", nil);
    self.circleProgressView.tintColor = [UIColor whiteColor];
    self.circleProgressView.elapsedTime = self.session.progressTime;
}

- (void)startTimer {
    if ((!self.progressTimer) || (![self.progressTimer isValid])) {
        
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.00
                                                      target:self
                                                    selector:@selector(poolTimer)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (void)poolTimer
{
    if ((self.session) && (self.session.state == kSessionStateStart))
    {
        self.circleProgressView.elapsedTime = self.session.progressTime;
    }
}


#pragma mark vibrate setting
- (void)vibratePlayNum:(NSInteger)num{
    //倒数第二个参数，是执行完震动回调，要执行才会达到连续多次震动的效果，
//    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, NULL, num);
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, completionCallback, num);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

static void completionCallback (SystemSoundID  mySSID,  int num){
//    NSLog(@"play  after = %d---vib = %d",num,vibratenumber);
    if(vibratenumber >= num-1){
//        NSLog(@"finish vibrate");
        vibratenumber = 0;
        AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate);
    }
    else{
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        vibratenumber ++;
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            NSLog(@"cancel");
            if (self.timer) {
                [self.timer invalidate];
                self.timer = nil;
            }
            if (self.progressTimer) {
                [self.progressTimer invalidate];
                self.progressTimer = nil;
            }
            
            self.circleProgressView.status = NSLocalizedString(@"取消训练", nil);
            self.circleProgressView.tintColor = [UIColor blackColor];
            self.circleProgressView.elapsedTime = 0;

            startButton.enabled = YES;
            NSString *hist = [[NSUserDefaults standardUserDefaults] objectForKey:@"historyTimes"];
            NSLog(@"cancel -- self history times = %d",hist.intValue);
            self.showStatusString.text = [NSString stringWithFormat:NSLocalizedString(@"最近一次训练训练被强制取消", @"")];
        }
    }
}


#pragma mark tableview delegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"plan plist array count = %lu",(unsigned long)self.planPliatDictionary.count);
    return self.planPliatDictionary.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = [[self.planPliatDictionary allKeys] objectAtIndex:indexPath.row];
    
    NSDictionary *dic = [[self.planPliatDictionary allValues] objectAtIndex:indexPath.row];
    
    NSString *walk = [dic valueForKey:@"walk"];
    NSString *run = [dic valueForKey:@"run"];
    NSString *count = [dic valueForKey:@"count"];
    NSString *time = [dic valueForKey:@"time"];

    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"步行 %@ 分钟, 慢跑 %@ 分钟, 循环 %@ 次, 共 %@ 分钟",walk,run,count,time];
    return cell;
}

- (void ) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"--%@",[[self.planPliatDictionary allValues] objectAtIndex:indexPath.row ]);
    NSDictionary *selectDic = [[self.planPliatDictionary allValues] objectAtIndex:indexPath.row ];

    NSLog(@"selected keys====%@",[[self.planPliatDictionary allKeys] objectAtIndex:indexPath.row ]);
    self.trainTypeStr = [[self.planPliatDictionary allKeys] objectAtIndex:indexPath.row ];
    
    [self showSetPlanDataWithWalk:[[selectDic objectForKey:@"walk"]floatValue] Run:[[selectDic objectForKey:@"run"]floatValue] Count:[[selectDic objectForKey:@"count"]intValue]];
}

#pragma mark actionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSLog(@"resume action sheet");
        NSLog(@"resume");
        ifPauseed = NO;
        
        [self.startButton setImage:[UIImage imageNamed:@"Pause"] forState:UIControlStateNormal];
        
        if (self.ifWalking == YES) {
            [self startProgressWithStatus:@"跑步"];
        }else if(self.ifWalking == NO){
            [self startProgressWithStatus:@"行走"];
        }
        
        [timer setFireDate:[NSDate distantPast]];
        
    }else if (buttonIndex == 1){
        NSLog(@"delete action sheet");
        [self stopRun];
    }
}
@end
