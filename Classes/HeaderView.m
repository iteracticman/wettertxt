//
//  HeaderView.m
//  wettertxt
//
//  Created by Peter Weishapl on 7/8/11.
//  Copyright 2011 iteractive. All rights reserved.
//

#import "HeaderView.h"


@implementation HeaderView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
      UIImage* img = [UIImage imageNamed:@"header.png"];
      img = [img stretchableImageWithLeftCapWidth:1 topCapHeight:0];
      btn = [UIButton buttonWithType:UIButtonTypeCustom];
      btn.userInteractionEnabled = NO;
      [btn setShowsTouchWhenHighlighted:NO];
      [btn setBackgroundImage:img forState:UIControlStateNormal];
      btn.alpha = .95;
      
      btn.contentEdgeInsets = UIEdgeInsetsMake(-2, 5, 0, 15);
      //btn.titleEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
      btn.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];;
      //btn.titleLabel.shadowColor = [UIColor scrollViewTexturedBackgroundColor];
      //btn.titleLabel.shadowOffset = CGSizeMake(0, 1);
      [btn setTitleColor:[UIColor viewFlipsideBackgroundColor] forState:UIControlStateNormal];
      
      
      //v.backgroundColor = [UIColor viewFlipsideBackgroundColor];
      //v.backgroundColor = [UIColor colorWithWhite:0 alpha:.4];
      //v.contentMode = UIViewContentModeRight;
      
      [self addSubview:btn];

    }
    return self;
}

- (void)dealloc
{
  [btn release];
    [super dealloc];
}

-(NSString *)title{
  return btn.titleLabel.text;
}

-(void)setTitle:(NSString *)title{
  [btn setTitle:title forState:UIControlStateNormal];
	
	[btn sizeToFit];
	btn.frame = CGRectMake(0, 8, btn.bounds.size.width, btn.bounds.size.height);
}

@end
