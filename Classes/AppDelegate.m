//
//  AppDelegate.m
//  wettertxt
//
//  Created by Peter Weishapl on 06.08.12.
//  Copyright (c) 2012 iteractive. All rights reserved.
//

#import "AppDelegate.h"
#import "ORFWeatherViewController.h"

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kFontSizeKey: @18}];
	
	NSString *fontSizeSetting = [NSString stringWithFormat:@"fontSize:%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"fontSize"]];
	DLog(@"%@", fontSizeSetting);
	//[ITATracking trackEvent:@"wettertxt" action:@"started" value:fontSizeSetting];
	
	NSString* baseURL = @"http://wetter.orf.at/m/%@/prognose";
	NSArray* states = @[@"oes", @"wien", @"niederoesterreich", @"burgenland", @"steiermark", @"oberoesterreich", @"salzburg", @"tirol", @"vorarlberg", @"kaernten"];
	NSArray* stateTitles = @[@"Österreich", @"Wien", @"NÖ", @"Burgenland", @"Steiermark", @"OÖ", @"Salzburg", @"Tirol", @"Vorarlberg", @"Kärnten"];
	NSArray* stateIcons = @[@"austria", @"vienna", @"loweraustria",@"burgenland", @"styria", @"upperaustria", @"salzburg",@"tyrol",@"vorarlberg",@"carinthia"];
	NSDictionary* stateDict = [NSDictionary dictionaryWithObjects:states forKeys:stateTitles];
	NSDictionary* iconsDict = [NSDictionary dictionaryWithObjects:stateIcons forKeys:stateTitles];
	NSArray* tabOrder = [[NSUserDefaults standardUserDefaults] objectForKey:@"tabOrder"];
	
	if (tabOrder == nil) {
		tabOrder = stateTitles;
	}
	
	NSMutableArray* viewControllers = [NSMutableArray array];
	for (int i=0; i < states.count; i++) {
		NSString* title = [tabOrder objectAtIndex:i];
		UIImage *icon = [UIImage imageNamed:[iconsDict objectForKey:title]];
		NSString *url = [NSString stringWithFormat:baseURL, [stateDict objectForKey:title]];
		
        ORFWeatherViewController *vc = [[ORFWeatherViewController alloc] init];
        vc.title = title;
        vc.tabBarItem.image = icon;
        vc.url = [NSURL URLWithString:url];
        
		[viewControllers addObject:vc];
	}
    
    self.tabController = [[UITabBarController alloc] init];
    //self.tabController.tabBar.tintColor = [UIColor colorWithHue:0.111 saturation:0.026 brightness:0.898 alpha:1.000];
	self.tabController.viewControllers = viewControllers;
	self.tabController.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedTabIndex"];
	self.tabController.moreNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.window.backgroundColor = [UIColor colorWithWhite:0.039 alpha:1.000];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = self.tabController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
