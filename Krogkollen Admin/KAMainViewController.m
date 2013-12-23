//
//  KAMainViewController.m
//  Krogkollen Admin
//
//  Created by Johan Backman on 2013-12-17.
//  Copyright (c) 2013 Livsglädje. All rights reserved.
//

#import "KAMainViewController.h"
#import <Parse/Parse.h>

@interface KAMainViewController ()

@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
@property (weak, nonatomic) IBOutlet UIButton *greenButton;
@property (weak, nonatomic) IBOutlet UIButton *yellowButton;
@property (weak, nonatomic) IBOutlet UIButton *redButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lastUpdatedText;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *currentQueueText;
@property PFUser* currentUser;
@property PFObject* parseObject;
@property PFObject* pub;
@property int currentQueueTime;

@end

@implementation KAMainViewController

NSString *QUEUE_TIME_STRING                 = @"queueTime";
NSString *QUEUE_TIME_LAST_UPDATED_STRING    = @"queueTimeLastUpdated";
NSString *PUB_STRING                        = @"Pub";
NSString *OWNER_STRING                      = @"Owner";
NSString *TIME_FORMAT_STRING                = @"hh:mm";

- (IBAction)updateQueueTime:(UIButton *)sender {
    // The buttons in the view are tagged 1-3, the same as the queue scale.
    self.currentQueueTime = sender.tag;
    [self setQueueText:self.currentQueueTime];
    [self updateInfo];
}

- (void)updateInfo {
    // Show update time in the GUI.
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:TIME_FORMAT_STRING];
    NSString *resultString = [dateFormatter stringFromDate: currentTime];
    // Sending epoch time to the server and not the time from above.
    [self.pub setObject:[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]] forKey:QUEUE_TIME_LAST_UPDATED_STRING];
    [self.pub setObject:[NSNumber numberWithInt:self.currentQueueTime] forKey:QUEUE_TIME_STRING];
    self.lastUpdatedText.title = resultString;
    [self.pub saveInBackground];
}

- (void) setQueueText: (int) queueValue {
    NSString* queueText;
    switch (queueValue) {
        case 1:
            queueText = NSLocalizedString(@"Queue_color_green", nil);
            break;
        case 2:
            queueText = NSLocalizedString(@"Queue_color_yellow", nil);
            break;
        case 3:
            queueText = NSLocalizedString(@"Queue_color_red", nil);
            break;
        default:
            queueText = NSLocalizedString(@"Queue_no_queue", nil);
            break;
    }
    self.currentQueueText.title = queueText;
}

- (void)initInfo {
    int queueValue = [[self.pub objectForKey:QUEUE_TIME_STRING] integerValue];
    [self setQueueText:queueValue];
    self.lastUpdatedText.title = [self convertEpochTime:[self.pub objectForKey:QUEUE_TIME_LAST_UPDATED_STRING]];
    [self.navBar setTitle:self.currentUser.username];
}

// Converts time from 1970 to current time with the correct timezone.
- (NSString* )convertEpochTime:(NSString*) time {
    NSTimeInterval seconds = [time doubleValue];

    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:TIME_FORMAT_STRING];
    
    return [dateFormatter stringFromDate: epochNSDate];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization    
    }
    return self;
}

- (IBAction)unwindToMain:(UIStoryboardSegue *)segue
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentUser = [PFUser currentUser];
    
    // Check if the current user is logged in.
    if (self.currentUser) {
        // Find the pub corresponding to the user.
        PFQuery *query = [PFQuery queryWithClassName:PUB_STRING];
        [query whereKey:OWNER_STRING equalTo:self.currentUser];
        self.pub = [query getFirstObject];
        //Initiate information from the server.
        [self initInfo];
    } else {
        // Move back to login if the user is not logged in.
        [self dismissViewControllerAnimated: YES completion: nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
