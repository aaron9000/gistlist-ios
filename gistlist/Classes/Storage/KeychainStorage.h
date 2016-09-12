//
//  KeychainStorage.h
//  ios-base
//
//  Created by Aaron Geisler on 3/12/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainStorage : NSObject

+ (BOOL) sharedGist;
+ (void) setSharedGist:(BOOL) sharedGist;
+ (NSInteger) completedTasks;
+ (void) setCompletedTasks:(NSInteger) completedTasks;
+ (NSString*) token;
+ (NSString*) userLogin;
+ (void) setToken:(NSString*) token userLogin:(NSString*) userLogin;

@end
