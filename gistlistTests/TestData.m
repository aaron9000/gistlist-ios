//
//  TestData.m
//  gistlist
//
//  Created by Aaron Geisler on 9/12/16.
//  Copyright © 2016 Aaron Geisler. All rights reserved.
//

#import "TestData.h"

@implementation TestData

+ (NSString*) gistString {
    return @"#TODO (05-17-2015)"
    ""
    ""
    "- [ ] File bug reports"
    "- [ ] Reschedule missed dentist appointment"
    "- [ ] Deploy Pennpult website"
    "- [x] Marinate chicken"
    "- [ ] Schedule time off"
    "- [x] Renew car insurance"
    "- [x] Schedule meeting with Alex"
    "- [ ] Review and merge pull request"
    "- [ ] Get beer and groceries"
    ""
    ""
    "--"
    "###[![alt text][2]][1] [Made with GistList](http://gistlist.io/)"
    "[1]: http://gistlist.io/"
    "[2]: http://gistlist.s3-website-us-east-1.amazonaws.com/gl-icon-4.png (GistList)"
    "[![alt text](http://gistlist.s3-website-us-east-1.amazonaws.com/btn-4.png)](http://itunes.com/apps/apptivus/gistlist)";
}

+ (NSDictionary*) sampleGistData {
    return @{
             @"url": @"https://api.github.com/gists/23fe77b213f016ba8163",
             @"id": @"1",
             @"description": @"description of gist",
             @"public": @YES,
             @"user": @{
                     @"login": @"octocat",
                     @"id": @1,
                     @"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
                     @"gravatar_id": @"somehexcode",
                     @"url": @"https://api.github.com/users/octocat"
                     },
             @"files": @{
                     @"ring.erl": @{
                             @"size": @932,
                             @"filename": @"ring.erl",
                             @"raw_url": @"https://gist.github.com/raw/365370/8c4d2d43d178df44f4c03a7f2ac0ff512853564e/ring.erl"
                             }
                     },
             @"comments": @0,
             @"comments_url": @"https://api.github.com/gists/71bca83c625d7bbd1ac5/comments/",
             @"html_url": @"https://gist.github.com/1",
             @"git_pull_url": @"git://gist.github.com/1.git",
             @"git_push_url": @"git@gist.github.com:1.git",
             @"created_at": @"2016-09-12T08:00:00Z",
             @"forks": @[
                     @{
                         @"user": @{
                                 @"login": @"octocat",
                                 @"id": @1,
                                 @"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
                                 @"gravatar_id": @"somehexcode",
                                 @"url": @"https://api.github.com/users/octocat"
                                 },
                         @"url": @"https://api.github.com/gists/ac16d17127f44732e77b",
                         @"created_at": @"2011-04-14T16:00:49Z"
                         }
                     ],
             @"history": @[
                     @{
                         @"url": @"https://api.github.com/gists/b5b5732025ffd72da0d2",
                         @"version": @"57a7f021a713b1c5a6a199b54cc514735d2d462f",
                         @"user": @{
                                 @"login": @"octocat",
                                 @"id": @1,
                                 @"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
                                 @"gravatar_id": @"somehexcode",
                                 @"url": @"https://api.github.com/users/octocat"
                                 },
                         @"change_status": @{
                                 @"deletions": @0,
                                 @"additions": @180,
                                 @"total": @180
                                 },
                         @"committed_at": @"2010-04-14T02:15:15Z"
                         }
                     ]
             };
}

@end
