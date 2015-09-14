//
//  Errors.m
//  gistlist
//
//  Created by Aaron Geisler on 4/11/15.
//  Copyright (c) 2015 Aaron Geisler. All rights reserved.
//

#import "Errors.h"
#import <CocoaLumberjack.h>

@implementation Errors

#pragma mark - Custom

+ (NSError *)alreadyAuthenticated{
    return [self errorWithDescription:@"Auth Error"
                           withReason:@"Already authenticated"
                       withSuggestion:@""];
}

+ (NSError *)notAuthenticated{
    return [self errorWithDescription:@"Auth Error"
                           withReason:@"Not authenticated"
                       withSuggestion:@""];
}

+ (NSError *)authFailure{
    return [self errorWithDescription:@"Auth Error"
                           withReason:@"Failed to authenticated"
                       withSuggestion:@""];
}

+ (NSError *)updateInProgress{
    return [self errorWithDescription:@"Flow Error"
                           withReason:@"Update in progress"
                       withSuggestion:@""];
}

+ (NSError *)hasNotPerformedInitialSync{
    return [self errorWithDescription:@"Flow Error"
                           withReason:@"Has not performed initial sync"
                       withSuggestion:@""];
}


+ (NSError *)dataError{
    return [self errorWithDescription:@"Data Error"
                           withReason:@"State issue"
                       withSuggestion:@""];
}

#pragma mark - Generic

+ (NSString *)errorMessage:(NSError *)error{
    
    // Dont want this
    if (error == nil) {
        return @"Unknown Error";
    }
    
    // Try to use our custom reason, fall back to default
    return error.userInfo[kCustomReason] ? : [error.userInfo[NSUnderlyingErrorKey] localizedDescription];
}

+ (NSError *)errorWithDescription:(NSString *)description withReason:(NSString *)reason withSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey : description,
                               NSLocalizedFailureReasonErrorKey : reason,
                               NSLocalizedRecoverySuggestionErrorKey : suggestion,
                               kCustomReason : reason
                               };
    NSError *error = [NSError errorWithDomain:kErrorDomain
                                         code:kErrorCode
                                     userInfo:userInfo];
    DDLogError(@"error generated:\n %@", [self errorMessage:error]);
    return error;
}


@end
