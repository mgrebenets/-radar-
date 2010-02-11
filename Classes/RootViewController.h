//
//  RootViewController.h
//  iScanner
//
//  Created by Maksym Grebenets on 2/2/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

@class iScannerAppDelegate;

@interface RootViewController : UIViewController {
	iScannerAppDelegate *appDelegate;
	IBOutlet UIButton *upgradeButton;
	IBOutlet UILabel *versionLabel;
}

- (IBAction)startAction:(id)sender;
- (IBAction)upgradeAction:(id)sender;
- (IBAction)openFeintAction:(id)sender;

- (IBAction)debugUpgradeAction:(id)sender;
- (IBAction)debugDowngradeAction:(id)sender;

@end
