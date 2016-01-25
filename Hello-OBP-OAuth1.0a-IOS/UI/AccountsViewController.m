//
//  AccountsViewController.m
//  Hello-OBP-OAuth1.0a-IOS
//
//  Created by Dunia Reviriego on 8/17/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import "AccountsViewController.h"
#import "STHTTPRequest.h"
#import "OAuthCore.h"

#import "LoginViewController.h"
#import "DetailsViewController.h"

@interface AccountsViewController ()
{
    NSDictionary *accounts;
    NSArray *account;
    
    NSString *accountSelected;
    NSString *transactionURL;

}
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
    self.linkOBPwebsite.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.linkOBPwebsite.titleLabel.numberOfLines = 2;
    [self.linkOBPwebsite setTitle:@"Hello-OBP-OAuth1.0a is demo for app designers.\nTo find out more visit the Open Bank Project." forState:UIControlStateNormal];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationItem.backBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [UIFont fontWithName:@"STHeitiJ-Medium" size:12.0], NSFontAttributeName,
                                                                    [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                    nil] forState:UIControlStateNormal];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Accounts"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [backItem setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIFont fontWithName:@"STHeitiJ-Medium" size:13.0], NSFontAttributeName,
                                       [UIColor whiteColor], NSForegroundColorAttributeName,
                                       nil] forState:UIControlStateNormal];
    
    [self.navigationItem setBackBarButtonItem:backItem];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *json = [defaults valueForKey:kAccountsJSON];
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    
    accounts = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    account = [accounts objectForKey: @"accounts"]; 
    
    self.accountsJSON.text = [accounts description];
    
    if (_accountsTypeToShow.selectedSegmentIndex == 0 ){
        [self.viewTable setHidden:NO];
        [self.viewJSON setHidden:YES];
    }
	else {
        [self.viewTable setHidden:YES];
        [self.viewJSON setHidden:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if([title isEqualToString:@"www.openbankproject.com"])
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
    return account.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSString *idAccount= [[[accounts objectForKey: @"accounts"]objectAtIndex:indexPath.row] objectForKey:@"id"];
    cell.textLabel.text = idAccount;
    //[[cell textLabel]setText:idAccount];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    accountSelected= [[[accounts objectForKey: @"accounts"]objectAtIndex:indexPath.row] objectForKey:@"id"];
    
    NSString *lURL = [NSString stringWithFormat: @"%@banks/%@/accounts/%@/owner/transactions",OAUTH_BASE_URL, OAUTH_CONSUMER_BANK_ID, accountSelected];
    transactionURL = lURL;
    [self getResourceWithString];
    
    
}


- (void)getResourceWithString {
    //NSLog(@"getResourceWithString says Hi");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    STHTTPRequest *request = [STHTTPRequest requestWithURLString:transactionURL];
	NSString *header = OAuthHeader([request url], //set method to GET
								   [request POSTDictionary]!=nil?@"POST":@"GET",
								   [@"" dataUsingEncoding:NSUTF8StringEncoding],
								   OAUTH_CONSUMER_KEY,
								   OAUTH_CONSUMER_SECRET_KEY,
								   [defaults valueForKey: kAccessTokenKeyForPreferences],
								   [defaults valueForKey: kAccessSecretKeyForPreferences],
								   nil, // oauth_verifier
								   OAuthCoreSignatureMethod_HMAC_SHA256,
								   nil); // callback
    
    
    [request setHeaderWithName:@"Authorization" value:header];

	STHTTPRequest __weak *request_ifStillAround = request;
    request.completionBlock = ^(NSDictionary *headers, NSString *body) {
		STHTTPRequest *request = request_ifStillAround;
		NSInteger status = request.responseStatus;
        if (status == 200) {
            //store into user defaults for later access
            //NSLog(@"in getResourceWithString json=%@", body);
            
            DetailsViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailsViewController"];
            dvc.JSON = body;
            dvc.accountSelected = accountSelected;
            [self.navigationController pushViewController:dvc animated:YES];

        }
    };
    
    request.errorBlock = ^(NSError *error) {
        NSLog(@"getResourceWithString got error %@", error);
    };
    
    [request startAsynchronous];
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
