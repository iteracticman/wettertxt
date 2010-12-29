//
//  ITATracking.h
//  vinolator
//
//  Created by Peter Weishapl on 12/18/10.
//  Copyright 2010 iteractic. All rights reserved.
//

@interface ITATracking : NSObject
{
}
+(BOOL)trackEvent:(NSString*)event action:(NSString*)action value:(NSString*)value;
+(BOOL)trackPageView:(NSString*)page;
@end

