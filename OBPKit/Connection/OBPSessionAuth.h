//
//  OBPSessionAuth.h
//  OBPKit
//
//  Created by Torsten Louland on 23/01/2016.
//  Copyright © 2016 TESOBE Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN



extern NSString* const	OBPSessionAuthErrorDomain;
NS_ENUM(NSInteger) {	OBPSessionAuthErrorCompletionUnsuccesful		= 4096,
						OBPSessionAuthErrorCompletionError				= 4097,
};



@class OBPAccessData;
@class OBPWebViewProvider;
@protocol OBPWebViewProvider;
typedef NSObject<OBPWebViewProvider>* OBPWebViewProviderRef;
@class STHTTPRequest;



typedef void(^HandleResultBlock)(NSError* _Nullable);



typedef NS_ENUM(uint8_t, OBPSessionAuthState)
{
	OBPSessionAuthStateInvalid,
	OBPSessionAuthStateValid,
	OBPSessionAuthStateInvalidating,
	OBPSessionAuthStateValidating,
};



@interface OBPSessionAuth : NSObject
+ (nullable instancetype)sessionAuthWithAccessData:(OBPAccessData*)accessData;
+ (nullable OBPSessionAuth*)findSessionWithAccessData:(OBPAccessData*)accessData;
+ (void)removeSession:(OBPSessionAuth*)sessionAuth;
+ (nullable OBPSessionAuth*)currentSession;
+ (NSArray<OBPSessionAuth*>*)allSessions;

- (BOOL)authorizeSTHTTPRequest:(STHTTPRequest*)request; ///< call as last step before launching an STHTTPRequest
- (BOOL)authorizeURLRequest:(NSMutableURLRequest*)request
		andWrapErrorHandler:(HandleResultBlock _Nullable * _Nonnull)handlerAt; ///< call as last step before launching an NSURLRequest. \param handlerAt points to your error handler block, which will be replaced by one belonging to this instance, and which will in turn call the original handler; this step is necessary so that revoked access can be detected.

@property (nonatomic, weak, nullable) OBPWebViewProviderRef webViewProvider; // defaults to -[OBPWebViewProvider defaultProvider]

@property (nonatomic, strong, readonly) OBPAccessData* accessData;
@property (nonatomic, readonly) OBPSessionAuthState state;
@property (nonatomic, readonly) BOOL valid; // convenience, usable with KVO

- (void)validate:(HandleResultBlock)completion; // log in, interracting if necessary; make session usable
- (void)invalidate; // log out, make session no longer usable.

@end



NS_ASSUME_NONNULL_END
