//
//  AppDelegate.m
//  wettertxt
//
//  Created by Peter Weishapl on 06.08.12.
//  Copyright (c) 2012 iteractive. All rights reserved.
//

#import "AppDelegate.h"
#import "ORFWeatherViewController.h"
#import "VideoForecastViewController.h"
#import "GANTracker.h"
#import "TestFlight.h"

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [TestFlight setDeviceIdentifier:[UIDevice currentDevice].uniqueIdentifier];
    [TestFlight takeOff:@"7ee3775942aa73462bdb5e6183d30e58_OTY5OTMyMDEyLTA2LTA1IDExOjEzOjIzLjg2MTA5Mw"];
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-34034367-1" dispatchPeriod:10 delegate:nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kFontSizeKey: @18}];

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
	self.tabController.viewControllers = viewControllers;
	self.tabController.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedTabIndex"];
	self.tabController.moreNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.tabController.delegate = self;
    self.window.backgroundColor = [UIColor blackColor];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [(ORFWeatherViewController *)self.tabController.selectedViewController loadData];
    
    self.window.rootViewController = self.tabController;
    [self.window makeKeyAndVisible];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    return YES;
}

- (void)orientationChanged:(NSNotification *)note {
    UIDeviceOrientation devOrient = [UIDevice currentDevice].orientation;
    if (UIInterfaceOrientationIsLandscape(devOrient)) {
        DLog(@"landscape");
        [self.window.rootViewController presentModalViewController:self.videoForecastViewController animated:YES];
    }else if(UIInterfaceOrientationIsPortrait(devOrient)){
        [self.window.rootViewController dismissModalViewControllerAnimated:YES];
    }
}

-(UINavigationController *)videoForecastViewController {
    if (_videoForecastViewController == nil) {
        _videoForecastViewController = [[UIStoryboard storyboardWithName:@"VideoForecast" bundle:nil] instantiateInitialViewController];
        _videoForecastViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    return _videoForecastViewController;
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
    if (viewController == tabBarController.selectedViewController) {
        [orfVC loadData];
    }
    
    return YES;
}

@end
