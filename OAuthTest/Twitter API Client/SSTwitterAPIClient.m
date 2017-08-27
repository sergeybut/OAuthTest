//
//  TwitterAPIClient.m
//  OAuthTest
//
//  Created by sergey on 8/8/17.
//  Copyright © 2017 sergey. All rights reserved.
//

#import "SSTwitterAPIClient.h"

// Tweetter message model
#import "SSTwitt.h"

// OAuth Manager
#import "BDBOAuth1SessionManager.h"
#import "NSDictionary+BDBOAuth1Manager.h"

// Strings
static NSString* const kTwitterClientErrorDomain = @"kTwitterClientErrorDomain";
static NSString* const kTwitterClientAPIURL   = @"https://api.twitter.com/1.1/";
static NSString* const kTwitterClientOAuthAuthorizeURL     = @"https://api.twitter.com/oauth/authorize";
static NSString* const kTwitterClientOAuthToRedirectURL     = @"https://api.twitter.com/oauth/authenticate";
static NSString* const kTwitterClientOAuthCallbackURL      = @"softservetest://authorize";
static NSString* const kTwitterClientOAuthRequestTokenPath = @"https://api.twitter.com/oauth/request_token";
static NSString* const kTwitterClientOAuthAccessTokenPath  = @"https://api.twitter.com/oauth/access_token";
static NSString* const kTwitterConsumerAPIKey  = @"dLfL6rL9GYQo0FZ2lVbi2ZFKZ";
static NSString* const kTwitterConsumerAPISecret  = @"cerNU8pGye3ToK7xv1dju0lqoIt55kJ2xGT4SAKjHKPCLgzdqe";

@interface SSTwitterAPIClient ()

// networking manager
@property(nonatomic, strong) BDBOAuth1SessionManager *networkManager;

@end

@implementation SSTwitterAPIClient

static SSTwitterAPIClient *_sharedClient = nil;

+ (SSTwitterAPIClient *)sharedInstance
{
    return [self createWithConsumerKey:nil secret:nil];;
}

+ (instancetype)createWithConsumerKey:(NSString *)apiKey secret:(NSString *)secret
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[[self class] alloc] initWithConsumerKey:apiKey sceret:secret];
    });
    
    return _sharedClient;
}

- (id)initWithConsumerKey:(NSString *)key sceret:(NSString *)secret
{
    self = [super init];
    
    if (nil != self)
    {
        NSURL *baseURL = [NSURL URLWithString:kTwitterClientAPIURL];
        
        // add hardcoded consumerKey and secret key - for testing
        _networkManager = [[BDBOAuth1SessionManager alloc] initWithBaseURL:baseURL consumerKey:kTwitterConsumerAPIKey consumerSecret:kTwitterConsumerAPISecret];
    }
    
    return self;
}

- (void)loginToTwitter
{
    [self.networkManager deauthorize];
    [self.networkManager fetchRequestTokenWithPath:kTwitterClientOAuthRequestTokenPath
                                            method:@"POST"
                                       callbackURL:[NSURL URLWithString:kTwitterClientOAuthCallbackURL]
                                             scope:nil
                                           success:^(BDBOAuth1Credential *requestToken) {
                                               
                                               NSString *authURLString = [kTwitterClientOAuthAuthorizeURL stringByAppendingFormat:@"?oauth_token=%@", requestToken.token];
                                               
                                               // open redirect message on safari browser
                                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authURLString]];
                                           }
                                           failure:^(NSError *error) {
                                               NSLog(@"Error: %@", error.localizedDescription);
                                           }];
 
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    NSDictionary *parameters = [NSDictionary bdb_dictionaryFromQueryString:url.query];
    
    if (parameters[BDBOAuth1OAuthTokenParameter] && parameters[BDBOAuth1OAuthVerifierParameter])
    {
        [self.networkManager fetchAccessTokenWithPath:kTwitterClientOAuthAccessTokenPath
                                               method:@"POST"
                                         requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query]
                                              success:^(BDBOAuth1Credential *accessToken) {
                                                //notify delegate about success with loggin to Twitter
                                                  [self.delegate didLoggeIn];
                                              }
                                              failure:^(NSError *error) {
                                                  NSLog(@"Error: %@", error.localizedDescription);
                                              }];
        
        return YES;
    }
    
    return NO;
 
}

- (void)twittsFromTimeLineWithMaxTwittsID:(NSString *)maxTwittsID andCompletionBlock:(TwitterCompletionBlock)completion
{
    // we start download just first 10 tweets
    static NSString *timelinePath = @"statuses/home_timeline.json?count=10";
    
    NSMutableDictionary *params = nil;
    
    // last tweet
    if (nil != maxTwittsID)
    {
        params = [NSMutableDictionary new];
        [params setObject:maxTwittsID forKey:@"max_id"];
    }
    
    [self.networkManager GET:timelinePath
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask *task, id responseObject) {
                         [self parseTweetsFromAPIResponse:responseObject completion:completion];
                     }
                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                         completion(nil, error);
                     }];
}

- (void)parseTweetsFromAPIResponse:(id)responseObject completion:(void (^)(NSArray *, NSError *))completion
{
    if (![responseObject isKindOfClass:[NSArray class]])
    {
        NSError *error = [NSError errorWithDomain:kTwitterClientErrorDomain
                                             code:10002
                                         userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Error happens with tweeter api", nil)}];
        
        return completion(nil, error);
    }
    
    NSArray *response = responseObject;
    
    NSMutableArray *tweets = [NSMutableArray array];
    
    
    //create tweet message models from respons if available
    for (NSDictionary *tweetInfo in response)
    {
        SSTwitt *tweet = [[SSTwitt alloc] initWithDictionary:tweetInfo];
        [tweets addObject:tweet];
    }
    
    completion(tweets, nil);
}

//check if user is authorized
- (BOOL)isAuthorized
{
    return self.networkManager.authorized;
}
@end
