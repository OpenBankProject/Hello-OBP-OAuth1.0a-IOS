//
//  TransactionDetailViewController.h
//  HelloOBP-iOS
//
//  Created by Torsten Louland on 03/05/2016.
//  Copyright © 2016 TESOBE. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface TransactionDetailViewController : UIViewController
- (void)setAccount:(NSDictionary*)account viewOfAccount:(NSDictionary*)viewOfAccount transaction:(NSDictionary*)transaction;
@end
