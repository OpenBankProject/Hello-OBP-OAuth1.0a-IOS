//
//  ReceiverVC.h
//  HelloOBP-iOS
//
//  Created by Torsten Louland on 03/10/2017.
//  Copyright © 2017 TESOBE. All rights reserved.
//

#import <UIKit/UIKit.h>



@class ReceiverVC;



@protocol ChooseReceiverClient <NSObject>
- (void)receiverVC:(ReceiverVC*)vc didChooseReceiverAccount:(NSDictionary*)receiverAccount;
@end
typedef NSObject<ChooseReceiverClient>* ChooseReceiverClientRef;



@interface ReceiverVC : UIViewController
- (void)setAccount:(NSDictionary*)account viewOfAccount:(NSDictionary*)viewOfAccount myOtherAccounts:(NSArray*)otherAccounts;
@property (nonatomic, copy) NSDictionary* banks;
@property (nonatomic, copy) NSDictionary* receiverAccount;
@property (nonatomic, weak) ChooseReceiverClientRef client;
@end
