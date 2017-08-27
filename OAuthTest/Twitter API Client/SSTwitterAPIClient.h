//
//  TwitterAPIClient.h
//  OAuthTest
//
//  Created by sergey on 8/8/17.
//  Copyright © 2017 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SSTwitterLoginProtocol <NSObject>

- (void)didLoggeIn;

@end
typedef void(^TwitterCompletionBlock)(NSArray *twitts, NSError *error)
;
@interface SSTwitterAPIClient : NSObject

#pragma mark Initialization
+ (SSTwitterAPIClient *)sharedInstance;
+ (instancetype)createWithConsumerKey:(NSString *)apiKey secret:(NSString *)secret;

#pragma mark Login
- (void)loginToTwitter;
- (BOOL)handleOpenURL:(NSURL *)url;
- (BOOL)isAuthorized;

#pragma mark Tweets
- (void)twittsFromTimeLineWithMaxTwittsID:(NSString *)maxTwittsID andCompletionBlock:(TwitterCompletionBlock)completion;

@property(nonatomic, weak) id<SSTwitterLoginProtocol> delegate;
@end
