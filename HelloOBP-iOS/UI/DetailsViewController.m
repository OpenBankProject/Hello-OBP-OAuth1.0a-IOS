//
//  DetailsViewController.m
//  HelloOBP-iOS
//
//  Created by Dunia Reviriego on 8/15/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import "DetailsViewController.h"
#import "MainViewController.h"
#import "TransactionDetailViewController.h"
#import "PaymentVC.h"
#import "JSONUnpackUtils.h"
#import <OBPKit/OBPKit.h>



@interface TransactionTableCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel* transactionValue;
@property (nonatomic, weak) IBOutlet UILabel* transactionCurrency;
@property (nonatomic, weak) IBOutlet UILabel* transactionType;
@property (nonatomic, weak) IBOutlet UILabel* otherAccountHolder;
@property (nonatomic, weak) IBOutlet UILabel* completionDate;
@end
@implementation TransactionTableCell
@end



#pragma mark -
@interface DetailsViewController ()

@property (nonatomic, strong, readwrite) NSDictionary* account;
@property (nonatomic, strong, readwrite) NSDictionary* viewOfAccount;
@property (nonatomic, strong, readwrite) NSDictionary* transactionsDict;
@property (nonatomic, strong, readwrite) NSDictionary* transPendingDict;
@property (nonatomic, strong, readwrite) NSArray* otherAccounts;

@property (strong, nonatomic) IBOutlet UITableView *tableViewTransactions;
@property (weak, nonatomic) IBOutlet UILabel *AccountID;
@property (weak, nonatomic) IBOutlet UITextView *transactionsJSON;
@property (weak, nonatomic) IBOutlet UIView *viewTable;
@property (weak, nonatomic) IBOutlet UIView *viewJSON;
@property (weak, nonatomic) IBOutlet UISegmentedControl *transactionsTypeToShow;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *transferBarButton;

- (IBAction)segmentedTransactionsTypeToShow:(UISegmentedControl*)sender;

@end



@implementation DetailsViewController
{
	NSDictionary*	_transactionToEdit;
	NSArray*		_transactionsList;
	NSArray*		_transPendingList;
	NSUInteger		sectionCount;
	NSUInteger		sectionIndex_pendingTransactions;
	NSUInteger		sectionIndex_completeTransactions;
}

- (void)setAccount:(NSDictionary*)account viewOfAccount:(NSDictionary*)viewOfAccount otherAccounts:(NSArray*)otherAccounts
{
	_account = account;
	_viewOfAccount = viewOfAccount;
	_otherAccounts = otherAccounts;
	[self updateContent];
}

- (void)configureSections
{
	sectionCount = 1;
	sectionIndex_pendingTransactions = (NSUInteger)-1;
	sectionIndex_completeTransactions = 0;
	if (_transPendingList.count)
	{
		sectionCount++;
		sectionIndex_pendingTransactions++;
		sectionIndex_completeTransactions++;
	}
}

- (void)updateJSONDisplay
{
	NSString*			pending = [_transPendingDict description] ?: @"-";
	NSString*			complete = [_transactionsDict description] ?: @"-";
	self.transactionsJSON.text =
		[NSString stringWithFormat:
			@"# Pending:\n%@\n# Completed:\n%@\n", pending, complete];
}

- (void)setTransactionsDict:(NSDictionary *)transactionsDict
{
	if (transactionsDict ? [_transactionsDict isEqualToDictionary: transactionsDict] : !_transactionsDict)
		return;
	_transactionsDict = [transactionsDict copy];
	_transactionsList = _transactionsDict[@"transactions"];
	self.transactionsJSON.text = [_transactionsDict description];
	[self configureSections];
	[self updateJSONDisplay];
	[self.tableViewTransactions reloadData];
}

- (void)setTransPendingDict:(NSDictionary *)transPendingDict
{
	if (transPendingDict ? [_transPendingDict isEqualToDictionary: transPendingDict] : !_transPendingDict)
		return;
	_transPendingDict = [transPendingDict copy];
	NSMutableArray* ma = [NSMutableArray array];
	for (NSDictionary* transactionRq in _transPendingDict[@"transaction_requests_with_charges"])
	{
		if ([transactionRq[@"status"] isEqual: @"COMPLETED"])
			continue;
		[ma addObject: transactionRq];
	}
	_transPendingList = [ma copy];
	[self configureSections];
	[self updateJSONDisplay];
	[self.tableViewTransactions reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableViewTransactions setDataSource:self];
    [self.tableViewTransactions setDelegate:self];
	[self configureSections];

    self.navigationItem.title = @"Transactions";

	self.transactionsJSON.text = [_transactionsDict description];

    if (_transactionsTypeToShow.selectedSegmentIndex == 0 ){
        [self.viewTable setHidden:NO];
        [self.viewJSON setHidden:YES];
    }
	else{
        
        [self.viewTable setHidden:YES];
        [self.viewJSON setHidden:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear: animated];
	[self updateContent];
}

- (void)updateContent
{
	if (!self.isViewLoaded || !_account)
		return;
	self.AccountID.text  = [_account salientStringAtKeyPath: @"label"]
						?: [_account salientStringAtKeyPath: @"number"]
						?: [_account salientStringAtKeyPath: @"id"]
						?: @"-";
	[self fetchCompletedTransactionsAndThen: ^{ [self fetchPendingTransactionsAndThen: ^{} ]; } ];
}

- (void)fetchCompletedTransactionsAndThen:(dispatch_block_t)completion
{
	NSString*			account_id = _account[@"id"];
	NSString*			bank_id = _account[@"bank_id"];
	NSString*			view_id = _viewOfAccount[@"id"];

	if (![bank_id length] || ![account_id length])
		return;

	if (view_id.length == 0)
		view_id = @"owner";

	NSString*			path = [[NSString stringWithFormat:
									@"banks/%@/accounts/%@/%@/transactions",
									bank_id, account_id, view_id]
								stringByAddingPercentEncodingWithAllowedCharacters:
									[NSCharacterSet URLPathAllowedCharacterSet]];
	OBPSession*				session = [OBPSession currentSession];
	HandleOBPMarshalError	errorHandler =
		^(NSError* error, NSString* path) {
			completion();
		};
	HandleOBPMarshalData	resultHandler =
		^(id deserializedObject, NSString* body) {
            self.transactionsDict = deserializedObject;
            completion();
        };

	[session.marshal getResourceAtAPIPath: path withOptions: nil
						 forResultHandler: resultHandler orErrorHandler: errorHandler];

}

- (void)fetchPendingTransactionsAndThen:(dispatch_block_t)completion
{
	NSString*			account_id = _account[@"id"];
	NSString*			bank_id = _account[@"bank_id"];
	NSString*			view_id = _viewOfAccount[@"id"];

	if (![bank_id length] || ![account_id length])
		return;

	if (view_id.length == 0)
		view_id = @"owner";

	if (![view_id isEqualToString: @"owner"])
		return; // transaction requests only visible in owner view

	NSString*			path = [[NSString stringWithFormat:
									@"banks/%@/accounts/%@/%@/transaction-requests",
									bank_id, account_id, view_id]
								stringByAddingPercentEncodingWithAllowedCharacters:
									[NSCharacterSet URLPathAllowedCharacterSet]];
	OBPSession*				session = [OBPSession currentSession];
	HandleOBPMarshalError	errorHandler =
		^(NSError* error, NSString* path)
		{
			completion();
		};
	HandleOBPMarshalData	resultHandler =
		^(id deserializedObject, NSString* body)
		{
            self.transPendingDict = deserializedObject;
			completion();
        };

	[session.marshal getResourceAtAPIPath: path withOptions: nil
						 forResultHandler: resultHandler orErrorHandler: errorHandler];

}


#pragma mark -

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
    return sectionCount;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (sectionCount == 1)
		return nil;
	if (section == sectionIndex_pendingTransactions)
		return @"Pending";
	if (section == sectionIndex_completeTransactions)
		return @"Completed";
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == sectionIndex_completeTransactions
    	 ? _transactionsList.count
    	 : _transPendingList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == sectionIndex_pendingTransactions)
	{
		TransactionTableCell*	ttc = [tableView dequeueReusableCellWithIdentifier: @"cell" forIndexPath: indexPath];
		NSDictionary*			transaction = _transPendingList[indexPath.row];
		NSString*				s;
		NSDate*					d;
		ttc.transactionValue.text = [transaction salientStringAtKeyPath: @"charge.value.amount"] ?: @"-";
		ttc.transactionCurrency.text = [transaction salientStringAtKeyPath: @"charge.value.currency"] ?: @"";
		ttc.transactionType.text = [transaction salientStringAtKeyPath: @"details.type"]
								?: [transaction salientStringAtKeyPath: @"details.label"]
								?: [transaction salientStringAtKeyPath: @"details.description"]
								?: @"-";
		ttc.otherAccountHolder.text = [transaction salientStringAtKeyPath: @"counterparty.holder.name"]
							 		?: [transaction salientStringAtKeyPath: @"from.account_id"]
							 		?: @"-";
		s = [transaction salientStringAtKeyPath: @"end_date"]
		 ?: [transaction salientStringAtKeyPath: @"start_date"]
		 ?: @"";
		if (nil != (d = [OBPDateFormatter dateFromString: s]))
		{
			BOOL includeTime = 0 != fmod([d timeIntervalSinceReferenceDate], 1);
			s = [NSDateFormatter localizedStringFromDate: d
											   dateStyle: NSDateFormatterMediumStyle
											   timeStyle: includeTime ? NSDateFormatterShortStyle
																	  : NSDateFormatterNoStyle];
		}
		ttc.completionDate.text = [s length] ? s : @"-";
		return ttc;
	}

	TransactionTableCell*	ttc = [tableView dequeueReusableCellWithIdentifier: @"cell" forIndexPath: indexPath];
	NSDictionary*			transaction = _transactionsList[indexPath.row];
	NSString*				s;
	NSDate*					d;
	ttc.transactionValue.text = [transaction salientDescriptionAtKeyPath: @"details.value.amount"] ?: @"-";
	ttc.transactionCurrency.text = [transaction salientStringAtKeyPath: @"details.value.currency"] ?: @"-";
	ttc.transactionType.text = [transaction salientStringAtKeyPath: @"details.type"]
							?: [transaction salientStringAtKeyPath: @"details.label"]
							?: [transaction salientStringAtKeyPath: @"details.description"]
							?: @"-";
	ttc.otherAccountHolder.text = [transaction salientStringAtKeyPath: @"other_account.holder.name"]
								?: [transaction salientStringAtKeyPath: @"counterparty.holder.name"]
								?: @"-";
	s = [transaction salientStringAtKeyPath: @"details.completed"];
	if (nil != (d = [OBPDateFormatter dateFromString: s]))
	{
		BOOL includeTime = 0 != fmod([d timeIntervalSinceReferenceDate], 1);
		s = [NSDateFormatter localizedStringFromDate: d
										   dateStyle: NSDateFormatterMediumStyle
										   timeStyle: includeTime ? NSDateFormatterShortStyle
																  : NSDateFormatterNoStyle];
	}
	ttc.completionDate.text = [s length] ? s : @"-";
	return ttc;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary*		transaction = _transactionsList[indexPath.row];
	_transactionToEdit = transaction;
    [self performSegueWithIdentifier: @"TransactionDetail" sender: self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.destinationViewController isKindOfClass: [TransactionDetailViewController class]])
	{
		TransactionDetailViewController* tdvc = (TransactionDetailViewController*)segue.destinationViewController;
		[tdvc setAccount: _account viewOfAccount: _viewOfAccount transaction: _transactionToEdit];
	}
	else
	if ([segue.destinationViewController isKindOfClass: [PaymentVC class]])
	{
		PaymentVC* payVC = segue.destinationViewController;
		[payVC setAccount: self.account
			viewOfAccount: self.viewOfAccount
			otherAccounts: self.otherAccounts];
		payVC.banks = self.banks;
	}
}

- (IBAction)unwindToDetailsViewController:(UIStoryboardSegue *)segue
{
}

@end
