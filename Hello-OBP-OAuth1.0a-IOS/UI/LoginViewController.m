//
//  LoginViewController.m
//  Hello-OBP-OAuth1.0a-IOS
//
//  Created by Dunia Reviriego on 4/22/14.
//  Copyright (c) 2014 Tesobe. All rights reserved.
//
// OBP API: https://github.com/OpenBankProject/OBP-API/wiki/OAuth-1.0-Server
// Sandbox: https://github.com/OpenBankProject/OBP-API/wiki/Sandbox


//1. Obtaining a request token: Open request url with consumer token and secret, get request token
//2. Redirecting the user: use token and local callback url as parameter (custom url scheme) and receive oauth_verifier
//3. Obtaining an access token: request access token to do authenticated access through callback response
//4. Accessing to protected resources


#import "LoginViewController.h"

#import "OBPAccessData.h"
#import "OBPSessionAuth.h"
#import "OBPWebViewProvider.h"
#import "DefaultServerDetails.h"

#import "STHTTPRequest.h"
#import "NSString+OBP.h"

// 1. To get the values for the following fields, please register your client here:
// https://apisandbox.openbankproject.com/consumer-registration



@interface LoginViewController () <UIWebViewDelegate, OBPWebViewProvider>
@property(nonatomic, retain) IBOutlet UIWebView *webView;
@end



@implementation LoginViewController
{
	OBPAccessData*			_accessData;
	NSString*				_APIBase;
	OBPSessionAuth*			_sessionAuth;
	OBPWebNavigationFilter	_callbackFilter;
	void				  (^_cancelNotifier)();
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Open Bank Project";

	// 2. Get the default OBP access data, and the corresponding session authoriser
	_accessData = [OBPAccessData defaultEntry];
	_sessionAuth = [OBPSessionAuth sessionAuthWithAccessData: _accessData];
	_APIBase = _accessData.APIBase;

    // 3. initialize the webview and add it to the view
    
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    self.webView.contentMode = UIViewContentModeScaleAspectFit;
	[self.view addSubview:self.webView];
	_sessionAuth.webViewProvider = self;

    // 4. Kick off session authentication
	[_sessionAuth validate:
		^(NSError* error)
		{
			if (error == nil)
				[self fetchAccounts];
            [self.navigationController popToRootViewControllerAnimated:YES];
		}
	];
}

#pragma mark -

- (NSString*)callbackScheme
{
	return OAUTH_URL_SCHEME;
}

- (void)showURL:(NSURL*)url filterNavWith:(OBPWebNavigationFilter)onwardNavigationFilter notifyCancelWith:(void(^)())cancelNotifier
{
	_callbackFilter = onwardNavigationFilter;
	_cancelNotifier = cancelNotifier;
	[self.webView loadRequest: [NSURLRequest requestWithURL: url]];
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
 navigationType:(UIWebViewNavigationType)navigationType
{
	if (_callbackFilter != nil)
	if (_callbackFilter(request.URL))
		return NO;

    return YES;
}

#pragma mark - Get Resources

- (void)fetchAccounts {

    NSString *lURL = [_APIBase stringForURLByAppendingPath: [NSString stringWithFormat: @"banks/%@/accounts/private", OAUTH_CONSUMER_BANK_ID]]; //Privates
    
    STHTTPRequest *request = [STHTTPRequest requestWithURLString:lURL];

	STHTTPRequest __weak *request_ifStillAround = request;
    request.completionBlock = ^(NSDictionary *headers, NSString *body) {
		STHTTPRequest *request = request_ifStillAround;
		NSInteger status = request.responseStatus;
        if (status == 200) {
            //NSLog(@"body = %@",body);
            //store into user defaults for later access
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:body forKey:kAccountsJSON];
            [defaults synchronize];
        }
    };
    
    request.errorBlock = ^(NSError *error) {
        NSLog(@"getResourceWithString got error %@", error);
    };

	if ([_sessionAuth authorizeSTHTTPRequest: request])
		[request startAsynchronous];
}

@end
