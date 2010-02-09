//
//  Level.m
//  iScanner
//
//  Created by Maksym Grebenets on 2/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Level.h"
#import "iScannerAppDelegate.h"


@implementation Level
@synthesize levelType;
@synthesize objectStr;

- (id)initWithDic:(NSDictionary *)data {
    if ((self = [super init])) {
        levelType = [[data objectForKey:kLevelTypeKey] integerValue];
        objectStr = [data objectForKey:kObjectStrKey];   // copy?
        answers = [[data objectForKey:kAnswersKey] copy];
    }
    return self;
}

+ (id)levelWithData:(NSDictionary *)data {
    return [[[Level alloc] initWithDic:data] autorelease];
}

- (NSString *)descString {
	NSString *str = [NSString stringWithFormat:@"levelType: %d\nobjectStr: %@\nanswers:\n", levelType, objectStr];
	for (NSString *answer in answers) {
		str = [str stringByAppendingFormat:@"%@\n", answer];
	}
	return str;
}

- (void)dealloc {
    [answers release];
    [super dealloc];
}

- (BOOL)correctAnswer:(NSString *)answer {
    // look for answer in answers array
    return ([objectStr localizedCaseInsensitiveCompare:answer] == NSOrderedSame 
			|| [answers containsObject:[answer lowercaseString]]);
}

@end
