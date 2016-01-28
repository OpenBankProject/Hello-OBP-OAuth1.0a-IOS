//
//  OBPWebViewProvider.h
//  OBPKit
//
//  Created by Torsten Louland on 24/01/2016.
//  Copyright © 2016 TESOBE Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN



typedef BOOL(^OBPWebNavigationFilter)(NSURL*); // return YES if URL consumed



@protocol OBPWebViewProvider <NSObject>
- (void)showURL:(NSURL*)url filterNavWith:(OBPWebNavigationFilter)navigationFilter notifyCancelWith:(void(^)())canceled; ///< show url in a webview, pass page navigation and redirects through navigationFilter, and call cancelled if the web view is closed by the user. \param url locates the web page in which the user will authorise client access to his/her resources. \param navigationFilter should be called with every new url to be loaded in the page, and will return YES when the authorisation callback url is detected, signifying that the provider should close the webview. \param cancel should be called if the user closes the webview.

- (NSString*)callbackScheme; ///< recommend the URL scheme that should be used for OAuth callbacks (i.e. when redirecting with the result of user's login); this can be a simple scheme for embedded web views, but if the provider shows an external webview, then the scheme needs to be one which the OS recognises as exclusively handled by this app.
@end



@interface OBPWebViewProvider : NSObject <OBPWebViewProvider>
+ (instancetype)defaultProvider;
+ (NSString*)defaultCallbackScheme;
@end



NS_ASSUME_NONNULL_END
