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
#define kUpgradeLevelIdx    (21)
#define kUpgradeLevelKey    @"Upgrade"	// this is a dictionary key, do not localize it
#define kUpgradeLevelObjectStr  NSLocalizedString(@"Upgrade", @"Upgrade")
#define kUnlockedLevelsKey	NSLocalizedString(@"kUnlockedLevelsKey", @"kUnlockedLevelsKey")

@interface iScannerAppDelegate ()
- (void)submitScore;
@end


@implementation iScannerAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize fullVersion;
@synthesize soundOn;

- (void)setFullVersion:(BOOL)full {
	fullVersion = full;
}

- (void)setSoundOn:(BOOL)sound {
	if (soundOn != sound) {
		if (sound) {
			[audioPlayer play];
		} else {
			[audioPlayer stop];
		}
	}
	soundOn = sound;
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
    
//	float f = hypotf(512, 512);
//	NSLog(@"%f", f);

	
    // Override point for customization after app launch  
	
	srand(time(NULL));

	// debugging
#ifdef DEBUGFULL	
	NSLog(@"%@", [[NSBundle mainBundle] bundleIdentifier]);
	NSString *bundleDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	NSLog(@"\nDisplay name: %@, Name: %@", bundleDisplayName, bundleName);
#endif
	
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
	//NSString *userLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
	//NSLog(@"%@", userLanguage);
	
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
	fullVersion = TRUE;	// make the game free
	
	// disable sound by default
	soundOn = FALSE;
	
	// prepare audio player
	NSString *sonarSoundPath = [[NSBundle mainBundle] pathForResource:@"sonar" ofType:@"mp3"];
	
	audioPlayer = [[AVAudioPlayer alloc] 
				   initWithContentsOfURL:[NSURL URLWithString:sonarSoundPath]
				   error:nil];	
	
	audioPlayer.numberOfLoops = -1;
	[audioPlayer setVolume:1];
	
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
						 andDisplayName:@"-Radar-"
							andSettings:nil 
						   andDelegates:nil];
	
	// sync user defaults
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	
	// submit score to open feint
	[self submitScore];
	
	// Save data if appropriate	// Shutdown OpenFeint
	[OpenFeint shutdown];
	
	// save full version flag
	[[NSUserDefaults standardUserDefaults] setBool:fullVersion forKey:kFullVersionKey];
	
	// save unlocked levels dictionary to user defaults
	[[NSUserDefaults standardUserDefaults] setObject:unlockedLevelsDic forKey:kUnlockedLevelsKey];	
	
	[audioPlayer stop];
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
	[audioPlayer release];
	[window release];
	[super dealloc];
}

- (NSArray *)levelPackForKey:(NSString *)key {
	return [levelPacksDic objectForKey:key];
}

#define kLeaderboardKey	@"LeaderboardID"
#define kStarterAchKey	@"StarterAchID"
#define kBeginnerAchKey	@"BeginnerAchID"
#define	kEagleEyeAchKey	@"EagleEyeAchID"
#define kHawkEyedAchKey	@"HawkEyedAchID"
#define kPenetratingEyeAchKey	@"kPenetratingEyeAchID"
#define kStarterAchLevels	(5)
#define	kBeginnerAchLevels	(20)
#define kEagleEyeAchLevels	(50)
#define kHawkEyedAchLevels	(75)
#define kPenetratingEyeAchLevels	(100)

- (void)submitScore {
	// go through all levels and update score
	for (NSString *levelPackKey in [levelPacksDic keyEnumerator]) {
		// submit highscore for this level to leaderboard
		NSInteger unlockedIdx = [[unlockedLevelsDic objectForKey:levelPackKey] integerValue];
		// submit progress only when level at least level 2 is unlocked (so at least level 1 is solved)
		if (unlockedIdx < 2) continue;
		[OFHighScoreService setHighScore:(unlockedIdx - 1)
						  forLeaderboard:[openFeintDic objectForKey:kLeaderboardKey] 
							   onSuccess:OFDelegate() 
							   onFailure:OFDelegate()];
		
	}	
}

- (void)openFeintAction:(id)sender {
	// launch openfeint dashboard
	[OpenFeint launchDashboard];
	// send high score to OF for all level packs
	[self submitScore];	
}

- (BOOL)unlockAchievement:(NSString *)achKey 
			   achLevelIdx:(NSInteger)achLevelIdx
			   levelIdx:(NSInteger)levelIdx
{
	BOOL unlocked = FALSE;
	if (levelIdx > achLevelIdx) {
		unlocked = TRUE;
		[OFAchievementService unlockAchievement:[openFeintDic objectForKey:achKey]];
	}
	return unlocked;
}

- (void)unlockLevel:(NSInteger)levelIdx forLevelPackWithKey:(NSString *)key {
    if (levelIdx > [[unlockedLevelsDic objectForKey:key] integerValue]) {
        // new value is greater than old - update to dictionary
        [unlockedLevelsDic setObject:[NSNumber numberWithInteger:levelIdx] forKey:key];
		
			// achievements
			BOOL playSound = FALSE;
			playSound |= [self unlockAchievement:kStarterAchKey achLevelIdx:kStarterAchLevels levelIdx:levelIdx];		
			playSound |= [self unlockAchievement:kBeginnerAchKey achLevelIdx:kBeginnerAchLevels levelIdx:levelIdx];
			playSound |= [self unlockAchievement:kEagleEyeAchKey achLevelIdx:kEagleEyeAchLevels levelIdx:levelIdx];
			playSound |= [self unlockAchievement:kHawkEyedAchKey achLevelIdx:kHawkEyedAchLevels levelIdx:levelIdx];
			playSound |= [self unlockAchievement:kPenetratingEyeAchKey achLevelIdx:kPenetratingEyeAchLevels levelIdx:levelIdx];
			
			// TODO: other achievements
			
			if (playSound) {
				// TODO: play ach unlocked sound
			}
    }
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
	return ([level.objectStr caseInsensitiveCompare:kUpgradeLevelObjectStr] == NSOrderedSame);
}

@end

