//
//  WetterLabel.m
//  wettertxt
//
//  Created by Peter Weishapl on 7/3/11.
//  Copyright 2011 iteractive. All rights reserved.
//

#import "WetterLabel.h"
#import "NSAttributedString+Attributes.h"
#import <CoreText/CoreText.h>

@interface WetterLabel()

@end

@implementation WetterLabel
- (id)init {
  self = [super init];
  if (self) {
    self.shouldLayoutCustomSubviews = NO;
  }
  return self;
}
/*-(CGSize)sizeThatFits:(CGSize)size{
  CGSize s = [super sizeThatFits:size];
  return CGSizeMake(round(s.width), round(s.height));
}*/
@end
