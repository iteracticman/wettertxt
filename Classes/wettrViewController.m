//
//  wettrViewController.m
//  wettr
//
//  Created by Peter Weishapl on 29.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "wettrViewController.h"
#import "TFHpple.h"
#import "IATableViewCell.h"
#import "ITATracking.h"
#import "WetterLabel.h"
#import "NSAttributedString+Attributes.h"
#import "DTAttributedTextContentView.h"
#import "HeaderView.h"

@implementation wettrViewController
@synthesize delegate;

- (id) initWithTitle:(NSString*)title baseURL:(NSString*)url image:(UIImage*)image days:(NSArray*)days
{
	self = [super initWithStyle:UITableViewStylePlain];
	if (self != nil) {
    headerViews = [[NSMutableDictionary alloc] initWithCapacity:days.count];
		dayPaths = [days retain];
		baseURL = [url retain];
		self.title = title;
		self.tabBarItem.image = image;

		NSString* loading = @"Lade...";
		_texts = [[NSMutableArray alloc] initWithCapacity:dayPaths.count];
		urls = [[NSMutableArray alloc] initWithCapacity:dayPaths.count];
		for (NSString* day in dayPaths) {
			[_texts addObject:loading];
			[urls addObject:[NSURL URLWithString:[NSString stringWithFormat:baseURL, day]]];
		}
	}
	return self;
}

- (void)dealloc {
  [headerViews release];
	[dayPaths release];
	[baseURL release];
	[urls release];
	[_texts release];
  [super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *kCellID = @"cellID";
    
    IATableViewCell *cell = (IATableViewCell*)[tableView dequeueReusableCellWithIdentifier:kCellID];
    if (cell == nil)
    {
			cell = [[[IATableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID] autorelease];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
			cell.textLabel.numberOfLines = 0;
    }
	
	if (indexPath.row == 0) {
		cell.textLabel.hidden = YES;
		cell.label.hidden = NO;
		
    NSString* txt = [_texts objectAtIndex:indexPath.section];
    if ([txt isKindOfClass:[NSAttributedString class]]) {
      cell.label.attributedString = (NSAttributedString*)txt;
    }else{
      cell.label.attributedString = [NSAttributedString attributedStringWithString:txt];
    }
		
    //[cell.label resetAttributedText];
	}else {
		cell.textLabel.hidden = NO;
		cell.label.hidden = YES;
		cell.label.attributedString = nil;
    
		cell.textLabel.textColor = [UIColor lightTextColor];
		cell.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
		cell.textLabel.textAlignment = UITextAlignmentCenter;

		cell.textLabel.text = @"Die Wettervorhersagen stammen von der Homepage des ZAMG - www.zamg.ac.at.";
	}
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.row == 0) {
		IATableViewCell* cell = (IATableViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell layoutSubviews];
		//DLog(@"getting height for: %@", cell.label.attributedText);
		CGFloat height = [cell.label sizeThatFits:CGSizeMake(cell.label.frame.size.width, CGFLOAT_MAX)].height;
		return height + 14;
	}else {
		return 36;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return _texts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if (section == _texts.count - 1) {
		return 2;
	}
	return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	UIViewController* wvc = [[UIViewController alloc] init];
	webView = [[UIWebView alloc] init];
	wvc.view = webView;
	
	UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:wvc];
	UIBarButtonItem* done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeWebView:)];
	UIBarButtonItem* openInSafari = [[UIBarButtonItem alloc] initWithTitle:@"In Safari öffnen" style:UIBarButtonItemStyleBordered target:self action:@selector(openInSafari:)];
	nav.navigationBar.barStyle = UIBarStyleBlack;
	wvc.navigationItem.rightBarButtonItem = done;
	wvc.navigationItem.leftBarButtonItem = openInSafari;
	
	[self presentModalViewController:nav animated:YES];
	
	NSURL *urlInWebView;
	if (indexPath.row == 0){
		urlInWebView = [[urls objectAtIndex:indexPath.section] retain];
	}else {
		urlInWebView = [[NSURL alloc] initWithString:@"http://www.zamg.ac.at"];
	}
	webView.delegate = self;
	[webView loadRequest:[NSURLRequest requestWithURL:urlInWebView]];
	[urlInWebView release];
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	[nav release];
	[wvc release];
	[done release];
	[openInSafari release];
}

#pragma mark -
#pragma mark WebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView{
	[delegate startedLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
	[delegate stoppedLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
	[delegate stoppedLoading];
}

#pragma mark -

-(void)closeWebView:(id)sender{
	[webView stopLoading];
	
	[self dismissModalViewControllerAnimated:YES];
	[webView release];
}

-(void)openInSafari:(id)sender{
	if ([webView.request URL]) {
		[[UIApplication sharedApplication] openURL:[webView.request URL]];
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
  HeaderView* hv = [headerViews objectForKey:[NSNumber numberWithInt:section]];
  if (hv == nil) {
    hv = [[HeaderView alloc] init];
    hv.title = [self tableView:tableView titleForHeaderInSection:section];
    [headerViews setObject:hv forKey:[NSNumber numberWithInt:section]];
  }

	return hv;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 27;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	switch(section){
		case 0: return @"Heute";
		case 1: return @"Morgen";
		case 2: return @"Übermorgen";
		case 3: return @"In 3 Tagen";
		case 4: return @"In 4 Tagen";
	}
	return nil;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
  NSUInteger i = 0;
	for (NSURL* url in urls) {
		[delegate startedLoading];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			DLog(@"fetching %@", url);
			NSMutableAttributedString* text;
      
			NSError* error = nil;
			NSData *data = [[NSData alloc] initWithContentsOfURL:url options:NSDataReadingMapped error:&error];
			
			if(error){
				ALog(@"ERROR %@", [error localizedDescription]);
				text = [NSMutableAttributedString attributedStringWithString:@"Oje! Die Daten konnten nicht geladen werden."];
			}else {
				// Create parser
				TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
				
				//Get all the cells of the 2nd row of the 3rd table 
				TFHppleElement* contMain = [xpathParser at:@"//div[@id='contMain']/div[1]/table[1]//tr[2]/td[2]/text()"];
				if(contMain){
					text = [self attributize:[[contMain content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
					//NSLog(@"fetched: %@ at %d", contMain, i);
					//text = [self addHighlights:text];
				}else {
					text = [NSMutableAttributedString attributedStringWithString:@"Auweh! Die Wetterdaten konnten zwar geladen, aber nicht ausgelesen werden. Hat sich die ZAMG Seite geändert?"];
				}
				[xpathParser release];
			}
			
			[text retain];
			dispatch_async(dispatch_get_main_queue(), ^{
				[delegate stoppedLoading];
				[_texts replaceObjectAtIndex:i withObject:text];
				[text release];
				[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationFade];
			});
			
			[data release];
		});
		i++;
	}	
}

-(NSMutableAttributedString*)attributize:(NSString*)text{
  NSMutableAttributedString *attString = [NSMutableAttributedString attributedStringWithString:text];
  CGFloat fontSize = [[NSUserDefaults standardUserDefaults] doubleForKey:@"fontSize"];
  UIFont *font = [UIFont systemFontOfSize:fontSize];
  [attString setFont:font];
  [attString setTextColor:[UIColor whiteColor]];
  [attString setTextAlignment:kCTLeftTextAlignment lineBreakMode:kCTLineBreakByWordWrapping];
  
	NSString* stringBefore;
  NSArray *highlights = [NSArray arrayWithObjects:@"regen", @"sturm", @"hagel", @"gewitter", @"blitz", @"hagel", @"unwetter", @"schneefall", @"regnet", @"stürmisch", @"stürmt", @"schneit", @"schüttet", @"schütten", nil];
  
  UIColor *warnBg = [[UIColor redColor] colorWithAlphaComponent:0.75];
  for (NSString *highlight in highlights) {
    NSScanner* scanner = [NSScanner scannerWithString:text];
    [scanner setCharactersToBeSkipped:nil];
    [scanner setCaseSensitive:NO];
    
    while ([scanner scanUpToString:highlight intoString:&stringBefore]) {
      if ([scanner isAtEnd]) break;
      NSRange range = NSMakeRange([scanner scanLocation], highlight.length);
      [attString setBackgroundColor:warnBg range:range];
      //[attString setTextColor:[UIColor blackColor] range:range];
      [scanner setScanLocation:[scanner scanLocation]+1];
    }
  }
  
  UIColor *tempBg = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
  NSScanner* scanner = [NSScanner scannerWithString:text];
  [scanner setCharactersToBeSkipped:nil];
	while ([scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&stringBefore]) {
		if ([scanner isAtEnd]) break;
    
    NSString* numberString;
    [scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&numberString];
    DLog(@"-number: %@", numberString);
    
    //keine höhenmeter hervorheben!
    if (numberString.length < 3) {
      NSUInteger rangeLength = numberString.length;
      if ([stringBefore hasSuffix:@"minus "]) {
        rangeLength += 6;
      }else if([stringBefore hasSuffix:@"-"]){
        rangeLength += 1;
      }
      
      NSRange range = NSMakeRange([scanner scanLocation]-rangeLength, rangeLength);
      
      [attString setBackgroundColor:tempBg range:range];
      [attString setTextColor:[UIColor blackColor] range:range];
      [attString setFontFamily:font.familyName size:font.pointSize bold:YES italic:NO range:range]; 
    }
	}
	//DLog(@"highlighted text: %@", attString);
	return attString;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

-(void) viewWillAppear:(BOOL)animated{
	[ITATracking trackPageView:[NSString stringWithFormat:@"/wettertxt/%@", self.title]];
	[self.tableView reloadData];
}

-(void)viewDidUnload{
  [super viewDidUnload];
  [headerViews removeAllObjects];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	[self.tableView reloadData];
}
@end
