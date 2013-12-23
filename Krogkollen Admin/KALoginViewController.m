//
//  KALoginViewController.m
//  Krogkollen Admin
//
//  Created by Johan Backman on 2013-12-14.
//  Copyright (c) 2013 Livsglädje. All rights reserved.
//

#import "KALoginViewController.h"
#import "KAMainViewController.h"
#import <Parse/Parse.h>

@interface KALoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@property BOOL logginIn;
@property BOOL keyboardUp;

@end

@implementation KALoginViewController

NSString * const MAIN_SEGUE_CONSTANT        = @"MainViewSegue";
int const LOGO_MOVE_DISTANCE                = 39;
int const TEXT_FIELD_MOVE_DISTANCE          = 82;
float const TEXT_FIELD_ANIMATION_DURATION   = 0.3f;

- (IBAction)userNameEditingDidBegin:(UITextField *)sender
{
    [self animateTextField: sender up: YES];
    if (!self.keyboardUp) {
        [self animateImageLogo: YES];
    }
}

- (IBAction)userNameEditingDidEnd:(UITextField *)sender
{
    [self animateTextField: sender up: NO];
    if (!self.keyboardUp) {
        [self animateImageLogo: NO];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
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
                                                self.logginIn = NO;
                                                [self.loginButton setHidden:NO];
                                                [self.loadingIndicator setHidden:YES];
                                                [self.loadingIndicator stopAnimating];
                                                // Reset both field so they're empty if the user logs out.
                                                [self.userNameTextField setText:@""];
                                                [self.passwordTextField setText:@""];
                                                // Present the main view.
                                                [self performSelector:@selector(showMainView) withObject:nil afterDelay:2.0];
                                                [self showMainView];
                                            } else {
                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login_failed_title", nil)
                                                                                                message:NSLocalizedString(@"Login_failed_body", nil)
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
    short addAmount = up ? LOGO_MOVE_DISTANCE : -LOGO_MOVE_DISTANCE;
    self.topConstraint.constant += addAmount;
    [self.logoImage setNeedsUpdateConstraints];
    [UIView animateWithDuration:.3 animations:^{
        [self.logoImage layoutIfNeeded];
    }];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    int movement = (up ? -TEXT_FIELD_MOVE_DISTANCE : TEXT_FIELD_MOVE_DISTANCE);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: TEXT_FIELD_ANIMATION_DURATION];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (BOOL)hasFourInchDisplay {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0);
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    self.keyboardUp = YES;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.keyboardUp = NO;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (IBAction)unwindToLogin:(UIStoryboardSegue *)segue
{
    [PFUser logOut];
}

- (void)showMainView {
    [self performSegueWithIdentifier:MAIN_SEGUE_CONSTANT sender:self];
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
    [self registerForKeyboardNotifications];
    // If the screen is of four inch size move the logotype slightly.
    if ([self hasFourInchDisplay])
        self.topConstraint.constant += 44;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
