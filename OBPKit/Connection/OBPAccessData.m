//
//  OBPSessionCredentials.m
//  OBPKit
//
//  Created by Torsten Louland on 23/01/2016.
//  Copyright © 2016 TESOBE Ltd. All rights reserved.
//

#import "OBPAccessData.h"
// sdk
// ext
#import "KeychainItemWrapper.h"
// prj
#import "OBPLogging.h"



#define KEY_SEP @"~"



NSString* const OBPAccessData_APIBase			= @"APIBase";
NSString* const OBPAccessData_APIServer			= @"APIServer";
NSString* const OBPAccessData_APIVersion		= @"APIVersion";
NSString* const OBPAccessData_AuthServerBase	= @"AuthServerBase";
NSString* const OBPAccessData_RequestPath		= @"RequestPath";
NSString* const OBPAccessData_GetUserAuthPath	= @"GetUserAuthPath";
NSString* const OBPAccessData_GetTokenPath		= @"GetTokenPath";
NSString* const OBPAccessData_ClientKey			= @"ClientKey";			// aka Consumer Key
NSString* const OBPAccessData_ClientSecret		= @"ClientSecret";		// aka Consumer Key
NSString* const OBPAccessData_TokenKey			= @"TokenKey";			// aka AccessToken
NSString* const OBPAccessData_TokenSecret		= @"TokenSecret";		// aka AccessSecret



@interface OBPAccessData () <NSCoding>
{
	NSString*		_key;
	NSString*		_name;
	NSString*		_APIServer;
	NSString*		_APIVersion;
	NSString*		_APIBase;
	NSDictionary*	_AuthServerDict;

	BOOL			_valid;
}
@property (readonly) BOOL valid;
@end



@implementation OBPAccessData
static NSMutableArray<OBPAccessData*>* sEntries = nil;
static NSString* sSavePath = nil;
+ (void)initialize
{
	if (self != [OBPAccessData class])
		return;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSString*		name;
		NSString*		path;
		name = [NSBundle mainBundle].bundleIdentifier;
		name = [name stringByAppendingString: @".ad"];
		path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
		path = [path stringByAppendingPathComponent: name];
		path = [path stringByAppendingPathExtension: @"dat"];
		sSavePath = path;
		sEntries = path ? [NSKeyedUnarchiver unarchiveObjectWithFile: path] : nil;
		if (sEntries == nil)
			sEntries = [NSMutableArray array];
	});
}
+ (NSArray<OBPAccessData*>*)entries
{
	return [sEntries copy];
};
+ (void)save
{
	static BOOL savePending = NO;
	if (savePending)
		return;
	savePending = YES;
	dispatch_async(dispatch_get_main_queue(),
		^{
			savePending = NO;
			NSMutableArray* ma = [NSMutableArray array];
			for (OBPAccessData* entry in sEntries)
			if (entry.valid)
				[ma addObject:entry];
			[NSKeyedArchiver archiveRootObject: ma toFile: sSavePath];
		}
	);
}
+ (instancetype)defaultEntry
{
	OBPAccessData* entry = [sEntries firstObject];
	return entry;
}
+ (void)removeEntry:(OBPAccessData*)entry
{
	if (!entry)
		return;
	NSUInteger index = [sEntries indexOfObjectIdenticalTo: entry];
	if (index != NSNotFound)
	{
		[sEntries removeObjectAtIndex: index];
		// TODO: remove key chain entry
		if (entry.valid)
			[self save];
	}
}
+ (instancetype)addEntryForAPIServer:(NSString*)APIServer
{
	if (![APIServer length])
		return nil;
	NSURLComponents* components = [NSURLComponents componentsWithString: APIServer];
	OBP_LOG_IF(nil==components, @"[OBPAccessData addEntryForAPIServer: %@] - error: not valid as a URL", APIServer);
	if (nil==components)
		return nil;
	NSString* key = [[NSUUID UUID] UUIDString];
	OBPAccessData* entry = [[OBPAccessData alloc] initWithKey: key APIServerURLComponents: components];
	[sEntries addObject: entry];
	return entry;
}
+ (nullable OBPAccessData*)firstEntryForAPIServer:(NSString*)APIServer
{
	OBPAccessData*		entry;
	NSURLComponents*	components = [NSURLComponents componentsWithString: APIServer];
	NSString*			matchVersion;
	NSString*			matchServer;
	matchVersion = [self versionFromOBPPath: components.path];
	components.path = nil;
	matchServer = components.string;
	for (entry in sEntries)
	{
		if ([matchServer isEqualToString: entry->_APIServer])
		if (!matchVersion || [matchVersion isEqualToString: entry->_APIVersion])
			return entry;
	}
	return nil;
}
#pragma mark -
+ (NSString*)versionFromOBPPath:(NSString*)path
{
	if (!path)
		return nil;
	NSRange		rangeOBP;
	NSRange		rangeEnd;

	if ((rangeOBP = [path rangeOfString: @"obp/v"]).length)
	{
		path = [path substringFromIndex: rangeOBP.location + rangeOBP.length - 1];
		rangeEnd = [path rangeOfString: @"/"];
		if (rangeEnd.length)
			path = [path substringToIndex: rangeEnd.location];
		return path;
	}
	return nil;
}
+ (NSString*)APIBaseForServer:(NSString*)server andAPIVersion:(NSString*)version
{
	if (![server length] || ![version length])
		return nil;
	NSURLComponents* components;
	NSString* base;
	components = [NSURLComponents componentsWithString: server];
	components.path = [@"/obp/" stringByAppendingString: version];
	base = components.string;
	return base;
}
#pragma mark -
- (instancetype)initWithKey:(NSString*)key APIServerURLComponents:(NSURLComponents*)components
{
	if (nil == (self = [super init]))
		return nil;
	_key = key;
	_name = components.host;
	_APIVersion = [[self class] versionFromOBPPath: components.path] ?: @"v1.2";
	components.path = nil;
	_APIServer = components.string;
	_APIBase = [[self class] APIBaseForServer: _APIServer andAPIVersion: _APIVersion];
	_AuthServerDict = @{
		OBPAccessData_AuthServerBase	:	_APIServer,
		OBPAccessData_RequestPath		:	@"/oauth/initiate",
		OBPAccessData_GetUserAuthPath	:	@"/oauth/authorize",
		OBPAccessData_GetTokenPath		:	@"/oauth/token",
	};
	return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (nil == (self = [super init]))
		return nil;
	_key = [aDecoder decodeObjectForKey: @"key"];
	_name = [aDecoder decodeObjectForKey: @"name"];
	_APIServer = [aDecoder decodeObjectForKey: @"APIServer"];
	_APIVersion = [aDecoder decodeObjectForKey: @"APIVersion"];
	_APIBase = [aDecoder decodeObjectForKey: @"APIBase"];
	_AuthServerDict = [aDecoder decodeObjectForKey: @"AuthServerDict"];
	_valid = [aDecoder decodeBoolForKey: @"valid"];
	return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject: _key forKey: @"key"];
	[aCoder encodeObject: _name forKey: @"name"];
	[aCoder encodeObject: _APIServer forKey: @"APIServer"];
	[aCoder encodeObject: _APIVersion forKey: @"APIVersion"];
	[aCoder encodeObject: _APIBase forKey: @"APIBase"];
	[aCoder encodeObject: _AuthServerDict forKey: @"AuthServerDict"];
	[aCoder encodeBool: _valid forKey: @"valid"];
}
- (void)save
{
	if (_valid)
		[[self class] save];
}
#pragma mark -
- (KeychainItemWrapper*)kciWrapper
{
	KeychainItemWrapper*	wrapper;
	NSString*				wrapperID;
	wrapperID = [NSBundle mainBundle].bundleIdentifier;
	wrapperID = [wrapperID stringByAppendingFormat: @".cr.%@", _key];
	wrapper = [[KeychainItemWrapper alloc] initWithIdentifier: wrapperID accessGroup: nil];
	return wrapper;
}
- (void)storeIntoKC:(NSDictionary*)keyDict
{
	NSString*				keys = // For now...
		[NSString stringWithFormat:
			@"%@" KEY_SEP @"%@" KEY_SEP @"%@" KEY_SEP @"%@",
			keyDict[OBPAccessData_ClientKey]	?: @"",
			keyDict[OBPAccessData_ClientSecret]	?: @"",
			keyDict[OBPAccessData_TokenKey]		?: @"",
			keyDict[OBPAccessData_TokenSecret]	?: @""
		];

	[[self kciWrapper] setObject: keys forKey: (__bridge id)kSecValueData];
}
- (NSMutableDictionary*)fetchFromKC
{
	NSMutableDictionary*	keyDict = [NSMutableDictionary dictionary];
	NSString*				keys = KEY_SEP KEY_SEP KEY_SEP;
	id						value;

	value = [[self kciWrapper] objectForKey: (__bridge id)kSecValueData];
	if ([value isKindOfClass: [NSString class]] && [value length])
		keys = value;

	NSArray* keyArray = [keys componentsSeparatedByString: KEY_SEP];
	if ([keyArray count] == 4)
	{
		keyDict[OBPAccessData_ClientKey]	= keyArray[0];
		keyDict[OBPAccessData_ClientSecret]	= keyArray[1];
		keyDict[OBPAccessData_TokenKey]		= keyArray[2];
		keyDict[OBPAccessData_TokenSecret]	= keyArray[3];
	}

	return keyDict;
}
#pragma mark -
- (void)setData:(NSDictionary*)data
{
	if (nil == data)
		return;
	BOOL			changed = NO;
	BOOL			changedKC = NO;
	NSString*		APIVersion = nil;
	NSString		*s0, *s1, *k;

	// Check for API version either explicitly or within API base
	if ([(s0 = data[OBPAccessData_APIVersion]) length])
		APIVersion = s0;
	else
	if ([(s0 = data[OBPAccessData_APIBase]) length])
	if (![s0 isEqualToString: _APIBase])
		APIVersion = s0.lastPathComponent;

	// Check if API version is changed
	if (APIVersion && ![APIVersion isEqualToString: _APIVersion])
	{
		_APIVersion = APIVersion;
		_APIBase = [[self class] APIBaseForServer: _APIServer andAPIVersion: _APIVersion];
		changed = YES;
	}

	// For Auth server base and paths, check for and apply any new non-empty values
	NSMutableDictionary* md = [_AuthServerDict mutableCopy];
	for (k in @[OBPAccessData_AuthServerBase, OBPAccessData_RequestPath,
				OBPAccessData_GetUserAuthPath, OBPAccessData_GetTokenPath])
	{
		if ([(s0 = data[k]) length])
		if (![(s1 = md[k]) isEqualToString: s0])
			md[k] = s0;
	}
	if (![_AuthServerDict isEqualToDictionary: md])
		_AuthServerDict = [md copy], changed = YES;

	// If any credentials have been supplied, check and store updates if necessary
	if (data[OBPAccessData_ClientKey]
	 || data[OBPAccessData_ClientSecret]
	 || data[OBPAccessData_TokenKey]
	 || data[OBPAccessData_TokenSecret])
	{
		// Fetch current credentials
		md = [self fetchFromKC];

		// Set client key and secret if not already set
		for (k in @[OBPAccessData_ClientKey, OBPAccessData_ClientSecret])
		if ([(s0 = data[k]) length])
		if (![(s1 = md[k]) length])
			md[k] = s0, changedKC = YES;

		// Always update token key and secret, including setting to empty (==logged out or revoked access)
		for (k in @[OBPAccessData_TokenKey, OBPAccessData_TokenSecret])
		if (nil != (s0 = data[k]))
		if (![(s1 = md[k]) isEqualToString: s0])
			md[k] = s0, changedKC = YES;

		if (changedKC)
			[self storeIntoKC: md];
		_valid = 0 != [md[OBPAccessData_ClientKey] length] * [md[OBPAccessData_ClientSecret] length];
	}

	if (changed)
		[self save];
}
- (NSDictionary*)data
{
	// load data from key chain and return (never store; we only store retrieval params)
	NSMutableDictionary*	md = [self fetchFromKC];
	md[OBPAccessData_APIServer] = _APIServer;
	md[OBPAccessData_APIVersion] = _APIVersion;
	md[OBPAccessData_APIBase] = _APIBase;
	[md addEntriesFromDictionary: _AuthServerDict];
	return [md copy];
}
#pragma mark -
- (void)setName:(NSString*)name
{
	if (![name length])
		name = [NSURLComponents componentsWithString: _APIServer].host;
	if ([name isEqualToString: _name])
		return;
	_name = name;
	[self save];
}
@end


