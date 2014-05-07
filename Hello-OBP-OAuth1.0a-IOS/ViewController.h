//
//  ViewController.h
//  Hello-OBP-OAuth1.0a-IOS
//
//  Created by comp on 4/22/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController <UIAlertViewDelegate> {
    UIBarButtonItem *rightNavButton;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *rightNavButton;
@property (strong, nonatomic) IBOutlet UIView *viewConnect;
@property (strong, nonatomic) IBOutlet UIView *viewData;
@property (strong, nonatomic) IBOutlet UIButton *connect;
@property (strong, nonatomic) IBOutlet UIButton *linkOBP;
@property (strong, nonatomic) IBOutlet UILabel *messageYesAutheticate;
@property (strong, nonatomic) IBOutlet UITextView *textJSON;

- (IBAction)logOut:(id)sender;

- (IBAction)connectToOBP:(id)sender;

- (IBAction)connectToGitHub:(id)sender;

@end
