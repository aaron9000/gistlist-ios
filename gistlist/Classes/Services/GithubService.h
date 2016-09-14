#import <Foundation/Foundation.h>
#import <ISO8601DateFormatter.h>
#import <Octokit/OctoKit.h>

@interface GithubService : NSObject{

}

- (BOOL) userIsAuthenticated;

- (RACSignal*) invalidateCachedLogin;
- (RACSignal*) authenticateWithStoredCredentials;
- (RACSignal*) authenticateUsername:(NSString*) user withPassword:(NSString*) password withAuth:(NSString*) auth;
- (RACSignal*) updateGist:(OCTGist*) gist withContent:(NSString*) content username:(NSString*) username;
- (RACSignal*) createViralGist;
- (RACSignal*) retrieveUserMetadata;
- (RACSignal*) createGistWithContent:(NSString*) content username:(NSString*) username;
- (RACSignal*) retrieveGistContentFromUrl:(NSURL*) url;
- (RACSignal*) retrieveMostRecentGistSince:(NSDate*) since;

+ (instancetype)sharedService;

@end
