//
//  UpgradeViewController.m
//  iScanner
//
//  Created by Maksym Grebenets on 2/10/10.
//  Copyright 2010 i4nApps. All rights reserved.
//

#import "UpgradeViewController.h"
#import "iScannerAppDelegate.h"
#import "Macro.h"


@implementation UpgradeViewController

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
	appDelegate = (iScannerAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// observe transactions
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
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
	// do not observe transactions any more
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];	
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark UIAlertViewDelegate protocol implementation
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// TODO:
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver protocol implementation
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
	for (SKPaymentTransaction *transaction in transactions) {
		NSLog(@"State: %d", transaction.transactionState);
		NSLog(@"Id: %d", transaction.transactionIdentifier);
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchased:
			case SKPaymentTransactionStateRestored:
				NSLog(@"Transaction purchased or restored");
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];	
				
				// set app delegate full version flag
				appDelegate.fullVersion = YES;
				
				// enable back and buy buttons (so they will be properly displayed if enter this view again)
				backButton.enabled = YES;
				buyButton.enabled = YES;
				[indicatorView stopAnimating];
				
				// nagivate to previous view (main menu or newly unlocked level)
				[[self navigationController] popViewControllerAnimated:YES];
				
				break;
			case SKPaymentTransactionStateFailed:
				NSLog(@"Tranaction failed");
				// user has already been notified about failed transaction by AppStore dialog
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];	
				
				NSLog(@"%@", transaction.error);
				NSLog(@"%@", [transaction.error localizedDescription]);
				NSLog(@"%@", [transaction.error localizedFailureReason]);				
				NSLog(@"%@", [transaction.error localizedRecoveryOptions]);
				NSLog(@"%@", [transaction.error localizedRecoverySuggestion]);
				
				[indicatorView stopAnimating];
				
				UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:locStr(@"Purchase Error") 
																	message:[transaction.error localizedDescription] 
																   delegate:nil 
														  cancelButtonTitle:locStr(@"OK") 
														  otherButtonTitles:nil];
				[failAlert show];
				[failAlert release];
				
				// enable back and buy buttons and status
				backButton.enabled = YES;
				buyButton.enabled = YES;
				break;
			default:
				NSLog(@"Transaction is still in progress");
				break;
		}
	}
}

#pragma mark Actions
- (IBAction)backAction:(id)sender {
	[indicatorView stopAnimating];
	[self.navigationController popViewControllerAnimated:YES];
}

#define kProductID	@"com.i4nApps.iRadar.FullVersion"

- (IBAction)buyAction:(id)sender {
	NSLog(@"%s", _cmd);
	
	// initiate payment
	SKPayment *payment = [SKPayment paymentWithProductIdentifier:kProductID];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
	
	// disable buy and back buttons until purchase is not over, update status
	backButton.enabled = NO;
	buyButton.enabled = NO;
	[indicatorView startAnimating];	
}



@end
