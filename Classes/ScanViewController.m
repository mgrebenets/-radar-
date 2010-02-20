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
#import "UpgradeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Macro.h"


#pragma mark -
#pragma mark Animation IDs and durations

#pragma mark View appearance
#define	kViewAppearanceAnimation	@"kViewAppearanceAnimation"
#define kViewAppearanceAnimationDuration	(1.0f)

#pragma mark Tutorial animations and defines
#define	kLastTutorialStep	(6)
#define kShowTutorialStepAnimationID	@"kShowTutorialStepAnimationID"
#define kShowTutorialStepAnimationDuration  (0.5f)
#define kNextTutorialStepAnimationID	@"kNextTutorialStepAnimationID"
#define kNextTutorialStepDuration	(0.5f)
#define kShowTapRequestAnimationID	@"kShowTapRequestAnimationID"
#define kHideTapRequestAnimationID	@"kHideTapRequestAnimationID"
#define kTapRequestAnimationDuration	(0.2f)

#define kRevealOpacity  (0.3f)      // reveal object view (by making cut view transparent)

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
#define kMoveAnswerFieldAnimationDuration   (0.25f)

#pragma mark Upgrade view proceed animation
#define kProceedToUpgradeAnimationID	@"kProceedToUpgradeAnimationID"

#define	kSoundAnimationImagesCnt	(6)
#define KSoundAnimationDuration		(4.0f)

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
- (void)keyboardWillShow:(NSNotification*)aNotification;
- (void)keyboardDidShow:(NSNotification*)aNotification;
- (void)keyboardWillHide:(NSNotification*)aNotification;
- (void)keyboardDidHide:(NSNotification*)aNotification;
- (void)registerForKeyboardNotifications;
@end


@implementation ScanViewController
@synthesize levelPackId;
@synthesize levelIdx;
@synthesize soundButton;

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
	answerFieldOriginalFrame = answerTextField.frame;
	
	[menuButton setTitle:NSLocalizedString(@"Menu", @"Menu") forState:UIControlStateNormal];
	
	// initially hide most of the elements
	// did not set them transparent in IB because it is not convinient to work there that way
	firstLevelButton.layer.opacity = 0.0f;
	prevLevelButton.layer.opacity = 0.0f;
	nextLevelButton.layer.opacity = 0.0f;
	lastLevelButton.layer.opacity = 0.0f;
	
	levelLabel.layer.opacity = 0.0f;
	tapMessage.layer.opacity = 0.0f;
	tapMessage.text = NSLocalizedString(@"Tap to Continue", @"Tap to Continue");	
	messageLabel.layer.opacity = 0.0f;
	answerCheckLabel.layer.opacity = 0.0f;
	answerTextField.layer.opacity = 0.0f;
	
	backButton.layer.opacity = 0.0f;
	openFeintButton.layer.opacity = 0.0f;
	
	// sound button
	soundButton.layer.opacity = 0.0f;
	NSMutableArray *animationImages = [NSMutableArray arrayWithObjects:nil];
	for (int i = 0; i < kSoundAnimationImagesCnt; i++) {
		NSString *imageName = [NSString stringWithFormat:@"sound-frame-%d.png", (i + 1)];
		[animationImages addObject:[UIImage imageNamed:imageName]];
	}
	soundButton.animationImages = animationImages;
	soundButton.animationDuration = KSoundAnimationDuration;
	soundButton.animationRepeatCount = 0;
	
	cutView.cutViewType = CutViewTypeRayScan;
	correctMessages = [[NSArray arrayWithObjects:NSLocalizedString(@"Correct!", @"Correct!"),
						 NSLocalizedString(@"Yes!", @"Yes!"),
						 NSLocalizedString(@"Right!", @"Right!"),
						 NSLocalizedString(@"Sure!", @"Sure!"),
						 NSLocalizedString(@"Of course!", @"Of course!"),
						 NSLocalizedString(@"Well yes!", @"Well yes!"),
						 NSLocalizedString(@"Well done!", @"Well done!"),
						 NSLocalizedString(@"Keep going!", @"Keep going!"),
						 NSLocalizedString(@"You knew it!", @"You knew it!"),
						 NSLocalizedString(@"Exactly!", @"Exactly!"),
						 NSLocalizedString(@"Good!", @"Good!"),
						 NSLocalizedString(@"Great!", @"Great!"),
						 nil] retain];
	 
	 wrongMessages = [[NSArray arrayWithObjects:NSLocalizedString(@"Wrong!", @"Wrong!"),
						NSLocalizedString(@"No!", @"No!"),
						NSLocalizedString(@"Oops!", @"Oops!"),
						NSLocalizedString(@"Nope!", @"Nope!"),
						NSLocalizedString(@"Try again!", @"Try again!"),
						NSLocalizedString(@"You were close!", @"You were close!"),
						NSLocalizedString(@"Maybe next time!", @"Maybe next time!"),
						NSLocalizedString(@"Almost there!", @"Almost there!"),
						NSLocalizedString(@"Another time!", @"Another time!"),
						nil] retain];	
	

	  
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
	[correctMessages release];
	[wrongMessages release];	
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
	
	// sound button image
	if (appDelegate.soundOn) {
		[soundButton startAnimating];
	} else {
		[soundButton stopAnimating];
	}
	
	// prev and first, next and last
	prevLevelButton.layer.opacity = (levelIdx == 0 ? 0.0f : 1.0f);
	firstLevelButton.layer.opacity = (levelIdx == 0 ? 0.0f : 1.0f);
	NSInteger unlockedLevelIdx = [appDelegate unlockedLevelIdxForLevelPackKey:levelPackId];
	nextLevelButton.layer.opacity = (levelIdx < unlockedLevelIdx ? 1.0f : 0.0f);
	lastLevelButton.layer.opacity = (levelIdx < unlockedLevelIdx ? 1.0f : 0.0f);
	
	// level label animation
	levelLabel.layer.opacity = 1.0f;
	
	// buttons
	backButton.layer.opacity = 1.0f;
	openFeintButton.layer.opacity = 1.0f;
	soundButton.layer.opacity = 1.0f;	
	
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
		
	// answer input field
	answerTextField.text = [NSLocalizedString(@"Answer", @"Answer") lowercaseString];
	answerTextField.layer.opacity = 1.0f;
	answerTextField.frame = answerFieldOriginalFrame;
	
	// get level pack to know max levels number
	NSArray *levelPack = [appDelegate levelPackForKey:levelPackId];	
	
	if (levelIdx == 0) {
		levelLabel.text = NSLocalizedString(@"Tutorial", @"Tutorial");
		tutorialLevel = TRUE;
		tutorialStep = 0;
		answerTextField.enabled = NO;
		answerTextField.textColor = [UIColor grayColor];
		// doTutorialStep will be called when appearance animation is done
	} else if ([appDelegate isUpgradeLevel:level]) {
		levelLabel.text = NSLocalizedString(@"Upgrade", @"Upgrade");
		// set scanner opacity so that answer is visible
		cutView.layer.opacity = kRevealOpacity;
		answerTextField.enabled = YES;
		answerTextField.textColor = [UIColor greenColor];
	}else if (levelIdx == (levelPack.count - 1)) {
		// set level label to level object string ("end")
		levelLabel.text = NSLocalizedString(@"To Be Continued...", @"To Be Continued...");
		// this is the end, reveal object by changing cut view opacity
		cutView.layer.opacity = kRevealOpacity;		
		// disable answer button
		answerTextField.enabled = NO;
		answerTextField.textColor = [UIColor grayColor];
	} else {
		// just a level, set its number
		levelLabel.text = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"Level", @"Level"), levelIdx];
		answerTextField.enabled = YES;		
		answerTextField.textColor = [UIColor greenColor];		
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
#ifdef DEBUGFULL	
	NSLog(@"scanViewAnimationDidStop:%@ finished:%d", animationID, [finished integerValue]);
#endif
	
	if ([animationID isEqual:kViewAppearanceAnimation]) {
#ifdef DEBUGFULL
		NSLog(@"kViewAppearanceAnimation animation done");
#endif		
		if (tutorialLevel) {
			[self doTutorialStep];
		}
		// else - wait for user input
	} else if ([animationID isEqual:kShowTutorialStepAnimationID]) {
		// more time before tap request to allow user to read message
		// the user could press next level already, so check if we're still in tutorial
		if (tutorialLevel) {
			BEGIN_ANIMATION(kShowTapRequestAnimationID, kTapRequestAnimationDuration * 5);
			tapMessage.layer.opacity = 1.0f;
			answerTextField.frame = answerFieldOriginalFrame;
			COMMIT_ANIMATION();
			requireTouch = YES;			
		}
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
		// create upgrade view and push to nav ctl
		UpgradeViewController *upgradeViewCtl = [[UpgradeViewController alloc] init];
		[self.navigationController pushViewController:upgradeViewCtl animated:YES];
		[upgradeViewCtl release];
	} else if ([animationID isEqual:kHideAnswerCheckAnimationID]) {
#ifdef DEBUGFULL
		NSLog(@"kHideAnswerCheckAnimationID");
#endif		
	} else if ([animationID isEqual:kCheckAnswerAnimationID]) {
#ifdef DEBUGFULL
		NSLog(@"kCheckAnswerAnimationID");
#endif		
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
		// pop up answer field
		CGRect popRect = answerFieldOriginalFrame;
		popRect.origin = CGPointMake(popRect.origin.x, popRect.origin.y - 20);
		answerTextField.frame = popRect;
	}
	COMMIT_ANIMATION();
}

- (NSString *)tutorialMessageAtStep:(NSInteger)step {
	NSString *stepStr = [NSString stringWithFormat:@"Step %d", step + 1];
	return NSLocalizedString(stepStr, stepStr);
}

- (void)tapAction:(id)sender {
	//NSLog(@"tapAction");
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
			answerCheckLabel.text = [correctMessages objectAtIndex:(rand() % correctMessages.count)];			
			answerCheckLabel.textColor = kCorrectAnswerColor;
		} else {
			answerCheckLabel.text = NSLocalizedString(@"Did you mean \"Yes\"? :)", @"Did you mean \"Yes\"? :)");
			answerCheckLabel.textColor = kCorrectAnswerColor;			
		}
		// display "correct" answer label
		BEGIN_ANIMATION(kCheckAnswerAnimationID, kCheckAnswerAnimationDuration);
		answerTextField.enabled = NO;
		answerTextField.textColor = [UIColor grayColor];
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
			answerCheckLabel.text = [correctMessages objectAtIndex:(rand() % correctMessages.count)];
			answerCheckLabel.textColor = kCorrectAnswerColor;
			cutView.layer.opacity = kRevealOpacity;
			answerTextField.enabled = NO;
			answerTextField.textColor = [UIColor grayColor];
		} else {
			// TODO: play wrong sound
			answerCheckLabel.text = [wrongMessages objectAtIndex:(rand() % wrongMessages.count)];
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
			levelLabel.layer.opacity = 0.0f;
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

#define kAnswerFieldResizeX     (80.0f)     // resize
- (void)moveAnswerTextField:(enum _MoveDirection)moveDirection keyboardHeight:(CGFloat)height {
#ifdef DEBUGFULL
	NSLog(@"%s", _cmd);
#endif	
	
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
		answerTextField.backgroundColor = [UIColor darkGrayColor];
	} else {
		// move down animated (to default position) and resize to default small size
		answerTextField.frame = answerFieldOriginalFrame; // to original position, as set with IB
		answerTextField.backgroundColor = [UIColor clearColor];
	}
	COMMIT_ANIMATION();
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
#ifdef DEBUGFULL
	NSLog(@"%s", _cmd);
#endif	
	// Get the size of the keyboard.
	NSDictionary* info = [aNotification userInfo];
	NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
	CGSize keyboardSize = [aValue CGRectValue].size;
	
	// move the answer input field up
	[self moveAnswerTextField:MoveDirectionUp keyboardHeight:keyboardSize.height];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardDidShow:(NSNotification*)aNotification
{
#ifdef DEBUGFULL
	NSLog(@"%s", _cmd);
#endif	
	// disable level navigation buttons
	firstLevelButton.enabled = NO;
	prevLevelButton.enabled = NO;
	nextLevelButton.enabled = NO;
	lastLevelButton.enabled = NO;
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
#ifdef DEBUGFULL
    NSLog(@"%s", _cmd);
#endif	
    // move the answer input field down (no need to know keyboard height here)
    [self moveAnswerTextField:MoveDirectionDown keyboardHeight:0];	
}

// Called when the UIKeyboardDidHideNotification is sent
- (void)keyboardDidHide:(NSNotification*)aNotification
{
#ifdef DEBUGFULL	
	NSLog(@"%s", _cmd);
#endif	
	
	// display "answer" string
	answerTextField.text = [NSLocalizedString(@"Answer", @"Answer") lowercaseString];	
	
	// enable level navigation buttons
	firstLevelButton.enabled = YES;
	prevLevelButton.enabled = YES;
	nextLevelButton.enabled = YES;
	lastLevelButton.enabled = YES;
}

- (void)registerForKeyboardNotifications
{
#ifdef DEBUGFULL	
	NSLog(@"%s", _cmd);
#endif	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];
												 
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShow:)
												 name:UIKeyboardDidShowNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidHide:)
												 name:UIKeyboardDidHideNotification object:nil];
}

#pragma mark UITextFieldDelegate protocol implementation
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
#ifdef DEBUGFULL
	NSLog(@"%s, input: %@", _cmd, textField.text);
#endif	
	
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
	if (appDelegate.soundOn) {
		[soundButton startAnimating];
	} else {
		[soundButton stopAnimating];
	}
}

- (IBAction)prevLevelAction:(id)sender {
	assert(levelIdx > 0);
	levelIdx--;
	levelLabel.layer.opacity = 0.0f;	
	[self updateView:YES];
}

- (IBAction)firstLevelAction:(id)sender {
	assert(levelIdx > 0);
	levelIdx = 0;
	levelLabel.layer.opacity = 0.0f;
	[self updateView:YES];
}

- (IBAction)nextLevelAction:(id)sender {
	assert(levelIdx < [appDelegate unlockedLevelIdxForLevelPackKey:levelPackId]);
	levelIdx++;
	levelLabel.layer.opacity = 0.0f;
	[self updateView:YES];
}

- (IBAction)lastLevelAction:(id)sender {
	assert(levelIdx < [appDelegate unlockedLevelIdxForLevelPackKey:levelPackId]);
	levelIdx = [appDelegate unlockedLevelIdxForLevelPackKey:levelPackId];
	levelLabel.layer.opacity = 0.0f;	
	[self updateView:YES];
}

// for testing
#pragma mark -
#pragma mark animations
- (IBAction)scanAction:(id)sender {
	[self stopScanningAnimation];
	if (cutView.cutViewType == CutViewTypeDrawnConcentricScan) {
		cutView.cutViewType = CutViewTypeRayScan;
	} else {
		cutView.cutViewType = CutViewTypeDrawnConcentricScan;
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
