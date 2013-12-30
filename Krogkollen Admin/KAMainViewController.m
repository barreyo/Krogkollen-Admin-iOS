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

- (IBAction)updateQueueTime:(UIButton *)sender {
    self.currentQueueTime = sender.tag;
    [self setQueueText:self.currentQueueTime];
    [self updateInfo];
    [self clearNotifications];
    [self scheduleUpdateReminder];
}

- (void)updateInfo {
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *resultString = [dateFormatter stringFromDate: currentTime];
    [self.pub setObject:[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]] forKey:@"queueTimeLastUpdated"];
    [self.pub setObject:[NSNumber numberWithInt:self.currentQueueTime] forKey:@"queueTime"];
    self.lastUpdatedText.title = resultString;
    [self.pub saveInBackground];
}

- (void) setQueueText: (int) queueValue {
    NSString* queueText;
    switch (queueValue) {
        case 1:
            queueText = @"GRÖN";
            break;
        case 2:
            queueText = @"GUL";
            break;
        case 3:
            queueText = @"RÖD";
            break;
        default:
            queueText = @"INGEN";
            break;
    }
    self.currentQueueText.title = queueText;
}

- (void) scheduleUpdateReminder {
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:(60 * 30)];
    localNotification.alertBody = @"Kötiden har inte uppdaterats på 30 minuter. Uppdatera.";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)initInfo {
    int queueValue = [[self.pub objectForKey:@"queueTime"] integerValue];
    [self setQueueText:queueValue];
    self.lastUpdatedText.title = [self convertEpochTime:[self.pub objectForKey:@"queueTimeLastUpdated"]];
}

- (NSString* )convertEpochTime:(NSString*) time {
    NSTimeInterval seconds = [time doubleValue];

    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    return [dateFormatter stringFromDate: epochNSDate];
}

- (void) clearNotifications {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization    
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Handle launching from a notification
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // Set icon badge number to zero
        [self clearNotifications];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uppdatera"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    [self clearNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentUser = [PFUser currentUser];
    if (self.currentUser) {
        PFQuery *query = [PFQuery queryWithClassName:@"Pub"];
        [query whereKey:@"owner" equalTo:self.currentUser];
        self.pub = [query getFirstObject];
        [self.navBar setTitle:self.currentUser.username];
        [self initInfo];
    } else {
        [self dismissViewControllerAnimated: YES completion: nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
