//
//  OAuthController.h
//  Hello-OBP-OAuth1.0a-IOS
//
//  Created by Dunia Reviriego on 4/22/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#define kAccessTokenKeyForPreferences @"accessToken"
#define kAccessSecretKeyForPreferences @"accessTokenSecret"
#define kAccountsJSON @"accountsJSON"

#define OAUTH_CONSUMER_KEY @"tzecy5lgatsbrvbt2ttfrxlelertfxywt3whes4q"
#define OAUTH_CONSUMER_SECRET_KEY @"eusfvy3oizylx11dr420nhxluv1rdan5qjjkgmkh"
#define OAUTH_URL_SCHEME @"helloobpios" // Your Application Name

#define OAUTH_AUTHENTICATE_URL @"https://apisandbox.openbankproject.com/"
#define OAUTH_BASE_URL @"https://apisandbox.openbankproject.com/obp/v1.2/"
#define OAUTH_CONSUMER_BANK_ID @"rbs" //Account of bank


@interface OAuthController : UIViewController <UIWebViewDelegate>  {
    NSMutableString *requestToken;
    NSMutableString *requestTokenSecret;
    UIWebView *webView;
}

@property(nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) NSMutableString *accessToken;
@property (nonatomic, retain) NSMutableString *accessTokenSecret;
@property (nonatomic, retain) NSMutableString *verifier;

- (void)getRequestToken;
- (void)openBrowserAuthRequest;
- (void)getAccessToken;
- (void)getResourceWithString;

@end
