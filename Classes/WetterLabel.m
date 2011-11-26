//
//  WetterLabel.m
//  wettertxt
//
//  Created by Peter Weishapl on 7/3/11.
//  Copyright 2011 iteractive. All rights reserved.
//

#import "WetterLabel.h"
#import <CoreText/CoreText.h>



@implementation WetterLabel
- (id)init {
  self = [super init];
  if (self) {
    self.textColor = [UIColor whiteColor];
    self.lineBreakMode = UILineBreakModeWordWrap;
    self.numberOfLines = 0;
    self.leading = 2.0; //* [UIScreen mainScreen].scale;
  }
  return self;
}
/*-(CGSize)sizeThatFits:(CGSize)size{
  CGSize s = [super sizeThatFits:size];
  return CGSizeMake(round(s.width), round(s.height));
}*/


@end
