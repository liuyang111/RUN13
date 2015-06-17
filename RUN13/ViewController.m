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
#import <SBJson/SBJson4Writer.h>

@interface ViewController ()

@end

@implementation ViewController
@synthesize numberOfMenuIetm;
@synthesize navMenu;
@synthesize popupController;
@synthesize showData;
@synthesize showHistory;
@synthesize startButton;
@synthesize pauseButton;
@synthesize stopButton;
@synthesize showStartTime;
@synthesize showEndTime;
@synthesize timer;
//@synthesize realTime;
@synthesize avAudioPlayer;
//@synthesize cancelTrainButton;
@synthesize planPliatDictionary;
@synthesize plistTableView;

int vibratenumber = 0;
int walknumber = 0;
int runnumber = 0;
int pausetimes = 0;
int walkSetNum;
int runSetNum;
int countSetNum;
int totalSetTime;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.numberOfMenuIetm = 4;  //每行显示ietm数目
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"menu" style:UIBarButtonItemStylePlain target:self action:@selector(openMenu:)];
    
    
    if (showHistory == nil) {
        showHistory = [[UILabel alloc] init];
    }
    if (showData == nil) {
        showData = [[UILabel alloc] init];
        showData.text = [NSString stringWithFormat:@"请首先设置训练计划"];
    }
    
    NSString *hist = [[NSUserDefaults standardUserDefaults] objectForKey:@"historyTimes"];
    NSLog(@"cancel -- self history times = %d",hist.intValue);
    showHistory.text = [NSString stringWithFormat:@"已进行 %d 次训练",hist.intValue];
    
    stopButton.enabled = NO;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"didRecieceMemoryWarning");
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
    [self.navigationItem.rightBarButtonItem setTitle:@"dismiss"];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didDismissMenu:(DOPNavbarMenu *)menu {
    [self.navigationItem.rightBarButtonItem setTitle:@"menu"];
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
//        [self showSetPlanDataWithWalk:walkTextFied.text.intValue Run:runTextFied.text.intValue Count:countTextFied.text.intValue];
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

    CNPPopupButton *button = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
    button.layer.cornerRadius = 4;
    //??
    button.selectionHandler = ^(CNPPopupButton *button){
        NSLog(@"Block for button: %@", button.titleLabel.text);
        //输入数据符合要求后，才能保存并推出popview
        if (walkTextFied.text.length == 0 || runTextFied.text.length == 0 || countTextFied.text.length == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"warning" message:@"有的值没填啊" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alert show];
        }else{
            [self showSetPlanDataWithWalk:walkTextFied.text.intValue Run:runTextFied.text.intValue Count:countTextFied.text.intValue];
            [self.popupController dismissPopupControllerAnimated:YES];
        }
    };

    
    self.popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel, customView, button]];
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
- (void)showSetPlanDataWithWalk:(int)walkTime Run:(int)runTime Count:(int)countNum{
    
    walkSetNum = walkTime;
    runSetNum = runTime;
    countSetNum = countNum;
    totalSetTime =( walkTime + runTime ) * countNum;
    
    showData.text = [NSString stringWithFormat:@"本次运动设置：行走 %d 分钟，慢跑 %d 分钟，共 %d 次。预计时长：%d 分钟",walkSetNum,runSetNum,countSetNum,totalSetTime];
    
//    NSString *kaishiSound = [[NSBundle mainBundle]pathForResource:@"zbkaishi" ofType:@"mp3"];
//    NSURL *kaishiSoundURL = [NSURL URLWithString:kaishiSound];
//    avAudioPlayer = nil;
//    avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:kaishiSoundURL error:nil];
//    [avAudioPlayer play];

}


- (IBAction)startRun:(id)sender {
    NSLog(@"start");
    NSLog(@"all times = %d",totalSetTime);
    if (totalSetTime != 0) {
        self.startButton.enabled = NO;
        runnumber = 0;
        walknumber = 0;
        pausetimes = 0;
        
        [self walkTimerSetting:timer];
        
        NSDate *now = [NSDate date];
        NSCalendar *cal = [NSCalendar currentCalendar];
        unsigned int unitFlags = kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay | kCFCalendarUnitHour | kCFCalendarUnitMinute |kCFCalendarUnitSecond;
        NSDateComponents *showdt = [cal components:unitFlags fromDate:now];
        
        showStartTime.text = [NSString stringWithFormat:@"%d-%d-%d   %d:%d:%d",showdt.year,showdt.month,showdt.day,showdt.hour,showdt.minute,showdt.second];
        
        showHistory.text = [NSString stringWithFormat:@"正在进行训练中。。。"];
    }
}

- (IBAction)pauseRun:(id)sender {
    if(![timer isValid]){
        UIAlertView *pauseErrorAlert = [[UIAlertView alloc] initWithTitle:@"warning" message:@"都没开始呢。。。" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [pauseErrorAlert show];
    }else{
        if (pauseButton.selected == YES) {
            NSLog(@"resume");
            pauseButton.selected = NO;
            [timer setFireDate:[NSDate distantPast]];
        }else{
            NSLog(@"pause");//暂停惩罚，已完成walk,run计数-1
            pauseButton.selected = YES;
            [timer setFireDate:[NSDate distantFuture]];
            runnumber --;
            walknumber --;
            pausetimes ++;
        }
    }
}

- (IBAction)stopRun:(id)sender {
    NSLog(@"stop");
    if ([self.timer isValid]) {
        NSLog(@"timer is valid can not stop");
//        [self.timer invalidate];
//        self.timer = nil;
        UIAlertView *stopalert = [[UIAlertView alloc] initWithTitle:@"warning" message:@"运动计划还没完呢" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [stopalert show];
        
    }
    else{
        NSString *hist = [[NSUserDefaults standardUserDefaults] objectForKey:@"historyTimes"];
        if (hist.length == 0) {
            self.historyTimes = 1;
        }
        else{
            self.historyTimes = hist.intValue +1 ;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",self.historyTimes] forKey:@"historyTimes"];
        
        NSLog(@"self history times = %d",self.historyTimes);
        
        showHistory.text = [NSString stringWithFormat:@"已进行 %d 次训练",self.historyTimes];
//        if (pausetimes == 0) {
//            realTime.text = [NSString stringWithFormat:@"顺利完成训练！！"];
//        }else{
//            realTime.text = [NSString  stringWithFormat:@"中途暂停 %d 次",pausetimes];
//        }
        startButton.enabled = YES;
        stopButton.enabled = NO;
    }
}

//使用定时器控制跑步和走路的时间，初始定义都是先开始走路，后跑步。每一次次数加1，当走路次数查过定义循环数时，标示已完成训练。
- (void)walkTimerSetting:(NSTimer *)timer{
    walknumber ++;
    NSLog(@"walk number = %d",walknumber);
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    if (walknumber <= walkSetNum) {
        
        [self vibratePlayNum:1];
        
        //+ video 这里是行走训练
        NSString *xingzouSound = [[NSBundle mainBundle]pathForResource:@"xingzou" ofType:@"wav"];
        NSURL *xingzouSoundURL = [NSURL URLWithString:xingzouSound];
        avAudioPlayer = nil;
        avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:xingzouSoundURL error:nil];
        [avAudioPlayer play];

        self.timer = [NSTimer scheduledTimerWithTimeInterval:walkSetNum * 60 target:self selector:@selector(runTimerSetting:) userInfo:nil repeats:YES];
    }
    else{
        //这里就本次结束训练了
        NSLog(@"end");
        [self vibratePlayNum:3];

        NSString *jieshuSound = [[NSBundle mainBundle]pathForResource:@"jieshu" ofType:@"wav"];
        NSURL *jieshuSoundURL = [NSURL URLWithString:jieshuSound];
        avAudioPlayer = nil;
        avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:jieshuSoundURL error:nil];
        [avAudioPlayer play];
        
        NSDate *now = [NSDate date];
        NSCalendar *cal = [NSCalendar currentCalendar];
        unsigned int unitFlags =  kCFCalendarUnitHour | kCFCalendarUnitMinute |kCFCalendarUnitSecond;
        NSDateComponents *showet = [cal components:unitFlags fromDate:now];
        
        showEndTime.text = [NSString stringWithFormat:@"%d:%d:%d",showet.hour,showet.minute,showet.second];
        
        stopButton.enabled = YES;
    }
}

- (void)runTimerSetting:(NSTimer *)timer{
    runnumber ++;
    NSLog(@"run timer = %d",runnumber);
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    [self vibratePlayNum:2];
    //+ video 这里跑步训练
    NSString *paobuSound = [[NSBundle mainBundle]pathForResource:@"paubu" ofType:@"wav"];
    NSURL *paobuSoundURL = [NSURL URLWithString:paobuSound];
    avAudioPlayer = nil;
    avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:paobuSoundURL error:nil];
    [avAudioPlayer play];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:runSetNum * 60 target:self selector:@selector(walkTimerSetting:) userInfo:nil repeats:YES];


}


//vibrate
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

//一定要取消本次训练，本次训练无记录
//- (IBAction)cancelRun:(id)sender{
//    if ([self.timer isValid]) {
//        UIAlertView *cancelRunAlert = [[UIAlertView alloc] initWithTitle:@"warning" message:@"取消就白跑了！" delegate:self cancelButtonTitle:@"再想想" otherButtonTitles:@"不跑了！", nil];
//        [cancelRunAlert show];
//        cancelRunAlert.tag = 101;
//    }
//}

//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if (alertView.tag == 101) {
//        if (buttonIndex == 1) {
//            NSLog(@"cancel");
//            if (self.timer) {
//                [self.timer invalidate];
//                self.timer = nil;
//            }
//            realTime.text = [NSString  stringWithFormat:@"本次训练被强制取消"];
//            startButton.enabled = YES;
//            NSString *hist = [[NSUserDefaults standardUserDefaults] objectForKey:@"historyTimes"];
//            NSLog(@"cancel -- self history times = %d",hist.intValue);
//            showHistory.text = [NSString stringWithFormat:@"已进行 %d 次训练",hist.intValue];
//        }
//    }
//}

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

    [self showSetPlanDataWithWalk:[[selectDic objectForKey:@"walk"]intValue] Run:[[selectDic objectForKey:@"run"]intValue] Count:[[selectDic objectForKey:@"count"]intValue]];
}
@end
