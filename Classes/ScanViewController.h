//
//  ScanViewController.h
//  iScanner
//
//  Created by Maksym Grebenets on 2/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class iScannerAppDelegate;
@class CutView;

@interface ScanViewController : UIViewController  <UITextFieldDelegate>{
	iScannerAppDelegate *appDelegate;
	NSString *levelPackId;
	NSInteger oldLevelIdx;
	NSInteger levelIdx;
	BOOL tutorialLevel;
	NSInteger tutorialStep;
	BOOL requireTouch;
	BOOL stopRepeatingScan;
	BOOL keyboardShowing;
	UIView *objectView;
	IBOutlet CutView *cutView;
	IBOutlet UIImageView *objectImageView;
	IBOutlet UILabel *objectLabel;
	IBOutlet UIButton *backButton;
	IBOutlet UIButton *openFeintButton;
	IBOutlet UIImageView *soundButton;
	IBOutlet UILabel *levelLabel;
	IBOutlet UIButton *prevLevelButton;
	IBOutlet UIButton *firstLevelButton;
	IBOutlet UIButton *nextLevelButton;
	IBOutlet UIButton *lastLevelButton;
	IBOutlet UILabel *messageLabel;
	IBOutlet UILabel *tapMessage;
	IBOutlet UITextField *answerTextField;
	IBOutlet UIButton *menuButton;
	CGRect answerFieldOriginalFrame;
	IBOutlet UILabel *answerCheckLabel;
	NSArray *correctMessages;
	NSArray *wrongMessages;	

	UIView *_bannerAd;	// add banner
}

- (void)tapAction:(id)sender;
- (IBAction)exitAction:(id)sender;
- (IBAction)openFeintAction:(id)sender;
- (IBAction)soundAction:(id)sender;
- (IBAction)prevLevelAction:(id)sender;
- (IBAction)firstLevelAction:(id)sender;
- (IBAction)nextLevelAction:(id)sender;
- (IBAction)lastLevelAction:(id)sender;

- (IBAction)scanAction:(id)sender;

@property (nonatomic, retain) NSString *levelPackId;
@property NSInteger levelIdx;
@property (readonly) UIImageView *soundButton;

@end
