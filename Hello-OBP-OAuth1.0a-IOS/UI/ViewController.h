//
//  ViewController.h
//  Hello-OBP-OAuth1.0a-IOS
//
//  Created by Dunia Reviriego on 4/22/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController <UIAlertViewDelegate> {
    UIBarButtonItem *rightNavButton;    
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *rightNavButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *leftNavButton;
@property (strong, nonatomic) IBOutlet UIView *viewConnect;
@property (strong, nonatomic) IBOutlet UIView *viewLogin;
@property (strong, nonatomic) IBOutlet UIButton *connectBankAPI;
@property (strong, nonatomic) IBOutlet UIButton *linkReadme;
@property (strong, nonatomic) IBOutlet UIButton *linkOBPwebsite;


- (IBAction)accountsTableView:(id)sender;

- (IBAction)connectToBankAPI:(id)sender;

- (IBAction)linkToReadme:(id)sender;

- (IBAction)linkToOBPwebsite:(id)sender;

- (IBAction)logOut:(id)sender;

- (IBAction)about:(id)sender;

@end
