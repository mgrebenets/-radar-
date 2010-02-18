//
//  RotatingSymbolsViewController.m
//  iScanner
//
//  Created by Maksym Grebenets on 2/14/10.
//  Copyright 2010 i4nApps. All rights reserved.
//

#import "RotatingSymbolsViewController.h"
#import "iScannerAppDelegate.h"
#import "GlyphView.h"

#define kGlyphViewTag	(111)

@implementation RotatingSymbolsViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	appDelegate = (iScannerAppDelegate *)[[UIApplication sharedApplication] delegate];
}

/*
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
    [super dealloc];
}

- (void)startAnimating {
#ifdef DEBUGFULL	
	NSLog(@"%s", _cmd);
#endif	
	for (UIView *glyphView in [self.view subviews]) {
		if (glyphView.tag == kGlyphViewTag) {
			[(GlyphView *)glyphView startAnimating];
		}
	}
}

- (void)stopAnimating {
#ifdef DEBUGFULL	
	NSLog(@"%s", _cmd);	
#endif	
	for (UIView *glyphView in [self.view subviews]) {
		if (glyphView.tag == kGlyphViewTag) {
			[(GlyphView *)glyphView stopAnimating];
		}
	}
}


@end
