//
//  Bobby_LiteAppDelegate.h
//  Bobby Lite
//
//  Created by Trent Gamblin on 11-09-03.
//  Copyright 2011 Nooskewl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Bobby_LiteViewController;

@interface Bobby_LiteAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet Bobby_LiteViewController *viewController;

@end
