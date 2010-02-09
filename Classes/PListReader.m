//
//  PListReader.m
//  JokerWild
//
//  Created by Maksym Grebenets on 7/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PListReader.h"


@implementation PListReader

+ (NSData *)applicationDataFromFile:(NSString *)fileName {
	NSData *localData = [[[NSData alloc] initWithContentsOfFile:fileName] autorelease];
#if DEBUGFULL	
	NSLog(@"\napplicationDataFromFile [%s]", [fileName UTF8String]);
#endif	
	return localData;
}

+ (id)applicationPlistFromFile:(NSString *)fileName {
	NSData *retData;
	NSString *error;
	id retPlist;
	NSPropertyListFormat format;
	
	NSLog(@"\napplicationPlistFromFile");
	
	retData = [PListReader applicationDataFromFile:fileName];
	if (!retData) {	
		NSLog(@"\nData file not found");
		return nil;
	}
	
	retPlist = [NSPropertyListSerialization propertyListFromData:retData 
												mutabilityOption:NSPropertyListImmutable 
														  format:&format
												errorDescription:&error];
	if (!retPlist) {	
		NSLog(@"\nPlist not returned, error: %@", error);
	}
	
	return retPlist;
}

@end
