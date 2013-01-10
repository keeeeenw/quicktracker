//
//  Spending+Budget.m
//  My Budget Planner
//
//  Created by Zixiao on 12-8-8.
//  Copyright (c) 2012年 Zixiao Wang. All rights reserved.
//

#import "Spending+Budget.h"

@implementation Spending (Budget)

//Get Total Spending
//Helper Method to Create new Spending NSMangedObject



+(Spending *)spendingWithPurchaseInfo:(NSDictionary *)purchaseInfo
               inManagedObjectContext:(NSManagedObjectContext *)context{
    Spending *spending;
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Spending"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"spend_id = %@",[purchaseInfo valueForKey:PURCHASE_ID]];
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
//    request.predicate = predicate;
//    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//   
//    NSArray *matches = [context executeFetchRequest:request error:nil];
//    
//    if (!matches || [matches count] > 1) {
//        //handle the error
//    } else if ([matches count] == 0) {
//        spending = [NSEntityDescription insertNewObjectForEntityForName:@"Spending" inManagedObjectContext:context];
//        spending.spend_id = [purchaseInfo valueForKey:PURCHASE_ID];
//        spending.name = [purchaseInfo valueForKey:PURCHASE_NAME];
//        spending.date = [purchaseInfo valueForKey:PURCHASE_DATE];
//        spending.amount = [purchaseInfo valueForKey:PURCHASE_AMOUNT];
//        NSLog(@"%@",spending);
//    } else {
//        spending = [matches lastObject];
//    }
    
    spending = [NSEntityDescription insertNewObjectForEntityForName:@"Spending" inManagedObjectContext:context];
    spending.spend_id = [purchaseInfo valueForKey:PURCHASE_ID];
    spending.name = [purchaseInfo valueForKey:PURCHASE_NAME];
    spending.date = [purchaseInfo valueForKey:PURCHASE_DATE];
    spending.amount = [purchaseInfo valueForKey:PURCHASE_AMOUNT];
    
    //Sections in TableViewController are organized by day, month and year. secion_id = (year * 10000) + (month * 100) + day
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[purchaseInfo valueForKey:PURCHASE_DATE]];
    NSString *tmp = [NSString stringWithFormat:@"%d", ([components year] * 10000) + ([components month]*100) + [components day]];
    
    spending.section_id = tmp;
    
    return spending;
}

+(NSNumber *) totalSpendingInManagedObjectContext:(NSManagedObjectContext *)context{
    NSNumber *totalSpending = [NSNumber numberWithDouble:0.0];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Spending"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"spend_id like '*'"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"amount" ascending:YES];
    request.predicate = predicate;
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSArray *matches = [context executeFetchRequest:request error:nil];
    
    if (matches != nil) {
        for (Spending *spend in matches) {
            //NSLog(@"Spending Amount %@",spend.amount);
            totalSpending = [NSNumber numberWithDouble:([totalSpending doubleValue] + [spend.amount doubleValue])];
        }
    }    
    return totalSpending;
}


@end
