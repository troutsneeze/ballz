//
//  BallzAppDelegate.h
//  Ballz
//
//  Created by Trent Gamblin on 11-05-29.
//  Copyright 2011 Nooskewl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BallzViewController;

@interface BallzAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet BallzViewController *viewController;

@end
