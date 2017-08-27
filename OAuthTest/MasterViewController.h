//
//  MasterViewController.h
//  OAuthTest
//
//  Created by sergey on 8/8/17.
//  Copyright © 2017 sergey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSTwitterAPIClient.h"

@interface MasterViewController : UITableViewController<SSTwitterLoginProtocol, UIScrollViewDelegate>

@end

