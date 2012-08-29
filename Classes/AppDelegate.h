//
//  AppDelegate.h
//  wettertxt
//
//  Created by Peter Weishapl on 06.08.12.
//  Copyright (c) 2012 iteractive. All rights reserved.
//

@class VideoForecastViewController;

@interface AppDelegate : NSObject<UIApplicationDelegate, UITabBarControllerDelegate>

@property (nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabController;
@property (strong, nonatomic) UINavigationController *videoForecastViewController;

@end
