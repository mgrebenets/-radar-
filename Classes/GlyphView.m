//
//  GlyphView.m
//  iScanner
//
//  Created by Maksym Grebenets on 2/14/10.
//  Copyright 2010 i4nApps. All rights reserved.
//

#import "GlyphView.h"

#define	kAnimationDurationMin	(1.0f)
#define kAnimationDurationMax	(5.0f)
#define kShowAnimationID	@"kShowAnimationID"
#define kHideAnimationID	@"kHideAnimationID"
#define kMaxUnicodeCode		(0x052F)

@interface GlyphView ()
- (void)alphaAnimation;
@end


@implementation GlyphView


- (void)dealloc {
	[moveAnimationGroup release];
	moveAnimationGroup = nil;
    [super dealloc];
}

- (float)randomDuration {
	return (kAnimationDurationMin + (kAnimationDurationMax - kAnimationDurationMin) * ((float)rand() / (float)RAND_MAX));
}

- (void)glyphAnimationDidStop:(NSString *)animationID 
						finished:(NSNumber *)finished 
						 context:(void *)context 
{
	if (stopAnimations) return;
	
	if ([animationID isEqual:kHideAnimationID]) {
		// TODO: hidden, replace with random character and show
		self.text = [NSString stringWithFormat:@"%C", rand() % kMaxUnicodeCode];
		[self alphaAnimation];
	} else if ([animationID isEqual:kShowAnimationID]) {
		// begin hiding it
		[self alphaAnimation]; 
	}

}

- (void)alphaAnimation {
	float duration = [self randomDuration];
	NSString *animationID = (self.alpha ? kHideAnimationID : kShowAnimationID);
	float alpha = (self.alpha ? 0.0f : 1.0f);
	[UIView beginAnimations:animationID context:NULL];
	[UIView setAnimationDuration:duration];
	[UIView setAnimationDelay:1.0f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(glyphAnimationDidStop:finished:context:)];
	self.alpha = alpha;
	//	[self.layer setOpacity:opacity];
	[UIView commitAnimations];
}

- (void)moveAnimation {
	if (!moveAnimationGroup) {
		CGMutablePathRef movePath = CGPathCreateMutable();
		CGPathMoveToPoint(movePath, NULL, self.center.x, self.center.y);
		int heightSign = (self.center.y < 240 ? 1 : -1);
		CGFloat rectWidth = heightSign * (self.center.y - 240) * 2;
		CGRect rect = CGRectMake(160 - rectWidth / 2, 
								  240 - rectWidth / 2, 
								  rectWidth, 
								  rectWidth);
		CGPathAddEllipseInRect(movePath, NULL, rect);
		//CGPathAddCurveToPoint(movePath,NULL,320.0,500.0,
		//					  566.0,500.0,
		//					  566.0,74.0);		
	
	
		CAKeyframeAnimation *moveAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
		moveAnimation.path = movePath;
		CFRelease(movePath);
		
		moveAnimationGroup = [[CAAnimationGroup animation] retain];
		moveAnimationGroup.animations=[NSArray arrayWithObject:moveAnimation];
		
		// set the timing function for the group and the animation duration
		moveAnimationGroup.timingFunction=[CAMediaTimingFunction 
										   functionWithName:kCAMediaTimingFunctionEaseIn];
//		moveAnimationGroup.duration = [self randomDuration];		
		moveAnimationGroup.duration = 10.0f + [self randomDuration];		
		moveAnimationGroup.repeatCount = HUGE_VAL;

	}
	[[self layer] addAnimation:moveAnimationGroup forKey:@"move"];
}

- (void)startAnimating {
	stopAnimations = FALSE;
	// TODO: start movement animation
	// start hide/show animation
	[self alphaAnimation];
	[self moveAnimation];
}

- (void)stopAnimating {
#ifdef DEBUGFULL	
	NSLog(@"%s", _cmd);
#endif	
	stopAnimations = TRUE;
	[[self layer] removeAllAnimations];
}

@end
