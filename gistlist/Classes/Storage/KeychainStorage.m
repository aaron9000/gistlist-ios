//
//  KeychainStorage.m
//  ios-base
//
//  Created by Aaron Geisler on 3/12/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import "KeychainStorage.h"
#import <SSKeychain.h>
#import <CocoaLumberjack.h>

@implementation KeychainStorage

#define kGLTokenService @"GistListTokenServiceKey"
#define kGLUserLoginService @"GistListUserLoginServiceKey"
#define kGLUserStarsServiceKey @"GistListUserStarsServiceKey"
#define kGLAccount @"GistListAccountKey"

+ (NSInteger) completedTasks{
    NSString* completedTasksString = [SSKeychain passwordForService:kGLUserStarsServiceKey account:kGLAccount];
    if (completedTasksString.length == 0){
        DDLogError(@"stars not found in KeyChain");
        return 0;
    }
    return completedTasksString.intValue;
}

+ (void) setCompletedTasks:(NSInteger) completedTasks{
    BOOL save = [SSKeychain setPassword:[NSString stringWithFormat:@"%i", (int)completedTasks] forService:kGLUserStarsServiceKey account:kGLAccount];
    if (!save){
        DDLogError(@"failed to save completed tasks in keychain");
    }
}

+ (NSString*) token{
    NSString* token = [SSKeychain passwordForService:kGLTokenService account:kGLAccount];
    if (token.length == 0){
        DDLogError(@"valid 'token' not found in keychain: %@", token);
    }
    return token;
}

+ (NSString*) userLogin{
    NSString* userLogin = [SSKeychain passwordForService:kGLUserLoginService account:kGLAccount];
    if (userLogin.length == 0){
        DDLogError(@"valid 'userLogin' not found in keychain: %@", userLogin);
    }
    return userLogin;
}

+ (void) setToken:(NSString*) token userLogin:(NSString*) userLogin{
    BOOL saveToken = [SSKeychain setPassword:token forService:kGLTokenService account:kGLAccount];
    BOOL saveUserLogin = [SSKeychain setPassword:userLogin forService:kGLUserLoginService account:kGLAccount];
    if (!saveToken || !saveUserLogin){
        DDLogError(@"failed to save 'token' / 'userLogin' in keychain");
    }
}

+ (void) resetKeychainData{
    [self setToken:@"" userLogin:@""];
    [self setCompletedTasks:0];
}

@end
