//
//  Level.h
//  iScanner
//
//  Created by Maksym Grebenets on 2/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum _LevelType {
	LevelTypeChar,
	LevelTypeImage
};

@interface Level : NSObject {
	NSInteger levelType;
	NSString *objectStr;
	NSArray *answers;
	BOOL upgradeLevel;
}

- (BOOL)correctAnswer:(NSString *)answer;

@property (readonly) NSInteger levelType;
@property (readonly) NSString *objectStr;
@property (readonly) BOOL upgradeLevel;

@end
