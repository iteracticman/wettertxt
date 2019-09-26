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

	//[ITATracking trackEvent:@"wettertxt" action:@"started" value:fontSizeSetting];
	
	NSString* baseURL = @"http://wetter.orf.at/m/%@/prognose";
	NSArray* states = @[@"oes", @"http://wetter.orf.at/m/oes/bergwetter", @"wien", @"niederoesterreich", @"burgenland", @"steiermark", @"oberoesterreich", @"salzburg", @"tirol", @"vorarlberg", @"kaernten"];
	NSArray* stateTitles = @[@"Österreich", @"Bergwetter", @"Wien", @"NÖ", @"Burgenland", @"Steiermark", @"OÖ", @"Salzburg", @"Tirol", @"Vorarlberg", @"Kärnten"];
	NSArray* stateIcons = @[@"austria", @"mountain", @"vienna", @"loweraustria",@"burgenland", @"styria", @"upperaustria", @"salzburg",@"tyrol",@"vorarlberg", @"carinthia"];
	NSDictionary* stateDict = [NSDictionary dictionaryWithObjects:states forKeys:stateTitles];
	NSDictionary* iconsDict = [NSDictionary dictionaryWithObjects:stateIcons forKeys:stateTitles];
	NSArray* tabOrder = [[NSUserDefaults standardUserDefaults] objectForKey:@"tabOrder"];

	if (tabOrder == nil) {
		tabOrder = stateTitles;
	} else {
        NSMutableSet *newTabs = [NSMutableSet setWithArray:stateTitles];
        [newTabs minusSet:[NSSet setWithArray:tabOrder]];
        
        if (newTabs.count > 0) {
            //in case where new tabs have been added in a new version 
            tabOrder = [tabOrder arrayByAddingObjectsFromArray:[newTabs allObjects]];
        }
    }
	
	NSMutableArray* viewControllers = [NSMutableArray array];
	for (int i=0; i < states.count; i++) {
        NSString *title = [tabOrder objectAtIndex:i];

		UIImage *icon = [UIImage imageNamed:[iconsDict objectForKey:title]];
        NSString *state = [stateDict objectForKey:title];
		NSString *url;
        
        if ([state hasPrefix:@"http://"]) {
            url = state;
        }else {
            url = [NSString stringWithFormat:baseURL, state];
        }
		
        ORFWeatherViewController *vc = [[ORFWeatherViewController alloc] init];
        vc.title = title;
        vc.tabBarItem.image = icon;
        vc.url = [NSURL URLWithString:url];
        
		[viewControllers addObject:vc];
	}
    
    self.tabController = [UITabBarController new];
	self.tabController.viewControllers = viewControllers;
    
    self.tabController.delegate = self;
    
    self.tabController.view.backgroundColor = [UIColor colorNamed:@"background"];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.tintColor = [UIColor colorNamed:@"tint"];
    
    self.window.rootViewController = self.tabController;
    [self.window makeKeyAndVisible];
    
    NSUInteger selIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedTabIndex"];
    self.tabController.selectedIndex = selIndex;
    
    return YES;
}

- (void)saveState {
    NSMutableArray* tabOrder = [NSMutableArray array];
	for (ORFWeatherViewController* vc in self.tabController.viewControllers) {
		[tabOrder addObject:vc.title];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:tabOrder forKey:@"tabOrder"];
    
	[[NSUserDefaults standardUserDefaults] setInteger:self.tabController.selectedIndex forKey:@"selectedTabIndex"];
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
    [self saveState];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[self saveState];
}

#pragma mark UITabBarControllerDelegate

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    ORFWeatherViewController *orfVC = (ORFWeatherViewController *)viewController;
    if (viewController != tabBarController.moreNavigationController &&  viewController == tabBarController.selectedViewController) {
        [orfVC loadData];
    }
    
    return YES;
}

@end
