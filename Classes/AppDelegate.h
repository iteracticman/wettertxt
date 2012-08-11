//
//  AppDelegate.h
//  wettertxt
//
//  Created by Peter Weishapl on 06.08.12.
//  Copyright (c) 2012 iteractive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDelegate : NSObject<UIApplicationDelegate>

@property (nonatomic) UIWindow *window;
@property (strong, nonatomic) IBOutlet UITabBarController *tabController;

@end
