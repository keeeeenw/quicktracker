//
//  QPMapAnnotation.m
//  QuickPlaner
//
//  Created by Zixiao on 4/28/13.
//  Copyright (c) 2013 Zixiao Wang. All rights reserved.
//

#import "QPMapAnnotation.h"

@implementation QPMapAnnotation

+ (QPMapAnnotation *)annotationForRecord:(NSDictionary *)record{
    QPMapAnnotation *annotation = [[QPMapAnnotation alloc]init];
    annotation.record = record;
    return annotation;
}

#pragma mark - MKAnnotation Delegate

- (NSString *) title{
    return [self.record objectForKey:@"Amount"];
}

- (NSString *) subtitle{
    return [self.record objectForKey:@"Note"];
}

- (CLLocationCoordinate2D ) coordinate{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.record objectForKey:@"Latitude"] doubleValue];
    coordinate.longitude = [[self.record objectForKey:@"Longitdue"] doubleValue];
    return coordinate;
}

@end
