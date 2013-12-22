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
    switch (sender.tag) {
        case 1:
            self.currentQueueTime = 1;
            self.currentQueueText.title = @"GRÖN";
            break;
        case 2:
            self.currentQueueTime = 2;
            self.currentQueueText.title = @"GUL";
            break;
        case 3:
            self.currentQueueTime = 3;
            self.currentQueueText.title = @"RÖD";
            break;
        default:
            break;
    }
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

- (void)initInfo {
    self.lastUpdatedText.title = [self convertEpochTime:[self.pub objectForKey:@"queueTimeLastUpdated"]];
}

- (NSString* )convertEpochTime:(NSString*) time {
    NSTimeInterval seconds = [time doubleValue];

    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm"];
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentUser = [PFUser currentUser];
    if (self.currentUser) {
        PFQuery *query = [PFQuery queryWithClassName:@"Pub"];
        [query whereKey:@"owner" equalTo:self.currentUser];
        self.pub = [query getFirstObject];
        NSLog(self.pub.description);
        [self.navBar setTitle:self.currentUser.username];
        [self initInfo];
    } else {
        // RETURN TO LOGIN
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
