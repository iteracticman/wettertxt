//
//  VideoForecastViewController.h
//  wettertxt
//
//  Created by Peter Weishapl on 28.08.12.
//  Copyright (c) 2012 iteractive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoForecastViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISlider *slider;
- (IBAction)viewSegmentChanged;
- (IBAction)refresh;
@end
