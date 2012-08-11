//
//  ORFWeatherViewController.h
//  wettertxt
//
//  Created by Peter Weishapl on 06.08.12.
//  Copyright (c) 2012 iteractive. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^WhenLoadedBlock)(UIWebView *webView);

@interface ORFWeatherViewController : UIViewController<UIWebViewDelegate>{
    NSMutableString *templateString;
}
@property (copy) WhenLoadedBlock onFinishingNextLoad;
@property NSURL *url;
@property UIWebView *webView;
@end
