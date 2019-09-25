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

- (id)init {
    self = [super init];
    if (self) {
        templateString = [NSMutableString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"template" withExtension:@"html"] encoding:NSUTF8StringEncoding error:nil];
    }
    return self;
}

- (void)loadData {
    if (_isLoading) {
        return;
    }
    
    _isLoading = YES;
    
    NSString *loadingString = [NSString stringWithFormat:@"Vorhersage von <a href='%@'>wetter.orf.at</a><br/>Wird geladen...",self.url];
    NSString *loadingHTML = [templateString stringByReplacingOccurrencesOfString:@"<header/>" withString:loadingString];
    
    __weak ORFWeatherViewController *weakSelf = self;
    
    self.onFinishingNextLoad = ^(WKWebView *webView){
        [weakSelf startLoading];
    };
    
    [self spin];
    [self showHTML:loadingHTML];
}

- (void)spin {
    [self.webView evaluateJavaScript:@"spin()" completionHandler:nil];
}

- (void)startLoading {
    [self spin];
    
    [ORFWeatherViewController incLoadCount];
    DLog(@"fetching %@", self.url);
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:self.url];
    req.timeoutInterval = 15;
    [[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //[NSThread sleepForTimeInterval:3];
        NSMutableString *text = [NSMutableString string];
        HTMLParser *parser;
        
        if (!error) {
            parser = [[HTMLParser alloc] initWithData:data error:&error];
        }
        
        if(error){
            DLog(@"ERROR %@", [error localizedDescription]);
            [text appendString:@"<p class=\"center\"><br/>Fehler beim Laden :(</p>"];
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
            NSString *HTML = [[self->templateString stringByReplacingOccurrencesOfString:@"<header/>" withString:loadingString] stringByReplacingOccurrencesOfString:@"<content/>" withString:text];
            DLog(@"%@", text);
            
            CGFloat offsetAdjust = 44 - self.view.safeAreaInsets.top;
            self.onFinishingNextLoad = ^(WKWebView *webView){
                if (error) return;
                
                
                [UIView animateWithDuration:0.4 animations:^{
                    webView.scrollView.contentOffset = CGPointMake(0, offsetAdjust);
                }];
            };
            
            [self showHTML:HTML];
            
            [ORFWeatherViewController decLoadCount];
            self->_isLoading = NO;
            self->_isLoaded = YES;
        });
    }] resume];
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
//        NSString highlight = [NSString stringWithFormat:@" %@ ", highlight]; //whole words only
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
    
    NSArray *exceptions = @[ @"Bregenz", @"Schneeberg", @"Bregenzerwald" ];
    for (NSString *exception in exceptions) {
        NSScanner* scanner = [NSScanner scannerWithString:text];
        [scanner setCharactersToBeSkipped:nil];
        [scanner setCaseSensitive:NO];
        
        while ([scanner scanUpToString:exception intoString:&stringBefore]) {
            if ([scanner isAtEnd]) break;
            //DLog(@"scaned til: %@", stringBefore);
            NSRange range = NSMakeRange([scanner scanLocation]+1, exception.length);
            [attString removeAttribute:kWarn range:range];
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

#pragma mark WKWebView

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        if ([url.absoluteString isEqualToString:@"wettertxt:reload"]) {
            [self loadData];
        } else {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                // don't care
            }];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.onFinishingNextLoad) {
            self.onFinishingNextLoad(webView);
            self.onFinishingNextLoad = nil;
        }
    });
}

#pragma mark View Lifecycle

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.opaque = YES;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:[WKWebViewConfiguration new]];
    self.webView.opaque = NO;
    self.webView.backgroundColor = self.view.window.backgroundColor;
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    
    [self.view addSubview:self.webView];
    [NSLayoutConstraint activateConstraints:@[
         [self.webView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
         [self.webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
         [self.webView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
         [self.webView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor]
    ]];
    
    self.webView.navigationDelegate = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
    UINavigationBar *blurBar = [UINavigationBar new];
    blurBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:blurBar];
    
    [NSLayoutConstraint activateConstraints:@[
        [blurBar.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [blurBar.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [blurBar.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [blurBar.rightAnchor constraintEqualToAnchor:self.view.rightAnchor]
    ]];
}

-(void)viewWillAppear:(BOOL)animated {
    if (!self.isLoaded) {
        [self loadData];
    }
}

@end
