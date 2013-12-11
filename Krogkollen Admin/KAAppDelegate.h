//
//  KAAppDelegate.h
//  Krogkollen Admin
//
//  Created by Johan Backman on 2013-12-11.
//  Copyright (c) 2013 Livsglädje. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
