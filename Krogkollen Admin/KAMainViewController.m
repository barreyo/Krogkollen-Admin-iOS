//
//  KAMainViewController.m
//  Krogkollen Admin
//
//  Created by Johan Backman on 2013-12-17.
//  Copyright (c) 2013 Livsglädje. All rights reserved.
//

#import "KAMainViewController.h"

@interface KAMainViewController ()

@end

@implementation KAMainViewController

- (IBAction)unwindToLogin:(UIStoryboardSegue *)segue
{
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
