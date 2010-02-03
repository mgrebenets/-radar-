//
//  ScanViewController.h
//  iScanner
//
//  Created by Maksym Grebenets on 2/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class iScannerAppDelegate;

@interface ScanViewController : UIViewController {
	iScannerAppDelegate *appDelegate;
	NSInteger levelIdx;
	BOOL tutorialLevel;
	NSInteger tutorialStep;
	BOOL requireTouch;
	BOOL stopRepeatingScan;
	UIView *objectView;
	IBOutlet UIImageView *cutView;
	IBOutlet UIImageView *objectImageView;
	IBOutlet UILabel *objectLabel;
	IBOutlet UIButton *openFeintButton;
	IBOutlet UIButton *soundButton;
	IBOutlet UIButton *prevLevelButton;
	IBOutlet UIButton *firstLevelButton;
	IBOutlet UIButton *nextLevelButton;
	IBOutlet UIButton *lastLevelButton;
	IBOutlet UIButton *answerButton;
	IBOutlet UILabel *messageLabel;
	IBOutlet UILabel *tapMessage;
}

- (void)tapAction:(id)sender;
- (IBAction)answerAction:(id)sender;
- (IBAction)exitAction:(id)sender;
- (IBAction)openFeintAction:(id)sender;
- (IBAction)soundAction:(id)sender;
- (IBAction)prevLevelAction:(id)sender;
- (IBAction)firstLevelAction:(id)sender;
- (IBAction)nextLevelAction:(id)sender;
- (IBAction)lastLevelAction:(id)sender;

@property (nonatomic, assign) iScannerAppDelegate *appDelegate;

@end
