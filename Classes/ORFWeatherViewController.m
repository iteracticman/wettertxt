//
//  ORFWeatherViewController.m
//  wettertxt
//
//  Created by Peter Weishapl on 06.08.12.
//  Copyright (c) 2012 iteractive. All rights reserved.
//

#import "ORFWeatherViewController.h"
#import "HTMLNode.h"
#import "HTMLParser.h"
#import "SVModalWebViewController.h"
#import "GANTracker.h"

#define kWarn @"warn"
#define kTemp @"temp"

@implementation ORFWeatherViewController
static NSUInteger loadCount;

+ (void)incLoadCount {
    loadCount++;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

+ (void)decLoadCount {
    if (loadCount > 0) {
        loadCount--;
    }
    
    if(loadCount == 0){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        templateString = [NSMutableString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"template" withExtension:@"html"] encoding:NSUTF8StringEncoding error:nil];
    }
    return self;
}

- (void)loadData {
    _isDataLoadedOrLoading = YES;
    
    [[GANTracker sharedTracker] trackPageview:self.url.absoluteString withError:nil];
    
    NSString *loadingString = [NSString stringWithFormat:@"Vorhersage von <a href='%@'>wetter.orf.at</a><br/>Wird geladen...",self.url];
    NSString *loadingHTML = [templateString stringByReplacingOccurrencesOfString:@"<header/>" withString:loadingString];
    [self showHTML:loadingHTML];
    
    __weak ORFWeatherViewController *weakSelf = self;
    self.onFinishingNextLoad = ^(UIWebView *webView){
        [weakSelf startLoading];
    };
}

- (void)startLoading {
    [self.webView stringByEvaluatingJavaScriptFromString:@"spin()"];
    [ORFWeatherViewController incLoadCount];
    DLog(@"fetching %@", self.url);
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:self.url];
    req.timeoutInterval = 15;
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *resp, NSData *data, NSError *error) {
        NSMutableString *text = [NSMutableString string];
        HTMLParser *parser;
        
        if (!error) {
            parser = [[HTMLParser alloc] initWithData:data error:&error];
        }
        
        if(error){
            DLog(@"ERROR %@", [error localizedDescription]);
            [text appendString:@"<p class=\"center\">Fehler beim Laden :(</p>"];
        }else {
            HTMLNode* content = [[parser body] findChildWithAttribute:@"role" matchingName:@"article" allowPartial:NO];
            
            // DLog(@"%@", content.rawContents);
            
            for (HTMLNode *child in content.children) {
                if (([@"h2" isEqualToString:child.tagName] && ![[child className] isEqualToString:@"stationsHeadline"])) {
                    [text appendString:child.rawContents];
                }
                if ([@"p" isEqualToString:child.tagName]) {
                    [text appendString:[self highlight:child.rawContents]];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *loadingString = [NSString stringWithFormat:@"Vorhersage von <a href='%@'>wetter.orf.at</a><br/>Aktualisert am %@",self.url, [NSDateFormatter  localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];
            NSString *HTML = [[templateString stringByReplacingOccurrencesOfString:@"<header/>" withString:loadingString] stringByReplacingOccurrencesOfString:@"<content/>" withString:text];
            DLog(@"%@", text);
            
            self.onFinishingNextLoad = ^(UIWebView *webView){
                if (error) return;
                [UIView animateWithDuration:0.4 animations:^{
                    self.webView.scrollView.contentOffset = CGPointMake(0, 44);
                }];
            };
            
            [self showHTML:HTML];
            
            [ORFWeatherViewController decLoadCount];
        });
    }];
}

- (void)addClass:(NSString *)cssClass toString:(NSMutableAttributedString *)attString {
    [attString enumerateAttribute:cssClass inRange:NSMakeRange(0, attString.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value) {
            [attString.mutableString insertString:@"</span>" atIndex:range.location+range.length-1];
            [attString.mutableString insertString:[NSString stringWithFormat:@"<span class=\"%@\">", cssClass] atIndex:range.location-1];
        }
    }];
}

- (NSString *)highlight:(NSString *)text {
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text];
    NSString* stringBefore;
    NSArray *highlights = @[@"regen", @"regenschauer", @"schauer", @"regentropfen", @"tröpfeln", @"regnen", @"regnerisch", @"regnet", @"niederschlag", @"niederschläge", @"schüttet", @"schütten", @"sturm", @"stürmisch", @"stürmt", @"hagel", @"gewitter", @"gewittrig", @"gewittrige", @"blitz", @"unwetter",  @"schnee", @"schneefall", @"schneefälle", @"schneien", @"schneit", @"schneeschauer", @"schneeregen", @"schneeregenschauer", @"stürmischer"];
    for (NSString *highlight in highlights) {
        //highlight = [NSString stringWithFormat:@" %@ ", highlight]; //whole words only
        NSScanner* scanner = [NSScanner scannerWithString:text];
        [scanner setCharactersToBeSkipped:nil];
        [scanner setCaseSensitive:NO];
        
        while ([scanner scanUpToString:highlight intoString:&stringBefore]) {
            if ([scanner isAtEnd]) break;
            //DLog(@"scaned til: %@", stringBefore);
            NSRange range = NSMakeRange([scanner scanLocation]+1, highlight.length);
            [attString addAttribute:kWarn value:kWarn range:range];
            //[attString setTextColor:[UIColor blackColor] range:range];
            [scanner setScanLocation:[scanner scanLocation]+1];
        }
    }
    
    NSScanner* scanner = [NSScanner scannerWithString:text];
    [scanner setCharactersToBeSkipped:nil];
	while ([scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&stringBefore]) {
		if ([scanner isAtEnd]) break;
        
        NSString* numberString;
        [scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&numberString];
        //DLog(@"-number: %@", numberString);
        
        //keine höhenmeter hervorheben!
        if (numberString.length < 3) {
            NSUInteger rangeLength = numberString.length ;
            if ([stringBefore hasSuffix:@"minus "]) {
                rangeLength += 6;
            }else if([stringBefore hasSuffix:@"-"]){
                rangeLength += 1;
            }
            
            NSRange range = NSMakeRange([scanner scanLocation]-rangeLength+1, rangeLength);
            
            [attString addAttribute:kTemp value:kTemp range:range];
        }
	}
    
    [self addClass:kWarn toString:attString];
    [self addClass:kTemp toString:attString];
    
    //DLog(@"highlighted: %@", attString.mutableString);
    return attString.string;
}

- (void)showHTML:(NSString *)loadingHTML {
    [self.webView loadHTMLString:loadingHTML baseURL:[[NSBundle mainBundle] bundleURL]];
}

#pragma mark UIWebView

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        if ([request.URL.absoluteString isEqualToString:@"wettertxt:reload"]) {
            [self loadData];
        }else {
            SVModalWebViewController *webVC = [[SVModalWebViewController alloc] initWithURL:request.URL];
            webVC.availableActions = SVWebViewControllerAvailableActionsOpenInSafari | SVWebViewControllerAvailableActionsCopyLink;
            [self presentModalViewController:webVC animated:YES];
            return NO;
        }
        
    }
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.onFinishingNextLoad) {
        self.onFinishingNextLoad(webView);
        self.onFinishingNextLoad = nil;
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

#pragma mark View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.opaque = YES;
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.opaque = NO;
    self.webView.backgroundColor = self.view.window.backgroundColor;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.webView.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self.view addSubview:self.webView];
    
    self.webView.delegate = self;
}

-(void)viewDidUnload {
    [super viewDidUnload];
    self.webView = nil;
}

@end
