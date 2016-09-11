//
//  OCTClient+FetchDatedGist.m
//  gistlist
//
//  Created by Aaron Geisler on 3/28/15.
//  Copyright (c) 2015 Aaron Geisler. All rights reserved.
//

#import "OCTClient+FetchDatedGist.h"
#import <OCTGist.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <NSDateFormatter+OCTFormattingAdditions.h>
#import <RACSignal+OCTClientAdditions.h>

@implementation OCTClient (FetchDatedGist)

- (RACSignal *)fetchGistsUpdatedSince:(NSDate *)since {
    NSParameterAssert(since != nil);
    
    if (!self.authenticated) return [RACSignal error:nil];
    NSDictionary *parameters = nil;
    if (since != nil) {
        parameters = @{ @"since" : [NSDateFormatter oct_stringFromDate:since] };
    }
    NSURLRequest *request = [self requestWithMethod:@"GET" path:@"gists" parameters:parameters notMatchingEtag:nil];
    return [[self enqueueRequest:request resultClass:OCTGist.class] oct_parsedResults];
}

- (RACSignal *)createGist:(OCTGistEdit *)edit {
    NSParameterAssert(edit != nil);
    
    if (!self.authenticated) return [RACSignal error:nil];
    
    NSDictionary *parameters = [MTLJSONAdapter JSONDictionaryFromModel:edit];
    
    // Convert integer true/false to boolean
    NSMutableDictionary * parametersM = [parameters mutableCopy];
    id public = parametersM[@"public"];
    if ([public isKindOfClass:[NSNumber class]]) {
        parametersM[@"public"] = [public boolValue] ? @(YES) : @(NO);
    }
    parameters = parametersM;
    
    NSURLRequest *request = [self requestWithMethod:@"POST" path:@"gists" parameters:parameters notMatchingEtag:nil];
    return [[self enqueueRequest:request resultClass:OCTGist.class] oct_parsedResults];
}

@end
