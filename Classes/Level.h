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
}

+ (id)levelWithData:(NSDictionary *)data;
- (BOOL)correctAnswer:(NSString *)answer;
- (NSString *)descString;

@property (readonly) NSInteger levelType;
@property (readonly) NSString *objectStr;

@end
