//
//  LevelPack.h
//  iScanner
//
//  Created by Maksym Grebenets on 2/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

// OBSOLETE

#import <Foundation/Foundation.h>
#import "Level.h"

@interface LevelPack : NSObject {
	NSArray *levelKeys;
}


- (NSString *)levelKeyAtIndex:(NSInteger)levelIdx;

@end
