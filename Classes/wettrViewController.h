//
//  wettrViewController.h
//  wettr
//
//  Created by Peter Weishapl on 29.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

@class HeaderView;

@protocol WettrViewControllerDelegate
-(void)startedLoading;
-(void)stoppedLoading;
@end

@interface wettrViewController : UITableViewController<UIWebViewDelegate> {
	NSString* baseURL;
	UIWebView* webView;
	NSArray* dayPaths;
	NSMutableArray* urls;
	NSMutableArray *_texts;
	id<WettrViewControllerDelegate> delegate;
  NSMutableDictionary *headerViews;
}

- (id) initWithTitle:(NSString*)title baseURL:(NSString*)url image:(UIImage*)image days:(NSArray*)days;
- (void)closeWebView:(id)sender;
-(void)attributize:(NSMutableAttributedString*)attString withBoldFont:(UIFont*)boldFont;
@property (assign, nonatomic) id<WettrViewControllerDelegate> delegate;
@end

