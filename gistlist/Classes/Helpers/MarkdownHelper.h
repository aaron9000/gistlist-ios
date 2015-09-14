//
//  MarkdownHelper.h
//  gistlist
//
//  Created by Aaron Geisler on 4/25/15.
//  Copyright (c) 2015 Aaron Geisler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarkdownHelper : NSObject


+ (NSString*) viralFilename;
+ (NSString*) viralDescription;
+ (NSString*) viralContent;
+ (NSString*) filenameKey;
+ (NSString*) addHeaderToContent:(NSString*) content;
+ (NSString*) hyphenatedDateString;
+ (NSString*) filenameForTodaysDate;
+ (NSString*) headerForTodaysDate;
+ (NSString*) footer;
+ (NSString*) descriptionForUsername:(NSString*) username;

@end
