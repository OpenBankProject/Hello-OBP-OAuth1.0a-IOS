//
//  DetailsViewController.h
//  Hello-OBP-OAuth1.0a-IOS
//
//  Created by Dunia Reviriego on 8/15/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableViewTransactions;

@property (nonatomic, strong) NSString *JSON;
@property (nonatomic, strong) NSString *accountSelected;



@property (weak, nonatomic) IBOutlet UILabel *AccountID;
@property (weak, nonatomic) IBOutlet UITextView *transactionsJSON;
@property (strong, nonatomic) IBOutlet UIButton *linkOBPwebsite;
@property (weak, nonatomic) IBOutlet UIView *viewTable;
@property (weak, nonatomic) IBOutlet UIView *viewJSON;
@property (weak, nonatomic) IBOutlet UISegmentedControl *transactionsTypeToShow;

-(IBAction)segmentedTransactionsTypeToShow:(UISegmentedControl*)sender;

- (IBAction)linkToOBPwebsite:(id)sender;

@end
