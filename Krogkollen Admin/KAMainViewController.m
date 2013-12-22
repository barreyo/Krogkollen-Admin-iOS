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
}

- (void)updateInfo {
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm"];
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

- (void)initInfo {
    int queueValue = [[self.pub objectForKey:@"queueTime"] integerValue];
    [self setQueueText:queueValue];
    self.lastUpdatedText.title = [self convertEpochTime:[self.pub objectForKey:@"queueTimeLastUpdated"]];
}

- (NSString* )convertEpochTime:(NSString*) time {
    NSTimeInterval seconds = [time doubleValue];

    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm"];
    
    return [dateFormatter stringFromDate: epochNSDate];
}

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
