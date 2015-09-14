//
//  MarkdownHelper.m
//  gistlist
//
//  Created by Aaron Geisler on 4/25/15.
//  Copyright (c) 2015 Aaron Geisler. All rights reserved.
//

#import "MarkdownHelper.h"
#import "URLs.h"

#define FILENAME_KEY @"GISTLIST"
#define APP_TITLE @"GistList"

@implementation MarkdownHelper

+ (NSString*) viralFilename{
    return @"GistList!.md";
}

+ (NSString*) viralDescription{
    return [NSString stringWithFormat:@"Try %@ for iOS! %@", APP_TITLE, HOMEPAGE_URL];
}

+ (NSString*) viralContent{
    NSString* titleLine = [NSString stringWithFormat:@"##![alt text](%@)  %@: TODO for coders", ICON_URL, APP_TITLE];
    NSString* screenshotLine = [NSString stringWithFormat:@"[![alt text](%@)](%@)", VIRAL_AD_IMAGE_URL, HOMEPAGE_URL];
    return [NSString stringWithFormat:@"%@ \n %@", titleLine, screenshotLine];
}

+ (NSString*) addHeaderToContent:(NSString*) content{
    return [NSString stringWithFormat:@"%@\n%@\n%@", [self headerForTodaysDate], content, [self footer]];
}

+ (NSString*) hyphenatedDateString{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-yyyy"];
    NSString* dateString = [formatter stringFromDate:[NSDate date]];
    return dateString;
}

+ (NSString*) filenameForTodaysDate{
    NSString* dateString = [self hyphenatedDateString];
    return [NSString stringWithFormat:@"%@ (%@).md", FILENAME_KEY, dateString];
}

+ (NSString*) headerForTodaysDate{
    NSString* titleLine = [NSString stringWithFormat:@"#TODO (%@)\n", [self hyphenatedDateString]];
    return [NSString stringWithFormat:@"%@\n", titleLine];
}

+ (NSString*) footer{
    NSString* a = [NSString stringWithFormat:@"###[![alt text][2]][1] [Made with %@](%@)", APP_TITLE, HOMEPAGE_URL];
    NSString* b = [NSString stringWithFormat:@"[1]: %@", HOMEPAGE_URL];
    NSString* c = [NSString stringWithFormat:@"[2]: %@ (%@)", ICON_URL, APP_TITLE];
    NSString* storeButton = [NSString stringWithFormat:@"[![alt text](%@)](%@)", VIRAL_BTN_IMAGE_URL, STORE_URL];
    NSString* footer = [NSString stringWithFormat:@"\n--\n%@\n%@\n%@\n%@", a, b, c, storeButton];
    return footer;
}

+ (NSString*) descriptionForUsername:(NSString*) username{
    return [NSString stringWithFormat:@"%@'s TODO (%@)\n", username, [self hyphenatedDateString]];
}

+ (NSString*) filenameKey{
    return FILENAME_KEY;
}

@end
