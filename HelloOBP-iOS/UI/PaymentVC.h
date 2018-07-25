//
//  PaymentVC.h
//  HelloOBP-iOS
//
//  Created by Torsten Louland on 02/10/2017.
//  Copyright © 2017 TESOBE. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface PaymentVC : UIViewController
- (void)setAccount:(NSDictionary*)account viewOfAccount:(NSDictionary*)viewOfAccount otherAccounts:(NSArray*)otherAccounts;
@property (nonatomic, copy) NSDictionary* banks;
@end
