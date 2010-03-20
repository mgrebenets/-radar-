//
//  UpgradeViewController.h
//  iScanner
//
//  Created by Maksym Grebenets on 2/10/10.
//  Copyright 2010 i4nApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
@class iScannerAppDelegate;
@class RotatingSymbolsViewController;

@interface UpgradeViewController : UIViewController 
									<UIAlertViewDelegate,
									SKPaymentTransactionObserver>
{
	iScannerAppDelegate *appDelegate;
	IBOutlet UIActivityIndicatorView *indicatorView;
	IBOutlet UIButton *backButton;
	IBOutlet UIButton *buyButton;
	IBOutlet UILabel *upgradeLabel;
	IBOutlet UILabel *moreNowLabel;
	IBOutlet UILabel *moreLaterLabel;
	IBOutlet UILabel *moreAchievementsLabel;
	IBOutlet UILabel *removeAdsLabel;
	RotatingSymbolsViewController *glyphsViewCtl;
}

- (IBAction)backAction:(id)sender;
- (IBAction)buyAction:(id)sender;

@end
