//
//  ScanViewController.m
//  iScanner
//
//  Created by Maksym Grebenets on 2/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScanViewController.h"
#import "iScannerAppDelegate.h"
#import "Macro.h"

#define ScanBeginPoint	CGPointMake(160, 480)
#define ScanEndPoint	CGPointMake(160, 0)
#define ScanCenterPoint	CGPointMake(160, 240)

#define	kLastTutorialStep	(5)

#pragma mark Animation IDs and durations
#define	kShowObjectViewAnimationID	@"kShowObjectViewAnimationID"
#define kScanMoveAnimationID	@"kScanMoveAnimationID"
#define kShowTutorialStepAnimationID	@"kShowTutorialStepAnimationID"

#define kTapRequestShowAnimationID	@"kTapRequestShowAnimationID"
#define kTapRequestHideAnimationID	@"kTapRequestHideAnimationID"
#define kTapRequestAnimationDuration	(0.5f)
#define kNextLevelAnimationID	@"kNextLevelAnimationID"
#define kNextLevelAnimationDuration	(1.0f)
#define kNextTutorialStepAnimationID	@"kNextTutorialStepAnimationID"
#define kNextTutorialStepDuration	(0.5f)

@interface ScanViewController ()
- (void)scanViewAnimationDidStop:(NSString *)animationID 
						finished:(NSNumber *)finished 
						 context:(void *)context;
@end

@interface ScanViewController (TutorialSteps)
- (void)doTutorialStep;
- (NSString *)tutorialMessageAtStep:(NSInteger)step;
@end


@implementation ScanViewController
@synthesize appDelegate;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
//	objectImageView.center = CGPointMake(160, 480);
	
	if (appDelegate.fullVersion) {
		openFeintButton.hidden = NO;
	}
	
	soundButton.hidden = !appDelegate.soundOn;
	
	prevLevelButton.hidden = (levelIdx == 0);
	firstLevelButton.hidden = (levelIdx == 0);
	nextLevelButton.hidden = !(levelIdx < appDelegate.levelPack.unlockedLevelIdx);
	lastLevelButton.hidden = !(levelIdx < appDelegate.levelPack.unlockedLevelIdx);

	Level *level = [appDelegate.levelPack levelAtIndex:levelIdx];
	
	if (level.levelType == LevelTypeChar) {
		objectView = objectLabel;
		objectLabel.text = level.objectStr;
	} else {
		objectView = objectImageView;
		objectImageView.image = [UIImage imageNamed:level.objectStr];
	}

	// reveal object view (and set to start position)
	objectView.center = ScanBeginPoint;
	[UIView beginAnimations:kShowObjectViewAnimationID context:NULL];
	[UIView setAnimationDuration:0.5];
	objectView.hidden = NO;
	[UIView commitAnimations];

	[UIView beginAnimations:kScanMoveAnimationID context:NULL];
	[UIView setAnimationDuration:5];
	[UIView setAnimationRepeatCount:(-1)];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(scanViewAnimationDidStop:finished:context:)];
	objectView.center = ScanEndPoint;
	[UIView commitAnimations];
	
	if (levelIdx == 0) {
		tutorialLevel = TRUE;
		tutorialStep = 0;
		answerButton.enabled = FALSE;
		[self doTutorialStep];
	} else if (levelIdx == appDelegate.levelPack.lastLevelIdx) {
		// TODO: this is the end, reveal object by changing cut view opacity
	}

	
}

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

#pragma mark -
#pragma mark Animation callbacks
- (void)scanViewAnimationDidStop:(NSString *)animationID 
				finished:(NSNumber *)finished 
				 context:(void *)context 
{
	NSLog(@"scanViewAnimationDidStop:%@ finished:%d", animationID, [finished integerValue]);
	
	if ([animationID isEqual:kScanMoveAnimationID]) {
	
	} else if ([animationID isEqual:kShowTutorialStepAnimationID]) {
		[UIView beginAnimations:kTapRequestShowAnimationID context:NULL];
		[UIView setAnimationDuration:kTapRequestAnimationDuration];
		tapMessage.hidden = NO;
		[UIView commitAnimations];
		requireTouch = YES;
	} else if ([animationID isEqual:kTapRequestHideAnimationID]) {
		NSString *tutorialAnimationID;
		NSTimeInterval duration;
		if (tutorialStep == kLastTutorialStep) {
			levelIdx++;
			tutorialAnimationID = kNextLevelAnimationID;
			duration = kNextLevelAnimationDuration;
		} else {
			tutorialStep++;
			tutorialAnimationID = kNextTutorialStepAnimationID;
			duration = kNextTutorialStepDuration;
		}
		[UIView beginAnimations:tutorialAnimationID context:NULL];
		[UIView setAnimationDuration:duration];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(scanViewAnimationDidStop:finished:context:)];
		messageLabel.hidden = YES;
		[UIView commitAnimations];
	} else if ([animationID isEqual:kNextLevelAnimationID]) {
		levelIdx++;
		[self viewWillAppear:YES];
	} else if ([animationID isEqual:kNextTutorialStepAnimationID]) {
		tutorialStep++;
		[self doTutorialStep];
	}
}

#pragma mark -
#pragma mark TUtorialSteps category implementation
- (void)doTutorialStep {
	messageLabel.text = [self tutorialMessageAtStep:tutorialStep];
	[UIView beginAnimations:kShowTutorialStepAnimationID context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(scanViewAnimationDidStop:finished:context:)];
	messageLabel.hidden = NO;
	[UIView commitAnimations];
}

- (NSString *)tutorialMessageAtStep:(NSInteger)step {
	NSString *stepStr = [NSString stringWithFormat:@"Tutorial Step %d", step + 1];
	return locStr(stepStr);
}

- (void)tapAction:(id)sender {
	NSLog(@"tapAction");
	if (!requireTouch) return;
	if (!tutorialLevel) return;
	[UIView beginAnimations:kTapRequestHideAnimationID context:NULL];
	[UIView setAnimationDuration:kTapRequestAnimationDuration];
	tapMessage.hidden = YES;
	[UIView commitAnimations];
	requireTouch = NO;	
}

#pragma mark -
#pragma mark Action handlers

- (IBAction)answerAction:(id)sender {
	// TODO: show keyboard
}

- (IBAction)exitAction:(id)sender {
	[[self navigationController] popViewControllerAnimated:YES];
}

@end
