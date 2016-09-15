
#import <CocoaLumberjack.h>
#import <ObjectiveSugar.h>
#import <AFNetworking.h>
#import "MarkdownHelper.h"
#import "GithubService.h"
#import "KeychainStorage.h"
#import "Config.h"
#import "Errors.h"
#import "Extensions.h"

@implementation GithubService

#pragma mark - Constants and Keys

#define GITHUB_SCOPES OCTClientAuthorizationScopesUser | OCTClientAuthorizationScopesGist | OCTClientAuthorizationScopesRepository

+ (instancetype)sharedService
{
    static GithubService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GithubService alloc] init];
        [OCTClient setClientID:GITHUB_CLIENT_ID clientSecret:GITHUB_CLIENT_SECRET];
    });
    return sharedInstance;
}

#pragma mark - Public

- (BOOL) userIsAuthenticated{
    return (BOOL)(_client != nil && [_client isAuthenticated]);
}

- (RACSignal*) authenticateWithStoredCredentials{
    NSString* savedToken = [KeychainStorage token];
    NSString* savedUserLogin = [KeychainStorage userLogin];
    if (savedToken.length > 0 && savedUserLogin.length > 0){
        OCTUser* user = [OCTUser userWithRawLogin:savedUserLogin server:OCTServer.dotComServer];
        _client = [OCTClient authenticatedClientWithUser:user token:savedToken];
    }
    if (_client.isAuthenticated){
        return [RACSignal return:@(YES)];
    }else{
        DDLogError(@"failed to auth with stored credentials");
        return [RACSignal error:Errors.authFailure];
    }
}

- (RACSignal*) authenticateUsername:(NSString*) user withPassword:(NSString*) password withAuth:(NSString*) auth{
    if ([_client isAuthenticated]){
        return [RACSignal error:Errors.alreadyAuthenticated];
    }

    OCTUser *u = [OCTUser userWithRawLogin:user server:OCTServer.dotComServer];
    RACSignal* signal = [OCTClient signInAsUser:u password:password oneTimePassword:auth scopes:GITHUB_SCOPES note:nil noteURL:nil fingerprint:nil];
    return [[signal deliverOn:RACScheduler.mainThreadScheduler] doNext:^(OCTClient* authenticatedClient) {
        _client = authenticatedClient;
        [KeychainStorage setToken:_client.token userLogin:_client.user.rawLogin];
    }];
}

- (RACSignal*) createViralGist{
    
    OCTGistFileEdit* gistFileEdit = [[OCTGistFileEdit alloc] init];
    gistFileEdit.filename = [MarkdownHelper viralFilename];
    gistFileEdit.content = [MarkdownHelper viralContent];
    
    OCTGistEdit* gistEdit = [[OCTGistEdit alloc] init];
    gistEdit.gistDescription = [MarkdownHelper viralDescription];
    gistEdit.filesToAdd = @[gistFileEdit];
    gistEdit.publicGist = YES;
    
    RACSignal *request = [_client createGist:gistEdit];
    return [request deliverOn:RACScheduler.mainThreadScheduler];
}


- (RACSignal*) createGistWithContent:(NSString*) content username:(NSString*) username{
    
    OCTGistFileEdit* gistFileEdit = [[OCTGistFileEdit alloc] init];
    gistFileEdit.filename = [MarkdownHelper filenameForTodaysDate];
    gistFileEdit.content = [MarkdownHelper addHeaderToContent:content];
    
    OCTGistEdit* gistEdit = [[OCTGistEdit alloc] init];
    gistEdit.filesToAdd = @[gistFileEdit];
    gistEdit.publicGist = NO;
    gistEdit.gistDescription = [MarkdownHelper descriptionForUsername:username];
    
    RACSignal *request = [_client createGist:gistEdit];
    return [request deliverOn:RACScheduler.mainThreadScheduler];
}

- (RACSignal*) updateGist:(OCTGist*) gist withContent:(NSString*) content username:(NSString*) username{
    
    NSString* filename = [gist.files.allKeys firstObject];
    OCTGistFileEdit* gistFileEdit = [[OCTGistFileEdit alloc] init];
    gistFileEdit.filename = filename;
    gistFileEdit.content = [MarkdownHelper addHeaderToContent:content];
    
    OCTGistEdit* gistEdit = [[OCTGistEdit alloc] init];
    gistEdit.gistDescription = [MarkdownHelper descriptionForUsername:username];
    gistEdit.filesToModify = @{filename: gistFileEdit};
    
    RACSignal *request = [_client applyEdit:gistEdit toGist:gist];
    return [request deliverOn:RACScheduler.mainThreadScheduler];
}

- (RACSignal*) retrieveGistContentFromUrl:(NSURL*) url{
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        NSOperationQueue *queue = [NSOperationQueue mainQueue];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:queue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if (error){
                                       DDLogError(@"failed to retrieve gist from url: %@", url);
                                       [subscriber sendError:error];
                                   }else{
                                       NSString* gistContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                       DDLogInfo(@"-----------------------------------------");
                                       DDLogInfo(@"%@", gistContent);
                                       DDLogInfo(@"-----------------------------------------");
                                      [subscriber sendNext:gistContent];
                                   }
                               }];
        return nil;
    }];
}

- (RACSignal*) retrieveUserMetadata{
    RACSignal *request = [_client fetchUserInfo];
    return [request deliverOn:RACScheduler.mainThreadScheduler];
}

- (RACSignal*) retrieveMostRecentGistSince:(NSDate*) since{
    RACSignal *request = [_client fetchGistsUpdatedSince:since];
    return [[[request collect] map:^id(NSArray* gists) {
        return [self filterGists:gists].first;
    }] deliverOn:RACScheduler.mainThreadScheduler];
}

#pragma mark - Helpers

- (RACSignal*) invalidateCachedLogin{
    [KeychainStorage setToken:@"" userLogin:@""];
    _client = nil;
    return [RACSignal return:@(YES)];
}

- (BOOL) containsFilenameOfInterest:(OCTGist*) gist{
    NSArray* filenames = gist.files.allKeys;
    NSArray* filteredFilenames = [filenames select:^BOOL(NSString* filename) {
        BOOL containsFileKey = [filename.lowercaseString containsString:MarkdownHelper.filenameKey.lowercaseString];
        BOOL containsViralKey = [filename containsString:MarkdownHelper.viralFilename];
        return containsFileKey && !containsViralKey;
    }];
    return filteredFilenames.count > 0;
}

- (NSMutableArray*) filterGists:(NSArray*) gists{
    
    // Keep only Gists with a relevant filename
    NSArray* filteredGists = [gists select:^BOOL(OCTGist* gist) {
        return [self containsFilenameOfInterest:gist];
    }];
    
    // Sort on creation date (newest first)
    NSMutableArray* mutableFilteredGists = [NSMutableArray arrayWithArray:filteredGists];
    NSSortDescriptor* sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
    [mutableFilteredGists sortUsingDescriptors:@[sortByDate]];
    return mutableFilteredGists;
}

@end
