//
//  OBPSessionCredentials.h
//  OBPKit
//
//  Created by Torsten Louland on 23/01/2016.
//  Copyright © 2016 TESOBE Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN



// Keys for values in -[OBPAccessData data]
extern NSString* const OBPAccessData_APIServer;			// e.g. https://apisandbox.openbankproject.com
extern NSString* const OBPAccessData_APIVersion;		// e.g. v1.1
extern NSString* const OBPAccessData_APIBase;			// e.g. https://apisandbox.openbankproject.com/obp/v1.1
extern NSString* const OBPAccessData_AuthServerBase;	// e.g. https://apisandbox.openbankproject.com
extern NSString* const OBPAccessData_RequestPath;		// default: /oauth/initiate
extern NSString* const OBPAccessData_GetUserAuthPath;	// default: /oauth/authorize
extern NSString* const OBPAccessData_GetTokenPath;		// default: /oauth/token
extern NSString* const OBPAccessData_ClientKey;			// (aka Consumer Key)
extern NSString* const OBPAccessData_ClientSecret;		// (aka Consumer Key)
extern NSString* const OBPAccessData_TokenKey;			// (aka AccessToken)
extern NSString* const OBPAccessData_TokenSecret;		// (aka AccessSecret)



/*
OBPAccessData
-	An OBPAccessData instance records the data necessary to access an OBP server, storing keys and secrets securely in the key chain.
-	The OBPAccessData class keeps a persistant record of all complete instances. An instance is complete once its client key and secret have been set.


*/
@interface OBPAccessData : NSObject
+ (nullable instancetype)addEntryForAPIServer:(NSString*)APIServer; ///< add a new instance for accessing the OBP server at url APIServer to the  instance recorded by the class. \return the new instance. \note if you pass in the API base url, the API server and version will be identified. \note you can have more than one instance for the same server, typically for use with different user logins, and they are differentiated by the unique key property; for user interface, you can differentiate them using the name property.
+ (nullable OBPAccessData*)firstEntryForAPIServer:(NSString*)APIServer;
+ (nullable OBPAccessData*)defaultEntry; ///< returns the earliest instance still held. (a convenience when only ever using a single entry)
+ (NSArray<OBPAccessData*>*)entries;
+ (void)removeEntry:(OBPAccessData*)entry;
@property (nonatomic, copy) NSString* name; ///< A differentiating name for use in user interface; set to the API host by default
@property (nonatomic, strong, readonly) NSString* APIServer; ///< url string for the API server
@property (nonatomic, strong, readonly) NSString* APIVersion; ///< string for the version of the API to use
@property (nonatomic, strong, readonly) NSString* APIBase; ///< base url for API calls, formed using the APIServer and APIVersion properties
@property (nonatomic, copy) NSDictionary* data; ///< Get/set access data. When getting data, the returned dictionary contains values for all the OBPAccessData_<xxx> keys defined above, with derived and default values filled in as necessary. When setting data, copies only the values for the OBPAccessData_<xxx> keys defined above, while leaving other held values unchanged; the API host is never changed after the instance has been created, regardless of values passed in for the keys OBPAccessData_APIServer and OBPAccessData_APIBase; the client key and secret are not changable once set.
@end



NS_ASSUME_NONNULL_END

/*
aka OBPServerDetail


-	APIBase
	-	unique key
	-	if credentials shared across API versions, then 
		-	use OBPServerURL as key (server/obp)
+	session data by API base
+	add session data for API base
-	(or just by/for server if credentials shared across API versions)

-	data
	-	get: loaded from key chain and passed
	-	set: verified, and written to key chain

-	name
	-	convenience if renaming from server host


+ (instancetype)defaults;
- (NSDictionary*)credentials;
- (NSDictionary*)credentialsForServer:(NSURL*)url;

singleton to provide per server (we don't know account because hidden behind OAuth, so only one set per server)
or instance per server?

want a default resource to be set up by default build, which doesn't require source code or resource to be modified; use script to create default credential files outside repo

*/
