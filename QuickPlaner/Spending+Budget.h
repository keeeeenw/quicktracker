//
//  Spending+Budget.h
//  My Budget Planner
//
//  Created by Zixiao on 12-8-8.
//  Copyright (c) 2012年 Zixiao Wang. All rights reserved.
//

#import "Spending.h"

#define PURCHASE_ID @"purchase_id"
#define PURCHASE_NAME @"purchase_name"
#define PURCHASE_DATE @"purchase_date"
#define PURCHASE_AMOUNT @"purchase_amount"
#define PURCHASE_LATITUDE @"PURCHASE_latitude"
#define PURCHASE_LONGITUDE @"PURCHASE_longitude"

@interface Spending (Budget)

+(Spending *)spendingWithPurchaseInfo:(NSDictionary *)purchaseInfo
               inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSNumber *) totalSpendingInManagedObjectContext:(NSManagedObjectContext *)context;
@end
