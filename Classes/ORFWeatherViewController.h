//
//  ORFWeatherViewController.h
//  wettertxt
//
//  Created by Peter Weishapl on 06.08.12.
//  Copyright (c) 2012 iteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

typedef void(^WhenLoadedBlock)(WKWebView *webView);

@interface ORFWeatherViewController : UIViewController<WKNavigationDelegate>{
    NSMutableString *templateString;
}
@property (copy) WhenLoadedBlock onFinishingNextLoad;
@property NSURL *url;
@property WKWebView *webView;
@property (readonly) BOOL isLoaded;
@property (readonly) BOOL isLoading;

- (void)loadData;
@end
