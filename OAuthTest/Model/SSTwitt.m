//
//  SSTwitt.m
//  OAuthTest
//
//  Created by sergey on 8/8/17.
//  Copyright © 2017 sergey. All rights reserved.
//

#import "SSTwitt.h"

static NSString * const kBDBTweetTweetTextName = @"text";
static NSString * const kBDBTweetUserInfoName = @"user";
static NSString * const kBDBTweetUserName = @"name";
static NSString * const kBDBTweetID = @"id";


@implementation SSTwitt

- (id)initWithDictionary:(NSDictionary *)tweetInfo {
    self = [super init];
    
    if (nil != self)
    {
        _tweetText = [tweetInfo[kBDBTweetTweetTextName] copy];
        
        _twittID = tweetInfo[kBDBTweetID];
        
        NSDictionary *userInfo = tweetInfo[kBDBTweetUserInfoName];
        
        _userName = userInfo[kBDBTweetUserName];
    }
    
    return self;
}

@end
