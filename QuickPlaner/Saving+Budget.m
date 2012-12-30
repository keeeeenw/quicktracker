//
//  Saving+Budget.m
//  My Budget Planner
//
//  Created by Zixiao on 12-8-8.
//  Copyright (c) 2012年 Zixiao Wang. All rights reserved.
//

#import "Saving+Budget.h"

@implementation Saving (Budget)

//Get Total Saving
//Helper Method to Create new Saving NSMangedObject

+(Saving *)savingWithSaveInfo:(NSDictionary *)saveInfo
               inManagedObjectContext:(NSManagedObjectContext *)context{
    Saving *save;
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Saving"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"save_id = %@",[saveInfo valueForKey:SAVE_ID]];
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"describe" ascending:YES];
//    request.predicate = predicate;
//    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//    
//    NSArray *matches = [context executeFetchRequest:request error:nil];
//    
//    if (!matches || [matches count] > 1) {
//        //handle the error
//    } else if ([matches count] == 0) {
//        save = [NSEntityDescription insertNewObjectForEntityForName:@"Saving" inManagedObjectContext:context];
//        save.save_id = [saveInfo valueForKey:SAVE_ID];
//        save.describe = [saveInfo valueForKey:SAVE_DESCRIPTION];
//        save.date = [saveInfo valueForKey:SAVE_DATE];
//        save.amount = [saveInfo valueForKey:SAVE_AMOUNT];
//        NSLog(@"%@",save);
//    } else {
//        save = [matches lastObject];
//    }
    save = [NSEntityDescription insertNewObjectForEntityForName:@"Saving" inManagedObjectContext:context];
    save.save_id = [saveInfo valueForKey:SAVE_ID];
    save.describe = [saveInfo valueForKey:SAVE_DESCRIPTION];
    save.date = [saveInfo valueForKey:SAVE_DATE];
    save.amount = [saveInfo valueForKey:SAVE_AMOUNT];
    //NSLog(@"%@",save);
    
    return save;
}

+(NSNumber *) totalSavingInManagedObjectContext:(NSManagedObjectContext *)context{
    NSNumber *totalSaving = [NSNumber numberWithDouble:0.0];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Saving"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"save_id like '*'"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"describe" ascending:YES];
//    request.predicate = predicate;
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSArray *matches = [context executeFetchRequest:request error:nil];
    
    if (matches != nil) {
        for (Saving *save in matches) {
            totalSaving = [NSNumber numberWithDouble:[totalSaving doubleValue] + [save.amount doubleValue]];
        }
    }
    
    return totalSaving;
}
@end
