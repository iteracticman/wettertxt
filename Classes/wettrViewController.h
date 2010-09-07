//
//  wettrViewController.h
//  wettr
//
//  Created by Peter Weishapl on 29.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface wettrViewController : UITableViewController {
	NSURL* urlInWebView;
	NSArray* urls;
	NSMutableArray *_texts;
}

- (id) initWithTitle:(NSString*)title baseURL:(NSString*)url image:(UIImage*)image;
- (void)closeWebView:(id)sender;
@end

