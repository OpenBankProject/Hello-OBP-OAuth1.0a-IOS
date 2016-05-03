//
//  AccountsViewController.h
//  HelloOBP-iOS
//
//  Created by Dunia Reviriego on 8/17/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableViewAccounts;

@property (strong, nonatomic) IBOutlet UIButton *linkOBPwebsite;
@property (strong, nonatomic) IBOutlet UIView *viewTable;
@property (strong, nonatomic) IBOutlet UIView *viewJSON;
@property (weak, nonatomic) IBOutlet UITextView *accountsJSON;

@property (weak, nonatomic) IBOutlet UISegmentedControl *accountsTypeToShow;

-(IBAction)segmentedAccountsTypeToShow:(UISegmentedControl*)sender;

- (IBAction)linkToOBPwebsite:(id)sender;
@property (nonatomic, strong) NSDictionary* banksDict;

@end
