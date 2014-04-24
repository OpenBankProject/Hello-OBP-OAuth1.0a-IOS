//
//  ViewController.m
//  Hello-OBP-OAuth1.0a-IOS
//
//  Created by comp on 4/22/14.
//  Copyright (c) 2014 TESOBE. All rights reserved.
//

#import "ViewController.h"
#import "OAuth.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //check for OBP and authorize
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if(![defaults objectForKey:@"access_token"]){
		[self.connect setHidden:NO];
	}
	else{
        [self.connect setHidden:YES];
	}

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connectToOBP:(id)sender {
	OAuth *controller = [[OAuth alloc] init];
	[self presentViewController:controller animated:NO completion:nil];
    [self.connect setHidden:YES];
	
}

@end
