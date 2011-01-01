//
//  wettrAppDelegate.m
//  wettr
//
//  Created by Peter Weishapl on 29.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//


#import "wettrAppDelegate.h"
#import "wettrViewController.h"
#import "ITATracking.h"
#import "GANTracker.h"

// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 5;

@implementation wettrAppDelegate
@synthesize window, tabController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-1903960-3"
                                         dispatchPeriod:kGANDispatchPeriodSec
                                               delegate:nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:16], @"fontSize", nil]];
	
	NSString *fontSizeSetting = [NSString stringWithFormat:@"fontSize:%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"fontSize"]];
	DLog(@"%@", fontSizeSetting);
	[ITATracking trackEvent:@"wettertxt" action:@"started" value:fontSizeSetting];
	
	NSString* baseURL = @"http://www.zamg.ac.at/wetter/prognose/%@";
	NSArray* states = [NSArray arrayWithObjects:@"", @"wien/", @"niederoesterreich/", @"burgenland/", @"steiermark/", @"oberoesterreich/", @"salzburg/", @"tirol/", @"vorarlberg/", @"kaernten/", nil];
	NSArray* stateTitles = [NSArray arrayWithObjects:@"Österreich", @"Wien", @"NÖ", @"Burgenland", @"Steiermark", @"OÖ", @"Salzburg", @"Tirol", @"Vorarlberg", @"Kärnten", nil];
	NSArray* stateIcons = [NSArray arrayWithObjects:@"austria", @"vienna", @"loweraustria",@"burgenland", @"styria", @"upperaustria", @"salzburg",@"tyrol",@"vorarlberg",@"carinthia", nil];
	NSDictionary* stateDict = [NSDictionary dictionaryWithObjects:states forKeys:stateTitles];
	NSDictionary* iconsDict = [NSDictionary dictionaryWithObjects:stateIcons forKeys:stateTitles];
	NSArray* tabOrder = [[NSUserDefaults standardUserDefaults] objectForKey:@"tabOrder"];
	
	NSArray* daysState = [NSArray arrayWithObjects:@"index",@"morgen", @"uebermorgen", nil];
	NSArray* daysAustria = [NSArray arrayWithObjects:@"index",@"morgen", @"uebermorgen", @"trend1", @"trend2", nil];
	
	if (tabOrder == nil) {
		tabOrder = stateTitles;
	}
	
	NSMutableArray* viewControllers = [NSMutableArray array];
	for (int i=0; i < states.count; i++) {
		NSString* title = [tabOrder objectAtIndex:i];
		NSArray* days = [title isEqualToString:@"Österreich"] ? daysAustria : daysState;
		UIImage* icon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[iconsDict objectForKey:title] ofType:@"png"]];
		NSString* url = [NSString stringWithFormat:baseURL, [stateDict objectForKey:title]];
		url = [url stringByAppendingString:@"%@.php"];
		wettrViewController* vc = [[wettrViewController alloc] initWithTitle:title baseURL:url image:icon days:days];
		vc.delegate = self;
		 
		[viewControllers addObject:vc];
		[vc release];
	}
	 
	tabController.viewControllers = viewControllers;
	
	tabController.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedTabIndex"];
	
	tabController.moreNavigationController.navigationBar.barStyle = UIBarStyleBlack;

	//window.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	//window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default.png"]];
	
	[window makeKeyAndVisible];
	[window addSubview:tabController.view];
	
    return YES;
}

-(void)startedLoading{
	loadCount++;
	DLog(@"started. loadCount: %d", loadCount);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)stoppedLoading{
	loadCount--;
	DLog(@"stopped. loadCount: %d", loadCount);
	if(loadCount == 0){
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	NSMutableArray* tabOrder = [NSMutableArray array];
	for (wettrViewController* vc in tabController.viewControllers) {
		[tabOrder addObject:vc.title];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:tabOrder forKey:@"tabOrder"];
	[[NSUserDefaults standardUserDefaults] setInteger:tabController.selectedIndex forKey:@"selectedTabIndex"];
}

- (void)dealloc {

	[window release];
	[tabController release];
    [super dealloc];
}

@end

