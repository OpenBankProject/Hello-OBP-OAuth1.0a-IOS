//
//  JSONUnpackUtils.h
//  HelloOBP-iOS
//
//  Created by Torsten Louland on 15/10/2017.
//  Copyright © 2017 TESOBE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSONUnpack)
- (NSString*)salientStringAtKeyPath:(NSString*)keyPath; // non-empty, and not null
- (NSString*)salientDescriptionAtKeyPath:(NSString*)keyPath; // non-empty description of non-null
@end
