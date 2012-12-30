//
//  Spending.h
//  QuickPlaner
//
//  Created by Zixiao on 12/30/12.
//  Copyright (c) 2012 Zixiao Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Spending : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * spend_id;
@property (nonatomic, retain) NSString * section_id;

@end
