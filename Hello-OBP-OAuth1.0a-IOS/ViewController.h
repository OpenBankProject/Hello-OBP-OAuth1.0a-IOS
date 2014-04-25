//
//  ViewController.h
//  Hello-OBP-OAuth1.0a-IOS
//
//  Created by comp on 4/22/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *connect;
@property (strong, nonatomic) IBOutlet UILabel *message;

- (IBAction)connectToOBP:(id)sender;

@end
