//
//  OAuthController.h
//  Hello-OBP-OAuth1.0a-IOS
//
//  Created by comp on 4/22/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#define kAccessTokenKeyForPreferences @"accessToken"
#define kAccessSecretKeyForPreferences @"accessTokenSecret"
#define kJSON @"textJSON"

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
