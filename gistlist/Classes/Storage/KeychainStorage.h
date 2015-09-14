//
//  KeychainStorage.h
//  ios-base
//
//  Created by Aaron Geisler on 3/12/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainStorage : NSObject

+ (BOOL) shared;
+ (void) setShared:(BOOL) shared;
+ (NSInteger) stars;
+ (void) setStars:(NSInteger) stars;
+ (NSString*) token;
+ (NSString*) userLogin;
+ (void) setToken:(NSString*) token userLogin:(NSString*) userLogin;

@end
