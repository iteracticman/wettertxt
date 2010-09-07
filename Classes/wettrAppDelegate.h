//
//  wettrAppDelegate.h
//  wettr
//
//  Created by Peter Weishapl on 29.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>

@class wettrViewController;

@interface wettrAppDelegate : NSObject <UIApplicationDelegate> {

	UIWindow *window;

	UITabBarController* tabController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;


@property (nonatomic, retain) IBOutlet UITabBarController *tabController;

@end

