//
//  NSString+OBP.m
//  OBPKit
//
//  Created by Torsten Louland on 25/01/2016.
//  Copyright © 2016 TESOBE Ltd. All rights reserved.
//

#import "NSString+OBP.h"
// sdk
// prj
#import "OBPLogging.h"



@implementation NSString (OBP)
- (NSString*)stringByAppendingURLQueryParams:(NSDictionary*)dictionary
{
	NSCharacterSet*		allowedInQuery = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSMutableString*	str = [self mutableCopy];
	const char*			sep = [str rangeOfString:@"?"].length ? "&" : "?";
    
    for (id key in dictionary)
	{
        NSString *keyString = [key description];
        NSString *valString = [dictionary[key] description];
		keyString = [keyString stringByAddingPercentEncodingWithAllowedCharacters: allowedInQuery];
		valString = [valString stringByAddingPercentEncodingWithAllowedCharacters: allowedInQuery];
		[str appendFormat: @"%s%@=%@", sep, keyString, valString];
		sep = "&";
    }

    return [str copy];
}

-(NSDictionary *)extractURLQueryParams
{
    NSMutableDictionary	*params = [NSMutableDictionary dictionary];
    NSArray				*pairs, *elements;
	NSString			*pair, *key, *val;

	pairs = [self componentsSeparatedByString: @"&"];

    for (pair in pairs)
	{
        elements = [pair componentsSeparatedByString: @"="];
		OBP_LOG_IF(2 != [elements count], @"-extractQueryParams\nNot an element pair: %@\nQuery string: %@", pair, self);
		if ([elements count] != 2)
			continue;
		key = elements[0];
		val = elements[1];
        key = [key stringByRemovingPercentEncoding];
        val = [val stringByRemovingPercentEncoding];
        
        params[key] = val;
    }

    return [params copy];
}

- (NSString*)urlEscapeString:(NSString *)unencodedString
{
    CFStringRef originalStringRef = (CFStringRef)CFBridgingRetain(unencodedString);
    NSString *s = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,originalStringRef, NULL, NULL,kCFStringEncodingUTF8));
    CFRelease(originalStringRef);
    return s;
}

- (NSString*)stringForURLByAppendingPath:(NSString*)path
{
	if (path == nil)
		return self;
	BOOL	trailing = 0 != [self rangeOfString: @"/" options: NSAnchoredSearch+NSBackwardsSearch].length;
	BOOL	leading = 0 != [path rangeOfString: @"/" options: NSAnchoredSearch].length;
	if (trailing && leading) // too many
		path = [path substringFromIndex: 1], leading = NO;
	else
	if (!trailing && !leading) // too few
		path = [@"/" stringByAppendingString: path], leading = YES;
	path = [self stringByAppendingString: path];
	return path;
}
@end
