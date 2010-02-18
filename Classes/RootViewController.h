//
//  RootViewController.h
//  iScanner
//
//  Created by Maksym Grebenets on 2/2/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

@class iScannerAppDelegate;
@class RotatingSymbolsViewController;

@interface RootViewController : UIViewController <UIAlertViewDelegate> {
	iScannerAppDelegate *appDelegate;
	IBOutlet UIImageView *hourglassImageView;
	IBOutlet UIImageView *gridImageView;
	IBOutlet UIButton *upgradeButton;
	IBOutlet UILabel *versionLabel;
	IBOutlet UILabel *appNameLabel;
	IBOutlet UILabel *versionNumLabel;
	IBOutlet UIButton *startButton;
	IBOutlet UIButton *openFeintButton;
	RotatingSymbolsViewController *glyphsViewCtl;
}

- (IBAction)startAction:(id)sender;
- (IBAction)upgradeAction:(id)sender;
- (IBAction)openFeintAction:(id)sender;

- (IBAction)debugUpgradeAction:(id)sender;
- (IBAction)debugDowngradeAction:(id)sender;

@end
