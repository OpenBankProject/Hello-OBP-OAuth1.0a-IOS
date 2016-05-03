//
//  AccountsViewController.m
//  HelloOBP-iOS
//
//  Created by Dunia Reviriego on 8/17/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import "AccountsViewController.h"

#import <STHTTPRequest/STHTTPRequest.h>
#import <OBPKit/OBPKit.h>
#import "DefaultServerDetails.h"

#import "MainViewController.h"
#import "DetailsViewController.h"

@interface AccountsViewController ()
{
    NSArray*		_accountsList;
}
@property (nonatomic, strong) NSDictionary* accountsDict;
@end

@implementation AccountsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableViewAccounts setDataSource:self];
    [self.tableViewAccounts setDelegate:self];
    
    self.navigationItem.title = @"Accounts";
    if (![[[UIDevice currentDevice] systemVersion] isEqualToString: @"6.1"]) {
    self.linkOBPwebsite.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.linkOBPwebsite.titleLabel.numberOfLines = 2;
    [self.linkOBPwebsite setTitle:@"Hello-OBP-OAuth1.0a is demo for app designers.\nTo find out more visit the Open Bank Project." forState:UIControlStateNormal];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationItem.backBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [UIFont fontWithName:@"STHeitiJ-Medium" size:12.0], NSFontAttributeName,
                                                                    [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                    nil] forState:UIControlStateNormal];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Accounts"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [backItem setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIFont fontWithName:@"STHeitiJ-Medium" size:13.0], NSFontAttributeName,
                                       [UIColor whiteColor], NSForegroundColorAttributeName,
                                       nil] forState:UIControlStateNormal];
    
    [self.navigationItem setBackBarButtonItem:backItem];
    }
    
    
    if (_accountsTypeToShow.selectedSegmentIndex == 0 ){
        [self.viewTable setHidden:NO];
        [self.viewJSON setHidden:YES];
    }
	else {
        [self.viewTable setHidden:YES];
        [self.viewJSON setHidden:NO];
    }

	[self fetchAccounts];
}

- (void)setAccountsDict:(NSDictionary*)accountsDict
{
	if (_accountsDict ? ![accountsDict isEqualToDictionary: _accountsDict] : !!accountsDict)
	{
		_accountsDict = accountsDict;
		_accountsList = accountsDict[@"accounts"];
		[self.tableViewAccounts reloadData];
		self.accountsJSON.text = [_accountsDict description];
	}
}

- (void)fetchAccounts
{
	OBPSession*		session = [OBPSession currentSession];
	NSString*		APIBase = session.serverInfo.APIBase;
	HandleOBPMarshalError errorHandler =
		^(NSError* error, NSString* path)
		{
			if (error.code == 404) // => optional call "accounts/private" is not supported on this server
				[self fetchAccountsByBank];
			else
				OBP_LOG(@"Request for resource at path %@ served by %@ got error %@", path, APIBase, error);
		};

	self.accountsDict = nil;

	[session.marshal getResourceAtAPIPath: @"accounts/private"
							  withOptions: @{OBPMarshalOptionExpectClass : [NSDictionary class],
											OBPMarshalOptionErrorHandler : errorHandler}
							   forHandler:
		^(id deserializedJSONObject, NSString* body) {
			self.accountsDict = deserializedJSONObject;
        }
	];
}

- (void)fetchAccountsByBank
{
	NSMutableArray*	bankIDs = [[_banksDict valueForKeyPath: @"banks.id"] mutableCopy];
	[self fetchPrivateAccountsForFirstOfBankIDs: bankIDs];
}

- (void)fetchPrivateAccountsForFirstOfBankIDs:(NSMutableArray*)bankIDs
{
	if (![bankIDs count])
		return;
	AccountsViewController __weak* self_ifStillHere = self;
	OBPSession*				session = [OBPSession currentSession];
	NSString*				APIBase = session.serverInfo.APIBase;
	NSString*				bankID = bankIDs[0]; [bankIDs removeObjectAtIndex: 0];
	NSString*				path = [NSString stringWithFormat: @"banks/%@/accounts/private", bankID];
	HandleOBPMarshalError	handleError =
		^(NSError* error, NSString* path)
		{
			OBP_LOG(@"Request for resource at path %@ served by %@ got error %@", path, APIBase, error);
			if (error.code == 404 || error.code == 204)
				[self_ifStillHere fetchPrivateAccountsForFirstOfBankIDs: bankIDs];
		};

	[session.marshal getResourceAtAPIPath: path
							  withOptions: @{OBPMarshalOptionExpectClass : [NSDictionary class],
											 OBPMarshalOptionErrorHandler : handleError}
							   forHandler:
		^(id deserializedJSONObject, NSString* body)
		{
			AccountsViewController*	avc = self_ifStillHere;
			if (avc == nil)
				return;
			NSDictionary*		accountsDict = deserializedJSONObject;
			NSArray*			accounts = accountsDict[@"accounts"];
			if ([accounts count])
			{
				NSArray*		array = avc.accountsDict[@"accounts"] ?: @[];
				accounts = [array arrayByAddingObjectsFromArray: accounts];
				avc.accountsDict = @{@"accounts" : accounts};
			}
			[avc fetchPrivateAccountsForFirstOfBankIDs: bankIDs];
        }
	];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)linkToOBPwebsite:(id)sender {
    [MainViewController linkToOBPwebsite: self];
}

- (IBAction)segmentedAccountsTypeToShow:(UISegmentedControl*)sender{
    
    if (_accountsTypeToShow.selectedSegmentIndex == 0) {
        [self.viewTable setHidden:NO];
        [self.viewJSON setHidden:YES];
        
    } else if(_accountsTypeToShow.selectedSegmentIndex == 1) {
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
    return _accountsList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell*	cell = [tableView dequeueReusableCellWithIdentifier: @"cell" forIndexPath: indexPath];
	NSDictionary*		account = _accountsList[indexPath.row];
	NSString*			accountID = account[@"id"];
	NSString*			bankID = account[@"bank_id"];
	NSDictionary*		bank = _banksDict[@"banksByID"][bankID];
	cell.textLabel.text = accountID;
	cell.detailTextLabel.text = [bank[@"short_name"] description];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary*		account = _accountsList[indexPath.row];
	NSString*			bank_id = account[@"bank_id"];
	NSString*			account_id = account[@"id"];
	NSArray*			views = account[@"views_available"];
	NSUInteger			viewIndex = 0;
	NSDictionary*		viewOfAccount = viewIndex < [views count] ? views[viewIndex] : nil;
	NSString*			view_id = viewOfAccount[@"id"];

	if (![bank_id length] || ![account_id length] || ![view_id length])
		return;

	NSString*			path = [NSString stringWithFormat: @"banks/%@/accounts/%@/%@/transactions", bank_id, account_id, view_id];

	[[OBPSession currentSession].marshal getResourceAtAPIPath: path
												  withOptions: @{OBPMarshalOptionExpectClass : [NSDictionary class]}
												   forHandler:
		^(id deserializedJSONObject, NSString* body) {
            DetailsViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailsViewController"];
            [dvc setAccount: account viewOfAccount: viewOfAccount transactionsDict: deserializedJSONObject];
            [self.navigationController pushViewController:dvc animated:YES];
        }
	];
}


/*#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"PrepareSegue");
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}*/


@end
