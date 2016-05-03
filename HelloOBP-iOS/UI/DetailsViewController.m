//
//  DetailsViewController.m
//  HelloOBP-iOS
//
//  Created by Dunia Reviriego on 8/15/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()

@property (nonatomic, strong, readwrite) NSDictionary* account;
@property (nonatomic, strong, readwrite) NSDictionary* viewOfAccount;
@property (nonatomic, strong, readwrite) NSDictionary* transactionsDict;
@property (nonatomic, strong, readwrite) NSArray* transactionsList;

@end

@implementation DetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
            }
    return self;
}

- (void)setAccount:(NSDictionary*)account viewOfAccount:(NSDictionary*)viewOfAccount transactionsDict:(NSDictionary*)transactionsDict
{
	_account = account;
	_viewOfAccount = viewOfAccount;
	_transactionsDict = transactionsDict;
	_transactionsList = transactionsDict[@"transactions"];
    self.AccountID.text = _account[@"id"];
    self.transactionsJSON.text = [_transactionsDict description];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableViewTransactions setDataSource:self];
    [self.tableViewTransactions setDelegate:self];
    
    self.navigationItem.title = @"Transactions";

    if (![[[UIDevice currentDevice] systemVersion] isEqualToString: @"6.1"]) {
    self.linkOBPwebsite.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.linkOBPwebsite.titleLabel.numberOfLines = 2;
    [self.linkOBPwebsite setTitle:@"Hello-OBP-OAuth1.0a is demo for app designers.\nTo find out more visit the Open Bank Project." forState:UIControlStateNormal];
    }
    
    if (_transactionsList.count == 0){
        _transactionsTypeToShow.selectedSegmentIndex = 1;
    }
    
    if (_transactionsTypeToShow.selectedSegmentIndex == 0 ){
        [self.viewTable setHidden:NO];
        [self.viewJSON setHidden:YES];
    }
	else{
        
        [self.viewTable setHidden:YES];
        [self.viewJSON setHidden:NO];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)linkToOBPwebsite:(id)sender {
    
    UIAlertView *message1 = [[UIAlertView alloc] initWithTitle:@"Open Bank Project"
                                                       message:@"You are leaving the app demo to go the OBP websites."
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"www.openbankproject.com", @"www.tesobe.com", @"github/openbankproject", @"Readme (with users)", nil];
    [message1 show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"www.openbankproject.com"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://openbankproject.com/en/about/"]];
    }
    else if
        ([title isEqualToString:@"www.tesobe.com"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://tesobe.com/en/projects/open-bank-project/"]];
    }
    else if
        ([title isEqualToString:@"github/openbankproject"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.github.com/OpenBankProject"]];
    }
    else if
        ([title isEqualToString:@"Readme (with users)"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/OpenBankProject/Hello-OBP-OAuth1.0a-IOS/blob/master/README.md#login-credentials"]];
    }
    
}

- (IBAction)segmentedTransactionsTypeToShow:(UISegmentedControl*)sender{
    
    if (_transactionsTypeToShow.selectedSegmentIndex == 0) {
        [self.viewTable setHidden:NO];
        [self.viewJSON setHidden:YES];
    }
    else if (_transactionsTypeToShow.selectedSegmentIndex == 1) {
        [self.viewTable setHidden:YES];
        [self.viewJSON setHidden:NO];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _transactionsList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell*	cell = [tableView dequeueReusableCellWithIdentifier: @"cell" forIndexPath: indexPath];
	NSDictionary*		transaction = _transactionsList[indexPath.row];
	NSString*			counterParty = [transaction valueForKeyPath: @"other_account.holder.name"];
	NSString*			completed = [transaction valueForKeyPath: @"details.completed"];
	cell.textLabel.text = counterParty;
	cell.detailTextLabel.text = completed;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected row: %li", (long)indexPath.row);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
