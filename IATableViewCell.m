//
//  IATableViewCell.m
//  wettertxt
//
//  Created by Peter Weishapl on 07.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "IATableViewCell.h"
#import "WetterLabel.h"

@implementation IATableViewCell
@synthesize label;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    label = [[WetterLabel alloc] init];
    label.automaticallyDetectLinks = NO;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.userInteractionEnabled = NO;
    label.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:label];
  }
  return self;
}

- (void)dealloc {
  [label release];
  [super dealloc];
}

-(void)layoutSubviews{
  [super layoutSubviews];
  
  label.frame = UIEdgeInsetsInsetRect(self.contentView.frame, UIEdgeInsetsMake(8, 6, 0, 2));
}

/*
- (void)drawRect:(CGRect)rect{
	CGContextRef ctx = UIGraphicsGetCurrentContext();

	CGContextSetLineWidth(ctx, 1.0);
	CGContextSetFillColorWithColor(ctx, [UIColor viewFlipsideBackgroundColor].CGColor);
	CGContextFillRect(ctx, self.bounds);
	
	CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:.3 alpha:.5].CGColor);
	CGContextMoveToPoint(ctx, 0, 0);
	CGContextAddLineToPoint(ctx, self.bounds.size.width, 0);
	
	CGContextStrokePath(ctx);
	
	CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0 alpha:.5].CGColor);
	CGContextMoveToPoint(ctx, 0, self.bounds.size.height);
	CGContextAddLineToPoint(ctx, self.bounds.size.width, self.bounds.size.height);
	
	CGContextStrokePath(ctx);
}*/
@end
