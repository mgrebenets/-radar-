//
//  iScannerAppDelegate.h
//  iScanner
//
//  Created by Maksym Grebenets on 2/2/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "LevelPack.h"

@interface iScannerAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	BOOL fullVersion;
	BOOL soundOn;
	LevelPack *levelPack;
}

- (void)openFeintAction:(id)sender;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property BOOL fullVersion;
@property BOOL soundOn;
@property (readonly) LevelPack *levelPack;

@end

