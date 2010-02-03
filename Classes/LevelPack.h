//
//  LevelPack.h
//  iScanner
//
//  Created by Maksym Grebenets on 2/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Level.h"

@interface LevelPack : NSObject {
	NSInteger unlockedLevelIdx;
	NSInteger lastLevelIdx;
}

- (Level *)levelAtIndex:(NSInteger)levelIdx;

@property (readonly) NSInteger unlockedLevelIdx;
@property (readonly) NSInteger lastLevelIdx;

@end
