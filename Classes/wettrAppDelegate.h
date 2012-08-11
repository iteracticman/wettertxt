//
//  wettrAppDelegate.h
//  wettr
//
//  Created by Peter Weishapl on 29.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "wettrViewController.h"

@interface wettrAppDelegate : NSObject <UIApplicationDelegate, WettrViewControllerDelegate> {
	UIWindow *window;
	UITabBarController* tabController;
	NSUInteger loadCount;
}

@property IBOutlet UIWindow *window;
@property IBOutlet UITabBarController *tabController;

@end

