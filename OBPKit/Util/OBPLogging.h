//
//  OBPLogging.h
//  OBPKit
//
//  Created by Torsten Louland on 24/01/2016.
//  Copyright © 2016 TESOBE Ltd. All rights reserved.
//

#ifndef OBPLogging_h
#define OBPLogging_h
// ...OBPLogging_h is inclusion guard

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#else
#include <stdio.h>
#endif

#ifndef OBP_LOG /* if not superceded by replacement definitions... */
	#ifndef OBP_NO_LOGGING /* if logging not suppressed... */

		/* OBP_LOG_BASE = bottleneck for all log output */
		#define OBP_LOG_BASE(fmt, ...) do{NSLog(fmt, __VA_ARGS__);}while(0)

		/* OBP_LOG = normal route for output; always in debug; conditional and by default off in release */
		#if DEBUG
			#define OBP_LOG(fmt, ...) OBP_LOG_BASE(fmt, ##__VA_ARGS__)
		#else
			#ifndef OBP_RELEASE_LOGGING
				#define OBP_RELEASE_LOGGING 0
			#endif
			#define OBP_LOG(fmt, ...) do{if(OBP_RELEASE_LOGGING)OBP_LOG_BASE(fmt, ##__VA_ARGS__);}while(0)
		#endif

		/* OBP_LOG_DR = exceptional route for output to be made in both in debug and release */
		#define OBP_LOG_DR(fmt, ...) OBP_LOG_BASE(fmt, ##__VA_ARGS__)

	#else
		#define OBP_LOG_BASE(fmt, ...)
		#define OBP_LOG_DR(fmt, ...)
		#define OBP_LOG(fmt, ...)
	#endif
#endif

#ifndef OBP_BREAK
	#define OBP_BREAK do{}while(0)
#endif

#define OBP_LOG_IF(test, fmt, ...) do{if(test)OBP_LOG(fmt, ##__VA_ARGS__);}while(0)
#define OBP_ASSERT(test) do{if(!(test)){OBP_LOG(@"Assert %s failed (%s:%d)", #test, __PRETTY_FUNCTION__, __LINE__);OBP_BREAK;}}while(0)

#endif /* OBPLogging_h */
