//
//  ViewController.h
//  RUN13
//
//  Created by 刘洋 on 6/11/15.
//  Copyright (c) 2015 css. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DOPNavbarMenu.h"
#import <CNPPopupController/CNPPopupController.h>
#import "Session.h"

@class CircleProgressView;

@interface ViewController : UIViewController<UIAlertViewDelegate, DOPNavbarMenuDelegate,CNPPopupControllerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (assign, nonatomic) NSInteger numberOfMenuIetm;
@property (strong, nonatomic) DOPNavbarMenu *navMenu;

@property (strong, nonatomic) CNPPopupController *popupController;

@property (strong, nonatomic) IBOutlet CircleProgressView *circleProgressView;
@property (nonatomic) Session *session;

@property (strong, nonatomic) IBOutlet UILabel *showData;
@property (strong, nonatomic) IBOutlet UILabel *showStatusString;
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *pauseButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) IBOutlet UILabel *showStartTime;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSString *startDateString;
@property (strong, nonatomic) NSString *endDateString;
@property (strong, nonatomic) IBOutlet UIProgressView * trainingSchedule;

//@property (strong, nonatomic) IBOutlet UILabel *realTime;
//@property (strong, nonatomic) IBOutlet UIButton *cancelTrainButton;

@property int historyTimes;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *progressTimer;

@property (strong, nonatomic) AVAudioPlayer *avAudioPlayer;

@property (strong, nonatomic) NSDictionary *planPliatDictionary;
@property (retain, nonatomic) IBOutlet UITableView *plistTableView;

@property (assign, nonatomic) Boolean ifWalking;


//- (IBAction)saveTextfieldData:(id)sender;
- (IBAction)startRun:(id)sender;
- (IBAction)pauseRun:(id)sender;
- (IBAction)stopRun:(id)sender;
//- (IBAction)cancelRun:(id)sender;

@end

