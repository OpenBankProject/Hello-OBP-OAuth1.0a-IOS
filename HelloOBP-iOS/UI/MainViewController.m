//
//
//  MainViewController.m
//  HelloOBP-iOS
//
//  Created by Dunia Reviriego on 4/22/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import "MainViewController.h"
#import <OBPKit/OBPKit.h>
#import <STHTTPRequest/STHTTPRequest.h>
#import "AccountsViewController.h"
#import "LoginViewController.h"
#import "DefaultServerDetails.h"


@implementation MainViewController
{
	OBPSession*			_session;
	NSDictionary*		_banks;
}

@synthesize rightNavButton;

- (UIBarButtonItem *)rightNavButton {
    // Method for active/desactive the button 
    if (!rightNavButton) {
        rightNavButton = [[UIBarButtonItem alloc] init];
        //configure the button here
        self.rightNavButton.title = @"Accounts";
    }
    [rightNavButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont fontWithName:@"STHeitiJ-Medium" size:12.0], NSFontAttributeName,
                                            [UIColor whiteColor], NSForegroundColorAttributeName,
                                            nil] forState:UIControlStateNormal];
    return rightNavButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Hello-OBP-OAuth1.0a";
    
    if (![[[UIDevice currentDevice] systemVersion] isEqualToString: @"6.1"]) {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Home"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [backItem setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"STHeitiJ-Medium" size:13.0], NSFontAttributeName,
                                        [UIColor whiteColor], NSForegroundColorAttributeName,
                                        nil] forState:UIControlStateNormal];
    
    [self.navigationItem setBackBarButtonItem:backItem];
    
    [self.leftNavButton setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIFont fontWithName:@"STHeitiJ-Medium" size:13.0], NSFontAttributeName,
                                                              [UIColor whiteColor], NSForegroundColorAttributeName,
                                                              nil] forState:UIControlStateNormal];

    
    [self.navigationItem setRightBarButtonItem:nil];
    self.linkOBPwebsite.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.linkOBPwebsite.titleLabel.numberOfLines = 2;
    self.navigationController.navigationBar.translucent = NO;
    [self.linkOBPwebsite setTitle:@"Hello-OBP-OAuth1.0a is demo for app designers.\nTo find out more visit the Open Bank Project." forState:UIControlStateNormal];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

-(void) viewWillAppear:(BOOL)animated{
    
    if (nil == (_session = [OBPSession currentSession]))
	{
		OBPServerInfo*	serverInfo = [OBPServerInfo defaultEntry];
		_session = [OBPSession sessionWithServerInfo: serverInfo];
	}
	//check for OBP and authorize
    if([_session valid]){
		[self fetchBanks];
        self.navigationItem.rightBarButtonItem = self.rightNavButton;
        [self.viewConnect setHidden:YES];
        [self.viewLogin setHidden:NO];
            }
	else{
        self.navigationItem.rightBarButtonItem = nil;
        [self.viewConnect setHidden:NO];
        [self.viewLogin setHidden:YES];
        //NSLog(@"Ups not connect");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)connectToBankAPI:(id)sender {
   
	if (USE_DIRECT_LOGIN)
	{
		_session.authMethod = OBPAuthMethod_DirectLogin;
		[_session validate:
			^(NSError * error)
			{
				BOOL connected = !error && _session.valid;
				if (connected)
					[self fetchBanks];
				self.navigationItem.rightBarButtonItem = connected ? self.rightNavButton : nil;
				[self.viewConnect setHidden: connected];
				[self.viewLogin setHidden: !connected];
			}
		];
	}
	else
	if (USE_EXTERNAL_WEBVIEW)
	{
		//	Test auth with default web view provider...
		//	_session.webViewProvider = [OBPWebViewProvider defaultProvider];
		//	...unnecessary if never changed.
		[_session validate:
			^(NSError * error)
			{
				BOOL connected = !error && _session.valid;
				if (connected)
					[self fetchBanks];
				self.navigationItem.rightBarButtonItem = connected ? self.rightNavButton : nil;
				[self.viewConnect setHidden: connected];
				[self.viewLogin setHidden: !connected];
			}
		];
	}
	else
    [self performSegueWithIdentifier:@"webView" sender:sender];
    
}
- (IBAction)linkToReadme:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/OpenBankProject/Hello-OBP-OAuth1.0a-IOS/blob/master/README.md#login-credentials"]];
}

- (IBAction)accountsTableView:(id)sender {
    [self performSegueWithIdentifier:@"Accounts" sender:sender];
}

- (IBAction)about:(id)sender {
    [self performSegueWithIdentifier:@"About" sender:sender];
}


- (IBAction)logOut:(id)sender {
    if ([_session valid]) {
		UIAlertController* ac =
			[UIAlertController alertControllerWithTitle: @"Log out"
												message: @"Are you sure you want to clear Data?"
										 preferredStyle: UIAlertControllerStyleAlert];
		[ac addAction: [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel
											  handler: ^(UIAlertAction * _Nonnull action) {}]];
		[ac addAction: [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault
											  handler:
			^(UIAlertAction* action)
			{
				[_session invalidate];
				self.navigationItem.rightBarButtonItem = nil;
				[self.viewConnect setHidden:NO];
				[self.viewLogin setHidden:YES];
			}
		]];
		[self presentViewController: ac animated: YES completion: nil];
    }
}

- (IBAction)linkToOBPwebsite:(id)sender {
	[[self class] linkToOBPwebsite: self];
}

+ (void)linkToOBPwebsite:(UIViewController*)vc
{

	UIAlertController* ac =
		[UIAlertController alertControllerWithTitle: @"Open Bank Project"
											message: @"You are leaving the app demo to go the OBP websites."
									 preferredStyle: UIAlertControllerStyleAlert];
	[ac addAction: [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel
										  handler: ^(UIAlertAction * _Nonnull action) {}]];
	[ac addAction: [UIAlertAction actionWithTitle: @"www.openbankproject.com" style: UIAlertActionStyleDefault
										  handler: ^(UIAlertAction* action) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://openbankproject.com"]];
	}]];
	[ac addAction: [UIAlertAction actionWithTitle: @"www.tesobe.com" style: UIAlertActionStyleDefault
										  handler: ^(UIAlertAction* action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://tesobe.com/en/projects/open-bank-project/"]];
	}]];
	[ac addAction: [UIAlertAction actionWithTitle: @"github/openbankproject" style: UIAlertActionStyleDefault
										  handler: ^(UIAlertAction* action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.github.com/OpenBankProject"]];
	}]];
	[ac addAction: [UIAlertAction actionWithTitle: @"Readme (with example user accounts)" style: UIAlertActionStyleDefault
										  handler: ^(UIAlertAction* action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/OpenBankProject/Hello-OBP-OAuth1.0a-IOS/blob/master/README.md#login-credentials"]];
	}]];
	[vc presentViewController: ac animated: YES completion: nil];
}

- (void)fetchBanks
{
	[_session.marshal getResourceAtAPIPath: @"banks"
							   withOptions: nil
						  forResultHandler:
		^(id deserializedObject, NSString* body)
		{
			NSDictionary*			banksDict = deserializedObject;
			NSMutableDictionary*	banksByID = [NSMutableDictionary dictionary];
			NSArray*				banks = banksDict[@"banks"];
			NSString*				bankID;
			NSDictionary*			bank;
			for (bank in banks)
			{
				bankID = bank[@"id"];
				banksByID[bankID] = bank;
			}
			NSMutableDictionary*	md = [banksDict mutableCopy];
			md[@"banksByID"] = banksByID;
			_banks = [md copy];
        }
						   orErrorHandler: nil
	];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender
{
	if ([segue.destinationViewController isKindOfClass: [AccountsViewController class]])
	{
		AccountsViewController*	acv = (AccountsViewController*)segue.destinationViewController;
		acv.banksDict = _banks;
	}
}

@end
