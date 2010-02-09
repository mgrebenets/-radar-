//
//  ScanViewController.m
//  iScanner
//
//  Created by Maksym Grebenets on 2/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScanViewController.h"
#import "iScannerAppDelegate.h"
#import "CutView.h"
#import <QuartzCore/QuartzCore.h>
#import "Macro.h"


#pragma mark -
#pragma mark Animation IDs and durations

#pragma mark View appearance
#define	kViewAppearanceAnimation	@"kViewAppearanceAnimation"
#define kViewAppearanceAnimationDuration	(1.0f)

#pragma mark Tutorial animations and defines
#define	kLastTutorialStep	(5)
#define kShowTutorialStepAnimationID	@"kShowTutorialStepAnimationID"
#define kShowTutorialStepAnimationDuration  (0.5f)
#define kNextTutorialStepAnimationID	@"kNextTutorialStepAnimationID"
#define kNextTutorialStepDuration	(0.5f)
#define kShowTapRequestAnimationID	@"kShowTapRequestAnimationID"
#define kHideTapRequestAnimationID	@"kHideTapRequestAnimationID"
#define kTapRequestAnimationDuration	(0.2f)

#define kRevealOpacity  (0.5f)      // reveal object view (by making cut view transparent)

#pragma mark Next level animations
#define kNextLevelAnimationID	@"kNextLevelAnimationID"
#define kNextLevelAnimationDuration	(1.0f)

#pragma mark Answer check animations
#define kCheckAnswerAnimationID	@"kCheckAnswerAnimationID"
#define kCheckAnswerAnimationDuration	(0.5f)
#define kHideAnswerCheckAnimationID	@"kHideAnswerCheckAnimationID"
#define kHideAnswerCheckAnimationDuration	(1.0f)
#define kCorrectAnswerColor ([UIColor greenColor])
#define kWrongAnswerColor ([UIColor redColor])
#define kMoveAnswerFieldAnimationID @"kMoveAnswerFieldAnimationID"
#define kMoveAnswerFieldAnimationDuration   (0.1f)

#pragma mark Upgrade view proceed animation
#define kProceedToUpgradeAnimationID	@"kProceedToUpgradeAnimationID"


@interface ScanViewController ()
- (Level *)currentLevel;
- (void)updateView:(BOOL)animated;
- (void)startScanningAnimation;
- (void)stopScanningAnimation;
- (void)scanViewAnimationDidStop:(NSString *)animationID 
						finished:(NSNumber *)finished 
						 context:(void *)context;
@end

@interface ScanViewController (TutorialSteps)
- (void)doTutorialStep;
- (NSString *)tutorialMessageAtStep:(NSInteger)step;
@end

enum _MoveDirection {
    MoveDirectionUp,
    MoveDirectionDown
};

@interface ScanViewController   (Keyboard)
- (void)moveAnswerTextField:(enum _MoveDirection)moveDirection keyboardHeight:(CGFloat)height;
- (void)keyboardWasShown:(NSNotification*)aNotification;
- (void)keyboardWasHidden:(NSNotification*)aNotification;
- (void)registerForKeyboardNotifications;
@end


@implementation ScanViewController
@synthesize levelPackId;

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
	// get delegate
	appDelegate = (iScannerAppDelegate *)[[UIApplication sharedApplication] delegate];
	// register for keyboard notifications
	[self registerForKeyboardNotifications];
	// get the answer input field original frame as set by IB, to use for positioning
	answerFieldOriginalFrmae = answerTextField.frame;
	
	cutView.cutViewType = CutViewTypeCircleScan;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[self updateView:animated];
	
	[self stopScanningAnimation];
	[self startScanningAnimation];
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
#pragma mark Additional methods
- (Level *)currentLevel {
	return [appDelegate levelFromPack:levelPackId atIndex:levelIdx];
}

- (void)updateView:(BOOL)animated {
	
	cutView.layer.opacity = 1.0f;
	
	if (animated) {
		[UIView beginAnimations:kViewAppearanceAnimation context:NULL];
		[UIView setAnimationDuration:kViewAppearanceAnimationDuration];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(scanViewAnimationDidStop:finished:context:)];		
	}
	
	// update current level idx to app delegates dictionary
	[appDelegate unlockLevel:levelIdx forLevelPackWithKey:levelPackId];
	
	// TODO: sound button image
	soundButton.titleLabel.text = (appDelegate.soundOn ? locStr(@"snd:on") : locStr(@"snd:off"));
	
	
	// prev and first, next and last
	prevLevelButton.layer.opacity = (levelIdx == 0 ? 0.0f : 1.0f);
	firstLevelButton.layer.opacity = (levelIdx == 0 ? 0.0f : 1.0f);
	NSInteger unlockedLevelIdx = [appDelegate unlockedLevelIdxForLevelPackKey:levelPackId];
	nextLevelButton.layer.opacity = (levelIdx < unlockedLevelIdx ? 1.0f : 0.0f);
	lastLevelButton.layer.opacity = (levelIdx < unlockedLevelIdx ? 1.0f : 0.0f);
	
	// get current level
	Level *level = [self currentLevel];
	
	if (level.levelType == LevelTypeChar) {
		objectView = objectLabel;
		objectLabel.text = level.objectStr;
		objectImageView.hidden = YES;
		objectLabel.hidden = NO;
	} else {
		objectView = objectImageView;
		objectImageView.image = [UIImage imageNamed:level.objectStr];
		objectImageView.hidden = NO;
		objectLabel.hidden = YES;
	}
	
	// not tutorial yet
	tutorialStep = 0;
	tutorialLevel = FALSE;
	requireTouch = FALSE;
	
	messageLabel.layer.opacity = 0.0f;
	tapMessage.layer.opacity = 0.0f;
	
	// level label animation
	levelLabel.layer.opacity = 1.0f;
	
	// answer input field
	answerTextField.text = [locStr(@"Answer") lowercaseString];
	
	// get level pack to know max levels number
	NSArray *levelPack = [appDelegate levelPackForKey:levelPackId];	
	
	if (levelIdx == 0) {
		levelLabel.text = locStr(@"Tutorial");
		tutorialLevel = TRUE;
		tutorialStep = 0;
		answerTextField.enabled = NO;
		// doTutorialStep will be called when appearance animation is done
	} else if ([appDelegate isUpgradeLevel:level]) {
		levelLabel.text = locStr(@"Upgrade");
		// set scanner opacity so that answer is visible
		cutView.layer.opacity = kRevealOpacity;
		answerTextField.enabled = YES;
	}else if (levelIdx == (levelPack.count - 1)) {
		// set level label to level object string ("end")
		levelLabel.text = locStr(@"End");
		// this is the end, reveal object by changing cut view opacity
		cutView.layer.opacity = kRevealOpacity;		
		// disable answer button
		answerTextField.enabled = NO;
	} else {
		// just a level, set its number
		levelLabel.text = [NSString stringWithFormat:@"%@ %d", locStr(@"Level"), levelIdx];
		answerTextField.enabled = YES;		
	}
	
	if (animated) {
		[UIView commitAnimations];
	}
}

#pragma mark -
#pragma mark Animation callbacks
- (void)scanViewAnimationDidStop:(NSString *)animationID 
						finished:(NSNumber *)finished 
						 context:(void *)context 
{
	NSLog(@"scanViewAnimationDidStop:%@ finished:%d", animationID, [finished integerValue]);
	
	if ([animationID isEqual:kViewAppearanceAnimation]) {
		NSLog(@"kViewAppearanceAnimation animation done");
		if (tutorialLevel) {
			[self doTutorialStep];
		}
		// else - wait for user input
	} else if ([animationID isEqual:kShowTutorialStepAnimationID]) {
		// TODO: more time before tap request to allow user to read message
		BEGIN_ANIMATION(kShowTapRequestAnimationID, kTapRequestAnimationDuration * 5);
		tapMessage.layer.opacity = 1.0f;
		COMMIT_ANIMATION();
		requireTouch = YES;
	} else if ([animationID isEqual:kHideTapRequestAnimationID]) {
		NSString *tutorialAnimationID;
		NSTimeInterval duration;
		if (tutorialStep == kLastTutorialStep) {
			tutorialAnimationID = kNextLevelAnimationID;
			duration = kNextLevelAnimationDuration;
		} else {
			tutorialAnimationID = kNextTutorialStepAnimationID;
			duration = kNextTutorialStepDuration;
		}
		BEGIN_ANIMATION(tutorialAnimationID, duration);
		messageLabel.layer.opacity = 0.0f;
		if (tutorialStep == kLastTutorialStep) {
			cutView.layer.opacity = 1.0f;   // also hide an answer when moving to next level
		}
		COMMIT_ANIMATION();
	} else if ([animationID isEqual:kNextLevelAnimationID]) {
		levelIdx++;
		[self updateView:YES];
	} else if ([animationID isEqual:kNextTutorialStepAnimationID]) {
		tutorialStep++;
		[self doTutorialStep];
	} else if ([animationID isEqual:kProceedToUpgradeAnimationID]){
		// TODO: create upgrade view and push to nav ctl
	} else if ([animationID isEqual:kHideAnswerCheckAnimationID]) {
		NSLog(@"kHideAnswerCheckAnimationID");
	} else if ([animationID isEqual:kCheckAnswerAnimationID]) {
		NSLog(@"kCheckAnswerAnimationID");
	}
	
}

#pragma mark -
#pragma mark TutorialSteps category implementation
- (void)doTutorialStep {
	BEGIN_ANIMATION(kShowTutorialStepAnimationID, kShowTutorialStepAnimationDuration);
	messageLabel.text = [self tutorialMessageAtStep:tutorialStep];
	messageLabel.layer.opacity = 1.0f;
	if (tutorialStep == 2) {
		// on one of the steps reveal object view by making cut view less opaque
		cutView.layer.opacity = kRevealOpacity;
	} else if (tutorialStep == 3) {
		// TODO: highligt/blink or any other animation for answer input field (1 time only)
	}
	COMMIT_ANIMATION();
}

- (NSString *)tutorialMessageAtStep:(NSInteger)step {
	NSString *stepStr = [NSString stringWithFormat:@"Tutorial Step %d", step + 1];
	return locStr(stepStr);
}

- (void)tapAction:(id)sender {
	NSLog(@"tapAction");
	if (!requireTouch) return;
	if (!tutorialLevel) return;
	BEGIN_ANIMATION(kHideTapRequestAnimationID, kTapRequestAnimationDuration);
	tapMessage.layer.opacity = 0.0f;
	COMMIT_ANIMATION();
	requireTouch = NO;	
}

#pragma mark -
#pragma mark Answer handling
- (void)checkAnswer:(NSString *)answer {
	Level *level = [self currentLevel];
	BOOL correctAnswer = [level correctAnswer:answer];
	
	if ([appDelegate isUpgradeLevel:level]) {
		// TODO: play correct sound
		if (correctAnswer) {
			answerCheckLabel.text = locStr(@"Correct");
			answerCheckLabel.textColor = kCorrectAnswerColor;
		} else {
			answerCheckLabel.text = locStr(@"Did you mean \"Yes\"? :)");
			answerCheckLabel.textColor = kCorrectAnswerColor;			
		}
		// display "correct" answer label
		BEGIN_ANIMATION(kCheckAnswerAnimationID, kCheckAnswerAnimationDuration);
		answerCheckLabel.layer.opacity = 1.0f;
		cutView.layer.opacity = kRevealOpacity; // show the answer
		COMMIT_ANIMATION();
		
		// fade off after delay to proceed to upgrade view
		BEGIN_ANIMATION_DELAYED(kProceedToUpgradeAnimationID, kHideAnswerCheckAnimationDuration, kCheckAnswerAnimationDuration);
		answerCheckLabel.layer.opacity = 0.0f;
		cutView.layer.opacity = 1.0f;   // hide the answer
		COMMIT_ANIMATION();
		
	} else {
		
		// begin animaion
		BEGIN_ANIMATION(kCheckAnswerAnimationID, kCheckAnswerAnimationDuration);
		
		if (correctAnswer) {
			// TODO: play correct sound
			answerCheckLabel.text = locStr(@"Correct");
			answerCheckLabel.textColor = kCorrectAnswerColor;
			cutView.layer.opacity = kRevealOpacity;
		} else {
			// TODO: play wrong sound
			answerCheckLabel.text = locStr(@"Wrong");
			answerCheckLabel.textColor = kWrongAnswerColor;
		}
		
		// reveal answer check label
		answerCheckLabel.layer.opacity = 1.0f;
		
		COMMIT_ANIMATION();
		
		// fade off
		if (correctAnswer) {
			BEGIN_ANIMATION_DELAYED(kNextLevelAnimationID, kHideAnswerCheckAnimationDuration, kCheckAnswerAnimationDuration);
			answerCheckLabel.layer.opacity = 0.0f;
			cutView.layer.opacity = 1.0f;
			COMMIT_ANIMATION();
		} else {
			BEGIN_ANIMATION_DELAYED(kHideAnswerCheckAnimationID, kHideAnswerCheckAnimationDuration, kCheckAnswerAnimationDuration);
			answerCheckLabel.layer.opacity = 0.0f;
			COMMIT_ANIMATION();
		}
	}
}

#pragma mark -
#pragma mark Keyboard notifications handling

#define kAnswerFieldResizeX     (40.0f)     // resize on 40px
- (void)moveAnswerTextField:(enum _MoveDirection)moveDirection keyboardHeight:(CGFloat)height {
	NSLog(@"%s", _cmd);
	
	CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
	BEGIN_ANIMATION(kMoveAnswerFieldAnimationID, kMoveAnswerFieldAnimationDuration);
	if (moveDirection == MoveDirectionUp) {
		// resize to bigger size to accept longer input and at the same time move to new position
		answerTextField.frame = CGRectMake(answerTextField.frame.origin.x - kAnswerFieldResizeX / 2,    // move left due to resize
										   screenSize.height - height - answerTextField.frame.size.height, // move above keyboard
										   answerTextField.frame.size.width + kAnswerFieldResizeX, // stretch horizontally
										   answerTextField.frame.size.height); // same height
		
		// clear displayed text to display cursor
		answerTextField.text = @"";
		answerTextField.placeholder = @"";
	} else {
		// move down animated (to default position) and resize to default small size
		answerTextField.frame = answerFieldOriginalFrmae; // to original position, as set with IB
		
		// display "answer" string
		answerTextField.text = @"";
		answerTextField.placeholder = [locStr(@"Answer") lowercaseString];
	}
	COMMIT_ANIMATION();
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
	NSLog(@"%s", _cmd);
	// Get the size of the keyboard.
	NSDictionary* info = [aNotification userInfo];
	NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
	CGSize keyboardSize = [aValue CGRectValue].size;
	
	// move the answer input field up
	[self moveAnswerTextField:MoveDirectionUp keyboardHeight:keyboardSize.height];	
}


// Called when the UIKeyboardDidHideNotification is sent
- (void)keyboardWasHidden:(NSNotification*)aNotification
{
	NSLog(@"%s", _cmd);
	// move the answer input field down (no need to know keyboard height here)
	[self moveAnswerTextField:MoveDirectionDown keyboardHeight:0];	
}

- (void)registerForKeyboardNotifications
{
	NSLog(@"%s", _cmd);
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasHidden:)
												 name:UIKeyboardDidHideNotification object:nil];
}

#pragma mark UITextFieldDelegate protocol implementation
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSLog(@"%s, input: %@", _cmd, textField.text);
	
	[textField resignFirstResponder];
	
	// check answer
	[self checkAnswer:textField.text];
	
	return YES;
}

#pragma mark -
#pragma mark Action handlers
- (IBAction)exitAction:(id)sender {
	[[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)openFeintAction:(id)sender {
	[appDelegate openFeintAction:self];
}

- (IBAction)soundAction:(id)sender {
	appDelegate.soundOn = !appDelegate.soundOn;
	// TODO: animated change (some picture)
	soundButton.titleLabel.text = (appDelegate.soundOn ? locStr(@"snd:on") : locStr(@"snd:off"));
}

- (IBAction)prevLevelAction:(id)sender {
	assert(levelIdx > 0);
	levelIdx--;
	[self updateView:YES];
}

- (IBAction)firstLevelAction:(id)sender {
	assert(levelIdx > 0);
	levelIdx = 0;
	[self updateView:YES];
}

- (IBAction)nextLevelAction:(id)sender {
	assert(levelIdx < [appDelegate unlockedLevelIdxForLevelPackKey:levelPackId]);
	levelIdx++;
	[self updateView:YES];
}

- (IBAction)lastLevelAction:(id)sender {
	assert(levelIdx < [appDelegate unlockedLevelIdxForLevelPackKey:levelPackId]);
	levelIdx = [appDelegate unlockedLevelIdxForLevelPackKey:levelPackId];
	[self updateView:YES];
}

// for testing
#pragma mark -
#pragma mark animations
- (IBAction)scanAction:(id)sender {
	[self stopScanningAnimation];
	if (cutView.cutViewType == CutViewTypeCircleScan) {
		cutView.cutViewType = CutViewTypeRadarScan;
	} else {
		cutView.cutViewType = CutViewTypeCircleScan;
	}

	[self startScanningAnimation];
}

- (void)startScanningAnimation {
	[cutView startAnimation];	
}

- (void)stopScanningAnimation {
	[cutView stopAnimation];
}

@end
