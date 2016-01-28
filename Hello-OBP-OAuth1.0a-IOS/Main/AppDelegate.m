//
//  AppDelegate.m
//  Hello-OBP-OAuth1.0a-IOS
//
//  Created by Dunia Reviriego on 5/14/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import "AppDelegate.h"
//
#import "OBPAccessData.h"
// prj
#import "DefaultServerDetails.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // to change the status bar style, also it´s necessary to change in .plist the key named “View controller-based status bar appearance” = NO
    NSLog(@"iPhone = %@", [[UIDevice currentDevice] systemVersion]);
    
    if (![[[UIDevice currentDevice] systemVersion] isEqualToString: @"6.1"]) {
        
   

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // to change the background color of navigation bar
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x409d85)]; 
    //  to change the color of back button
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    // to assign a custom backgroung image
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"logo-obp only text.png"] forBarMetrics:UIBarMetricsDefault];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);

    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"STHeitiTC-Light" size:14.0], NSFontAttributeName, nil]];
     }
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];

	UIStoryboard *story = [UIStoryboard storyboardWithName: @"Main" bundle: Nil];
	[_window setRootViewController:[story instantiateInitialViewController]];

    [self.window makeKeyAndVisible];

	if (nil == [OBPAccessData firstEntryForAPIServer: kDefaultServer_APIBase])
	{
		OBPAccessData*	accessData;
		accessData = [OBPAccessData addEntryForAPIServer: kDefaultServer_APIBase];
		accessData.data = DefaultServerDetails();
	}

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
