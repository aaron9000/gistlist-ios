//
//  GitHubService.h
//  ios-base
//
//  Created by Aaron Geisler on 3/12/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OctoKit.h>

@interface GithubService : NSObject{

}

+ (void) invalidateCachedLogin;
+ (BOOL) userIsAuthenticated;
+ (BOOL) authenticateWithStoredCredentials;

+ (RACSignal*) authenticateUsername:(NSString*) user withPassword:(NSString*) password withAuth:(NSString*) auth;
+ (RACSignal*) updateGist:(OCTGist*) gist withContent:(NSString*) content username:(NSString*) username;
+ (RACSignal*) createViralGist;
+ (RACSignal*) retrieveUserMetadata;
+ (RACSignal*) createGistWithContent:(NSString*) content username:(NSString*) username;
+ (RACSignal*) retrieveGistWithRawUrl:(NSURL*) url;
+ (RACSignal*) retrieveGistsSince:(NSDate*) since;

@end
