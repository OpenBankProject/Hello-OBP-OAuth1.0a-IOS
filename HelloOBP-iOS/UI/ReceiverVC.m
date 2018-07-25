//
//  ReceiverVC.m
//  HelloOBP-iOS
//
//  Created by Torsten Louland on 03/10/2017.
//  Copyright © 2017 TESOBE. All rights reserved.
//

#import "ReceiverVC.h"
#import "JSONUnpackUtils.h"



@interface ReceiverVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UISegmentedControl *homeOrAwayControl;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL showHomeAccounts;
@end



@implementation ReceiverVC
{
	NSDictionary*		_fromAccount;
	NSDictionary*		_viewOfAccount;
	NSArray*			_homeAccounts;
	NSArray*			_awayAccounts;

	NSDictionary*		_receiverAccount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setAccount:(NSDictionary*)account viewOfAccount:(NSDictionary*)viewOfAccount myOtherAccounts:(NSArray*)otherAccounts
{
	_fromAccount = [account copy];
	_viewOfAccount = [viewOfAccount copy];
	_homeAccounts = [otherAccounts copy];
	_awayAccounts = @[];
}

- (BOOL)showHomeAccounts
{
	return 0 == _homeOrAwayControl.selectedSegmentIndex;
}

- (void)setShowHomeAccounts:(BOOL)showHomeAccounts
{
	if (self.showHomeAccounts == showHomeAccounts)
		return;
	_homeOrAwayControl.selectedSegmentIndex = showHomeAccounts ? 0 : 1;
	[_tableView reloadData];
}

- (void)setReceiverAccount:(NSDictionary*)receiverAccount
{
	if (receiverAccount ? [_receiverAccount isEqual: receiverAccount] : !_receiverAccount)
		return;
	BOOL home = YES;
	_receiverAccount = receiverAccount;
	if (_receiverAccount && NSNotFound != [_awayAccounts indexOfObject: _receiverAccount])
		home = NO;
	_homeOrAwayControl.selectedSegmentIndex = home ? 0 : 1;
	[_tableView reloadData];
}

- (IBAction)homeOrAwayControlHit:(id)sender
{
	[_tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray*			accounts = self.showHomeAccounts ? _homeAccounts : _awayAccounts;
	return [accounts count];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
	BOOL				home = self.showHomeAccounts;
	UITableViewCell*	cell = [tableView dequeueReusableCellWithIdentifier: home ? @"homeAccountCell" : @"awayAccountCell"];
	NSArray*			accounts = home ? _homeAccounts : _awayAccounts;
	NSDictionary*		account = accounts[indexPath.row];

	NSString*			bankID = account[@"bank_id"];
	if (bankID && [_fromAccount[@"bank_id"] isEqualToString: bankID])
		bankID = nil;
	NSDictionary*		bank = bankID ? _banks[@"banksByID"][bankID] : nil;
	NSString*			bankName = [bank salientDescriptionAtKeyPath: @"short_name"];

	NSString*			accountName = [account salientDescriptionAtKeyPath: @"label"];
	NSString*			accountNumber = [account salientDescriptionAtKeyPath: @"number"];
	NSString*			accountID = [account salientDescriptionAtKeyPath: @"id"];

	NSString*			accountDesc;
	NSString*			accountSub = nil;
	accountDesc = accountName ?: accountNumber ?: accountID;
	if (accountName && accountName != accountDesc)
		accountSub = accountName;
	if (bankName)
		accountSub = accountSub ? [accountSub stringByAppendingFormat: @", %@", bankName] : bankName;

	cell.textLabel.text = accountDesc;
	cell.detailTextLabel.text = accountSub;
	cell.selected = [account isEqual: _receiverAccount];

	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL				home = self.showHomeAccounts;
	NSArray*			accounts = home ? _homeAccounts : _awayAccounts;
	NSDictionary*		account = accounts[indexPath.row];
	self.receiverAccount = account;
	[_client receiverVC: self didChooseReceiverAccount: account];
}

@end
