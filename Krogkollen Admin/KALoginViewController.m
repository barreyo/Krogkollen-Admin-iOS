//
//  KALoginViewController.m
//  Krogkollen Admin
//
//  Created by Johan Backman on 2013-12-14.
//  Copyright (c) 2013 Livsglädje. All rights reserved.
//

#import "KALoginViewController.h"
#import <Parse/Parse.h>
#import "KAMainViewController.h"

@interface KALoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@property BOOL logginIn;
@property BOOL logoTopState;

@end

@implementation KALoginViewController

- (IBAction)userNameEditingDidBegin:(UITextField *)sender {
    [self animateTextField: sender up: YES];
    [self animateImageLogo: YES];
}

- (IBAction)userNameEditingDidEnd:(UITextField *)sender {
    [self animateTextField: sender up: NO];
    if (!self.logoTopState) {
        [self animateImageLogo: NO];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.tag == 1) {
        UITextField *passwordTextField = (UITextField *)[self.view viewWithTag:2];
        [passwordTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
        [self login];
    }
    return YES;
}

- (IBAction)loginButtonAction:(id)sender
{
    [self login];
}

- (void) login
{
    if (self.logginIn == NO) {
        
        [self.loadingIndicator setHidden:NO];
        [self.loadingIndicator startAnimating];
        [self.loginButton setHidden:YES];
        
        [PFUser logInWithUsernameInBackground:self.userNameTextField.text password:self.passwordTextField.text
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {

                                            } else {
                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Inloggning misslyckades"
                                                                                                message:@"Fel användarnamn eller lösenord."
                                                                                               delegate:nil
                                                                                      cancelButtonTitle:@"OK"
                                                                                      otherButtonTitles:nil];
                                                [alert show];
                                                self.logginIn = NO;
                                                [self.loginButton setHidden:NO];
                                                [self.loadingIndicator setHidden:YES];
                                                [self.loadingIndicator stopAnimating];
                                            }
                                        }];
        self.logginIn = YES;
    }
}

- (void) animateImageLogo: (BOOL) up
{
    self.topConstraint.constant = up ? 112 : 73;
    [self.logoImage setNeedsUpdateConstraints];
    [UIView animateWithDuration:.3 animations:^{
        [self.logoImage layoutIfNeeded];
    }];
    self.logoTopState = !self.logoTopState;
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 82;
    const float movementDuration = 0.3f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
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
    self.logginIn = NO;
    [self.loadingIndicator setHidden:YES];
    self.userNameTextField.delegate = self;
    self.passwordTextField.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
