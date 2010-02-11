//
//  iScannerAppDelegate.m
//  iScanner
//
//  Created by Maksym Grebenets on 2/2/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "iScannerAppDelegate.h"
#import "OpenFeint.h"
#import "OFLeaderboardService.h"
#import "OFLeaderboard.h"
#import "OFHighScoreService.h"
#import "OFHighScore.h"
#import "OFAchievementService.h"
#import "RootViewController.h"
#import "PListReader.h"
#import "Macro.h"

#define kFullVersionKey	@"kFullVersionKey"
#define kUpgradeLevelIdx    (10)
#define kUpgradeLevelKey    locStr(@"Upgrade")
#define kUpgradeLevelObjectStr  kUpgradeLevelKey
#define kUnlockedLevelsKey	@"kUnlockedLevelsKey"


@implementation iScannerAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize fullVersion;
@synthesize soundOn;

- (void)setFullVersion:(BOOL)full {
	fullVersion = full;
	if (fullVersion) {
		[self unlockUpgradeAchievement];
	}
}

- (void)logLevelsDic:(NSDictionary *)theLevelsDic {
	for (NSString *key in [theLevelsDic keyEnumerator]) {
		NSLog(@"level key: %@", key);
		NSDictionary *levelDic = [levelsDic objectForKey:key];
		NSLog(@"levelType: %d", [[levelDic objectForKey:kLevelTypeKey] integerValue]);
		NSLog(@"objectStr: %@", [levelDic objectForKey:kObjectStrKey]);
		NSLog(@"answers:");
		NSArray *answers = [levelDic objectForKey:kAnswersKey];
		for (NSString *answer in answers) {
			NSLog(@"%@", answer);
		}
		
		// also check level creation
		NSLog(@"Check Level class");
		Level *level = [Level levelWithData:levelDic];
		NSLog(@"%@", [level descString]);
	}	
}

- (void)logLevelPack:(NSArray *)levelPack withName:(NSString *)name {
	NSLog(@"Level Pack: %@", name);
	for (NSString *key in levelPack) {
		NSLog(@"Level Key: %@", key);
	}
}

- (void)logUnlockedLevels:(NSMutableDictionary *)dic {
	for (NSString *key in [dic keyEnumerator]) {
		NSLog(@"key: %@, value: %d", key, [[dic objectForKey:key] integerValue]);
	}
}

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch  
	NSLog(@"%@", [[NSBundle mainBundle] bundleIdentifier]);
	
	// init level objects (load from plist file)
	levelsDic = [[PListReader applicationPlistFromFile:[[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"]] retain];

	// debug
	//[self logLevelsDic:levelsDic];
	
	// load all level packs from .plist files
	NSArray *basicLevelPack = [PListReader applicationPlistFromFile:[[NSBundle mainBundle] pathForResource:@"BasicLevelPack" ofType:@"plist"]];	

	// debug
	//[self logLevelPack:basicLevelPack withName:kBasicLevelPackKey];
	
	// compose levels pack dictionary
	levelPacksDic = [[NSDictionary alloc] initWithObjectsAndKeys:basicLevelPack, kBasicLevelPackKey, nil];
	
	// read unlocked levels dictionary from user defaults
	unlockedLevelsDic = [[NSUserDefaults standardUserDefaults] objectForKey:kUnlockedLevelsKey];
	if (!unlockedLevelsDic) {
		// first time, nothing in user default yet
		unlockedLevelsDic = [[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:0], kBasicLevelPackKey, nil] retain];							 
		NSDictionary *defsDic = [NSDictionary dictionaryWithObject:unlockedLevelsDic forKey:kUnlockedLevelsKey];
		[[NSUserDefaults standardUserDefaults] registerDefaults:defsDic];
	}
	
	// debug
	//[self logUnlockedLevels:unlockedLevelsDic];
	
	// full version flag
	fullVersion = [[NSUserDefaults standardUserDefaults] boolForKey:kFullVersionKey];
	
	// TODO: new level packs added, look for missing levels in unlocked levels dic and add them
	
	// load open feint leaderboards and achievements ids
	openFeintDic = [[PListReader applicationPlistFromFile:[[NSBundle mainBundle] 
														   pathForResource:@"OpenFeint" 
														   ofType:@"plist"]] retain];
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	
	// init open feint (AFTER MAIN WINDOW IS DISPLAYED)
	[OpenFeint initializeWithProductKey:@"xc5YoWpsN9mbsqU8IvandA"
							  andSecret:@"TxUIpSgWZEMKOYIlz5y2oDQ8BrZ2kS1XPSCMChFIRA"
						 andDisplayName:@"iЯadaЯ"
							andSettings:nil 
						   andDelegates:nil];
	
	// sync user defaults
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate	// Shutdown OpenFeint
	[OpenFeint shutdown];
	
	// save full version flag
	[[NSUserDefaults standardUserDefaults] setBool:fullVersion forKey:kFullVersionKey];
	
	
	// save unlocked levels dictionary to user defaults
	[[NSUserDefaults standardUserDefaults] setObject:unlockedLevelsDic forKey:kUnlockedLevelsKey];	
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[OpenFeint applicationWillResignActive];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[OpenFeint applicationDidBecomeActive];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[levelsDic release];
	[levelPacksDic release];
	[unlockedLevelsDic release];
	[openFeintDic release];
	[navigationController release];
	[window release];
	[super dealloc];
}

- (void)openFeintAction:(id)sender {
	// launch openfeint dashboard
	[OpenFeint launchDashboard];
}

- (NSArray *)levelPackForKey:(NSString *)key {
	return [levelPacksDic objectForKey:key];
}

#define kLeaderboardKey	@"LeaderboardID"
#define kBeginnerAchKey	@"BeginnerAchID"
#define kUpgradeAchKey	@"UpgradeAchID"
#define	kBeginnerAchLevels	(10)

- (void)unlockLevel:(NSInteger)levelIdx forLevelPackWithKey:(NSString *)key {
    if (levelIdx > [[unlockedLevelsDic objectForKey:key] integerValue]) {
        // new value is greater than old - update to dictionary
        [unlockedLevelsDic setObject:[NSNumber numberWithInteger:levelIdx] forKey:key];
		
		// submit highscore to leaderboard
		[OFHighScoreService setHighScore:levelIdx
						  forLeaderboard:[openFeintDic objectForKey:kLeaderboardKey] 
							   onSuccess:OFDelegate() 
							   onFailure:OFDelegate()];
		
		// achievements
		if (levelIdx > kBeginnerAchLevels) {
			[OFAchievementService unlockAchievement:[openFeintDic objectForKey:kBeginnerAchKey]];
		}
		// TODO: other achievements
    }
}

- (void)unlockUpgradeAchievement {
	[OFAchievementService unlockAchievement:[openFeintDic objectForKey:kUpgradeAchKey]];
}

- (NSInteger)unlockedLevelIdxForLevelPackKey:(NSString *)key {
    return [[unlockedLevelsDic objectForKey:key] integerValue];
}

- (Level *)levelFromPack:(NSString *)packKey atIndex:(NSInteger)levelIdx {
    // if this is not full version and base level pack is played, then only limited number of levels are free
    if (!fullVersion 
        && [packKey isEqual:kBasicLevelPackKey] 
        && levelIdx == kUpgradeLevelIdx)
    {
        return [self levelForKey:kUpgradeLevelKey];
    }
	
    return [self levelForKey:[[levelPacksDic objectForKey:packKey] objectAtIndex:levelIdx]];
}

- (Level *)levelForKey:(NSString *)key {
    return [Level levelWithData:[levelsDic objectForKey:key]];
}

- (BOOL)isUpgradeLevel:(Level *)level {
	return [level.objectStr isEqual:kUpgradeLevelObjectStr];
}

@end

