//
//  OBPSessionAuth.m
//  OBPKit
//
//  Created by Torsten Louland on 23/01/2016.
//  Copyright © 2016 TESOBE Ltd. All rights reserved.
//

#import "OBPSessionAuth.h"
// sdk
// ext
#import "STHTTPRequest.h"
#import "OAuthCore.h"
// prj
#import "OBPLogging.h"
#import "OBPAccessData.h"
#import "OBPWebViewProvider.h"
#import "NSString+OBP.h"



NSString* const OBPSessionAuthErrorDomain = @"OBPSessionAuth";



@interface OBPSessionAuth ()
{
	OBPAccessData*			_accessData;
	OBPWebViewProviderRef	_WVProvider;
	NSString*				_callbackURLString;
	NSString*				_requestToken;
	NSString*				_requestTokenSecret;
	NSString*				_verifier;
}
@property (nonatomic, readwrite) OBPSessionAuthState state;
@property (nonatomic, strong) HandleResultBlock validateCompletion;
@property (nonatomic, readwrite) BOOL valid;
@end



#pragma mark -
@implementation OBPSessionAuth
static NSMutableArray<OBPSessionAuth*>* sSessions = nil;
+ (void)initialize
{
	if (self != [OBPSessionAuth class])
		return;
	sSessions = [NSMutableArray array];
}
+ (nullable OBPSessionAuth*)currentSession
{
	return [sSessions firstObject];
}
+ (nullable instancetype)findSessionWithAccessData:(OBPAccessData*)accessData
{
	OBPSessionAuth* sessionAuth;
	for (sessionAuth in sSessions)
	if (sessionAuth->_accessData == accessData)
		return sessionAuth;
	return nil;
}
+ (nullable instancetype)sessionAuthWithAccessData:(OBPAccessData*)accessData
{
	OBPSessionAuth* sessionAuth;
	if (!accessData)
		return nil;
	if (nil != (sessionAuth = [self findSessionWithAccessData: accessData]))
		return sessionAuth;
	sessionAuth = [[self alloc] initWithAccessData: accessData
								   webViewProvider: [OBPWebViewProvider defaultProvider]];
	[sSessions addObject: sessionAuth];
	return sessionAuth;
}
+ (void)removeSession:(OBPSessionAuth*)sessionAuth
{
	[sSessions removeObjectIdenticalTo: sessionAuth];
}
+ (NSArray<OBPSessionAuth*>*)allSessions
{
	return [sSessions copy];
}
#pragma mark -
- (instancetype)initWithAccessData:(OBPAccessData*)accessData webViewProvider:(OBPWebViewProvider*)wvp
{
	if (!accessData)
		self = nil;
	else
		self = [super init];

	if (self)
	{
		self.webViewProvider = wvp;
		_accessData = accessData;
		NSDictionary* d = _accessData.data;
		if (0 != [d[OBPAccessData_TokenKey] length] * [d[OBPAccessData_TokenSecret] length])
			_valid = YES, _state = OBPSessionAuthStateValid;
	}

	return self;
}
#pragma mark -
- (void)validate:(HandleResultBlock)completion
{
	OBP_ASSERT(_state == OBPSessionAuthStateInvalid);
	if (_state == OBPSessionAuthStateInvalid)
	if (completion)
	{
		_validateCompletion = completion;
		_WVProvider = _webViewProvider; // Keep a strong reference to the webViewProvider for the duration of our athentication process.
		[self getAuthRequestToken];
	}
}
- (void)completedWith:(NSString*)token and:(NSString*)secret error:(NSError*)error // deliberately vague
{
	if ([token length] && [secret length])
		_state = OBPSessionAuthStateValid;
	else
		_state = OBPSessionAuthStateInvalid, token = secret = @"";
	_accessData.data = @{
		OBPAccessData_TokenKey		: token,
		OBPAccessData_TokenSecret	: secret,
	};
	_WVProvider = nil;
	_callbackURLString = nil;
	_requestToken = nil;
	_requestTokenSecret = nil;
	_verifier = nil;
	if (_validateCompletion)
	{
		HandleResultBlock validateCompletion = _validateCompletion;
		_validateCompletion = nil;
		validateCompletion(error);
	}
	self.valid = _state == OBPSessionAuthStateValid;
}
- (void)getAuthRequestToken
{
	NSDictionary*			d = _accessData.data;
	NSString*				base = d[OBPAccessData_AuthServerBase];
	NSString*				path = d[OBPAccessData_RequestPath];
	NSString*				consumerKey = d[OBPAccessData_ClientKey];
	NSString*				consumerSecret = d[OBPAccessData_ClientSecret];
	NSString*				callbackScheme;
	NSString*				header;
    STHTTPRequest*			request;
	STHTTPRequest __weak*	request_ifStillAround;

	path = [base stringForURLByAppendingPath: path];
	request_ifStillAround = request = [STHTTPRequest requestWithURLString: path];
	request.POSTDictionary = @{}; // --> method will be POST

	callbackScheme = _WVProvider.callbackScheme;
	if (![callbackScheme length])
		callbackScheme = [NSBundle mainBundle].bundleIdentifier;
	_callbackURLString = [callbackScheme stringByAppendingString: @"://callback"];

	header = OAuthHeader(
		request.url,
		request.POSTDictionary?@"POST":@"GET",
		[NSData data],
		consumerKey,
		consumerSecret,
		nil, // oauth_token
		nil, // oauth_token_secret
		nil, // oauth_verifier
		OAuthCoreSignatureMethod_HMAC_SHA256,
		_callbackURLString);

    [request setHeaderWithName: @"Authorization" value: header];

    request.completionBlock =
		^(NSDictionary *headers, NSString *body)
		{
			STHTTPRequest*	request = request_ifStillAround;
			NSInteger		status = request.responseStatus;
			NSDictionary*	response;
			NSString*		callbackResult;
			BOOL			completedStage = NO;

			if (status == 200)
			{
				body = [body stringByRemovingPercentEncoding];
				response = [body extractURLQueryParams];
				callbackResult = response[@"oauth_callback_confirmed"];
				if([callbackResult isEqualToString: @"true"])
				{
					_requestToken = response[@"oauth_token"];
					_requestTokenSecret = response[@"oauth_token_secret"];
					[self getUsersAuthorisation];
					completedStage = YES;
				}
			}

			if (!completedStage)
			{
				OBP_LOG(@"getAuthRequestToken request completion not successful: status=%d headers=%@ body=%@", (int)status, headers, body);
				[self completedWith: nil and: nil error: [NSError errorWithDomain: OBPSessionAuthErrorDomain code: OBPSessionAuthErrorCompletionUnsuccesful userInfo: @{@"status":@(status), NSURLErrorKey:request?request.url:[NSNull null]}]];
			}
		};

    request.errorBlock =
		^(NSError *error)
		{
			OBP_LOG(@"getAuthRequestToken got error %@", error);
			[self completedWith: nil and: nil error: [NSError errorWithDomain: OBPSessionAuthErrorDomain code: OBPSessionAuthErrorCompletionError userInfo: @{NSUnderlyingErrorKey:error,NSURLErrorKey:request_ifStillAround.url?:[NSNull null]}]];
		};
    
	_state = OBPSessionAuthStateValidating;
    [request startAsynchronous];
	self.valid = _state == OBPSessionAuthStateValid;
}
- (void)getUsersAuthorisation
{
	NSDictionary*			d = _accessData.data;
	NSString*				base = d[OBPAccessData_AuthServerBase];
	NSString*				path = d[OBPAccessData_GetUserAuthPath];
	NSURLComponents*		baseComponents = [NSURLComponents componentsWithString: base];
	NSURL*					url;

	baseComponents.path = path;
	baseComponents.queryItems = @[[NSURLQueryItem queryItemWithName: @"oauth_token" value: _requestToken]];
	url = baseComponents.URL; // returns nil if path not prefixed by "/"
	OBP_ASSERT(url);

	[_WVProvider showURL: url
		   filterNavWith:
		^BOOL(NSURL* url)
		{
			NSDictionary*	parameters;
			NSString*		requestToken;
			NSString*		urlString = [url absoluteString];

			if ([urlString hasPrefix: _callbackURLString])
			if (nil != (parameters = [url.query extractURLQueryParams]))
			if (nil != (requestToken = parameters[@"oauth_token"]))
			if ([_requestToken isEqualToString: requestToken])
			{
				_verifier = parameters[@"oauth_verifier"];
				[self getAccessToken];
				return YES;
			}

			return NO;
		}
		notifyCancelWith:
		^()
		{
			[self completedWith: nil and: nil error: [NSError errorWithDomain: NSCocoaErrorDomain code: NSUserCancelledError userInfo: @{NSURLErrorKey:url}]];
		}
	];
}
- (void)getAccessToken
{
	NSDictionary*			d = _accessData.data;
	NSString*				base = d[OBPAccessData_AuthServerBase];
	NSString*				path = d[OBPAccessData_GetTokenPath];
	NSString*				consumerKey = d[OBPAccessData_ClientKey];
	NSString*				consumerSecret = d[OBPAccessData_ClientSecret];
	NSString*				header;
    STHTTPRequest*			request;
	STHTTPRequest __weak*	request_ifStillAround;

	path = [base stringForURLByAppendingPath: path];
	request_ifStillAround = request = [STHTTPRequest requestWithURLString: path];
	request.POSTDictionary = @{}; // --> method will be POST

	header = OAuthHeader(
		request.url,
		request.POSTDictionary?@"POST":@"GET",
		[NSData data],
		consumerKey,
		consumerSecret,
		_requestToken, // oauth_token
		_requestTokenSecret, // oauth_token_secret
		_verifier, // oauth_verifier
		OAuthCoreSignatureMethod_HMAC_SHA256,
		_callbackURLString);

    [request setHeaderWithName: @"Authorization" value: header];

    request.completionBlock =
		^(NSDictionary *headers, NSString *body)
		{
			STHTTPRequest*	request = request_ifStillAround;
			NSInteger		status = request.responseStatus;
			NSDictionary*	response;
			NSString*		token;
			NSString*		secret;
			BOOL			completedStage = NO;

			if (status == 200)
			{
				body = [body stringByRemovingPercentEncoding];
				response = [body extractURLQueryParams];
				token = response[@"oauth_token"];
				secret = response[@"oauth_token_secret"];
				[self completedWith: token and: secret error: nil];
				completedStage = YES;
			}

			if (!completedStage)
			{
				OBP_LOG(@"getAccessToken request completion not successful: status=%d headers=%@ body=%@", (int)status, headers, body);
				[self completedWith: nil and: nil error: [NSError errorWithDomain: OBPSessionAuthErrorDomain code: OBPSessionAuthErrorCompletionUnsuccesful userInfo: @{@"status":@(status), NSURLErrorKey:request.url?:[NSNull null]}]];
			}
		};

    request.errorBlock =
		^(NSError *error)
		{
			OBP_LOG(@"getAccessToken got error %@", error);
			[self completedWith: nil and: nil error: [NSError errorWithDomain: OBPSessionAuthErrorDomain code: OBPSessionAuthErrorCompletionError userInfo: @{NSUnderlyingErrorKey:error,NSURLErrorKey:request_ifStillAround.url?:[NSNull null]}]];
		};
    
    [request startAsynchronous];
}
#pragma mark -
- (void)invalidate
{
	_accessData.data = @{
		OBPAccessData_TokenKey		: @"",
		OBPAccessData_TokenSecret	: @"",
	};
	_state = OBPSessionAuthStateInvalid;
	self.valid = _state == OBPSessionAuthStateValid;
//	could do instead...
//	[self completedWith: nil and: nil error: [NSError errorWithDomain: NSCocoaErrorDomain code: NSUserCancelledError userInfo:nil]];
//	...also need to ensure validate aborts if in progress.
}
#pragma mark -
- (HandleResultBlock)detectRevokeBlockWithChainToBlock:(HandleResultBlock)chainBlock
{
	HandleResultBlock	block =
		^(NSError* error)
		{
			switch (error.code)
			{
				case 401:
					OBP_LOG(@"Request got 401 Unauthorized => Access to server %@ revoked", _accessData.name);
					[self invalidate];
					break;

				case NSURLErrorUserAuthenticationRequired:
					if (![error.domain isEqualToString: NSURLErrorDomain])
						break;
					OBP_LOG(@"Request got NSURLErrorUserAuthenticationRequired => Access to server %@ revoked", _accessData.name);
					[self invalidate];
					break;
			}

			if (chainBlock != nil)
				chainBlock(error);
		};

	return block;
}
- (BOOL)authorizeSTHTTPRequest:(STHTTPRequest*)request
{
	OBP_ASSERT(_state == OBPSessionAuthStateValid);
	if (_state != OBPSessionAuthStateValid)
		return NO;

	NSDictionary*			d = _accessData.data;
	NSString*				consumerKey = d[OBPAccessData_ClientKey];
	NSString*				consumerSecret = d[OBPAccessData_ClientSecret];
	NSString*				tokenKey = d[OBPAccessData_TokenKey];
	NSString*				tokenSecret = d[OBPAccessData_TokenSecret];
	NSString*				header;

	OBP_ASSERT(0 != [consumerKey length] * [consumerSecret length] * [tokenKey length] * [tokenSecret length]);

	header = OAuthHeader(
		request.url,
		request.POSTDictionary?@"POST":@"GET",
		[NSData data],
		consumerKey,
		consumerSecret,
		tokenKey, // oauth_token
		tokenSecret, // oauth_token_secret
		nil, // oauth_verifier
		OAuthCoreSignatureMethod_HMAC_SHA256,
		nil); // callback

    [request setHeaderWithName: @"Authorization" value: header];

	// Chain error handler to detect if token has been revoked
	request.errorBlock = [self detectRevokeBlockWithChainToBlock: request.errorBlock];

	return YES;
}
- (BOOL)authorizeURLRequest:(NSMutableURLRequest*)request andWrapErrorHandler:(HandleResultBlock*)handlerAt
{
	OBP_ASSERT(_state == OBPSessionAuthStateValid);
	if (_state != OBPSessionAuthStateValid)
		return NO;

	NSDictionary*			d = _accessData.data;
	NSString*				consumerKey = d[OBPAccessData_ClientKey];
	NSString*				consumerSecret = d[OBPAccessData_ClientSecret];
	NSString*				tokenKey = d[OBPAccessData_TokenKey];
	NSString*				tokenSecret = d[OBPAccessData_TokenSecret];
	NSString*				header;

	OBP_ASSERT(0 != [consumerKey length] * [consumerSecret length] * [tokenKey length] * [tokenSecret length]);

	header = OAuthHeader(
		request.URL,
		request.HTTPMethod,
		[NSData data],
		consumerKey,
		consumerSecret,
		tokenKey, // oauth_token
		tokenSecret, // oauth_token_secret
		nil, // oauth_verifier
		OAuthCoreSignatureMethod_HMAC_SHA256,
		nil); // callback

    [request setValue: header forHTTPHeaderField: @"Authorization"];

	// Chain error handler to check if token has been revoked
	if (handlerAt)
	   *handlerAt = [self detectRevokeBlockWithChainToBlock: *handlerAt];

	return YES;
}
@end



