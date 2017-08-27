//
//  SSTwitt.h
//  OAuthTest
//
//  Created by sergey on 8/8/17.
//  Copyright © 2017 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSTwitt : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *tweetText;
@property (nonatomic, strong) NSNumber *twittID;

- (id)initWithDictionary:(NSDictionary *)tweetInfo;


@end
