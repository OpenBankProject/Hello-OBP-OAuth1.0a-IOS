//
//  DetailsViewController.h
//  HelloOBP-iOS
//
//  Created by Dunia Reviriego on 8/15/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableViewTransactions;
- (void)setAccount:(NSDictionary*)account viewOfAccount:(NSDictionary*)viewOfAccount transactionsDict:(NSDictionary*)transactionsDict;

@property (weak, nonatomic) IBOutlet UILabel *AccountID;
@property (weak, nonatomic) IBOutlet UITextView *transactionsJSON;
@property (strong, nonatomic) IBOutlet UIButton *linkOBPwebsite;
@property (weak, nonatomic) IBOutlet UIView *viewTable;
@property (weak, nonatomic) IBOutlet UIView *viewJSON;
@property (weak, nonatomic) IBOutlet UISegmentedControl *transactionsTypeToShow;

-(IBAction)segmentedTransactionsTypeToShow:(UISegmentedControl*)sender;

- (IBAction)linkToOBPwebsite:(id)sender;
@property (nonatomic, strong, readonly) NSDictionary* account;
@property (nonatomic, strong, readonly) NSDictionary* viewOfAccount;
@property (nonatomic, strong, readonly) NSDictionary* transactionsDict;

@end
