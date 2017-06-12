//
//  DefaultServerDetails.h
//  HelloOBP-iOS
//
//  Created by Torsten Louland on 26/01/2016.
//  Copyright © 2016 TESOBE. All rights reserved.
//

#ifndef ServerDetails_h
#define ServerDetails_h

#import <Foundation/Foundation.h>
#import <OBPKit/OBPServerInfo.h>


#if 1

#define OAUTH_AUTHENTICATE_URL		@"https://apisandbox.openbankproject.com"
#define OAUTH_BASE_URL				@"https://apisandbox.openbankproject.com/obp/v2.0.0/"
#define OAUTH_CONSUMER_KEY			@"tzecy5lgatsbrvbt2ttfrxlelertfxywt3whes4q"
#define OAUTH_CONSUMER_SECRET_KEY	@"eusfvy3oizylx11dr420nhxluv1rdan5qjjkgmkh"

#else

// Try with a different server - fill in the details here:
#define ANOTHER_OBP_SERVER_HOST		@"https://api-anotherserver.openbankproject.com/"

#define OAUTH_AUTHENTICATE_URL		ANOTHER_OBP_SERVER_HOST
#define OAUTH_BASE_URL				ANOTHER_OBP_SERVER_HOST @"obp/v3.0.0/"

// Get key and secret by registering your client at: ANOTHER_OBP_SERVER_HOST/consumer-registration
#define OAUTH_CONSUMER_KEY			@"paste-your-consumer-key-here"
#define OAUTH_CONSUMER_SECRET_KEY	@"paste-your-consumer-secret-here"

#endif


#define USE_DIRECT_LOGIN 0
#define USE_EXTERNAL_WEBVIEW 0



static NSString* const kDefaultServer_APIBase = OAUTH_BASE_URL;



NS_INLINE NSDictionary* DefaultServerDetails()
{
	return @{
		OBPServerInfo_APIBase			:	kDefaultServer_APIBase,
		OBPServerInfo_AuthServerBase	:	OAUTH_AUTHENTICATE_URL,
		OBPServerInfo_ClientKey			:	OAUTH_CONSUMER_KEY,
		OBPServerInfo_ClientSecret		:	OAUTH_CONSUMER_SECRET_KEY,
		// ...this is insecure because this only a demo app, but your production app should retrieve your client key and secret from a secure storage place rather than plain text in the app where they can easily be retrieved from the executable.
	};
}

#endif /* ServerDetails_h */
