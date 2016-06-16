//
//  TransactionDetailViewController.m
//  HelloOBP-iOS
//
//  Created by Torsten Louland on 03/05/2016.
//  Copyright © 2016 TESOBE. All rights reserved.
//

#import "TransactionDetailViewController.h"
//
#include <OBPKit/OBPKit.h>
#include "MainViewController.h"



typedef NS_ENUM(uint8_t, FieldType)
{ eFieldType_Text, eFieldType_Date, eFieldType_Amount, eFieldType_Currency, };

NSString*
LabelTextFrom(NSDictionary* dict, NSString* path, FieldType ft, NSString* dflt)
{
	NSString*		labelText = @"";
	id				value = [dict valueForKeyPath: path];
	id				obj;
	NSString*		valueString = @"";
	const char*		sep = "";
	NSDate*			date;
	BOOL			includeTime;
	if ([value isKindOfClass: [NSArray class]])
	{
		for (obj in value)
			valueString = [valueString stringByAppendingFormat: @"%s%@", sep, [obj description]], sep = ", ";
	}
	else
		valueString = [value description];
	valueString = [valueString stringByReplacingOccurrencesOfString: @"<null>" withString: @""];
	switch (ft)
	{
		case eFieldType_Text:
		case eFieldType_Amount:
		case eFieldType_Currency:
			labelText = [valueString length] ? valueString : dflt;
			break;
		case eFieldType_Date:
			if (nil != (date = [OBPDateFormatter dateFromString: valueString]))
			{
				includeTime = 0 != fmod([date timeIntervalSinceReferenceDate], 1);
				valueString = [NSDateFormatter localizedStringFromDate: date
															 dateStyle: NSDateFormatterMediumStyle
															 timeStyle: includeTime ? NSDateFormatterShortStyle
																					: NSDateFormatterNoStyle];
			}
			labelText = [valueString length] ? valueString : dflt;
			break;
	}
	return labelText;
}



#pragma mark -
@interface TransactionDetailViewController ()
{
	NSDictionary*	_account;
	NSDictionary*	_viewOfAccount;
	NSDictionary*	_transaction;
}

@property (nonatomic, weak) IBOutlet UILabel* this_account_id_label;
@property (nonatomic, weak) IBOutlet UILabel* this_account_number_label;
@property (nonatomic, weak) IBOutlet UILabel* this_account_holder_names_label;
@property (nonatomic, weak) IBOutlet UILabel* this_account_bank_name_label;

@property (nonatomic, weak) IBOutlet UILabel* details_type_label;
@property (nonatomic, weak) IBOutlet UILabel* details_description_label; // label pre v1.2.1
@property (nonatomic, weak) IBOutlet UILabel* details_posted_label;
@property (nonatomic, weak) IBOutlet UILabel* details_completed_label;
@property (nonatomic, weak) IBOutlet UILabel* details_new_balance_amount_label;
@property (nonatomic, weak) IBOutlet UILabel* details_value_amount_label;
@property (nonatomic, weak) IBOutlet UILabel* details_value_currency_label;

@property (nonatomic, weak) IBOutlet UILabel* other_account_id_label;
@property (nonatomic, weak) IBOutlet UILabel* other_account_number_label;
@property (nonatomic, weak) IBOutlet UILabel* other_account_holder_name_label;
@property (nonatomic, weak) IBOutlet UILabel* other_account_bank_name_label;

@property (nonatomic, weak) IBOutlet UILabel* metadata_narrative_label;

@end



#pragma mark -
@implementation TransactionDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self loadLabels];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear: animated];
}

- (void)setAccount:(NSDictionary*)account viewOfAccount:(NSDictionary*)viewOfAccount transaction:(NSDictionary*)transaction
{
	_account = account;
	_viewOfAccount = viewOfAccount;
	_transaction = transaction;
	if (self.isViewLoaded)
		[self loadLabels];
}

- (void)loadLabels
{
	NSString		*s1, *s2, *keyPath;
	CGFloat			minorVersion;

	s1 = [OBPSession currentSession].serverInfo.APIVersion; // v1.1, v1.2, v1.2.1, v1.3, etc
	s1 = [s1 substringFromIndex: [s1 rangeOfString: @"."].location]; // strip off v1
	minorVersion = [s1 floatValue];

	self.this_account_id_label.text = LabelTextFrom(_transaction, @"this_account.id", eFieldType_Text, @"-");
	self.this_account_number_label.text = LabelTextFrom(_transaction, @"this_account.number", eFieldType_Text, @"-");
	self.this_account_holder_names_label.text = LabelTextFrom(_transaction, @"this_account.holders.name", eFieldType_Text, @"-");
	self.this_account_bank_name_label.text = LabelTextFrom(_transaction, @"this_account.bank.name", eFieldType_Text, @"-");

	self.details_type_label.text = LabelTextFrom(_transaction, @"details.type", eFieldType_Text, nil);
	keyPath = minorVersion >= 2.1 ? @"details.description" :  @"details.label";
	self.details_description_label.text = LabelTextFrom(_transaction, keyPath, eFieldType_Text, nil);
	self.details_posted_label.text = s1 = LabelTextFrom(_transaction, @"details.posted", eFieldType_Date, nil);
	self.details_completed_label.text = s2 = LabelTextFrom(_transaction, @"details.completed", eFieldType_Date, nil);
	if (s1 && s2 && [s1 isEqualToString: s2])
		self.details_posted_label.text = nil; // only show posted if its different from completed
	self.details_new_balance_amount_label.text = LabelTextFrom(_transaction, @"details.new_balance.amount", eFieldType_Amount, @"0");
	self.details_value_amount_label.text = LabelTextFrom(_transaction, @"details.value.amount", eFieldType_Amount, nil);
	self.details_value_currency_label.text = LabelTextFrom(_transaction, @"details.value.currency", eFieldType_Text, nil);

	self.other_account_id_label.text = LabelTextFrom(_transaction, @"other_account.id", eFieldType_Text, @"-");
	self.other_account_number_label.text = LabelTextFrom(_transaction, @"other_account.number", eFieldType_Text, @"-");
	self.other_account_holder_name_label.text = LabelTextFrom(_transaction, @"other_account.holder.name", eFieldType_Text, @"-");
	self.other_account_bank_name_label.text = LabelTextFrom(_transaction, @"other_account.bank.name", eFieldType_Text, @"-");

	self.metadata_narrative_label.text = LabelTextFrom(_transaction, @"metadata.narrative", eFieldType_Text, @"-");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if (segue.destinationViewController == self.parentViewController)
	{
	}
}

- (IBAction)linkToWebsites:(id)sender
{
    [MainViewController linkToOBPwebsite: self];
}

@end



