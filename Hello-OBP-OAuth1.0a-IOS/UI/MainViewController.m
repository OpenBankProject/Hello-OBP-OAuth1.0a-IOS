//
//
//  MainViewController.m
//  Hello-OBP-OAuth1.0a-IOS
//
//  Created by Dunia Reviriego on 4/22/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import "MainViewController.h"
#import "LoginViewController.h"
#import "OBPAccessData.h"
#import "OBPSessionAuth.h"


@implementation MainViewController
{
	OBPSessionAuth*		_sessionAuth;
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
    
    if (_sessionAuth == nil)
	{
		OBPAccessData*	accessData = [OBPAccessData defaultEntry];
		_sessionAuth = [OBPSessionAuth sessionAuthWithAccessData: accessData];
	}
	//check for OBP and authorize
    if([_sessionAuth valid]){
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
    if ([_sessionAuth valid]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Log out"
                                                          message:@"Are you sure you want to clear Data?"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"OK", nil];
        [message show];
    }
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
    if([title isEqualToString:@"OK"])
    {
        [_sessionAuth invalidate];
        self.navigationItem.rightBarButtonItem = nil;
        [self.viewConnect setHidden:NO];
        [self.viewLogin setHidden:YES];
    }
    else if([title isEqualToString:@"www.openbankproject.com"])
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

@end
