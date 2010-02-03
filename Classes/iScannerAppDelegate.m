//
//  iScannerAppDelegate.m
//  iScanner
//
//  Created by Maksym Grebenets on 2/2/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "iScannerAppDelegate.h"
#import "RootViewController.h"

@implementation iScannerAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize fullVersion;
@synthesize soundOn;
@synthesize levelPack;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

- (void)openFeintAction:(id)sender {
	// TODO: launch openfeint dashboard
}

@end

