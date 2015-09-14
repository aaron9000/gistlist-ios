//
//  OCTClient+FetchDatedGist.h
//  gistlist
//
//  Created by Aaron Geisler on 3/28/15.
//  Copyright (c) 2015 Aaron Geisler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OCTClient.h>

@class OCTGist;
@class OCTGistEdit;

@interface OCTClient (FetchDatedGist)

- (RACSignal *)fetchGistsUpdatedSince:(NSDate *)since;
- (RACSignal *)createGist:(OCTGistEdit *)edit;

@end
