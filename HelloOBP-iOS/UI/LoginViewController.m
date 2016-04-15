//
//  LoginViewController.m
//  HelloOBP-iOS
//
//  Created by Dunia Reviriego on 4/22/14.
//  Copyright (c) 2014 Tesobe. All rights reserved.
//
// OBP API: https://github.com/OpenBankProject/OBP-API/wiki/OAuth-1.0-Server
// Sandbox: https://github.com/OpenBankProject/OBP-API/wiki/Sandbox


#import "LoginViewController.h"

#import <OBPKit/OBPKit.h>
#import "DefaultServerDetails.h"



@interface LoginViewController () <UIWebViewDelegate, OBPWebViewProvider>
@property(nonatomic, retain) IBOutlet UIWebView *webView;
@end



@implementation LoginViewController
{
	OBPServerInfo*			_serverInfo;
	NSString*				_APIBase;
	OBPSession*				_session;
	OBPWebNavigationFilter	_callbackFilter;
	OBPWebCancelNotifier	_cancelNotifier;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Open Bank Project";

	// 2. Get the default server info, and make a corresponding session to access it
	_serverInfo = [OBPServerInfo defaultEntry];
	_session = [OBPSession sessionWithServerInfo: _serverInfo];
	_APIBase = _serverInfo.APIBase;

    // 3. initialize the webview and add it to the view
    
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    self.webView.contentMode = UIViewContentModeScaleAspectFit;
	[self.view addSubview:self.webView];
	_session.webViewProvider = self;

    // 4. Kick off session authentication
	[_session validate:
		^(NSError* error)
		{
            [self.navigationController popToRootViewControllerAnimated:YES];
		}
	];
}

#pragma mark -

- (NSString*)callbackScheme
{
	return OAUTH_URL_SCHEME;
}

- (void)showURL:(NSURL*)url filterNavWith:(OBPWebNavigationFilter)onwardNavigationFilter notifyCancelBy:(OBPWebCancelNotifier)cancelNotifier
{
	_callbackFilter = onwardNavigationFilter;
	_cancelNotifier = cancelNotifier;
	[self.webView loadRequest: [NSURLRequest requestWithURL: url]];
}

- (void)resetWebViewProvider
{
	_callbackFilter = nil;
	_cancelNotifier = nil;
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

@end
