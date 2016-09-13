//
//  KeychainStorage.h
//  ios-base
//
//  Created by Aaron Geisler on 3/12/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainStorage : NSObject

+ (NSInteger) completedTasks;
+ (NSString*) token;
+ (NSString*) userLogin;

+ (void) setCompletedTasks:(NSInteger) completedTasks;
+ (void) setToken:(NSString*) token userLogin:(NSString*) userLogin;
+ (void) resetKeychainData;

@end
