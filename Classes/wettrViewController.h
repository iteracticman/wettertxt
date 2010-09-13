//
//  wettrViewController.h
//  wettr
//
//  Created by Peter Weishapl on 29.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WettrViewControllerDelegate
-(void)startedLoading;
-(void)stoppedLoading;
@end

@interface wettrViewController : UITableViewController<UIWebViewDelegate> {
	NSString* baseURL;
	NSURL* urlInWebView;
	NSArray* dayPaths;
	NSMutableArray* urls;
	NSMutableArray *_texts;
	id<WettrViewControllerDelegate> delegate;
}

- (id) initWithTitle:(NSString*)title baseURL:(NSString*)url image:(UIImage*)image days:(NSArray*)days;
- (void)closeWebView:(id)sender;

@property (assign, nonatomic) id<WettrViewControllerDelegate> delegate;
@end

