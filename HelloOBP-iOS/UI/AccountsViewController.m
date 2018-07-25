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
#import "JSONUnpackUtils.h"



@interface AccountCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *sub;
@property (weak, nonatomic) IBOutlet UILabel *balance;
@property (weak, nonatomic) IBOutlet UILabel *currency;
@end



@implementation AccountCell
@end




@interface AccountsViewController ()
{
	NSArray*		_accountIDs;
	NSDictionary*	_accountByID;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewAccounts;
@property (strong, nonatomic) IBOutlet UIView *viewTable;
@property (strong, nonatomic) IBOutlet UIView *viewJSON;
@property (weak, nonatomic) IBOutlet UITextView *accountsJSON;
@property (weak, nonatomic) IBOutlet UISegmentedControl *accountsTypeToShow;
- (IBAction)segmentedAccountsTypeToShow:(UISegmentedControl*)sender;

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
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationItem.backBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [UIFont fontWithName:@"HeveticaNeue-Medium" size:12.0], NSFontAttributeName,
                                                                    [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                    nil] forState:UIControlStateNormal];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Accounts"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [backItem setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIFont fontWithName:@"HeveticaNeue-Medium" size:13.0], NSFontAttributeName,
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

- (void)addAccount:(NSDictionary*)account
{
	NSMutableArray*			ma = [(_accountIDs ?: @[]) mutableCopy];
	NSMutableDictionary*	md = [(_accountByID ?: @{}) mutableCopy];
	NSString*				accID = account[@"id"];
	if (accID.length && ![ma containsObject: accID])
	{
		[ma addObject: accID];
		md[accID] = account;
		_accountIDs = [ma copy];
		_accountByID = [md copy];
		[self.tableViewAccounts reloadData];
	}
}

- (void)fetchAccounts
{
	OBPSession*				session = [OBPSession currentSession];
	NSString*				APIBase = session.serverInfo.APIBase;
	HandleOBPMarshalError	errorHandler =
		^(NSError* error, NSString* path)
		{
			if (error.code == 404) // => optional call "accounts/private" is not supported on this server
				[self fetchAccountsByBank];
			else
				OBP_LOG(@"Request for resource at path %@ served by %@ got error %@", path, APIBase, error);
		};
	HandleOBPMarshalData	resultHandler =
		^(id deserializedObject, NSString* body)
		{
//	old accounts/private result...
//			NSDictionary* accounts = deserializedObject;
//			self.accountsDict = @{@"accounts" : accounts};
		//	Fix: [
			/*	Originally there used to be a JSON Object (i.e. dictionary) at the root of all responses, and in the case of fetch accounts, it would contain a single key "accounts" with an array of account entries as its value - all good. At some point, the server started returning the array as athe root object, so we adapted. Now that original behaviour has been restored, we have to cater for both. */
		//	NSArray* accounts = deserializedObject;
			NSArray*	accounts = @[];
			NSObject*	obj = deserializedObject;
			if ([obj isKindOfClass: [NSDictionary class]])
			{
				NSDictionary* dict = (NSDictionary*)obj;
				obj = dict[@"accounts"];
			}
			if ([obj isKindOfClass: [NSArray class]])
				accounts = (NSArray*)obj;
		//  ]
			self.accountsJSON.text = [accounts description];
			[self fetchDetailsForFirstOfAccounts: [accounts mutableCopy]];
        };

	_accountByID = nil;
	_accountIDs = nil;
	[self.tableViewAccounts reloadData];

//	old...
//	NSString*		path = @"accounts/private";
//	NSDictionary*	options = nil;
	NSString*		path = @"my/accounts";
//	Fix: [
	// Originally we expected a dictionary (default, => options=nil), then we expect an array...
//	NSDictionary*	options = @{OBPMarshalOptionExpectClass : [NSArray class]};
	// ...but now it could be either, so indicate no expectation:
	NSDictionary*	options = @{OBPMarshalOptionExpectClass : [NSNull null]};
//	]
	[session.marshal getResourceAtAPIPath: path withOptions: options
						 forResultHandler: resultHandler orErrorHandler: errorHandler];
}

- (void)fetchAccountsByBank
{
	NSMutableArray*	bankIDs = [[_banks valueForKeyPath: @"banks.id"] mutableCopy];
	[self fetchAccountsWithQualifier: @"/private" forFirstOfBankIDs: bankIDs];
}

- (void)fetchAccountsWithQualifier:(NSString*)qualifier forFirstOfBankIDs:(NSMutableArray*)bankIDs
{
	if (![bankIDs count])
		return;
	AccountsViewController __weak* self_ifStillHere = self;
	OBPSession*				session = [OBPSession currentSession];
	NSString*				APIBase = session.serverInfo.APIBase;
	NSString*				bankID = bankIDs[0]; [bankIDs removeObjectAtIndex: 0];
	NSString*				path = [NSString stringWithFormat: @"banks/%@/accounts%@", bankID, qualifier?:@""];
	path = [path stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLPathAllowedCharacterSet]];
	HandleOBPMarshalError	errorHandler =
		^(NSError* error, NSString* path)
		{
			OBP_LOG(@"Request for resource at %@/%@ got error %@", APIBase, path, error);
			if (error.code == 404 || error.code == 204)
			{
				[bankIDs insertObject: bankID atIndex: 0];
				[self_ifStillHere fetchAccountsWithQualifier: nil forFirstOfBankIDs: bankIDs];
			}
		};
	HandleOBPMarshalData	resultHandler =
		^(id deserializedObject, NSString* body)
		{
			AccountsViewController*	avc = self_ifStillHere;
			if (avc == nil)
				return;
			NSDictionary*		accountsDict = nil;
			NSArray*			accounts = nil;
			if ([deserializedObject isKindOfClass: [NSDictionary class]])
				accountsDict = deserializedObject, accounts = accountsDict[@"accounts"];
			else
			if ([deserializedObject isKindOfClass: [NSArray class]])
				accounts = deserializedObject, accountsDict = @{@"accounts" : accounts};
			[avc fetchDetailsForFirstOfAccounts: [accounts mutableCopy]];
			[avc fetchAccountsWithQualifier: qualifier forFirstOfBankIDs: bankIDs];
        };

	NSDictionary*			options = @{
		OBPMarshalOptionExpectClass : [NSNull null]
		// ...v2.0.0 breaks with past and returns an array instead of a dictionary so compatibility with both we can't assume the container class
	};

	[session.marshal getResourceAtAPIPath: path withOptions: options
						 forResultHandler: resultHandler orErrorHandler: errorHandler];
}

- (void)fetchDetailsForFirstOfAccounts:(NSMutableArray*)accounts
{
	if (![accounts count])
		return;
	AccountsViewController __weak* self_ifStillHere = self;
	OBPSession*				session = [OBPSession currentSession];
	NSString*				APIBase = session.serverInfo.APIBase;
	NSDictionary*			account = accounts[0]; [accounts removeObjectAtIndex: 0];
	NSString*				bankID = account[@"bank_id"];
	NSString*				accountID = account[@"id"];
	NSString*				path = [NSString stringWithFormat: @"my/banks/%@/accounts/%@/account", bankID, accountID];
//	...is equivalent to using "owner" view in any endpoint that relates to accounts...
//	NSString*				path = [NSString stringWithFormat: @"banks/%@/accounts/%@/owner/account", bankID, accountID];
	path = [path stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLPathAllowedCharacterSet]];
	HandleOBPMarshalError	errorHandler =
		^(NSError* error, NSString* path)
		{
			OBP_LOG(@"Request for resource at %@/%@ got error %@", APIBase, path, error);
			[self_ifStillHere fetchDetailsForFirstOfAccounts: accounts];
		};
	HandleOBPMarshalData	resultHandler =
		^(id deserializedObject, NSString* body)
		{
			AccountsViewController*	avc = self_ifStillHere;
			if (avc == nil)
				return;
			NSDictionary*		accountDict = nil;
			if ([deserializedObject isKindOfClass: [NSDictionary class]])
			{
				accountDict = deserializedObject;
				[self addAccount: accountDict];
			}
			[avc fetchDetailsForFirstOfAccounts: accounts];
        };

	[session.marshal getResourceAtAPIPath: path withOptions: nil
						 forResultHandler: resultHandler orErrorHandler: errorHandler];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return _accountByID.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	AccountCell*		cell = [tableView dequeueReusableCellWithIdentifier: @"accountCell" forIndexPath: indexPath];
	NSString*			accountID = _accountIDs[indexPath.row];
	NSDictionary*		account = _accountByID[accountID];
	NSString*			bankID = account[@"bank_id"];
	NSDictionary*		bank = _banks[@"banksByID"][bankID];

	NSArray*			a = @[];
	for (NSString* k in @[@"label", @"number", @"id"]) {
		NSString* s = [account salientStringAtKeyPath: k];
		if (nil != s) a = [a arrayByAddingObject: s];
	}

	cell.title.text  = [a firstObject] ?: @"-";
	NSString* s0 = [a count] > 1 ? a[1] : nil;
	NSString* s1 = [bank salientStringAtKeyPath: @"full_name"];
	cell.sub.text = s0 && s1 ? [s0 stringByAppendingFormat: @" @ %@", s1]
				  : s0 ? s0
				  : s1 ? s1
				  : @"";
	cell.balance.text = [account salientStringAtKeyPath: @"balance.amount"] ?: @"";
	cell.currency.text = [account salientStringAtKeyPath: @"balance.currency"] ?: @"EUR";
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString*			account_id = _accountIDs[indexPath.row];
	NSDictionary*		account = _accountByID[account_id];
	NSString*			bank_id = account[@"bank_id"];
	if (![bank_id length] || ![account_id length])
		return;
	NSArray*			views = account[@"views_available"];
	NSDictionary*		viewOfAccount;
	NSDictionary*		bestView = nil;
	NSUInteger			viewIndex = 0;
	NSUInteger			bestViewIndex = -1;

	for (viewOfAccount in views)
	{
		if (bestView == nil
		 || [viewOfAccount[@"id"] isEqualToString: @"owner"]
		 || ([bestView[@"is_public"] boolValue] && ![viewOfAccount[@"is_public"] boolValue]))
		{
			bestView = viewOfAccount;
			bestViewIndex = viewIndex;
		}
		viewIndex++;
	}

	NSMutableArray* ma = [NSMutableArray array];
	for (NSString* otherAccountID in _accountByID) {
		NSDictionary* otherAccount = _accountByID[otherAccountID];
		if (!otherAccount || [otherAccountID isEqualToString: account_id])
			continue;
		[ma addObject: otherAccount];
	}
	NSArray* others = [ma copy];

	DetailsViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier: @"DetailsViewController"];
	[dvc setAccount: account viewOfAccount: bestView otherAccounts: others];
	dvc.banks = _banks;
	[self.navigationController pushViewController:dvc animated:YES];
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
