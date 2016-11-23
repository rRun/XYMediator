//
//  XYViewController.m
//  XYMediator
//
//  Created by hexy on 11/15/2016.
//  Copyright (c) 2016 hexy. All rights reserved.
//

#import "XYViewController.h"

#import "XYAppDelegate.h"

@interface XYViewController ()

@end

@implementation XYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
   // [XYRouter openURL:@"app://modulea"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)didJump:(id)sender {
    [XYRouter openURL:@"app://profile/123"];
}

@end
