//
//  RotatingSymbolsViewController.h
//  iScanner
//
//  Created by Maksym Grebenets on 2/14/10.
//  Copyright 2010 i4nApps. All rights reserved.
//

#import <UIKit/UIKit.h>
@class iScannerAppDelegate;

@interface RotatingSymbolsViewController : UIViewController {
	iScannerAppDelegate *appDelegate;
}

- (void)startAnimating;
- (void)stopAnimating;

@end
