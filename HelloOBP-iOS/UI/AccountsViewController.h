//
//  AccountsViewController.h
//  HelloOBP-iOS
//
//  Created by Dunia Reviriego on 8/17/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSDictionary* banksDict;

@end
