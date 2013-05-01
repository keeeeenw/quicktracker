//
//  Saving+Budget.h
//  My Budget Planner
//
//  Created by Zixiao on 12-8-8.
//  Copyright (c) 2012年 Zixiao Wang. All rights reserved.
//

#import "Saving.h"

#define SAVE_ID @"save_id"
#define SAVE_DESCRIPTION @"save_description"
#define SAVE_DATE @"save_date"
#define SAVE_AMOUNT @"save_amount"
#define SAVE_LATITUDE @"save_latitude"
#define SAVE_LONGITUDE @"save_longitude"


@interface Saving (Budget)

+(Saving *)savingWithSaveInfo:(NSDictionary *)saveInfo
       inManagedObjectContext:(NSManagedObjectContext *)context;
+(NSNumber *) totalSavingInManagedObjectContext:(NSManagedObjectContext *)context;
@end
