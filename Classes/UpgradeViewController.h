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


@interface UpgradeViewController : UIViewController 
									<UIAlertViewDelegate,
									SKPaymentTransactionObserver>
{
	iScannerAppDelegate *appDelegate;
	IBOutlet UIActivityIndicatorView *indicatorView;
	IBOutlet UIButton *backButton;
	IBOutlet UIButton *buyButton;
}

- (IBAction)backAction:(id)sender;
- (IBAction)buyAction:(id)sender;

@end
