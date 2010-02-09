/*
 *  Macro.h
 *  iScanner
 *
 *  Created by Maksym Grebenets on 2/3/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#define locStr(x)	NSLocalizedString(x, x)

#define BEGIN_ANIMATION_DELAYED(id, duration, delay) \
	[UIView beginAnimations:id context:NULL];\
	[UIView setAnimationDuration:duration];\
	[UIView setAnimationDelay:delay];\
	[UIView setAnimationDelegate:self];\
	[UIView setAnimationDidStopSelector:@selector(scanViewAnimationDidStop:finished:context:)];

#define BEGIN_ANIMATION(id, duration)	BEGIN_ANIMATION_DELAYED(id, duration, 0.0f)

#define COMMIT_ANIMATION()	[UIView commitAnimations];