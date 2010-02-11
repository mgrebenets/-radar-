//
//  iScannerAppDelegate.h
//  iScanner
//
//  Created by Maksym Grebenets on 2/2/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "Level.h"

#define kBasicLevelPackKey   @"kBasicLevelPackKey"
#define kLevelTypeKey	@"levelType"
#define kObjectStrKey	@"objectStr"
#define kAnswersKey		@"answers"

@interface iScannerAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	BOOL fullVersion;
	BOOL soundOn;
	NSDictionary *levelsDic;
	NSDictionary *levelPacksDic;
	NSMutableDictionary *unlockedLevelsDic;
	NSDictionary *openFeintDic;
}

- (void)openFeintAction:(id)sender;

- (NSArray *)levelPackForKey:(NSString *)key;
- (NSInteger)unlockedLevelIdxForLevelPackKey:(NSString *)key;
- (void)unlockLevel:(NSInteger)levelIdx forLevelPackWithKey:(NSString *)key;
- (Level *)levelFromPack:(NSString *)packKey atIndex:(NSInteger)index;
- (Level *)levelForKey:(NSString *)key;
- (BOOL)isUpgradeLevel:(Level *)level;
- (void)unlockUpgradeAchievement;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property BOOL fullVersion;
@property BOOL soundOn;

@end

