//
//  JSONUnpackUtils.m
//  HelloOBP-iOS
//
//  Created by Torsten Louland on 15/10/2017.
//  Copyright © 2017 TESOBE. All rights reserved.
//

#import "JSONUnpackUtils.h"



@implementation NSDictionary (JSONUnpack)
- (NSString*)salientStringAtKeyPath:(NSString*)keyPath
{
	NSString*	s = [self valueForKeyPath: keyPath];
	if ([s isKindOfClass: [NSString class]])
	if ([s length])
	if (![@[ @"null", @"NULL" ] containsObject: s])
		return s;
	return nil;
}
- (NSString*)salientDescriptionAtKeyPath:(NSString*)keyPath
{
	id			obj = [self valueForKeyPath: keyPath];
	if ([obj isKindOfClass: [NSNull class]])
		return nil;
	NSString*	s = [obj description];
	if ([s length])
	if (![@[ @"null", @"NULL" ] containsObject: s])
		return s;
	return nil;
}
@end
