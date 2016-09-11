//
//  GistListLogic.h
//  ios-base
//
//  Created by Aaron Geisler on 3/12/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RACSignal+Extensions.h"
#import "TaskList.h"
#import "Task.h"

@interface AppService : NSObject{

}

// Getters
+ (NSString*) taskDescriptionAtIndex:(NSInteger) index;
+ (Task*) taskAtIndex:(NSInteger) index;
+ (BOOL) taskIsCompleteAtIndex:(NSInteger) index;
+ (NSInteger) taskCount;
+ (NSString*) userImageUrl;
+ (NSString*) username;
+ (NSURL*) gistUrl;

// Sessions
+ (void) start;
+ (void) signOut;
+ (BOOL) userIsAuthenticated;
+ (BOOL) performedInitialSync;
+ (BOOL) hasStoredCreds;
+ (RACSignal*) startOfflineSession;
+ (RACSignal*) startSessionAndSyncWithStoredCreds;
+ (RACSignal*) startSessionAndSyncWithUsername:(NSString*) user password:(NSString*) password auth:(NSString*) auth;

// Synchronization
+ (RACSignal*) attemptSync;

// Task Mangement
+ (RACSignal*) createViralGist;
+ (RACSignal*) updateTask:(NSInteger) index withText:(NSString*) newText;
+ (RACSignal*) deleteTask:(NSInteger) index;
+ (RACSignal*) toggleTask:(NSInteger) index;
+ (RACSignal*) addNewTaskWithText:(NSString*) text;

@end
