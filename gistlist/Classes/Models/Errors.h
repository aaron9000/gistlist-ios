//
//  Errors.h
//  gistlist
//
//  Created by Aaron Geisler on 4/11/15.
//  Copyright (c) 2015 Aaron Geisler. All rights reserved.
//

#import <Foundation/Foundation.h>

// Errors
#define kErrorReasonBadData @"BAD_DATA"

// Keys
#define kCustomReason @"GLCustomReason"
#define kErrorDomain @"GLErrorDomain"
#define kErrorCode 111111

@interface Errors : NSObject

// Custom
+ (NSError *)alreadyAuthenticated;
+ (NSError *)notAuthenticated;
+ (NSError *)authFailure;
+ (NSError *)updateInProgress;
+ (NSError *)hasNotPerformedInitialSync;
+ (NSError *)dataError;

// Generic
+ (NSString *)errorMessage:(NSError *)error;
+ (NSError *)errorWithDescription:(NSString *)description withReason:(NSString *)reason withSuggestion:(NSString *)suggestion;

@end
