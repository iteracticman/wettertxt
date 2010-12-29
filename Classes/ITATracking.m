//
//  ITATracking.m
//  vinolator
//
//  Created by Peter Weishapl on 12/18/10.
//  Copyright 2010 iteractic. All rights reserved.
//

#import "ITATracking.h"
#import "GANTracker.h"
#import <Foundation/Foundation.h>

@implementation ITATracking

+(BOOL)trackEvent:(NSString*)event action:(NSString*)action value:(NSString*)value{
	NSError* error;
	[[GANTracker sharedTracker] trackEvent:event action:action label:value value:0 withError:&error];
	
	if (error) {
		DLog(@"tracking error: %@", [error description]);
		return NO;
	}
	return YES;
}
+
(BOOL) trackPageView:(NSString*)page{
	NSError* error;
	[[GANTracker sharedTracker] trackPageview:page withError:&error];
	
	if (error) {
		DLog(@"tracking error: %@", [error description]);
		return NO;
	}
	return YES;
}
@end