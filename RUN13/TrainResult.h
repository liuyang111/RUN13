//
//  TrainResult.h
//  RUN13
//
//  Created by 刘洋 on 6/24/15.
//  Copyright (c) 2015 css. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TrainResult : NSManagedObject

@property (nonatomic, retain) NSString * startTime;
@property (nonatomic, retain) NSString * endTime;
@property (nonatomic, retain) NSString * trainType;
@property (nonatomic, retain) NSString * pauseTimes;
@property (nonatomic, retain) NSString * addTime;
@property (nonatomic, retain) NSString * trainDetail;

@end
