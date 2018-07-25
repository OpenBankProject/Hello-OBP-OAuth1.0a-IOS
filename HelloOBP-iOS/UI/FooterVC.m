//
//  FooterVC.m
//  HelloOBP-iOS
//
//  Created by Torsten Louland on 02/10/2017.
//  Copyright © 2017 TESOBE. All rights reserved.
//

#import "FooterVC.h"
#import "MainViewController.h"



@interface FooterVC ()
@property (strong, nonatomic) IBOutlet UIButton* linkButton;
@end



@implementation FooterVC

- (void)viewDidLoad {
	[super viewDidLoad];

	self.linkButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
	self.linkButton.titleLabel.numberOfLines = 2;
	NSString* appName = [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
	NSString* linkTitle = [NSString stringWithFormat: @"%@ is demo for app designers.\nTo find out more visit the Open Bank Project.", appName];
	[self.linkButton setTitle: linkTitle forState:UIControlStateNormal];
}

- (IBAction)footerLinkAction:(id)sender {
	[MainViewController linkToOBPwebsite: self];
}

@end
