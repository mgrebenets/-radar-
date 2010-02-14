//
//  RootViewController.m
//  iScanner
//
//  Created by Maksym Grebenets on 2/2/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RootViewController.h"
#import "ScanViewController.h"
#import "iScannerAppDelegate.h"
#import "UpgradeViewController.h"
#import "Macro.h"


@implementation RootViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	appDelegate = (iScannerAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	appNameLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	versionNumLabel.text = [NSString stringWithFormat:@"v%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
	[startButton setTitle:NSLocalizedString(@"Start", @"Start") forState:UIControlStateNormal];
	[upgradeButton setTitle:NSLocalizedString(@"Upgrade", @"Upgrade") forState:UIControlStateNormal];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	upgradeButton.hidden = appDelegate.fullVersion;
	versionLabel.text = (appDelegate.fullVersion ? NSLocalizedString(@"Full Version", @"Full Version") : NSLocalizedString(@"Lite Version", @"Lite Version"));
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (IBAction)startAction:(id)sender {
	ScanViewController *viewCtl = [[ScanViewController alloc] init];
	viewCtl.levelPackId = kBasicLevelPackKey;
	viewCtl.levelIdx = [appDelegate unlockedLevelIdxForLevelPackKey:kBasicLevelPackKey];
	[[self navigationController] pushViewController:viewCtl animated:YES];
	[viewCtl release];
}

- (IBAction)upgradeAction:(id)sender {
	UpgradeViewController *upgradeViewCtl = [[UpgradeViewController alloc] init];
	[self.navigationController pushViewController:upgradeViewCtl animated:YES];
	[upgradeViewCtl release];
}

- (IBAction)openFeintAction:(id)sender {
	[appDelegate openFeintAction:sender];
}

- (IBAction)debugUpgradeAction:(id)sender {
	appDelegate.fullVersion = YES;
	[self viewWillAppear:YES];
}

- (IBAction)debugDowngradeAction:(id)sender {
	appDelegate.fullVersion = NO;
	[self viewWillAppear:YES];	
}


@end

