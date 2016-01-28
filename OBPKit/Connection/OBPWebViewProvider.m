//
//  OBPWebViewProvider.m
//  OBPKit
//
//  Created by Torsten Louland on 24/01/2016.
//  Copyright © 2016 TESOBE Ltd. All rights reserved.
//

#import "OBPWebViewProvider.h"



@implementation OBPWebViewProvider
+ (instancetype)defaultProvider
{
	return nil;
}
+ (NSString*)defaultCallbackScheme
{
	/*	Info dictionary should contain a sectionlike this in order to declare which URL schemes it can handle, and hence can be sent to it by the system.
			<key>CFBundleURLTypes</key>
			<array>
				<dict>
					<key>CFBundleURLName</key>
					<string>com.satisfyingstructures.$(PRODUCT_NAME:rfc1034identifier:lower)</string>
					<key>CFBundleURLSchemes</key>
					<array>
						<string>$(PRODUCT_NAME:rfc1034identifier:lower)</string>
					</array>
				</dict>
			</array>
		We parse the first one out below, or fallback to the bundle identifier if not found.
	*/
	NSString*		scheme;
	NSBundle*		bundle = [NSBundle mainBundle];
	NSString*		s;
	NSDictionary*	d = bundle.infoDictionary;
	NSArray*		a = d[@"CFBundleURLTypes"];
	d = [a firstObject];
	a = d[@"CFBundleURLSchemes"];
	s = [a firstObject];
	scheme = [s length] ? s : bundle.bundleIdentifier;
	return scheme;
}
#pragma mark -
- (void)showURL:(NSURL*)url filterNavWith:(OBPWebNavigationFilter)navigationFilter notifyCancelWith:(void(^)())cancelNotifier
{
/*
iOS:
- make new UIWebView and delegate and push
- delegate pass URL from -webView:shouldStartLoadWithRequest:navigationType: through onwardNavigationFilter
- if it returns yes, tear all down

Mac:
- make new window with WKWebView and nav delegate, show
- delegate pass URL from -webView:decidePolicyForNavigationAction:decisionHandler: through onwardNavigationFilter
- if it returns yes, tear all down

- fallback
    [[NSWorkspace sharedWorkspace] openURL:url];
#if TARGET_OS_IPHONE
#else
// helper to get URL from AE?
#endif
*/
}
- (NSString*)callbackScheme
{
	return [[self class] defaultCallbackScheme];
}
@end
