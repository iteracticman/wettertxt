//
//  VideoForecastViewController.m
//  wettertxt
//
//  Created by Peter Weishapl on 28.08.12.
//  Copyright (c) 2012 iteractive. All rights reserved.
//

#import "VideoForecastViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoForecastViewController ()

@end

@implementation VideoForecastViewController
@synthesize slider;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark Actions

- (IBAction)viewSegmentChanged {
}

- (IBAction)refresh {
}

#pragma mark Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];

    self.toolbarItems = @[ [[UIBarButtonItem alloc] initWithCustomView:self.slider] ];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://wetter.orf.at/m/oes/wetterprognosen"]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *resp, NSData *data, NSError *err) {
        DLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    //AVAsset *
}

- (void)viewDidUnload {
    [self setSlider:nil];
    [super viewDidUnload];
}
@end
