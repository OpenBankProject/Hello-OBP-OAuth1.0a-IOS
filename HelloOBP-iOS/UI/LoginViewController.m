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

#import <WebKit/WebKit.h>
#import <OBPKit/OBPKit.h>
#import "DefaultServerDetails.h"



@interface LoginViewController () <OBPWebViewProvider, WKNavigationDelegate>
@end



@implementation LoginViewController
{
	WKWebView*				_webView;
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

	// 2. Get the current session if already set, otherwise a session with the default server info
	_session = [OBPSession currentSession] ?: [OBPSession sessionWithServerInfo: [OBPServerInfo defaultEntry]];
	_serverInfo = _session.serverInfo;
	_APIBase = _serverInfo.APIBase;

    // 3. initialize the webview and add it to the view
    CGRect frame = self.view.bounds;
	_webView = [[WKWebView alloc] initWithFrame: frame];
	_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_webView.configuration.websiteDataStore = [WKWebsiteDataStore nonPersistentDataStore];
	_webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = NO;
	_webView.navigationDelegate = self;
	[self.view addSubview: _webView];

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
	return [OBPDefaultWebViewProvider callbackSchemeWithName: @"callback"];
}

- (void)showURL:(NSURL*)url filterNavWith:(OBPWebNavigationFilter)onwardNavigationFilter notifyCancelBy:(OBPWebCancelNotifier)cancelNotifier
{
	_callbackFilter = onwardNavigationFilter;
	_cancelNotifier = cancelNotifier;
	[_webView loadRequest: [NSURLRequest requestWithURL: url]];
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

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView*)webView decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction decisionHandler:(void(^)(WKNavigationActionPolicy))decisionHandler
{
	WKNavigationActionPolicy	policy = WKNavigationActionPolicyAllow;
	WKNavigationType			navType = navigationAction.navigationType;
	NSURL*						navURL;

	OBP_LOG_IF(0, @"\nnavigationAction: %@", navigationAction);

	if (navType == WKNavigationTypeLinkActivated
	 || navType == WKNavigationTypeOther)
	{
		navURL = navigationAction.request.URL;
		if (_callbackFilter != nil)
		if (_callbackFilter(navURL))
			policy = WKNavigationActionPolicyCancel;
	}

	decisionHandler(policy);
}

@end
