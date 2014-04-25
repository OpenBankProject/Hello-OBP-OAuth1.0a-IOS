//
//  OAuth.h
//  Hello-OBP-OAuth1.0a-IOS
//
//  Created by comp on 4/22/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAccessTokenKeyForPreferences @"accessToken"
#define kAccessSecretKeyForPreferences @"accessTokenSecret"

@interface OAuth : UIViewController <UIWebViewDelegate>  {
    NSMutableString *requestToken;
    NSMutableString *requestTokenSecret;
    
}

@property (nonatomic, retain) NSMutableString *accessToken;
@property (nonatomic, retain) NSMutableString *accessTokenSecret;
@property (nonatomic, retain) NSMutableString *verifier;

- (void)getRequestToken;
- (void)openBrowserAuthRequest;
- (void)getAccessToken;

@end
