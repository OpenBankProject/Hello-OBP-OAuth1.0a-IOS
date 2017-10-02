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
#import <OBPKit/OBPDateFormatter.h>



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
@property (nonatomic, strong, readwrite) NSArray* transactionsList;

@property (strong, nonatomic) IBOutlet UITableView *tableViewTransactions;
@property (weak, nonatomic) IBOutlet UILabel *AccountID;
@property (weak, nonatomic) IBOutlet UITextView *transactionsJSON;
@property (weak, nonatomic) IBOutlet UIView *viewTable;
@property (weak, nonatomic) IBOutlet UIView *viewJSON;
@property (weak, nonatomic) IBOutlet UISegmentedControl *transactionsTypeToShow;

- (IBAction)segmentedTransactionsTypeToShow:(UISegmentedControl*)sender;

@end



@implementation DetailsViewController
{
	NSDictionary*	_transactionToEdit;
}

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
	if (self.isViewLoaded)
	{
		self.AccountID.text = _account[@"id"];
		self.transactionsJSON.text = [_transactionsDict description];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableViewTransactions setDataSource:self];
    [self.tableViewTransactions setDelegate:self];
    
    self.navigationItem.title = @"Transactions";

	self.AccountID.text = _account[@"id"];
	self.transactionsJSON.text = [_transactionsDict description];

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
	TransactionTableCell*	ttc = [tableView dequeueReusableCellWithIdentifier: @"cell" forIndexPath: indexPath];
	NSDictionary*			transaction = _transactionsList[indexPath.row];
	NSString*				s;
	NSDate*					d;
	ttc.transactionValue.text = [(s = [transaction valueForKeyPath: @"details.value.amount"]) length] ? s : @"-";
	ttc.transactionCurrency.text = [(s = [transaction valueForKeyPath: @"details.value.currency"]) length] ? s : @"";
	if (![(s = [transaction valueForKeyPath: @"details.type"]) length])
	if (![(s = [transaction valueForKeyPath: @"details.label"]) length])
	if (![(s = [transaction valueForKeyPath: @"details.description"]) length])
		s = @"-";
	ttc.transactionType.text = s;
	ttc.otherAccountHolder.text = [(s = [transaction valueForKeyPath: @"other_account.holder.name"]) length] ? s : @"-";
	s = [transaction valueForKeyPath: @"details.completed"];
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
}

- (IBAction)unwindToDetailsViewController:(UIStoryboardSegue *)segue
{
}

@end
