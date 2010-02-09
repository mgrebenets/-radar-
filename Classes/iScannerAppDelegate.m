//
//  iScannerAppDelegate.m
//  iScanner
//
//  Created by Maksym Grebenets on 2/2/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "iScannerAppDelegate.h"
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
	
	// init level objects (load from plist file)
	levelsDic = [[PListReader applicationPlistFromFile:[[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"]] retain];

	// debug
	[self logLevelsDic:levelsDic];
	
	// load all level packs from .plist files
	NSArray *basicLevelPack = [PListReader applicationPlistFromFile:[[NSBundle mainBundle] pathForResource:@"BasicLevelPack" ofType:@"plist"]];	

	// debug
	[self logLevelPack:basicLevelPack withName:kBasicLevelPackKey];
	
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
	[self logUnlockedLevels:unlockedLevelsDic];
	
	// full version flag
	fullVersion = [[NSUserDefaults standardUserDefaults] boolForKey:kFullVersionKey];
	
	// TODO: new level packs added, look for missing levels in unlocked levels dic and add them
	
	// TODO: init openfeint
	
	// TODO (? ... no): more advanced (paid), get user's progress from openfeint network store card
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	
	// sync user defaults
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
	
	// save full version flag
	[[NSUserDefaults standardUserDefaults] setBool:fullVersion forKey:kFullVersionKey];
	
	// TODO: shutdown open feint
	
	// save unlocked levels dictionary to user defaults
	[[NSUserDefaults standardUserDefaults] setObject:unlockedLevelsDic forKey:kUnlockedLevelsKey];	
}

// TODO: reload memory waringin and will resign handlers (with open feint support)


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[levelsDic release];
	[levelPacksDic release];
	[unlockedLevelsDic release];
	[navigationController release];
	[window release];
	[super dealloc];
}

- (void)openFeintAction:(id)sender {
	// TODO: launch openfeint dashboard
}

- (NSArray *)levelPackForKey:(NSString *)key {
	return [levelPacksDic objectForKey:key];
}

- (void)unlockLevel:(NSInteger)levelIdx forLevelPackWithKey:(NSString *)key {
    if (levelIdx > [[unlockedLevelsDic objectForKey:key] integerValue]) {
        // new value is greater than old - update to dictionary
        [unlockedLevelsDic setObject:[NSNumber numberWithInteger:levelIdx] forKey:key];
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
        return [levelsDic objectForKey:kUpgradeLevelKey];
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

