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

@interface ViewController () {
    NSDictionary *accounts;
    NSArray *account;
}
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
    [rightNavButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont fontWithName:@"Helvetica-Bold" size:14.0], NSFontAttributeName,
                                            [UIColor grayColor], NSForegroundColorAttributeName,
                                            nil] forState:UIControlStateNormal];
    return rightNavButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"viewDidLoad");

    [self.tableViewAccounts setDataSource:self];
    [self.tableViewAccounts setDelegate:self];
    
    self.navigationItem.title = @"Hello-OBP-OAuth1.0a";
    [self.navigationItem setRightBarButtonItem:nil];
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

-(void) viewWillAppear:(BOOL)animated{
    //NSLog(@"viewWillAppear");

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    	//check for OBP and authorize
    if([defaults valueForKey: kAccessTokenKeyForPreferences]){
        self.navigationItem.rightBarButtonItem = self.rightNavButton;
        [self.viewConnect setHidden:YES];
        [self.viewData setHidden:NO];
        
        //Parse JSON to take the names of Accounts
        NSString *json = [defaults valueForKey:kJSON];
        //NSLog(@"viewWillAppear say json = %@", json);
        NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        accounts = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        account = [accounts objectForKey: @"accounts"];
        [self.tableViewAccounts reloadData];

    }
	else {
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
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/OpenBankProject/Hello-OBP-OAuth1.0a-IOS/blob/master/README.md"]];
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


#pragma TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return account.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"myCell"];
    }
    NSString *idAccount= [[[accounts objectForKey: @"accounts"]objectAtIndex:indexPath.row] objectForKey:@"id"];
    cell.textLabel.text = idAccount;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected row: %li", (long)indexPath.row);
}

@end
