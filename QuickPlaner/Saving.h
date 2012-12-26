//
//  Saving.h
//  My Budget Planner
//
//  Created by Zixiao on 12-8-8.
//  Copyright (c) 2012年 Zixiao Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Saving : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSString * describe;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * save_id;

@end
