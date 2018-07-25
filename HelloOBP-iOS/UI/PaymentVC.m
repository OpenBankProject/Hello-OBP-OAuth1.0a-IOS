//
//  PaymentVC.m
//  HelloOBP-iOS
//
//  Created by Torsten Louland on 02/10/2017.
//  Copyright © 2017 TESOBE. All rights reserved.
//

#import "PaymentVC.h"
#import "ReceiverVC.h"
#import "JSONUnpackUtils.h"
#import <OBPKit/OBPKit.h>



enum {
	kSection_Sender = 0,
	kSection_Recipient,
	kSection_Amount,
	kSection_Message,
	kSection_count
};



@interface AmountCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@end;



@implementation AmountCell
@end;



@interface MessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@end;



@implementation MessageCell
- (CGFloat)messageTextViewHeightToFit
{
	UITextView*			mtv = _messageTextView;
	NSAttributedString*	at = mtv.attributedText;
	UIEdgeInsets		insets = mtv.textContainerInset;
						insets.left += mtv.textContainer.lineFragmentPadding;
						insets.right += mtv.textContainer.lineFragmentPadding;
	UIEdgeInsets		outsets = { .top = -insets.top, .left = -insets.left,
									.bottom = -insets.bottom, .right = -insets.right};
	CGRect				boundsCur = mtv.bounds;
	CGRect				textAreaCur = UIEdgeInsetsInsetRect(boundsCur, insets);
	CGSize				available = { textAreaCur.size.width, 1e5 };
	CGRect				textAreaNew = [at boundingRectWithSize: available
													   options: NSStringDrawingUsesLineFragmentOrigin
													   context: nil];
	CGFloat				heightToFit = UIEdgeInsetsInsetRect(textAreaNew, outsets).size.height;
	CGFloat				scale = [UIScreen mainScreen].scale;
	heightToFit = ceil(heightToFit * scale) / scale;
	return heightToFit;
}
@end;



@interface PaymentVC () <UITableViewDelegate, UITableViewDataSource, ChooseReceiverClient, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapRecogniser;
@property (weak, nonatomic) IBOutlet UIButton *makePaymentButton;
@property (weak, nonatomic) IBOutlet UIView *makePaymentBorderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *processingCluster;
@property (assign, nonatomic) BOOL processingPayment;
@property (weak, nonatomic) IBOutlet UILabel *paymentConfirmationLabel;

@property (weak, nonatomic) UIResponder *activeEditor;
@property (assign, nonatomic) BOOL needToAdjustHeight;

@property (weak, nonatomic) MessageCell* messageCell;
@property (assign, nonatomic) CGFloat messageRowHeight;

@end



@implementation PaymentVC
{
	NSDictionary*		_account;
	NSDictionary*		_viewOfAccount;
	NSArray*			_otherAccounts;

	NSDictionary*		_recipientAccount;
	NSNumber*			_amount;
	NSNumberFormatter*	_amountFormatter;

	NSString*			_message;
	CGFloat				_messageTextToRowHeight;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self enableMakePayment];
}

- (void)setAccount:(NSDictionary*)account viewOfAccount:(NSDictionary*)viewOfAccount otherAccounts:(NSArray*)otherAccounts
{
	_account = [account copy];
	_viewOfAccount = [viewOfAccount copy];
	_otherAccounts = [otherAccounts copy];

	_amountFormatter = [[NSNumberFormatter alloc] init];
	_amountFormatter.numberStyle = NSNumberFormatterDecimalStyle;
	_amountFormatter.minimumFractionDigits = 0;
	_amountFormatter.maximumFractionDigits = 2;
	_amountFormatter.minimum = 0;

	_amount = @0;

	[self enableMakePayment];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.destinationViewController isKindOfClass: [ReceiverVC class]])
	{
		ReceiverVC* rvc = segue.destinationViewController;
		[rvc setAccount: _account viewOfAccount: _viewOfAccount myOtherAccounts: _otherAccounts];
		rvc.banks = _banks;
		rvc.receiverAccount = _recipientAccount;
		rvc.client = self;
		NSIndexPath* ip = _tableView.indexPathForSelectedRow;
		if (ip)
			[_tableView deselectRowAtIndexPath: ip animated: YES];
	}
}

- (void)endEditing
{
	if ([_activeEditor isFirstResponder])
		[_activeEditor resignFirstResponder];
}

- (IBAction)tapRecognised:(UITapGestureRecognizer *)sender {
	[self endEditing];
}

- (void)enableMakePayment
{
	self.makePaymentButton.enabled = _account != nil && !_processingPayment;
	BOOL enabledNow = self.makePaymentButton.enabled;
	if (enabledNow)
	{
		self.paymentConfirmationLabel.text = @"";
		self.paymentConfirmationLabel.hidden = YES;
	}
}

- (NSString*)whyNotMakeAPayment
{
	if (nil == _recipientAccount)
		return @"Please choose a recipient.";
	if (0.0 >= _amount.doubleValue)
		return @"Please enter the amount to transfer.";
	if (nil == _message)
		return @"Please enter a message for the recipient.";
	return nil;
}

- (IBAction)makePaymentHit:(UIButton *)sender
{
	[self endEditing];
	if (!_makePaymentButton.enabled)
		return;
	NSString* recommendation = [self whyNotMakeAPayment];
	if (nil != recommendation)
	{
		UIAlertController* ac = [UIAlertController alertControllerWithTitle: @"Make a Transfer" message: recommendation preferredStyle: UIAlertControllerStyleAlert];
		[ac addAction: [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler: nil]];
		[self presentViewController: ac animated: YES completion: nil];
		return;
	}
	[self makePayment];
}

- (void)setProcessingPayment:(BOOL)processingPayment
{
	if (_processingPayment == processingPayment)
		return;
	_processingPayment = processingPayment;
	self.processingCluster.hidden = !_processingPayment;
	self.tableView.userInteractionEnabled = !_processingPayment;
	[self enableMakePayment];
}

- (void)paymentDone
{
	NSString*		currency = [_account valueForKeyPath: @"balance.currency"];
	currency = currency.length ? currency : @"EUR";
	NSString*		recipientName = [_recipientAccount salientStringAtKeyPath: @"label"]
								 ?: [_recipientAccount salientStringAtKeyPath: @"number"]
								 ?: [_recipientAccount salientStringAtKeyPath: @"id"]
								 ?: @"-";
	NSString*		desc =
		[NSString stringWithFormat:
			@"%@ %@ paid to account %@ with message: %@",
			currency,
			[_amountFormatter stringFromNumber: _amount],
			recipientName,
			_message];
	_message = nil;
	_amount = nil;
	_recipientAccount = nil;
	[_tableView reloadData];
	self.paymentConfirmationLabel.text = desc;
	self.paymentConfirmationLabel.hidden = NO;
	self.makePaymentButton.enabled = YES;
}

- (void)makePayment {
	NSString*		home_bank_id = _account[@"bank_id"];
	NSString*		away_bank_id = _recipientAccount[@"bank_id"];
	NSString*		home_account_id = _account[@"id"];
	NSString*		away_account_id = _recipientAccount[@"id"];
	NSString*		currency = [_account valueForKeyPath: @"balance.currency"];
	NSString*		path =
		[NSString stringWithFormat:
			@"/banks/%@/accounts/%@/owner/transaction-request-types/SANDBOX_TAN/transaction-requests",
			home_bank_id, home_account_id];
	NSDictionary*	payload =
		@{
			@"to" : @{
				@"bank_id"		: away_bank_id,
				@"account_id"	: away_account_id
			},
			@"value" : @{
				@"currency"		: currency,
				@"amount"		: _amount
			},
			@"description"		: _message
		};
	OBPSession*				session = [OBPSession currentSession];
	HandleOBPMarshalError	errorHandler =
		^(NSError* error, NSString* path) {
			self.processingPayment = NO;
			OBP_LOG(@"Payment failed with %@\npath: %@\npayload: %@\nerror: %@", error.localizedDescription, path, payload, error);
			self.paymentConfirmationLabel.text = error.localizedDescription;
			self.paymentConfirmationLabel.hidden = NO;
		};
	HandleOBPMarshalData	resultHandler =
		^(id deserializedObject, NSString* body) {
			self.processingPayment = NO;
			[self paymentDone];
        };

	self.processingPayment = YES;
	[session.marshal createResource: payload
						  atAPIPath: path
						withOptions: nil
				   forResultHandler: resultHandler
					 orErrorHandler: errorHandler];
}

#pragma mark -

- (void)setMessageRowHeight:(CGFloat)messageRowHeight
{
	if (messageRowHeight < 44)
		messageRowHeight = 44;
	if (messageRowHeight > 120)
		messageRowHeight = 120;
	if (_messageRowHeight != messageRowHeight)
	{
		_messageRowHeight = messageRowHeight;
		[_tableView beginUpdates];
		[_tableView endUpdates];
		[self setNeedToAdjustHeight];
	}
}

- (void)adjustMessageRowHeight
{
	MessageCell* mc = _messageCell;
	if (mc != nil)
		self.messageRowHeight = [mc messageTextViewHeightToFit] + _messageTextToRowHeight;
}

- (void)setNeedToAdjustHeight
{
	[self setNeedToAdjustHeight: YES];
}

- (void)setNeedToAdjustHeight:(BOOL)needToAdjustHeight
{
	if (!_needToAdjustHeight
	 && needToAdjustHeight)
	{
		dispatch_async(
			dispatch_get_main_queue(),
			^{
				[self adjustHeightIfNeeded];
			}
		);
	}
	_needToAdjustHeight = needToAdjustHeight;
}

- (void)adjustHeightIfNeeded
{
	if (_needToAdjustHeight)
	{
		[self adjustMessageRowHeight];

		_needToAdjustHeight = NO;
		CGFloat height = 0;
		for (NSUInteger i = 0; i < kSection_count; i++)
		{
			CGRect r = [self.tableView rectForSection: i];
			height += r.size.height;
		}
		self.tableHeightConstraint.constant = height;
		[self.view setNeedsUpdateConstraints];
	}
}

#pragma mark - ChooseReceiverClient

- (void)receiverVC:(ReceiverVC*)vc didChooseReceiverAccount:(NSDictionary*)receiverAccount
{
	_recipientAccount = receiverAccount;
	[_tableView reloadData];
	[self.navigationController popViewControllerAnimated: YES];
	[self enableMakePayment];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return kSection_count;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section)
	{
		case kSection_Sender:		return @"Sending From:";
		case kSection_Recipient:	return @"To Recipient:";
		case kSection_Amount:		return @"Amount:";
		case kSection_Message:		return @"Message:";
		default:					return @"";
	}
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
	switch (indexPath.section)
	{
		case kSection_Sender:
		case kSection_Recipient:
			{
				UITableViewCell*	cell = [tableView dequeueReusableCellWithIdentifier: @"accountCell"];
				BOOL				sender = indexPath.section == kSection_Sender;
				NSDictionary*		account = sender ? _account : _recipientAccount;

				if (!account && !sender)
				{
					cell.textLabel.text = @"Choose a Recipient…";
					cell.detailTextLabel.text = nil;
					return cell;
				}

				NSString*			bankID = account[@"bank_id"];
			//	if (!sender && bankID && [_account[@"bank_id"] isEqualToString: bankID])
			//		bankID = nil;
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

				cell.accessoryType = sender
								   ? UITableViewCellAccessoryNone
								   : UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = sender
								   ? UITableViewCellSelectionStyleNone
								   : UITableViewCellSelectionStyleDefault;

				[self setNeedToAdjustHeight];
				return cell;
			}
			break;
		case kSection_Amount:
			{
				AmountCell* cell = [_tableView dequeueReusableCellWithIdentifier: @"amountCell"];
				cell.amountTextField.delegate = self;
				cell.amountTextField.text = [_amountFormatter stringFromNumber: _amount];
				NSString* currency = [_account valueForKeyPath: @"balance.currency"];
				cell.currencyLabel.text = [currency length] ? currency : @"EUR";
				[self setNeedToAdjustHeight];
				return cell;
			}
			break;
		case kSection_Message:
			{
				MessageCell* cell = [_tableView dequeueReusableCellWithIdentifier: @"messageCell"];
				if (_messageTextToRowHeight == 0)
					_messageTextToRowHeight = cell.contentView.bounds.size.height - cell.messageTextView.frame.size.height;
				_messageRowHeight = cell.contentView.bounds.size.height;
				cell.messageTextView.delegate = self;
				cell.messageTextView.text = _message ?: @"";
				[self setNeedToAdjustHeight];
				self.messageCell = cell;
				return cell;
			}
			break;
		default:
			return [tableView dequeueReusableCellWithIdentifier: @"accountCell"];
	}
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == kSection_Message)
	if (indexPath.row == 0)
		return _messageRowHeight;
	return -1;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	self.activeEditor = textField;
	self.tapRecogniser.enabled = YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
	return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (_activeEditor == textField)
	{
		NSString* s = textField.text;
		NSNumber* n = s.length ? [_amountFormatter numberFromString: s] : @0;
		if (n)
			_amount = n;
		_activeEditor = nil;
		self.tapRecogniser.enabled = NO;
		[self enableMakePayment];
	}
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSString* now = textField.text;
	NSString* s0 = [now stringByReplacingCharactersInRange: range withString: string];

	// 0) assess some things for later
	NSRange r = [s0 rangeOfString: _amountFormatter.decimalSeparator];
	NSUInteger positionEndInt = r.length ? r.location : s0.length;
	NSUInteger positionNewSel = range.location + string.length;
	NSUInteger newFractionalDigits = r.length ? s0.length - NSMaxRange(r) : 0;

	// 1) must make a valid number (after removing thousand separators)
	NSString* sx = [s0 stringByReplacingOccurrencesOfString: _amountFormatter.groupingSeparator withString: @""];
	NSNumber* n0 = sx.length ? [_amountFormatter numberFromString: sx] : @0;
	if (nil == n0)
		return NO;

	// 2) must be round-trip persistent
	NSString* s1 = [_amountFormatter stringFromNumber: n0];
	NSNumber* n1 = [_amountFormatter numberFromString: s1];
	if (![n0 isEqualToNumber: n1])
		return NO;

	// 3) special cases: strip leading zeros / strip excess trailing zeros
	if (![s0 hasPrefix: s1] || newFractionalDigits > _amountFormatter.maximumFractionDigits)
	{
		// Replace with default formatted text. This will also wipe the selection.
		textField.text = s1;

		// Now restore the selection: it will have same position relative to end of integer part
		NSUInteger pos = [s1 rangeOfString: _amountFormatter.decimalSeparator].location;
		if (pos == NSNotFound)
			pos = s1.length; // no decimal sep, so end of integral part is end of string
		pos += positionNewSel - positionEndInt;
		if (pos >= s1.length)
			pos = s1.length;
		UITextPosition* tp = [textField positionFromPosition: textField.beginningOfDocument offset: pos];
		UITextRange* tr = [textField textRangeFromPosition: tp toPosition: tp];
		textField.selectedTextRange = tr;

		// And suppress the default replacement
		return NO;
	}

	return YES;
}
/*
- (BOOL)textFieldShouldClear:(UITextField *)textField;               // called when clear button pressed. return NO to ignore (no notifications)
- (BOOL)textFieldShouldReturn:(UITextField *)textField;              // called when 'return' key pressed. return NO to ignore.
*/
#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	static NSCharacterSet* sDisallowedCharacters = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSMutableCharacterSet* mcs = [[NSMutableCharacterSet alloc] init];
		[mcs formUnionWithCharacterSet: [NSCharacterSet alphanumericCharacterSet]];
		[mcs addCharactersInString: @".,-/ ()"];
		[mcs invert];
		sDisallowedCharacters = [mcs copy];
	});
	NSString* now = textView.text;
	NSString* s0 = [now stringByReplacingCharactersInRange: range withString: text];
	#define MAX_CHARS 512
	// ...or real limit.
	if ([s0 length] > MAX_CHARS)
		return NO;
	if ([text rangeOfCharacterFromSet: sDisallowedCharacters].length)
		return NO;
	return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
	self.activeEditor = textView;
	self.tapRecogniser.enabled = YES;

}
- (void)textViewDidEndEditing:(UITextView *)textView
{
	if (_activeEditor == textView)
	{
		_activeEditor = nil;
		_message = textView.text ?: @"";
		self.tapRecogniser.enabled = NO;
		[self enableMakePayment];
	}
}
- (void)textViewDidChange:(UITextView *)textView
{
	[self adjustMessageRowHeight];
	[self ensureVisible];
}
- (void)textViewDidChangeSelection:(UITextView *)textView
{
	[self ensureVisible];
}
- (void)ensureVisible
{

}
/*
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
- (BOOL)textViewShouldEndEditing:(UITextView *)textView;

*/
@end
