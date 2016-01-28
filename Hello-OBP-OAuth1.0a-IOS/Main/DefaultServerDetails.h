//
//  DefaultServerDetails.h
//  Hello-OBP-OAuth1.0a-IOS
//
//  Created by Torsten Louland on 26/01/2016.
//  Copyright © 2016 TESOBE. All rights reserved.
//

#ifndef ServerDetails_h
#define ServerDetails_h

#import <Foundation/Foundation.h>
#import "OBPAccessData.h"



#define kAccountsJSON @"accountsJSON"

#define OAUTH_AUTHENTICATE_URL @"https://apisandbox.openbankproject.com/"
#define OAUTH_BASE_URL @"https://apisandbox.openbankproject.com/obp/v1.2/"

// To get the values for the following fields, please register your client here:
// https://apisandbox.openbankproject.com/consumer-registration
#define OAUTH_CONSUMER_KEY @"tzecy5lgatsbrvbt2ttfrxlelertfxywt3whes4q"
#define OAUTH_CONSUMER_SECRET_KEY @"eusfvy3oizylx11dr420nhxluv1rdan5qjjkgmkh"

#define OAUTH_URL_SCHEME @"helloobpios" // Your Application Name
#define OAUTH_CONSUMER_BANK_ID @"rbs" //Account of bank



static NSString* const kDefaultServer_APIBase = OAUTH_BASE_URL;



NS_INLINE NSDictionary* DefaultServerDetails()
{
	return @{
		OBPAccessData_APIBase			:	kDefaultServer_APIBase,
		OBPAccessData_AuthServerBase	:	OAUTH_AUTHENTICATE_URL,
		OBPAccessData_ClientKey			:	OAUTH_CONSUMER_KEY,
		OBPAccessData_ClientSecret		:	OAUTH_CONSUMER_SECRET_KEY,
		// ...this is insecure because this only a demo app, but your production app should retrieve your client key and secret from a secure storage place rather than plain text in the app.
	};
}

#endif /* ServerDetails_h */
