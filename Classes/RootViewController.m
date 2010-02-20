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
#import "RotatingSymbolsViewController.h"
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

	glyphsViewCtl = [[RotatingSymbolsViewController alloc] initWithNibName:@"RotatingSymbolsViewController" bundle:[NSBundle mainBundle]];
	[self.view insertSubview:glyphsViewCtl.view atIndex:0];
	
	// hide all elements to reveal when view appears
//	gridImageView.alpha = 0.0f;	
	appNameLabel.alpha = 0.0f;
	versionLabel.alpha = 0.0f;
	versionNumLabel.alpha = 0.0f;
	startButton.alpha = 0.0f;
	upgradeButton.alpha = 0.0f;
	openFeintButton.alpha = 0.0f;
	glyphsViewCtl.view.alpha = 0.0f;
	
	soundSettingRequested = FALSE;
}

#define	kLoadingAnimationID	@"kLoadingAnimationID"
#define kLoadingAnimationDuration	(2.5f)
#define kRevealAnimationID	@"kRevealAnimationID"
#define kCircleImageViewTag	(201)

#define kSoundAlertViewTag	(1)
- (void)viewAnimationDidStop:(NSString *)animationID 
						finished:(NSNumber *)finished 
						 context:(void *)context 
{
	if (!soundSettingRequested && [animationID isEqual:kRevealAnimationID]) {
		// ask user if he wants to use in-game sounds
		UIAlertView *soundAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enable Sounds Title", @"Enable Sounds Title") 
															 message:NSLocalizedString(@"Enable Sounds Message", @"Enable Sounds Message") 
															delegate:self 
												   cancelButtonTitle:NSLocalizedString(@"Disable", @"Disable") 
												   otherButtonTitles:NSLocalizedString(@"Enable", @"Enable"), nil];
		soundAlert.tag = kSoundAlertViewTag;
		[soundAlert show];
		[soundAlert release];
		
		soundSettingRequested = TRUE;
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	upgradeButton.hidden = appDelegate.fullVersion;
	versionLabel.text = (appDelegate.fullVersion ? NSLocalizedString(@"Full Version", @"Full Version") : NSLocalizedString(@"Lite Version", @"Lite Version"));
	
	// rotate hourglass and hide circles one by one
	[UIView beginAnimations:kLoadingAnimationID context:NULL];
	[UIView setAnimationDuration:kLoadingAnimationDuration];
	{
		hourglassImageView.transform = CGAffineTransformMakeRotation(-M_PI);
		// nest hiding animation for hourglass
		{
			[UIView beginAnimations:@"hide hourglass" context:NULL];
			[UIView setAnimationDuration:0.5f];
			[UIView setAnimationDelay:2.0f];
			hourglassImageView.alpha = 0.0f;
			[UIView commitAnimations];
		}
		// nest hiding animation for circles
		int i = 0;
		for (UIView *view in [self.view subviews]) {
			if (view.tag == kCircleImageViewTag) {
				[UIView beginAnimations:@"hide circle" context:NULL];
				[UIView setAnimationDelay:(i + 1) * 0.5f];
				[UIView setAnimationDuration:0.5f];
				view.alpha = 0.0f;
				[UIView commitAnimations];
				i++;
			}
		}
	}
	[UIView commitAnimations];	
	
	// reveal animation after delay (when previous animation completes)
	[UIView beginAnimations:kRevealAnimationID context:NULL];
	[UIView setAnimationDuration:1.0f];
	[UIView setAnimationDelay:kLoadingAnimationDuration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(viewAnimationDidStop:finished:context:)];
	{
		//		gridImageView.alpha = 1.0f;
		appNameLabel.alpha = 1.0f;
		versionLabel.alpha = 1.0f;
		versionNumLabel.alpha = 1.0f;
		startButton.alpha = 1.0f;
		upgradeButton.alpha = 1.0f;
		openFeintButton.alpha = 1.0f;
		glyphsViewCtl.view.alpha = 1.0f;
	}
	[UIView commitAnimations];	
	
	[glyphsViewCtl startAnimating];
}
		 
		 
#pragma mark -
#pragma mark UIAlertViewDelegate protocol implementation
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == kSoundAlertViewTag) {
		if (buttonIndex != alertView.cancelButtonIndex) {
			appDelegate.soundOn = TRUE;
		} else {
			appDelegate.soundOn = FALSE;
		}
	}
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[glyphsViewCtl stopAnimating];
}


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

