//
//  QPMapAnnotation.h
//  QuickPlaner
//
//  Created by Zixiao on 4/28/13.
//  Copyright (c) 2013 Zixiao Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface QPMapAnnotation : NSObject <MKAnnotation>
+ (QPMapAnnotation *)annotationForRecord:(NSDictionary *)record; // spending/saving record dictionary
@property (nonatomic, strong) NSDictionary *record;
@end
