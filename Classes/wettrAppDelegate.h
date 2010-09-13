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

@property (nonatomic, retain) IBOutlet UIWindow *window;


@property (nonatomic, retain) IBOutlet UITabBarController *tabController;

@end

