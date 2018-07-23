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

//          •••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
//          •••••••• To configure for use with a different server or as a different app... ••••••••
//          •••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
//          •••• 1) Change the bundle identifier of this app in the Project > General settings
//          •••• 2a) Read https://github.com/OpenBankProject/OBPKit-iOSX#callback-schemes
//          •••• 2b) Get your API Keys from the GET API KEY link on the home page of the OBP server
//          •• you want to use, and composing your redirect URL in the way described in the link in
//          •• just above. Save the result of the key request to a PDF - you will likely need other
//          •• info from it later.
//          •••• 3) Change the following `#if 0` to `#if 1`
#if 0
//          •••• 4) Set the two domains here to the that of the server you will use
#define OAUTH_AUTHENTICATE_URL		@"https://some_other_obp_server.openbankproject.com"
#define OAUTH_BASE_URL				@"https://some_other_obp_server.openbankproject.com/obp/v3.0.0/"
//          •••• 5) Paste in your consumer key and secret
#define OAUTH_CONSUMER_KEY			@"paste-your-consumer-key-here"
#define OAUTH_CONSUMER_SECRET_KEY	@"paste-your-consumer-secret-here"
//          •••• 6) build, run and try it out!

#else

// These default settings will connect to the default OBP sandbox:
#define OAUTH_AUTHENTICATE_URL		@"https://apisandbox.openbankproject.com"
#define OAUTH_BASE_URL				@"https://apisandbox.openbankproject.com/obp/v3.0.0/"
#define OAUTH_CONSUMER_KEY			@"bmxc0hsg5u0z5qbaabd25uf1z5o5a1l0jh1wge1s"
#define OAUTH_CONSUMER_SECRET_KEY	@"lgqbdta4yu50o2iv4bjaevogo4vo3nffbas5cvsc"

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
