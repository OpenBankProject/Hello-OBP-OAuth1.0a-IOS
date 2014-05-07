//
//
//  ViewController.m
//  Hello-OBP-OAuth1.0a-IOS
//
//  Created by comp on 4/22/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import "ViewController.h"
#import "OAuthController.h"

@interface ViewController ()
@end

@implementation ViewController

@synthesize rightNavButton;

- (UIBarButtonItem *)rightNavButton {
    // Method for active/desactive the button 
    if (!rightNavButton) {
        rightNavButton = [[UIBarButtonItem alloc] init];
        //configure the button here
        self.rightNavButton.title = @"Log out";
    }
    return rightNavButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Hello-OBP-OAuth1.0a";
    [self.navigationItem setRightBarButtonItem:nil];
   
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

-(void) viewWillAppear:(BOOL)animated{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//check for OBP and authorize
    if([defaults valueForKey: kAccessTokenKeyForPreferences]){
        self.navigationItem.rightBarButtonItem = self.rightNavButton;
        [self.viewConnect setHidden:YES];
        [self.viewData setHidden:NO];
        self.textJSON.text = [defaults valueForKey:kJSON];
    }
	else{
        self.navigationItem.rightBarButtonItem = nil;
        [self.viewConnect setHidden:NO];
        [self.viewData setHidden:YES];
        //NSLog(@"Ups not connect");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connectToOBP:(id)sender {
   
    [self performSegueWithIdentifier:@"webViewSegue" sender:sender];
    
}
- (IBAction)connectToGitHub:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/OpenBankProject/Hello-OBP-OAuth1.0a-IOS"]];
}


- (IBAction)logOut:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey: kAccessTokenKeyForPreferences]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Log out"
                                                          message:@"Are you sure you want to clear Data?"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"OK", nil];
        [message show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // Clear the Data if click OK
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"])
    {
        [defaults removeObjectForKey: kAccessSecretKeyForPreferences];
        [defaults removeObjectForKey: kAccessTokenKeyForPreferences];
        [defaults synchronize];
        [self.viewConnect setHidden:NO];
        [self.viewData setHidden:YES];
        self.navigationItem.rightBarButtonItem = nil;
    }
    
}

@end
