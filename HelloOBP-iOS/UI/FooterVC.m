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
	[self.linkButton setTitle: @"Hello-OBP-iOS is demo for app designers.\nTo find out more visit the Open Bank Project." forState:UIControlStateNormal];
}

- (IBAction)footerLinkAction:(id)sender {
	[MainViewController linkToOBPwebsite: self];
}

@end
