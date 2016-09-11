//
// Created by Adam Krasny on 1/13/15.
// Copyright (c) 2015 Aaron Geisler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RACSignal (Extensions)

- (RACSignal *)withLoadingSpinner;
- (RACSignal *)withErrorAlert;

@end
