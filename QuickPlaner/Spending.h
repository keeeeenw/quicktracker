//
//  Spending.h
//  My Budget Planner
//
//  Created by Zixiao on 12-8-8.
//  Copyright (c) 2012年 Zixiao Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Spending : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * spend_id;

@end
