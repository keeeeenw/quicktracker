//
//  VactionDocumentHelper.m
//  FlickerTopPlaces
//
//  Created by Zixiao on 12-7-24.
//  Copyright (c) 2012年 Zixiao Wang. All rights reserved.
//

#import "DocumentHelper.h"

@interface DocumentHelper()

@end

@implementation DocumentHelper

+ (UIManagedDocument *)sharedManagedDocumentForName:(NSString *)name{
    NSURL *fileURL = [self documentFileURL:name];
    static UIManagedDocument *database = nil;
    if (!database) {
        database = [[UIManagedDocument alloc]initWithFileURL:fileURL];
    }
    return database;
}

+ (void)openDocument:(NSString *)name
          usingBlock:(completion_block_t)completionBlock{
    NSURL *fileURL = [self documentFileURL:name];
    static UIManagedDocument *database = nil;
    database = [[UIManagedDocument alloc]initWithFileURL:fileURL];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[database.fileURL path]]) {
        //Create a new database on disk
        [database saveToURL:database.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if (success) {
                NSLog(@"Creating New Database Succeed");
                completionBlock(database);
            } else {
                NSLog(@"Creating New Database Not Succeed");
            }
        }];
    } else if (database.documentState == UIDocumentStateClosed){
        //Already exist on disk, but closed, we open it up
        [database openWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"Opening Existing Database Succeed");
                completionBlock(database);
            } else {
                NSLog(@"Opening Exisiting Database Not Succeed");
            }
        }];
    } else if (database.documentState == UIDocumentStateNormal){
        //Already opened
        completionBlock(database);
    }
}

+ (NSURL *)documentFileURL:(NSString *)name{
    NSURL *documentURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *databaseURL = [documentURL URLByAppendingPathComponent:@"CoreData"];
    //Create the new ../CoreData directory if it does not already exist
    if (![[NSFileManager defaultManager] fileExistsAtPath:[databaseURL path]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[databaseURL path]withIntermediateDirectories:YES attributes:nil error:nil];
    }
    databaseURL = [databaseURL URLByAppendingPathComponent:name];
    //NSLog(@"The Path for Database is %@",[databaseURL path]);
    return databaseURL;
}

@end
