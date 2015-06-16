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

@interface ViewController : UIViewController<UIAlertViewDelegate, DOPNavbarMenuDelegate>

@property (assign, nonatomic) NSInteger numberOfMenuIetm;
@property (strong, nonatomic) DOPNavbarMenu *navMenu;

@property (strong, nonatomic) IBOutlet UITextField *walk;
@property (strong, nonatomic) IBOutlet UITextField *run;
@property (strong, nonatomic) IBOutlet UITextField *count;
@property (strong, nonatomic) IBOutlet UIButton *saveData;
@property (strong, nonatomic) IBOutlet UILabel *showData;
@property (strong, nonatomic) IBOutlet UILabel *showHistory;
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *pauseButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) IBOutlet UILabel *showStartTime;
@property (strong, nonatomic) IBOutlet UILabel *showEndTime;
@property (strong, nonatomic) IBOutlet UILabel *planTime;
@property (strong, nonatomic) IBOutlet UILabel *realTime;
@property (strong, nonatomic) IBOutlet UIButton *cancelTrainButton;

@property int historyTimes;
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) AVAudioPlayer *avAudioPlayer;


- (IBAction)saveTextfieldData:(id)sender;
- (IBAction)startRun:(id)sender;
- (IBAction)pauseRun:(id)sender;
- (IBAction)stopRun:(id)sender;
- (IBAction)cancelRun:(id)sender;

@end

