//
//  VactionDocumentHelper.h
//  FlickerTopPlaces
//
//  Created by Zixiao on 12-7-24.
//  Copyright (c) 2012年 Zixiao Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completion_block_t)(UIManagedDocument *vacation);

@interface DocumentHelper : NSObject

+ (UIManagedDocument *)sharedManagedDocumentForName:(NSString *)name;

+ (void)openDocument:(NSString *)name
          usingBlock:(completion_block_t)completionBlock;

+ (void)removeDocument:(NSString *)name;
@end
