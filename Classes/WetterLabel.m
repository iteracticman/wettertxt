//
//  WetterLabel.m
//  wettertxt
//
//  Created by Peter Weishapl on 7/3/11.
//  Copyright 2011 iteractive. All rights reserved.
//

#import "WetterLabel.h"
#import "NSAttributedString+Attributes.h"

@interface WetterLabel()
-(NSAttributedString*)attributize:(NSString*)text;
@end

@implementation WetterLabel

-(void)setText:(NSString *)text{
  self.attributedText = [self attributize:text];
}

-(NSAttributedString*)attributize:(NSString*)text{
  NSMutableAttributedString *attString = [NSMutableAttributedString attributedStringWithString:text];
  [attString setFont:self.font];
  [attString setTextColor:self.textColor];
  //[attString setTextAlignment:self.textAlignment lineBreakMode:CTLine];
  
	NSScanner* scanner = [NSScanner scannerWithString:text];
	[scanner setCharactersToBeSkipped:nil];
	
	NSString* stringBeforeDigit;
	
	while ([scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&stringBeforeDigit]) {
		DLog(@"scanned: %@", stringBeforeDigit);
		
		if (![scanner isAtEnd]) {
			NSString* numberString;
			[scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&numberString];
			DLog(@"-number: %@", numberString);
			
			//keine höhenmeter hervorheben!
			if (numberString.length < 3) {
        NSUInteger rangeLength = numberString.length;
        if ([stringBeforeDigit hasSuffix:@"minus "]) {
          rangeLength += 6;
        }else if([stringBeforeDigit hasSuffix:@"-"]){
          rangeLength += 1;
        }
        [attString setFontFamily:self.font.familyName size:self.font.pointSize bold:YES italic:NO range:NSMakeRange([scanner scanLocation]-rangeLength, rangeLength)]; 
			}
		}
	}
	
	DLog(@"highlighted text: %@", attString);
	return attString;
}

@end
