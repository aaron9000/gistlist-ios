//
//  LocalStorage.m
//  Blob
//
//  Created by Aaron Geisler on 3/9/13.
//
//

#import <CocoaLumberjack.h>
#import "LocalStorage.h"

#define kLocalData @"LocalData"

@implementation LocalStorage

static LocalData* _cachedData = nil;

+ (LocalData*) retrieveFromDefaults{
    NSDictionary* dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kLocalData];
    LocalData* settings = [[LocalData alloc] initWithDictionary:dict];
    return settings;
}

+ (LocalData*) localData{
    if (_cachedData == nil){
        _cachedData = [self retrieveFromDefaults];
    }
    return [_cachedData clone];
}

+ (void) setLocalData:(LocalData*) localData{
    if (!localData){
        DDLogError(@"LocalSettings: saveLocalData: nil settings");
        return;
    }
    NSDictionary* dict = [localData dictionaryValue];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kLocalData];
    _cachedData = [localData clone];
}

+ (void) resetLocalData{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    if (appDomain){
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLocalData];
    }
}

@end
