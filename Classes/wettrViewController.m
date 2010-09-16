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

@implementation wettrViewController
@synthesize delegate;

- (id) initWithTitle:(NSString*)title baseURL:(NSString*)url image:(UIImage*)image days:(NSArray*)days
{
	self = [super initWithNibName:@"wettrViewController" bundle:nil];
	if (self != nil) {
		dayPaths = [days retain];
		baseURL = [url retain];
		self.title = title;
		self.tabBarItem.image = image;

		const NSString* loading = @"Lade...";
		_texts = [[NSMutableArray alloc] initWithCapacity:dayPaths.count];
		urls = [[NSMutableArray alloc] initWithCapacity:dayPaths.count];
		for (NSString* day in dayPaths) {
			[_texts addObject:loading];
			[urls addObject:[NSURL URLWithString:[NSString stringWithFormat:baseURL, day]]];
		}
	}
	return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *kCellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (cell == nil)
    {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		cell.textLabel.numberOfLines = 0;
		
		/*cell.backgroundView = [[[IATableViewCell alloc] init] autorelease];
		cell.contentView.backgroundColor = [UIColor clearColor];
		cell.contentView.opaque = NO;
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.textLabel.opaque = NO;*/
    }
	
	if (indexPath.row == 0) {
		cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
		cell.textLabel.textColor = [UIColor whiteColor];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		
		cell.textLabel.text = [_texts objectAtIndex:indexPath.section];
	}else {
		cell.textLabel.textColor = [UIColor lightTextColor];
		cell.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		
		cell.textLabel.text = @"Die Wettervorhersagen stammen von der Homepage des ZAMG - www.zamg.ac.at.";
	}
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell* cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
	
	[cell layoutIfNeeded];
	CGFloat height = [cell.textLabel sizeThatFits:CGSizeMake(cell.textLabel.frame.size.width, CGFLOAT_MAX)].height;
	return height + 14;
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
	UIImage* img = [UIImage imageNamed:@"header.png"];
	img = [img stretchableImageWithLeftCapWidth:1 topCapHeight:0];
	UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.userInteractionEnabled = NO;
	[btn setShowsTouchWhenHighlighted:NO];
	[btn setTitle:[self tableView:tableView titleForHeaderInSection:section] forState:UIControlStateNormal];
	[btn setBackgroundImage:img forState:UIControlStateNormal];
	btn.alpha = .95;
	
	btn.contentEdgeInsets = UIEdgeInsetsMake(-2, 5, 0, 15);
	//btn.titleEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
	btn.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
	//btn.titleLabel.shadowColor = [UIColor scrollViewTexturedBackgroundColor];
	//btn.titleLabel.shadowOffset = CGSizeMake(0, 1);
	[btn setTitleColor:[UIColor viewFlipsideBackgroundColor] forState:UIControlStateNormal];
	
	UIView* v = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	//v.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	//v.backgroundColor = [UIColor colorWithWhite:0 alpha:.4];
	//v.contentMode = UIViewContentModeRight;
	
	[v addSubview:btn];
	
	[btn sizeToFit];
	btn.frame = CGRectMake(0, 8, btn.bounds.size.width, btn.bounds.size.height);
	
	return v;
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
	
	NSUInteger i = 0;
	for (NSURL* url in urls) {
		[delegate startedLoading];
		dispatch_async(dispatch_get_global_queue(0, 0), ^{			
			NSLog(@"fetching %@", url);
			NSString* text;

			NSError* error = nil;
			NSData *data = [[NSData alloc] initWithContentsOfURL:url options:NSDataReadingMapped error:&error];
			
			if(error){
				NSLog(@"ERROR %@", [error localizedDescription]);
				text = @"Oje! Die Daten konnten nicht geladen werden.";
			}else {
				// Create parser
				TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
				
				//Get all the cells of the 2nd row of the 3rd table 
				TFHppleElement* contMain = [xpathParser at:@"//div[@id='contMain']/div[1]/table[1]//tr[2]/td[2]/text()"];
				if(contMain){
					text = [[contMain content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
					//NSLog(@"fetched: %@ at %d", contMain, i);
				}else {
					text = @"Auweia! Die Wetterdaten konnten nicht ausgelesen werden.";
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}

-(void) viewWillAppear:(BOOL)animated{
	[self.tableView reloadData];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[dayPaths release];
	[baseURL release];
	[urls release];
	[_texts release];
    [super dealloc];
}

@end
